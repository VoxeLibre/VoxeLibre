mcl_formspec = {}

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
function mcl_formspec.get_itemslot_bg_v4(x, y, w, h)
	local out = ""
	for i = 0, w - 1, 1 do
		for j = 0, h - 1, 1 do
			out = out .."image["..x+i+(i*0.25)..","..y+j+(j*0.25)..";1,1;mcl_formspec_itemslot.png]"
		end
	end
	return out
end

