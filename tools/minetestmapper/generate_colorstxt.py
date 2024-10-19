#!/usr/bin/env python3
import sys
import os.path
import getopt
import re
from math import sqrt
try:
	from PIL import Image
except:
	print("Could not load image routines, install PIL ('pillow' on pypi)!", file=sys.stderr)
	exit(1)

############
############
# Instructions for generating a colors.txt file for custom games and/or mods:
# 1) Add the dumpnodes mod to a Minetest world with the chosen game and mods enabled.
# 2) Join ingame and run the /dumpnodes chat command.
# 3) Run this script and poin it to the installation path of the game using -g,
#    the path(s) where mods are stored using -m and the nodes.txt in your world folder.
#    Example command line:
#      ./util/generate_colorstxt.py --game /usr/share/minetest/games/minetest_game \
#        -m ~/.minetest/mods ~/.minetest/worlds/my_world/nodes.txt
# 4) Copy the resulting colors.txt file to your world folder or to any other places
#    and use it with minetestmapper's --colors option.
###########
###########

# minimal sed syntax, s|match|replace| and /match/d supported
REPLACEMENTS = [
	# Delete some nodes that are usually hidden
	r'/^fireflies:firefly /d',
	r'/^butterflies:butterfly_/d',
	# Nicer colors for water and lava
	r's/^(default:(river_)?water_(flowing|source)) [0-9 ]+$/\1 39 66 106 128 224/',
	r's/^(default:lava_(flowing|source)) [0-9 ]+$/\1 255 100 0/',
	r's/^(mclx?_core:(river_)?water_(flowing|source)) [0-9 ]+$/\1 35 66 128 224 128/',
	r's/^(mcl_core:lava_(flowing|source)) [0-9 ]+$/\1 230 90 0/',
	# Transparency for glass nodes and panes
	r's/^(default:.*glass) (\d+ \d+ \d+)( \d+)*$/\1 \2 64 16/',
	r's/^(doors:.*glass[^ ]*) (\d+ \d+ \d+)( \d+)*$/\1 \2 64 16/',
	r's/^(mcl_core:.*glass[^ ]*) (\d+ \d+ \d+)( \d+)*$/\1 \2 64 16/',
	r's/^(xpanes:.*(pane|bar)[^ ]*) (\d+ \d+ \d+)( \d+)*$/\1 \3 64 16/',
	r's/^(mcl_core:.*leaves(?:_orphan)?) (\d+ \d+ \d+)( \d+)*$/\1 \2/', # no alpha
	r's/^(mcl_core:.*ice(?:_\d+)?) (\d+ \d+ \d+)( \d+)*$/\1 \2/', # no alpha
	r's/^(mcl_core:snow) (\d+ \d+ \d+)( \d+)*$/\1 \2 223 31/', # almost no alpha
]

def usage():
	print("Usage: generate_colorstxt.py [options] [input file] [output file]")
	print("If not specified the input file defaults to ./nodes.txt and the output file to ./colors.txt")
	print("  -g / --game <folder>\t\tSet path to the game (for textures), required")
	print("  -m / --mods <folder>\t\tAdd search path for mod textures")
	print("  --replace <file>\t\tLoad replacements from file (ADVANCED)")

def collect_files(path):
	for dirpath, dirnames, filenames in os.walk(path):
		for f in filenames:
			if not f in textures:
				textures[f] = os.path.join(dirpath, f)

def average_color(filename, color2):
	inp = Image.open(filename).convert('RGBA')
	data = inp.load()

	c, w = [0, 0, 0], 0
	for y in range(inp.size[0]):
		for x in range(inp.size[1]):
			px = data[y, x]
			a = px[3] / 255
			if a == 0: continue
			c[0] = c[0] + px[0] * a
			c[1] = c[1] + px[1] * a
			c[2] = c[2] + px[2] * a
			w = w + a

	if w == 0:
		print(f"didn't find color for '{os.path.basename(filename)}'", file=sys.stderr)
		return "0 0 0"
	c0, c1, c2 = c[0] / w, c[1] / w, c[2] / w
	if color2: # param2 blending
		c0, c1, c2 = c0 * color2[0] / 255., c1 * color2[1] / 255., c2 * color2[2] / 255.
	# for alpha, find maximum alpha in chunks to account for complex textures
	a = 0
	for y2 in range(0,inp.size[0],8):
		for x2 in range(0,inp.size[1],8):
			a2, n = 0, 0
			for y in range(y2, min(y2+16,inp.size[0])):
				for x in range(x2, min(x2+16,inp.size[1])):
					a2 = a2 + data[y,x][3]
					n = n + 1
			a2 = a2 / n
			a = max(a, a2)

	if a > 0 and a < 190:
		return "%d %d %d %d" % (c0, c1, c2, a)
	return "%d %d %d" % (c0, c1, c2)

