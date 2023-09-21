#!/usr/bin/env python3
import argparse
import json
import os
import platform
import re
import shutil
import subprocess
import tempfile
from pathlib import Path
from urllib.request import urlopen

parser = argparse.ArgumentParser(description="download tools")

parser.add_argument("-f", action="store_true")

args = parser.parse_args()

TOOLS = {
    "rg": "BurntSushi/ripgrep",
    "fzf": "junegunn/fzf",
    "fd": "sharkdp/fd",
    "jq": "jqlang/jq",
    "zoxide": "ajeetdsouza/zoxide",
    "btop": {
        "repo": "aristocratos/btop",
        "files": {"themes": "~/.config/btop/themes"},
    },
}

GREEN = "\x1b[32m"  # ]
BLUE = "\x1b[34m"  # ]
RED = "\x1b[31m"  # ]
RESET = "\x1b[0m"  # ]


def run_script(script, *script_args):
    process = subprocess.Popen(
        ["bash", "-c", script, "--", *script_args],
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
    )
    stdout, stderr = process.communicate()
    return process.returncode, stdout, stderr


EXTRACT_SCRIPT = """
cd $(dirname $1) || exit 2
case "$1" in
  *.tar.bz2 | *.tbz2 | *.tbz) tar xvjf "$1" || exit 2;;
  *.tar.xz) tar xvJf "$1" || exit 2 ;;
  *.tar.gz | *.tgz) tar xvzf "$1" || exit 2 ;;
  *.tar) tar xvf "$1" || exit 2 ;;
  *.zip) unzip "$1" || exit 2 ;;
  *) exit 1 ;;
esac
exit 0
"""


def extract(file):
    result, _, stderr = run_script(EXTRACT_SCRIPT, file)
    if result == 2:
        raise ValueError(f"extraction failed: {stderr}")
    return result == 0


system = [platform.system().lower()]
machine = platform.machine().lower()
if machine == "x86_64":
    architecture = ["x86_64", "amd64", "linux64"]
    specific_architecture = []
else:
    architecture = ["arm"]
    specific_architecture = re.findall("armv[0-9]", machine)
archive = ["tar"]
compiler = ["gnu", "musl"]

aspects = [system, specific_architecture, architecture, compiler, archive]


def score_asset(asset):
    name = asset["name"].lower()
    discount = 0.8
    score = sum(
        any(word in name for word in aspect) * discount**i
        for i, aspect in enumerate(aspects)
    )
    return score


def get_archive_url(repo):
    url = f"https://api.github.com/repos/{repo}/releases"
    with urlopen(url) as file:
        j = json.loads(file.read().decode("utf-8"))

    release = next(x for x in j if not x["prerelease"])
    assets = release["assets"]
    for asset in assets:
        asset["score"] = score_asset(asset)
    assets = sorted(assets, key=lambda x: x["score"], reverse=True)
    return assets[0]["browser_download_url"]


BIN_FOLDER = Path("~/bin").expanduser()
BIN_FOLDER.mkdir(exist_ok=True)


def tool_is_setup(name, tool_args):
    tool_dest = BIN_FOLDER / name
    return all(
        Path(path).expanduser().exists()
        for path in [tool_dest, *tool_args.get("files", {}).values()]
    )


def move(src, dest):
    if dest.is_file():
        if not dest.is_file():
            raise ValueError("dest is file but src is not")
        dest.unlink()
    elif dest.is_dir():
        if not src.is_dir():
            raise ValueError("dest is dir but src is not")
        shutil.rmtree(dest)
    shutil.move(src, dest)


def extract_tool_from_archive(name, archive_path: Path, tool_args):
    extra_files = tool_args.get("files", {})
    parent_path = archive_path.parent
    tool_dest = BIN_FOLDER / name
    if extract(archive_path):
        Path(archive_path).unlink()
    files = list(parent_path.glob("*"))
    if len(files) == 1:
        (result_dir,) = files
    else:
        result_dir = parent_path
    if result_dir.is_file():
        move(result_dir, tool_dest)
    elif result_dir.is_dir():
        for candidate_path in ["", "bin"]:
            check_path = result_dir / candidate_path / name
            if check_path.exists() and check_path.is_file():
                move(check_path, tool_dest)
                break
        else:
            raise ValueError("tool not found")
        for src_path, dest_path in extra_files.items():
            dest_path = Path(dest_path).expanduser()
            dest_path.parent.mkdir(parents=True, exist_ok=True)
            move(result_dir / src_path, dest_path)
    else:
        raise ValueError("no directory")
    tool_dest.chmod(755)


def download_tool(name, tool_args):
    url = get_archive_url(tool_args["repo"])
    archive_name = os.path.basename(url)
    print(f"[downloading {archive_name}] ", end="", flush=True)
    with urlopen(url) as file:
        content = file.read()
    temp_dir = Path(tempfile.mkdtemp())
    archive_path = temp_dir / archive_name
    archive_path.write_bytes(content)
    try:
        extract_tool_from_archive(name, archive_path, tool_args)
    finally:
        shutil.rmtree(temp_dir)


for name, tool_args in TOOLS.items():
    if isinstance(tool_args, str):
        tool_args = {"repo": tool_args}
    print(f"installing {name} ", end="", flush=True)

    if tool_is_setup(name, tool_args) and not args.f:
        print(f"{BLUE}exists{RESET}", flush=True)
    else:
        try:
            download_tool(name, tool_args)
            print(f"{GREEN}success{RESET}", flush=True)
        except Exception as exc:
            print(f"{RED}failure: {str(exc)}{RESET}", flush=True)
