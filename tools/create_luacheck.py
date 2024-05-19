import os
import re
from pathlib import Path

# Just run this script from voxelibre directory to get a list of every global vars to use in luacheck configuration files

path =  "./mods/"

pattern = re.compile(r'^(?P<global_var>[A-Za-z_0-9]+)[ ]*=[ ]*\{')
pattern_local = re.compile(r'local (?P<local_var>[A-Za-z_0-9]+)')

global_vars = []


print("---Copy/Paste output in your luacheck conf file---\n")


pathlist = Path(path).rglob('*.lua')
for path in pathlist:
    path_in_str = str(path)
    # print(path_in_str)
    found = False
    with open(path_in_str) as f:
        local_vars = []
        for i, line in enumerate(f.readlines()):
            m = pattern.match(line)
            if m:
                global_name = m.group('global_var')
                if global_name not in local_vars:
                    #print(path_in_str, ":", i+1, ":", m.group('global_var').strip())
                    global_vars.append(m.group('global_var').strip())
                    found = True
                    break

            else:
                n = pattern_local.match(line)
                if n:
                    local_vars.append(n.group('local_var'))

        if not found:
            nb_varloc = len(local_vars)
            #print(path_in_str, ": -", "({} variables locales)".format(nb_varloc) if nb_varloc > 0 else '')

print(', '.join(['"{}"'.format(v) for v in global_vars]))
