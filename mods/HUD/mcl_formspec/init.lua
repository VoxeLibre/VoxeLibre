local string = string
local table = table

local sf = string.format

mcl_formspec = {}

mcl_formspec.label_color = "#313131"

mcl_formspec.label_size = tonumber(minetest.settings:get("mcl_label_font_size")) or 24

mcl_formspec.apply_label_size = sf("style_type[label;font_size=%s]", mcl_formspec.label_size)

function mcl_formspec.get_itemslot_bg(x, y, w, h)
	local out = ""
	for i = 0, w - 1, 1 do
		for j = 0, h - 1, 1 do
			out = out .."image["..x+i..","..y+j..";1,1;mcl_formspec_itemslot.png]"
		end
	end
	return out
end

--This function will replace mcl_formspec.get_itemslot_bg then every formspec will be upgrade to version 4
local function get_slot(x, y, size)
	local t = "image["..x-size..","..y-size..";".. 1+(size*2)..",".. 1+(size*2)..";mcl_formspec_itemslot.png]"
	return t
end

mcl_formspec.itemslot_border_size = 0.05

function mcl_formspec.get_itemslot_bg_v4(x, y, w, h, size)
	if not size then
		size = mcl_formspec.itemslot_border_size
	end
	local out = ""
	for i = 0, w - 1, 1 do
		for j = 0, h - 1, 1 do
			out = out .. get_slot(x+i+(i*0.25), y+j+(j*0.25), size)
		end
	end
	return out
end