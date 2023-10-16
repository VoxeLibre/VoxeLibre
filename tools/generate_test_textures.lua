#!/usr/bin/env lua5.1
dofile("../init.lua")

local _ = { 0 }
local R = { 1 }
local G = { 2 }
local B = { 3 }

local pixels_colormapped_bt = {
	{ _, _, _, _, _, B, _, B, },
	{ _, _, _, _, _, B, B, B, },
	{ _, _, G, G, G, B, _, B, },
	{ _, _, G, _, G, B, B, B, },
	{ _, R, G, _, _, _, _, _, },
	{ _, R, G, G, G, _, _, _, },
	{ _, R, _, _, _, _, _, _, },
	{ R, R, R, _, _, _, _, _, },
}

local pixels_colormapped_tb = {
	{ R, R, R, _, _, _, _, _, },
	{ _, R, _, _, _, _, _, _, },
	{ _, R, G, G, G, _, _, _, },
	{ _, R, G, _, _, _, _, _, },
	{ _, _, G, _, G, B, B, B, },
	{ _, _, G, G, G, B, _, B, },
	{ _, _, _, _, _, B, B, B, },
	{ _, _, _, _, _, B, _, B, },
}

image_colormapped_bt = tga_encoder.image(pixels_colormapped_bt)
image_colormapped_tb = tga_encoder.image(pixels_colormapped_tb)

colormap_32bpp = {
	{    0,   0,   0, 128 },
	{ 255,    0,   0, 255 },
	{    0, 255,   0, 255 },
	{    0,   0, 255, 255 },
}
image_colormapped_bt:save(
	"type1_32bpp_bt.tga",
	{ colormap = colormap_32bpp, color_format = "B8G8R8A8", scanline_order = "bottom-top" }
)
image_colormapped_tb:save(
	"type1_32bpp_tb.tga",
	{ colormap = colormap_32bpp, color_format = "B8G8R8A8", scanline_order = "top-bottom" }
)
image_colormapped_bt:save(
	"type1_16bpp_bt.tga",
	{ colormap = colormap_32bpp, color_format = "A1R5G5B5", scanline_order = "bottom-top" }
)
image_colormapped_tb:save(
	"type1_16bpp_tb.tga",
	{ colormap = colormap_32bpp, color_format = "A1R5G5B5", scanline_order = "top-bottom" }
)

colormap_24bpp = {
	{    0,   0,   0 },
	{ 255,    0,   0 },
	{    0, 255,   0 },
	{    0,   0, 255 },
}
image_colormapped_bt:save(
	"type1_24bpp_bt.tga",
	{ colormap = colormap_32bpp, color_format = "B8G8R8", scanline_order = "bottom-top" }
)
image_colormapped_tb:save(
	"type1_24bpp_tb.tga",
	{ colormap = colormap_32bpp, color_format = "B8G8R8", scanline_order = "top-bottom" }
)

local _ = {    0,   0,   0, 128 }
local R = { 255,    0,   0, 255 }
local G = {    0, 255,   0, 255 }
local B = {    0,   0, 255, 255 }

local pixels_rgba_bt = {
	{ _, _, _, _, _, B, _, B, },
	{ _, _, _, _, _, B, B, B, },
	{ _, _, G, G, G, B, _, B, },
	{ _, _, G, _, G, B, B, B, },
	{ _, R, G, _, _, _, _, _, },
	{ _, R, G, G, G, _, _, _, },
	{ _, R, _, _, _, _, _, _, },
	{ R, R, R, _, _, _, _, _, },
}

local pixels_rgba_tb = {
	{ R, R, R, _, _, _, _, _, },
	{ _, R, _, _, _, _, _, _, },
	{ _, R, G, G, G, _, _, _, },
	{ _, R, G, _, _, _, _, _, },
	{ _, _, G, _, G, B, B, B, },
	{ _, _, G, G, G, B, _, B, },
	{ _, _, _, _, _, B, B, B, },
	{ _, _, _, _, _, B, _, B, },
}

image_rgba_bt = tga_encoder.image(pixels_rgba_bt)
image_rgba_tb = tga_encoder.image(pixels_rgba_tb)

image_rgba_bt:save(
	"type2_32bpp_bt.tga",
	{ color_format="B8G8R8A8", compression="RAW", scanline_order = "bottom-top" }
)
image_rgba_tb:save(
	"type2_32bpp_tb.tga",
	{ color_format="B8G8R8A8", compression="RAW", scanline_order = "top-bottom" }
)
image_rgba_bt:save(
	"type10_32bpp_bt.tga",
	{ color_format="B8G8R8A8", compression="RLE", scanline_order = "bottom-top" }
)
image_rgba_tb:save(
	"type10_32bpp_tb.tga",
	{ color_format="B8G8R8A8", compression="RLE", scanline_order = "top-bottom" }
)

local _ = {    0,   0,   0 }
local R = { 255,    0,   0 }
local G = {    0, 255,   0 }
local B = {    0,   0, 255 }

local pixels_rgb_bt = {
	{ _, _, _, _, _, B, _, B, },
	{ _, _, _, _, _, B, B, B, },
	{ _, _, G, G, G, B, _, B, },
	{ _, _, G, _, G, B, B, B, },
	{ _, R, G, _, _, _, _, _, },
	{ _, R, G, G, G, _, _, _, },
	{ _, R, _, _, _, _, _, _, },
	{ R, R, R, _, _, _, _, _, },
}

local pixels_rgb_tb = {
	{ R, R, R, _, _, _, _, _, },
	{ _, R, _, _, _, _, _, _, },
	{ _, R, G, G, G, _, _, _, },
	{ _, R, G, _, _, _, _, _, },
	{ _, _, G, _, G, B, B, B, },
	{ _, _, G, G, G, B, _, B, },
	{ _, _, _, _, _, B, B, B, },
	{ _, _, _, _, _, B, _, B, },
}

image_rgb_bt = tga_encoder.image(pixels_rgb_bt)
image_rgb_tb = tga_encoder.image(pixels_rgb_tb)

image_rgb_bt:save(
	"type2_24bpp_bt.tga",
	{ color_format="B8G8R8", compression="RAW", scanline_order = "bottom-top" }
)
image_rgb_tb:save(
	"type2_24bpp_tb.tga",
	{ color_format="B8G8R8", compression="RAW", scanline_order = "top-bottom" }
)
image_rgb_bt:save(
	"type10_24bpp_bt.tga",
	{ color_format="B8G8R8", compression="RLE", scanline_order = "bottom-top" }
)
image_rgb_tb:save(
	"type10_24bpp_tb.tga",
	{ color_format="B8G8R8", compression="RLE", scanline_order = "top-bottom" }
)
image_rgb_bt:save(
	"type2_16bpp_bt.tga",
	{ color_format="A1R5G5B5", compression="RAW", scanline_order = "bottom-top" }
)
image_rgb_tb:save(
	"type2_16bpp_tb.tga",
	{ color_format="A1R5G5B5", compression="RAW", scanline_order = "top-bottom" }
)
image_rgb_bt:save(
	"type10_16bpp_bt.tga",
	{ color_format="A1R5G5B5", compression="RLE", scanline_order = "bottom-top" }
)
image_rgb_tb:save(
	"type10_16bpp_tb.tga",
	{ color_format="A1R5G5B5", compression="RLE", scanline_order = "top-bottom" }
)
