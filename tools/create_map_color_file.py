import json, os
from PIL import Image

colors = {}
palettes = {}

for root, directories, files in os.walk(".."):
	if root.endswith("/textures"):
		for name in files:
			try:
				img = Image.open(os.path.join(root, name)).convert("RGBA")
				pixels = img.load()

				if "palette" in name:
					palette = []

					for y in range(0, img.size[1]):
						for x in range(0, img.size[0]):
							r, g, b, a = pixels[x, y]
							palette.append((r, g, b))

					palettes[name] = palette
				else:
					r_total = 0
					g_total = 0
					b_total = 0

					count = 0

					for x in range(0, img.size[0]):
						for y in range(0, img.size[1]):
							r, g, b, a = pixels[x, y]
							if a > 0:
								r_total += r / 255 * a
								g_total += g / 255 * a
								b_total += b / 255 * a
								count += a / 255

					average_color = None

					if count > 0:
						average_color = (int(r_total / count), int(g_total / count), int(b_total / count))
					else:
						average_color = (255, 255, 255)

					colors[name] = average_color

					img.close()
			except IOError:
				pass

path = "../mods/ITEMS/mcl_maps/"

with open(path + "colors.json", "w") as colorfile:
	colorfile.write(json.dumps(colors))

with open(path + "palettes.json", "w") as palettefile:
	palettefile.write(json.dumps(palettes))

