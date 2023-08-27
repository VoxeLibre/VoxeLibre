dofile("init.lua")

local colormap = {
	{   0,   0,   0 }, -- black
	{ 255, 255, 255 }, -- white
	{ 255,   0,   0 }, -- red
	{   0, 255,   0 }, -- green
	{   0,   0, 255 }, -- blue
}

local _ = { 0 }
local W = { 1 }
local R = { 2 }
local G = { 3 }
local B = { 4 }

local pixels_tiny = {
	{ W, W, W, W, W, W, W, W, W, W, W, W, },
	{ W, _, _, _, _, _, _, _, _, _, _, W, },
	{ W, _, _, _, _, _, _, B, _, B, _, W, },
	{ W, _, _, _, _, _, _, B, B, B, _, W, },
	{ W, _, _, _, G, G, G, B, _, B, _, W, },
	{ W, _, _, _, G, _, G, B, B, B, _, W, },
	{ W, _, _, R, G, _, _, _, _, _, _, W, },
	{ W, _, _, R, G, G, G, _, _, _, _, W, },
	{ W, _, _, R, _, _, _, _, _, _, _, W, },
	{ W, _, R, R, R, _, _, _, _, _, _, W, },
	{ W, _, _, _, _, _, _, _, _, _, _, W, },
	{ W, W, W, W, W, W, W, W, W, W, W, W, },
}

local pixels_huge = {}

local size_tiny = #pixels_tiny
local size_huge = 1200
local scale = size_huge / size_tiny

for x_huge = 1,size_huge,1 do
	local x_tiny = math.ceil( x_huge / scale )
	for z_huge = 1,size_huge,1 do
		local z_tiny = math.ceil( z_huge / scale )
		if nil == pixels_huge[z_huge] then
		   pixels_huge[z_huge] = {}
		end
		pixels_huge[z_huge][x_huge] = pixels_tiny[z_tiny][x_tiny]
	end
end

tga_encoder.image(pixels_tiny):save("logo_tiny.tga", {colormap=colormap})
tga_encoder.image(pixels_huge):save("logo_huge.tga", {colormap=colormap})

