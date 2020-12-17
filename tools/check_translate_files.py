# Output indicator
# !<   Indicates a text line without '=' in template.txt
# <<   Indicates an untranslated line in template.txt
# !>   Indicates a text line without '=' in translate file (.tr)
# >>   Indicates an unknown translated line in translate file (.tr)
# >>   Missing file: Indicates a missing translate file (.tr)

import os
import argparse

parser = argparse.ArgumentParser(description='Check translation file with template.txt for a given language.')
parser.add_argument("language", help='language code')
args = parser.parse_args()

path =  "../mods/"
code_lang = args.language

def LoadTranslateFile(filename, direction):
    result = set()
    file = open(filename, 'r', encoding="utf-8")
    for line in file:
        line = line.strip()
        if line.startswith('#') or line == '':
            continue
        if '=' in line:
            result.add(line.split('=')[0])
        else:
            print (direction + line)

    return result

def CompareFiles(f1, f2):
    r1 = LoadTranslateFile(f1, "!> ")
    r2 = LoadTranslateFile(f2, "!< ")

    for key in r1.difference(r2):
        print (">> " + key )
    for key in r2.difference(r1):
        print ("<< " + key )

for root, directories, files in os.walk(path):
    if root.endswith('locale'):
        template = None
        language = None

        for name in files:
            if name == 'template.txt':
                template = os.path.join(root, name)
            if name.endswith("." + code_lang + ".tr"):
                language = os.path.join(root, name)

        if template is not None:
            if language is None:
                language = os.path.join(root, os.path.basename(os.path.dirname(root))) + "." + code_lang + ".tr"
            
            if os.path.exists(language) and os.path.isfile(language):
                print("Compare files %s with %s" % (template, language))
                CompareFiles(template, language)
            else:
                LoadTranslateFile(filename, "!> ")
                print(">> Missing file = " + language)
