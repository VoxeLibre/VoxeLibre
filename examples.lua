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
tga_encoder.image(pixels):save("gradient_8bpp_raw.tga", {colors="BW", compression="RAW", pixel_depth=8})

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
gradients:save("gradients_8bpp_raw.tga", {colors="BW", compression="RAW", pixel_depth=8})
gradients:save("gradients_16bpp_raw.tga", {colors="RGB", compression="RAW", pixel_depth=16})
gradients:save("gradients_16bpp_rle.tga", {colors="RGB", compression="RLE", pixel_depth=16})
gradients:save("gradients_24bpp_raw.tga", {colors="RGB", compression="RAW", pixel_depth=24})
gradients:save("gradients_24bpp_rle.tga", {colors="RGB", compression="RLE", pixel_depth=24})

for x = 1,16,1 do -- left to right
	for z = 1,16,1 do -- bottom to top
		local color = pixels[z][x]
		color[#color+1] = ((x * x) + (z * z)) % 256
		pixels[z][x] = color
	end
end
gradients:save("gradients_32bpp_raw.tga", {colors="RGBA", compression="RAW", pixel_depth=32})

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
tga_encoder.image(pixels):save("fractal_8bpp.tga", {colors="BW", pixel_depth=8})
tga_encoder.image(pixels):save("fractal_16bpp.tga", {colors="RGB", pixel_depth=16})
tga_encoder.image(pixels):save("fractal_24bpp.tga", {colors="RGB", pixel_depth=24})
