#!/usr/bin/env python

import os
import re
import subprocess
from time import sleep

progress_re = re.compile(r"\[([0-9]+)/([0-9]+)\]")

process = subprocess.Popen(["nvim", "--headless"], stderr=subprocess.PIPE)
stderr = process.stderr
os.set_blocking(stderr.fileno(), False)

output = ""
nodata_count = 0
while True:
    sleep(5)
    new_data = stderr.read()
    if not new_data:
        nodata_count += 1
        print(f"nodata count: {nodata_count}")
    else:
        new_data = new_data.decode("utf-8").lower()
        print(new_data, end="")
        output += new_data
        nodata_count = 0
    if nodata_count >= 6:
        break
    if "treesitter parser" in output:
        results = progress_re.findall(output)
        if results:
            a, b = map(int, results[-1])
            print(a, b)
            if a == b:
                break

sleep(5)
print("terminating")
process.kill()
