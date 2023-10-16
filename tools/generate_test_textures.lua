#!/usr/bin/env lua5.1
dofile("../init.lua")

local _ = { 0 }
local R = { 1 }
local G = { 2 }
local B = { 3 }

local pixels_colormapped = {
	{ _, _, _, _, _, B, _, B, },
	{ _, _, _, _, _, B, B, B, },
	{ _, _, G, G, G, B, _, B, },
	{ _, _, G, _, G, B, B, B, },
	{ _, R, G, _, _, _, _, _, },
	{ _, R, G, G, G, _, _, _, },
	{ _, R, _, _, _, _, _, _, },
	{ R, R, R, _, _, _, _, _, },
}

image_colormapped = tga_encoder.image(pixels_colormapped)

colormap_32bpp = {
	{    0,   0,   0, 128 },
	{ 255,    0,   0, 255 },
	{    0, 255,   0, 255 },
	{    0,   0, 255, 255 },
}
image_colormapped:save(
	"type1_32bpp_bt.tga",
	{ colormap = colormap_32bpp, color_format = "B8G8R8A8" }
)
image_colormapped:save(
	"type1_16bpp_bt.tga",
	{ colormap = colormap_32bpp, color_format = "A1R5G5B5" }
)

colormap_24bpp = {
	{    0,   0,   0 },
	{ 255,    0,   0 },
	{    0, 255,   0 },
	{    0,   0, 255 },
}
image_colormapped:save(
	"type1_24bpp_bt.tga",
	{ colormap = colormap_32bpp, color_format = "B8G8R8" }
)

local _ = {    0,   0,   0, 128 }
local R = { 255,    0,   0, 255 }
local G = {    0, 255,   0, 255 }
local B = {    0,   0, 255, 255 }

local pixels_rgba = {
	{ _, _, _, _, _, B, _, B, },
	{ _, _, _, _, _, B, B, B, },
	{ _, _, G, G, G, B, _, B, },
	{ _, _, G, _, G, B, B, B, },
	{ _, R, G, _, _, _, _, _, },
	{ _, R, G, G, G, _, _, _, },
	{ _, R, _, _, _, _, _, _, },
	{ R, R, R, _, _, _, _, _, },
}

image_rgba = tga_encoder.image(pixels_rgba)

image_rgba:save(
	"type2_32bpp_bt.tga",
	{ color_format="B8G8R8A8", compression="RAW" }
)
image_rgba:save(
	"type10_32bpp_bt.tga",
	{ color_format="B8G8R8A8", compression="RLE" }
)

local _ = {    0,   0,   0 }
local R = { 255,    0,   0 }
local G = {    0, 255,   0 }
local B = {    0,   0, 255 }

local pixels_rgb = {
	{ _, _, _, _, _, B, _, B, },
	{ _, _, _, _, _, B, B, B, },
	{ _, _, G, G, G, B, _, B, },
	{ _, _, G, _, G, B, B, B, },
	{ _, R, G, _, _, _, _, _, },
	{ _, R, G, G, G, _, _, _, },
	{ _, R, _, _, _, _, _, _, },
	{ R, R, R, _, _, _, _, _, },
}

image_rgb = tga_encoder.image(pixels_rgb)

image_rgb:save(
	"type2_24bpp_bt.tga",
	{ color_format="B8G8R8", compression="RAW" }
)
image_rgb:save(
	"type10_24bpp_bt.tga",
	{ color_format="B8G8R8", compression="RLE" }
)

image_rgb:save(
	"type2_16bpp_bt.tga",
	{ color_format="A1R5G5B5", compression="RAW" }
)
image_rgb:save(
	"type10_16bpp_bt.tga",
	{ color_format="A1R5G5B5", compression="RLE" }
)
