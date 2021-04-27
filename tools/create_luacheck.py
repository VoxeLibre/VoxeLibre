import os
import re
from pathlib import Path

path =  "./mods/"
# pattern = re.compile(r'^(?P<nomtableau>[^ \t\]]+)[ ]*=[ ]*\{')
pattern = re.compile(r'^(?P<nomtableau>[^ \t\]]+)[ ]*=[ ]*\{')


pathlist = Path(path).rglob('*.lua')
for path in pathlist:
    path_in_str = str(path)
    # print(path_in_str)
    trouve = False
    with open(path_in_str) as f:
        for i, line in enumerate(f.readlines()):
            m = pattern.match(line)
            if m:
                print(path_in_str, ":", i+1, ":", m.group('nomtableau').strip())
                trouve = True
                break
        if not trouve:
            print(path_in_str, ": -")

for subdir, dirs, files in os.walk(path):
    for file in files:
        print(os.path.join(subdir, file))
        filepath = subdir + os.sep + file
        if filepath.endswith(".lua"):
            print(filepath)