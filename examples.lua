dofile("init.lua")

-- encode a bitmap
local _ = { 0, 0, 0 }
local R = { 255, 127, 127 }
local pixels = {
	{ _, _, _, _, _, _, _ },
	{ _, _, _, R, _, _, _ },
	{ _, _, R, R, R, _, _ },
	{ _, R, R, R, R, R, _ },
	{ _, R, R, R, R, R, _ },
	{ _, _, R, _, R, _, _ },
	{ _, _, _, _, _, _, _ },
}
tga_encoder.image(pixels):save("bitmap_small.tga")

-- test that image can be encoded
local bitmap_small_0 = tga_encoder.image(pixels)
bitmap_small_0:encode()
assert(191 == #bitmap_small_0.data)

-- test that imbage can be encoded with parameters
local bitmap_small_1 = tga_encoder.image(pixels)
bitmap_small_1:encode(
	{
		colormap = {},
		color_format = "B8G8R8",
		compression = "RAW",
	}
)
assert(191 == #bitmap_small_1.data)

-- change a single pixel, then rescale the bitmap
local pixels_orig = pixels
pixels_orig[4][4] = { 255, 255, 255 }
local pixels = {}
for x = 1,56,1 do
	local x_orig = math.ceil(x/8)
	for z = 1,56,1 do
		local z_orig = math.ceil(z/8)
		local color = pixels_orig[z_orig][x_orig]
		pixels[z] = pixels[z] or {}
		pixels[z][x] = color
	end
end
tga_encoder.image(pixels):save("bitmap_large.tga")

-- note that the uncompressed grayscale TGA file written in this
-- example is 80 bytes – but an optimized PNG file is 81 bytes …
local pixels = {}
for x = 1,6,1 do -- left to right
	for z = 1,6,1 do -- bottom to top
		local color = { math.min(x * z * 4 - 1, 255) }
		pixels[z] = pixels[z] or {}
		pixels[z][x] = color
	end
end
tga_encoder.image(pixels):save("gradient_8bpp_raw.tga", {color_format="Y8", compression="RAW"})

local pixels = {}
for x = 1,16,1 do -- left to right
	for z = 1,16,1 do -- bottom to top
		local r = math.min(x * 32 - 1, 255)
		local g = math.min(z * 32 - 1, 255)
		local b = 0
		-- blue rectangle in top right corner
		if x > 8 and z > 8 then
			r = 0
			g = 0
			b = math.min(z * 16 - 1, 255)
		end
		local color = { r, g, b }
		pixels[z] = pixels[z] or {}
		pixels[z][x] = color
	end
end
local gradients = tga_encoder.image(pixels)
gradients:save("gradients_8bpp_raw.tga", {color_format="Y8", compression="RAW"})
gradients:save("gradients_16bpp_raw.tga", {color_format="A1R5G5B5", compression="RAW"})
gradients:save("gradients_16bpp_rle.tga", {color_format="A1R5G5B5", compression="RLE"})
gradients:save("gradients_24bpp_raw.tga", {color_format="B8G8R8", compression="RAW"})
gradients:save("gradients_24bpp_rle.tga", {color_format="B8G8R8", compression="RLE"})

for x = 1,16,1 do -- left to right
	for z = 1,16,1 do -- bottom to top
		local color = pixels[z][x]
		color[#color+1] = ((x * x) + (z * z)) % 256
		pixels[z][x] = color
	end
end
gradients:save("gradients_32bpp_raw.tga", {color_format="B8G8R8A8", compression="RAW"})
-- the RLE-compressed file is larger than just dumping pixels because
-- the gradients in this picture can not be compressed well using RLE
gradients:save("gradients_32bpp_rle.tga", {color_format="B8G8R8A8", compression="RLE"})

local pixels = {}
for x = 1,512,1 do -- left to right
	for z = 1,512,1 do -- bottom to top
		local oz = (z - 256) / 256 + 0.75
		local ox = (x - 256) / 256
		local px, pz, i = 0, 0, 0
		while (px * px) + (pz * pz) <= 4 and i < 128 do
			px = (px * px) - (pz * pz) + oz
			pz = (2 * px  * pz) + ox
			i =  i + 1
		end
		local color = {
			math.max(0, math.min(255, math.floor(px * 64))),
			math.max(0, math.min(255, math.floor(pz * 64))),
			math.max(0, math.min(255, math.floor(i))),
		}
		pixels[z] = pixels[z] or {}
		pixels[z][x] = color
	end
end
tga_encoder.image(pixels):save("fractal_8bpp.tga", {color_format="Y8"})
tga_encoder.image(pixels):save("fractal_16bpp.tga", {color_format="A1R5G5B5"})
tga_encoder.image(pixels):save("fractal_24bpp.tga", {color_format="B8G8R8"})

-- encode a colormapped bitmap
local K = { 0 }
local B = { 1 }
local R = { 2 }
local G = { 3 }
local W = { 4 }
local colormap = {
	{   1,   2,   3 }, -- K
	{   0,   0, 255 }, -- B
	{ 255,   0,   0 }, -- R
	{   0, 255,   0 }, -- G
	{ 253, 254, 255 }, -- W
}
local pixels = {
	{ W, K, W, K, W, K, W },
	{ R, G, B, R, G, B, K },
	{ K, W, K, W, K, W, K },
	{ G, B, R, G, B, R, W },
	{ W, W, W, K, K, K, W },
	{ B, R, G, B, R, G, K },
	{ B, R, G, B, R, G, W },
}
-- note that the uncompressed colormapped TGA file written in this
-- example is 108 bytes – but an optimized PNG file is 121 bytes …
tga_encoder.image(pixels):save("colormapped_B8G8R8.tga", {colormap=colormap})
-- encoding as A1R5G5B5 saves 1 byte per palette entry → 103 bytes
tga_encoder.image(pixels):save("colormapped_A1R5G5B5.tga", {colormap=colormap, color_format="A1R5G5B5"})

-- encode a colormapped bitmap with transparency
local _ = { 0 }
local K = { 1 }
local W = { 2 }
local colormap = {
	{   0,   0,   0,   0 },
	{   0,   0,   0, 255 },
	{ 255, 255, 255, 255 },
}
local pixels = {
	{ _, K, K, K, K, K, _ },
	{ _, K, W, W, W, K, _ },
	{ K, K, W, W, W, K, K },
	{ K, W, W, W, W, W, K },
	{ _, K, W, W, W, K, _ },
	{ _, _, K, W, K, _, _ },
	{ _, _, _, K, _, _, _ },
}
tga_encoder.image(pixels):save("colormapped_B8G8R8A8.tga", {colormap=colormap})

-- encoding a colormapped image with illegal colormap indexes should error out
local colormap = {
	{   0,   0,   0,   0 },
	{   0,   0,   0, 255 },
}
local status, message = pcall(
	function ()
		tga_encoder.image(pixels):encode({colormap=colormap})
	end
)
assert(
	false == status and
	"init.lua:36: colormap index 2 not in colormap of size 2" == message
)
