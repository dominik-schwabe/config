#!/usr/bin/env python3
import json
import platform
import sys
from urllib.request import urlopen
import re

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


url = f"https://api.github.com/repos/{sys.argv[1]}/releases"
with urlopen(url) as file:
    j = json.loads(file.read().decode("utf-8"))

release = next(x for x in j if not x["prerelease"])
assets = release["assets"]
for asset in assets:
    asset["score"] = score_asset(asset)
print(sorted(assets, key=lambda x: x["score"], reverse=True)[0]["browser_download_url"])
