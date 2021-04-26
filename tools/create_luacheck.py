import os
import re
from pathlib import Path

path =  "../mods/"
pattern = re.compile(r'[a-z]')

pathlist = Path(path).rglob('*.lua')
for path in pathlist:
    path_in_str = str(path)
    print(path_in_str)
    with open(path_in_str) as f:
        for line in f:
            if pattern.search(line):
                print(line)

for subdir, dirs, files in os.walk(path):
    for file in files:
        print(os.path.join(subdir, file))
        filepath = subdir + os.sep + file
        if filepath.endswith(".lua"):
            print(filepath)