#!/usr/bin/env python3
import sys, os.path, getopt, re, json
from pyparsing import CharsNotIn, Suppress, infix_notation, opAssoc, ZeroOrMore
from PIL import Image, ImageColor, ImageChops, ImageEnhance, ImageMath # aka "pillow"

############
############
# Instructions for generating a colors.txt file for custom games and/or mods:
# 1) Add the dumpnodes mod to a Minetest world with the chosen game and mods enabled.
# 2) Join ingame and run the /dumpnodes chat command.
# 3) Run this script and poin it to the installation path of the game using -g,
#    the path(s) where mods are stored using -m and the nodes.txt in your world folder.
#    Example command line:
#      python3 generate_colorstxt.py \
#        --game /usr/share/minetest/games/minetest_game \
#        --mods ~/.minetest/mods \
#        --mods /usr/share/minetest/textures \
#        ~/.minetest/worlds/my_world/nodes.txt
# 4) Copy the resulting colors.txt file to your world folder or to any other places
#    and use it with minetestmapper's --colors option.
# 5) Copy the resulting colors.json file to the mcl_maps mod
###########
###########

# adjust water transparency, primarily for minetestmapper
def adjust_water_transparency(cs):
	if isinstance(cs[0], int):
		return (cs[0],cs[1],cs[2], 224, 128)
	return [(x[0],x[1],x[2], 224, 128) for x in cs]
def strip_alpha(cs):
	if isinstance(cs[0], int):
		return (cs[0],cs[1],cs[2])
	return [(x[0],x[1],x[2]) for x in cs]
# called with nodename, colors
REPLACEMENTS = [(re.compile(pat),rule) for pat,rule in [
	(r'^fireflies:firefly$',None),
	(r'^butterflies:butterfly_',None),
	# Nicer colors for water and lava
	(r'^(default|mclx?_core):river_water_(flowing|source)$', (36, 67, 130, 224, 128)),
	(r'^(default|mclx?_core):water_(flowing|source)$', adjust_water_transparency), # was (36, 67, 130, 224, 128)),
	(r'^(default|mcl_core):lava_(flowing|source)$', (230, 90, 0)),
	# Transparency for glass nodes and panes
	(r'^default:.*glass$', lambda c: (c[0], c[1], c[2], 64, 16)),
	(r'^doors:.*glass[^ ]*$', lambda c: (c[0], c[1], c[2], 64, 16)),
	(r'^mcl_core:.*glass[^ ]*$', lambda c: (c[0], c[1], c[2], 64, 16)),
	(r'^xpanes:.*(pane|bar)', lambda c: (c[0], c[1], c[2], 64, 16)),
	(r'^mcl_core:.*leaves(_orphan)?$', strip_alpha), # no alpha
	(r'^mcl_core:.*ice(?:_\d+)?$', lambda c: (c[0], c[1], c[2])), # no alpha
	(r'^mcl_core:snow$', lambda c: (c[0], c[1], c[2], 223, 31)), # almost no alpha
	(r'^mcl_bamboo:bamboo(_endcap)?$', lambda c: (c[0], c[1], c[2], 32)), # much more alpha
]]

def usage():
	print("Usage: generate_colorstxt.py [options] [input file]")
	print("If not specified the input file defaults to ./nodes.txt")
	print("The output will be written as ./colors.txt for minetestmapper")
	print("and as ./colors.json for the mcl_maps module")
	print("  -g / --game <folder>\t\tSet path to the game (for textures), required")
	print("  -m / --mods <folder>\t\tAdd search path for mod textures")

