mcl_formspec = {}

mcl_formspec.label_color = "#313131"

---@param x number
---@param y number
---@param w number
---@param h number
---@return string
function mcl_formspec.get_itemslot_bg(x, y, w, h)
	local out = ""
	for i = 0, w - 1, 1 do
		for j = 0, h - 1, 1 do
			out = out .. "image[" .. x + i .. "," .. y + j .. ";1,1;mcl_formspec_itemslot.png]"
		end
	end
	return out
end

---This function will replace mcl_formspec.get_itemslot_bg then every formspec will be upgrade to version 4
---@param x number
---@param y number
---@param size number
---@return string
local function get_slot(x, y, size)
	local t = "image[" .. x - size .. "," .. y - size .. ";" .. 1 + (size * 2) ..
		"," .. 1 + (size * 2) .. ";mcl_formspec_itemslot.png]"
	return t
end

mcl_formspec.itemslot_border_size = 0.05

---@param x number
---@param y number
---@param w integer
---@param h integer
---@param size? number
---@return string
function mcl_formspec.get_itemslot_bg_v4(x, y, w, h, size)
	if not size then
		size = mcl_formspec.itemslot_border_size
	end
	local out = ""
	for i = 0, w - 1, 1 do
		for j = 0, h - 1, 1 do
			out = out .. get_slot(x + i + (i * 0.25), y + j + (j * 0.25), size)
		end
	end
	return out
end