def get_param2_color(filename, param2):
	if not filename: return None
	inp = Image.open(filename).convert('RGBA')
	data = inp.load()
	x, y = param2 % inp.size[0], param2 // inp.size[0]
	col = data[y, x]
	return col[0], col[1], col[2] # copy

def apply_sed(line, exprs):
	for expr in exprs:
		if expr[0] == '/':
			if not expr.endswith("/d"): raise ValueError()
			if re.search(expr[1:-2], line):
				return ''
		elif expr[0] == 's':
			expr = expr.split(expr[1])
			if len(expr) != 4 or expr[3] != '': raise ValueError()
			line = re.sub(expr[1], expr[2], line)
		else:
			raise ValueError()
	return line
#

try:
	opts, args = getopt.getopt(sys.argv[1:], "hg:m:", ["help", "game=", "mods=", "replace="])
except getopt.GetoptError as e:
	print(str(e))
	exit(1)
if ('-h', '') in opts or ('--help', '') in opts:
	usage()
	exit(0)

input_file = "./nodes.txt"
output_file = "./colors.txt"
texturepaths = []

try:
	gamepath = next(o[1] for o in opts if o[0] in ('-g', '--game'))
	if not os.path.isdir(os.path.join(gamepath, "mods")):
		print(f"'{gamepath}' doesn't exist or does not contain a game.", file=sys.stderr)
		exit(1)
	texturepaths.append(gamepath)
except StopIteration:
	print("No game path set but one is required. (see --help)", file=sys.stderr)
	exit(1)

try:
	tmp = next(o[1] for o in opts if o[0] == "--replace")
	REPLACEMENTS.clear()
	with open(tmp, 'r') as f:
		for line in f:
			if not line or line[0] == '#': continue
			REPLACEMENTS.append(line.strip())
except StopIteration:
	pass

for o in opts:
	if o[0] not in ('-m', '--mods'): continue
	if not os.path.isdir(o[1]):
		print(f"Given path '{o[1]}' does not exist.'", file=sys.stderr)
		exit(1)
	texturepaths.append(o[1])

if len(args) > 2:
	print("Too many arguments.", file=sys.stderr)
	exit(1)
if len(args) > 1:
	output_file = args[1]
if len(args) > 0:
	input_file = args[0]

if not os.path.exists(input_file) or os.path.isdir(input_file):
	print(f"Input file '{input_file}' does not exist.", file=sys.stderr)
	exit(1)

#

print(f"Collecting textures from {len(texturepaths)} path(s)... ", end="", flush=True)
textures = {}
for path in texturepaths:
	collect_files(path)
print("done", len(textures), "files")

print("Processing nodes...")
fin = open(input_file, 'r')
fout = open(output_file, 'w')
n = 0
for line in fin:
	line = line.rstrip('\r\n')
	if not line or line[0] == '#':
		fout.write(line + '\n')
		continue
	line = line.split(" ")
	node, tex = line[0], line[1]
	if not tex or tex == "blank.png":
		continue
	if tex not in textures:
		print(f"skip {node} texture {tex} not found")
		continue
	# TODO: full param2 support
	color2 = None
	if len(line) > 3 and line[2].startswith("color"):
		color2 = get_param2_color(textures.get(line[3]), 0)
	color = average_color(textures[tex], color2)
	line = f"{node} {color}"
	#print(f"ok {node}")
	line = apply_sed(line, REPLACEMENTS)
	if line:
		fout.write(line + '\n')
		n += 1
fin.close()
fout.close()
print(f"Done, {n} entries written.")
