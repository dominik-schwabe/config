#!/usr/bin/env python3
import sys
import json
import platform
from urllib.request import urlopen

system = ["linux"]
if platform.machine() == "x86_64":
    architecture = ["x86_64", "amd64", "linux64"]
else:
    architecture = ["arm"]
archive = ["tar"]
compiler = ["gnu", "musl"]

aspects = [system, architecture, compiler, archive]

def score_asset(asset):
    name = asset["name"]
    discount = 1
    score = 1/len(name)
    for aspect in aspects:
        for word in aspect:
            if word in name:
                score += 1 * discount
                break
        discount *= 0.8
    return score

url = f"https://api.github.com/repos/{sys.argv[1]}/releases"
with urlopen(url) as file:
    j = json.loads(file.read().decode("utf-8"))
    
release = next(x for x in j if not x["prerelease"])
assets = release["assets"]
for asset in assets:
    asset["score"] = score_asset(asset)
print(sorted(assets, key=lambda x: x["score"], reverse=True)[0]["browser_download_url"])