############ Reduce an input texture to an average color.
def average_color(name, inp, color2):
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
		print(f"Texture all transparent: {name}", file=sys.stderr)
		return None
	c0, c1, c2 = c[0] / w, c[1] / w, c[2] / w
	if color2: # param2 blending
		c0, c1, c2 = c0 * color2[0] / 255., c1 * color2[1] / 255., c2 * color2[2] / 255.
	# for alpha, find maximum alpha in chunks to account for complex textures
	a = 0
	for y2 in range(0,inp.size[0]-15,8):
		for x2 in range(0,inp.size[1]-15,8):
			a2 = 0
			for y in range(y2, min(y2+16,inp.size[0])):
				for x in range(x2, min(x2+16,inp.size[1])):
					a2 = a2 + data[y,x][3]
			a2 = a2 / 256
			a = max(a, a2)

	if a > 0 and a < 190:
		return tuple(int(round(x)) for x in (c0, c1, c2, a))
	return tuple(int(round(x)) for x in (c0, c1, c2))

_param2_cache = dict()
def get_param2_colors(filename):
	if not filename: return None
	cols = _param2_cache.get(filename)
	if not cols and filename in textures:
		inp = Image.open(textures[filename]).convert('RGBA')
		data = inp.load()
		cols = []
		for y in range(inp.size[1]):
			for x in range(inp.size[0]):
				col = data[x, y]
				if col[3] == 0: break
				assert len(cols) == x + y * inp.size[0]
				cols.append((col[0], col[1], col[2])) # copy
		_param2_cache[filename] = cols
	return cols

def get_param2_color(filename, param2):
	if not filename: return None
	cols = get_param2_colors(filename)
	return cols[param2] if cols else None

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

# global texture cache
textures = {}

########################### Texture parser
# Pure image load
class Filename:
	def __init__(self, tokens):
		self.fn = tokens[0]
	
	def gen(self, prev=None):
		if self.fn == "blank.png":
			return Image.new("RGBA", (1,1), (0, 0, 0, 0))
		if not self.fn in textures:
			raise FileNotFoundError(self.fn)
		im = Image.open(textures[self.fn]).convert('RGBA')
		if not prev: return im
		prev.alpha_composite(im)
		return prev

	def pprint(self):
		print("Load " + self.fn)

