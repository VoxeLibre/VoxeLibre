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
tga_encoder.image(pixels, {colors="BW", pixel_depth=8}):save("gradients_8bpp.tga")

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
tga_encoder.image(pixels, {colors="RGB", pixel_depth=16}):save("gradients_16bpp.tga")
tga_encoder.image(pixels, {colors="RGB", pixel_depth=24}):save("gradients_24bpp.tga")
