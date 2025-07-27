# Output indicator
# >>   Spell checking error
# !>   Indicates a text line with too many '=' in translate file (.tr)

import os
import argparse
import hunspell
import re

parser = argparse.ArgumentParser(description='Check translation file using pyhunspell for a given language.')
parser.add_argument("language", help='language code')
parser.add_argument("dic_file", help='path to .dic file')
parser.add_argument("aff_file", help='path to .aff file')
parser.add_argument('-a', "--add", help='path to file with additional words', default=None)
parser.add_argument('-s', "--suggestions", action="store_true", help='display spelling suggestions for incorrectly spelled words')
args = parser.parse_args()

PATH =  "../mods/"
code_lang = args.language
hs = hunspell.HunSpell(args.dic_file, args.aff_file)
if args.add is not None:
    with open(args.add, 'r') as file:
        for word in file:
            hs.add(word.strip())

def get_errors(file):
    result = set()
    for line in file:
        line = line.strip()
        if line.startswith('#') or line == '':
            continue
        if '=' in line:
            try:
                _, translated = re.split(r'[^@]=', line)
            except:
                print("!> Too many '='s in line:", line)
                continue
            for word in re.split(r'\@.|[\W ]',translated): 
                if not hs.spell(word):
                    result.add(word)

    return result

def spell_check(filename):
    with open(filename, 'r', encoding="utf-8") as file:
        errors = get_errors(file)
    if len(errors) > 0: 
        print("Spell checking errors in '", filename[len(PATH):], "':", sep='')
        for word in errors:
            print('>>', word)
            if args.suggestions:
                print(">> Did you mean:", ", ".join(hs.suggest(word)), "?")


for root, _, _ in os.walk(PATH):
    if root.endswith('locale'):
        translated_file = os.path.join(root, os.path.basename(os.path.dirname(root))) + "." + code_lang + ".tr"
        
        if os.path.exists(translated_file) and os.path.isfile(translated_file):
            spell_check(translated_file)
