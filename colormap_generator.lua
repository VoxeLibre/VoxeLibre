dofile("init.lua")

-- This generates images necessary to colorize 16 Minetest nodes in 4096 colors.
-- It serves as a demonstration of what you can achieve using colormapped nodes.
-- It is be useful for grass or beam or glass nodes that need to blend smoothly.

-- Sample depth rescaling is done according to the algorithm presented in:
-- <https://www.w3.org/TR/2003/REC-PNG-20031110/#13Sample-depth-rescaling>
local max_sample_in = math.pow(2, 4) - 1
local max_sample_out = math.pow(2, 8) - 1

for r = 0,15 do
	local pixels = {}
	for g = 0,15 do
		if nil == pixels[g + 1] then
			pixels[g + 1] = {}
		end
		for b = 0,15 do
			local color = {
				math.floor((r * max_sample_out / max_sample_in) + 0.5),
				math.floor((g * max_sample_out / max_sample_in) + 0.5),
				math.floor((b * max_sample_out / max_sample_in) + 0.5),
			}
			pixels[g + 1][b + 1] = color
		end
	end
	local filename = "colormap_" .. tostring(r) .. ".tga"
	tga_encoder.image(pixels):save(
		filename,
		{ color_format="A1R5G5B5" } -- waste less bits
	)
end
