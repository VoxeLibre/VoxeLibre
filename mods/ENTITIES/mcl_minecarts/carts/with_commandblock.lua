local modname = minetest.get_current_modname()
local mod = mcl_minecarts
local S = minetest.get_translator(modname)

function table_metadata(table)
	return {
		table = table,
		set_string = function(self, key, value)
			--print("set_string("..tostring(key)..", "..tostring(value)..")")
			self.table[key] = tostring(value)
		end,
		get_string = function(self, key)
			if self.table[key] then
				return tostring(self.table[key])
			end
		end
	}
end

-- Minecart with Command Block
mod.register_minecart({
	itemstring = "mcl_minecarts:command_block_minecart",
	entity_id = "mcl_minecarts:command_block_minecart",
	description = S("Minecart with Command Block"),
	tt_help = nil,
	loncdesc = nil,
	usagehelp = nil,
	initial_properties = {
		mesh = "mcl_minecarts_minecart_block.b3d",
		textures = {
			"jeija_commandblock_off.png^[verticalframe:2:0",
			"jeija_commandblock_off.png^[verticalframe:2:0",
			"jeija_commandblock_off.png^[verticalframe:2:0",
			"jeija_commandblock_off.png^[verticalframe:2:0",
			"jeija_commandblock_off.png^[verticalframe:2:0",
			"jeija_commandblock_off.png^[verticalframe:2:0",
			"mcl_minecarts_minecart.png",
		},
	},
	icon = "mcl_minecarts_minecart_command_block.png",
	drop = {"mcl_minecarts:minecart"},
	on_rightclick = function(self, clicker)
		self._staticdata.meta = self._staticdata.meta or {}
		local meta = table_metadata(self._staticdata.meta)

		mesecon.commandblock.handle_rightclick(meta, clicker)
	end,
	_mcl_minecarts_on_place = function(self, placer)
		-- Create a fake metadata object that stores into the cart's staticdata
		self._staticdata.meta = self._staticdata.meta or {}
		local meta = table_metadata(self._staticdata.meta)

		mesecon.commandblock.initialize(meta)
		mesecon.commandblock.place(meta, placer)
	end,
	on_activate_by_rail = function(self, timer)
		self._staticdata.meta = self._staticdata.meta or {}
		local meta = table_metadata(self._staticdata.meta)

		mesecon.commandblock.action_on(meta, self.object:get_pos())
	end,
	creative = true
})