# Filter operations - todo: split them in the parser already?
class Filter:
	_combinere = re.compile(r"(-?\d+),(-?\d+)=(.*)")

	def __init__(self, tokens):
		self.fname = tokens[0]
		self.opts = tokens[1:]

	def gen(self, prev=None):
		# complex image loading filter, the most important one
		if self.fname in ["combine"]:
			assert prev is None
			#print(self.fname, self.opts)
			w, h = map(int, self.opts[0].split("x"))
			im = Image.new("RGBA", (w,h), (255,255,0,0))
			for blit in self.opts[1:]:
				blit = Filter._combinere.match(blit).groups()
				x, y, bfn = int(blit[0]), int(blit[1]), blit[2]
				if not bfn in textures:
					print("Skipping missing texture:", bfn, file=sys.stderr)
					return im
				t = Image.open(textures[bfn]).convert('RGBA')
				im.alpha_composite(t, dest=(x,y))
			return im
		elif self.fname == "transformFX":
			return prev.transpose(Image.Transpose.FLIP_LEFT_RIGHT)
		elif self.fname == "transformFY":
			return prev.transpose(Image.Transpose.FLIP_TOP_BOTTOM)
		elif self.fname == "transformR90":
			return prev.transpose(Image.Transpose.ROTATE_90)
		elif self.fname == "transformR180":
			return prev.transpose(Image.Transpose.ROTATE_180)
		elif self.fname == "transformR270":
			return prev.transpose(Image.Transpose.ROTATE_270)
		elif self.fname == "opacity":
			#print(self.fname, self.opts)
			f = int(self.opts[0]) / 255.
			bands = prev.split()
			bands[3].point(lambda x: x * f)
			return Image.merge('RGBA', bands)
		elif self.fname == "noalpha":
			prev.putalpha(255)
			return prev
		elif self.fname == "multiply":
			#print(self.fname, self.opts)
			col = ImageColor.getrgb(self.opts[0])
			im = Image.new("RGB", prev.size, col)
			bands = prev.split()
			im = ImageChops.multiply(im, Image.merge('RGB', bands[:3]))
			im.putalpha(bands[3])
			return im
		elif self.fname == "brighten":
			im = Image.new("RGB", prev.size, (255,255,255))
			bands = prev.split()
			im = Image.blend(im, Image.merge('RGB', bands[:3]), 0.5)
			im.putalpha(bands[3])
			return im
		elif self.fname == "hsl":
			#print(self.fname, self.opts)
			assert self.opts[0] == "0", "Color shifts are currently not implemented." ## TODO
			assert len(self.opts) == 2, "Only saturation is currently supported." ## TODO
			f = int(self.opts[1])
			return ImageEnhance.Color(prev).enhance(f/100. + 1)
		elif self.fname == "colorize":
			# Needs testing.
			# print(self.fname, self.opts, prev.size)
			col = ImageColor.getrgb(self.opts[0])
			if len(self.opts) == 1:
				im = Image.new("RGB", prev.size, col)
				mask = prev.getchannel("A")
				mask.point(lambda x: 255 if x > 0 else 0)
				im.putalpha(mask)
				return im
			elif self.opts[1] == "alpha":
				im = Image.new("RGB", prev.size, col)
				im.putalpha(prev.getchannel("A"))
				return im
			else:
				f = int(self.opts[1]) / 255.
				im = Image.new("RGBA", prev.size, col)
				mask = prev.getchannel("A")
				mask.point(lambda x: 255 if x > 0 else 0)
				im = Image.blend(prev, im, f)
				im.putalpha(mask)
				assert im.has_transparency_data
				return im
		elif self.fname in ["resize"]:
			#print(self.fname, self.opts)
			w, h = map(int, self.opts[0].split("x"))
			return prev.resize((w,h))
		elif self.fname in ["mask"]:
			#print(self.fname, self.opts)
			# bitwise AND, very odd operation
			mfn = self.opts[0]
			if not mfn in textures:
				print("Skipping missing texture:", mfn, file=sys.stderr)
				return prev
			m = Image.open(textures[mfn]).convert('RGBA')
			return Image.merge('RGBA', [ImageMath.unsafe_eval("a&b", a=a, b=b).convert("L") for a,b in zip(prev.split(), m.split())])
		elif self.fname in ["lowpart"]:
			#print(self.fname, self.opts)
			f = int(self.opts[0]) / 100
			t = int(prev.size[1] * f)
			return prev.crop((0, t, prev.size[0], prev.size[1]))
		elif self.fname in ["verticalframe"]:
			#print(self.fname, self.opts)
			vdiv, idx = int(self.opts[0]), int(self.opts[1])
			h = prev.size[1] // vdiv
			return prev.crop((0, h * idx, prev.size[0], h * (idx + 1)))
		print("Texture filter", self.fname, *self.opts, "not implemented yet.", file=sys.stderr)

	def pprint(self):
		print(self.fname, *self.opts)

class Overlay:
	def __init__(self, tokens):
		self.overlays = tokens[0]
	
	def gen(self, prev=None):
		cur = prev
		for o in self.overlays:
			cur = o.gen(cur)
		return cur

	def pprint(self):
		for o in self.overlays:
			o.pprint()


# not sure how we would define escapes for filenames with ^ : or backslash
filt = (Suppress("[") + CharsNotIn("^[():")("name") + ZeroOrMore(Suppress(":") + CharsNotIn("^[():")("opt*")))("filter*")
filt.set_parse_action(Filter)
fname = CharsNotIn("^():\\")("filename*")
fname.set_parse_action(Filename)
parser = infix_notation(filt ^ fname, lpar=Suppress('('), rpar=Suppress(')'),
	op_list=[(Suppress("^"), 2, opAssoc.LEFT, Overlay)])

