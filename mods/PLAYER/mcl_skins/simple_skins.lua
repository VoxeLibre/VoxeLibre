local function init_simple_skins()
	local id, f, data, skin = 0
	local mod_path = minetest.get_modpath("mcl_skins")
	while true do

		if id == 0 then
			skin = "character.png"
		else
			skin = "mcl_skins_character_" .. id .. ".png"

			-- Does skin file exist?
			f = io.open(mod_path .. "/textures/" .. skin)

			-- escape loop if not found
			if not f then
				break
			end
			f:close()
		end

		local metafile

		-- does metadata exist for that skin file ?
		if id == 0 then
			metafile = "mcl_skins_character.txt"
		else
			metafile = "mcl_skins_character_"..id..".txt"
		end
		f = io.open(mod_path .. "/meta/" .. metafile)

		data = nil
		if f then
			data = minetest.deserialize("return {" .. f:read("*all") .. "}")
			f:close()
		end

		-- add metadata to list
		mcl_skins.simple_skins[id] = {
			texture = skin,
			slim_arms = data and data.gender == "female",
		}
		id = id + 1
	end
	
	if #mcl_skins.simple_skins > 0 then
		table.insert(mcl_skins.tab_names, 1, "skin")
	else
		mcl_skins.simple_skins = {}
	end
end

init_simple_skins()
