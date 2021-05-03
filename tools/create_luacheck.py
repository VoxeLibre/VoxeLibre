import os
import re
from pathlib import Path

path =  "./mods/"
# pattern = re.compile(r'^(?P<nomtableau>[^ \t\]]+)[ ]*=[ ]*\{')
pattern = re.compile(r'^(?P<nomtableau>[A-Za-z_0-9]+)[ ]*=[ ]*\{')
pattern_local = re.compile(r'local (?P<nomvar>[A-Za-z_0-9]+)')

global_vars = []

pathlist = Path(path).rglob('*.lua')
for path in pathlist:
    path_in_str = str(path)
    # print(path_in_str)
    trouve = False
    with open(path_in_str) as f:
        variables_locales = []
        for i, line in enumerate(f.readlines()):
            m = pattern.match(line)
            if m:
                nomtableau = m.group('nomtableau')
                if nomtableau not in variables_locales:
                    print(path_in_str, ":", i+1, ":", m.group('nomtableau').strip())
                    global_vars.append(m.group('nomtableau').strip())
                    trouve = True
                    break

            else:
                n = pattern_local.match(line)
                if n:
                    variables_locales.append(n.group('nomvar'))

        if not trouve:
            nb_varloc = len(variables_locales)
            #print(path_in_str, ": -", "({} variables locales)".format(nb_varloc) if nb_varloc > 0 else '')

""" for subdir, dirs, files in os.walk(path):
    for file in files:
        print(os.path.join(subdir, file))
        filepath = subdir + os.sep + file
        if filepath.endswith(".lua"):
            print(filepath) """

print(', '.join(['"{}"'.format(v) for v in global_vars]))