try:
	opts, args = getopt.getopt(sys.argv[1:], "hg:m:", ["help", "game=", "mods="])
except getopt.GetoptError as e:
	print(str(e))
	exit(1)
if ('-h', '') in opts or ('--help', '') in opts:
	usage()
	exit(0)

input_file = "./nodes.txt"
output_file = "./colors.txt"
json_file = "./colors.json"
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

for o in opts:
	if o[0] not in ('-m', '--mods'): continue
	if not os.path.isdir(o[1]):
		print(f"Given path '{o[1]}' does not exist.'", file=sys.stderr)
		exit(1)
	texturepaths.append(o[1])

if len(args) > 2:
	print("Too many arguments.", file=sys.stderr)
	exit(1)
if len(args) > 0:
	input_file = args[0]

if not os.path.exists(input_file) or os.path.isdir(input_file):
	print(f"Input file '{input_file}' does not exist.", file=sys.stderr)
	exit(1)

# Build a cache to locate textures
print(f"Collecting textures from {len(texturepaths)} path(s)... ", end="", flush=True)
for path in texturepaths:
	for dirpath, dirnames, filenames in os.walk(path):
		for f in filenames:
			if not f in textures:
				textures[f] = os.path.join(dirpath, f)

print("done", len(textures), "files")

print("Processing nodes...")
cmap = dict()
fin = open(input_file, 'r')
for line in fin:
	line = line.rstrip('\r\n')
	if not line or line[0] == '#':
		#fout.write(line + '\n')
		continue
	line = line.split(" ")
	node, tex = line[0], line[1]
	if not tex or tex == "blank.png":
		continue
	im = None
	if "^" in tex or "[" in tex:
		#print(node, tex)
		im = parser.parse_string(tex)[0].gen()
		#assert not "/" in node
		#im.save(os.path.join("/tmp/test",node+".png"))
	elif tex not in textures:
		print(f"skip {node} texture {tex} not found")
		continue
	else:
		im = Image.open(textures[tex]).convert("RGBA")
	# TODO: full param2 support
	color2 = None
	if len(line) == 3 and line[2].startswith("#"):
		color2 = ImageColor.getrgb(line[2])
	elif len(line) > 3 and line[2].startswith("color"):
		if line[3].startswith("[combine:16x2:0,0="): line[3] = line[3][len("[combine:16x2:0,0="):] # simple resize for colorwallmounted
		tints = get_param2_colors(line[3])
		if tints:
			cmap[node] = [average_color(node+" "+tex, im, v) for v in tints]
			continue
		print("Unsupported:", *line)
	elif len(line) > 2:
		print("Unsupported:", *line[2:])
	color = average_color(node+" "+tex, im, color2)
	cmap[node] = color
fin.close()

# fix some missing values, perform some substitutions
for node, color in sorted(cmap.items()):
	# Try stripping off last _postfix
	if not color: color = cmap.get(node.rsplit("_", 1)[0])
	for pat, rule in REPLACEMENTS:
		if pat.search(node):
			color = rule(color) if callable(rule) else rule
	cmap[node] = color

cmap = dict((x,y) for x,y in sorted(cmap.items()) if y) # remove remaining null entries

n = 0
fout = open(output_file, 'w')
prefix = ""
for node, color in cmap.items():
	if not prefix or not node.startswith(prefix):
		prefix = node.split(":")[0] + ":"
		fout.write("\n# " + prefix[:-1] + "\n")
	if not isinstance(color[0], int): color = color[0] # param2 needs minetestmapper support first
	color = " ".join(str(x) for x in color)
	fout.write(f"{node} {color}\n")
	n += 1
fout.close()
js = json.dumps(cmap, indent="\t", separators=(",",":\t"))
js = re.sub(r'\n\t*(?!["\t}])', " ", js) # partially undo indenting to make more compact
open(json_file, "w").write(js)
print(f"Done, {n} entries written.")
