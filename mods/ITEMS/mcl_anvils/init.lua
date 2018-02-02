local MAX_NAME_LENGTH = 30
local MAX_WEAR = 65535
local SAME_TOOL_REPAIR_BOOST = math.ceil(MAX_WEAR * 0.05) -- 5%
local MATERIAL_TOOL_REPAIR_BOOST = math.ceil(MAX_WEAR * 0.25) -- 25%

local function get_anvil_formspec(set_name)
	if not set_name then
		set_name = ""
	end
	return "size[9,8.75]"..
	"background[-0.19,-0.25;9.41,9.49;mcl_anvils_inventory.png]"..
	mcl_vars.inventory_header..
	"list[current_player;main;0,4.5;9,3;9]"..
	"list[current_player;main;0,7.74;9,1;]"..
	"list[context;input;1,2.5;1,1;]"..
	"list[context;input;4,2.5;1,1;1]"..
	"list[context;output;8,2.5;1,1;]"..
	"field[3.25,1;4,1;name;;"..minetest.formspec_escape(set_name).."]"..
	"button[7,0.7;2,1;name_button;Set name]"..
	"listring[context;output]"..
	"listring[current_player;main]"..
	"listring[context;input]"..
	"listring[current_player;main]"
end

-- Update the inventory slots of an anvil node.
-- meta: Metadata of anvil node
local function update_anvil_slots(meta)
	local inv = meta:get_inventory()
	local new_name = meta:get_string("set_name")
	local input1, input2, output
	input1 = inv:get_stack("input", 1)
	input2 = inv:get_stack("input", 2)
	output = inv:get_stack("output", 1)
	local new_output, name_item
	local check_rename = false

	-- Both input slots occupied
	if (not input1:is_empty() and not input2:is_empty()) then
		-- Repair, if tool
		local def1 = input1:get_definition()
		local def2 = input2:get_definition()

		-- Repair calculation helper.
		-- Adds the “inverse” values of wear1 and wear2.
		-- Then adds a boost health value directly.
		-- Returns the resulting (capped) wear.
		local function calculate_repair(wear1, wear2, boost)
			local new_health = (MAX_WEAR - wear1) + (MAX_WEAR - wear2)
			if boost then
				new_health = new_health + boost
			end
			return math.max(0, math.min(MAX_WEAR, MAX_WEAR - new_health))
		end

		-- Same tool twice
		if input1:get_name() == input2:get_name() and def1.type == "tool" then
			-- Add tool health together plus a small bonus
			-- TODO: Combine tool enchantments
			local new_wear = calculate_repair(input1:get_wear(), input2:get_wear(), SAME_TOOL_REPAIR_BOOST)
			input1:set_wear(new_wear)
			name_item = input1
		-- Tool + repair item
		else
			-- Any tool can have a repair item. This may be defined in the tool's item definition
			-- as an itemstring in the field `_repair_material`. Only if this field is set, the
			-- tool can be repaired with a material item.
			-- Example: Iron Pickaxe + Iron Ingot. `_repair_material = mcl_core:iron_ingot`

			-- Big repair bonus
			-- TODO: Combine tool enchantments
			local tool, material
			if def1.type == "tool" and def1._repair_material then
				tool = input1
				tooldef = def1
				material = input2
			elseif def2.type == "tool" and def2._repair_material then
				tool = input2
				tooldef = def2
				material = input1
			end
			if tool and material then
				local has_correct_material = false
				if string.sub(tooldef._repair_material, 1, 6) == "group:" then
					has_correct_material = minetest.get_item_group(material:get_name(), string.sub(tooldef._repair_material, 7)) ~= 0
				elseif material:get_name() == tooldef._repair_material then
					has_correct_material = true
				end
				if has_correct_material then
					local new_wear = calculate_repair(tool:get_wear(), MAX_WEAR, MATERIAL_TOOL_REPAIR_BOOST)
					tool:set_wear(new_wear)
					name_item = tool
				else
					new_output = ""
				end
			else
				new_output = ""
			end
		end
	-- Exactly 1 input slot occupied
	elseif (not input1:is_empty() and input2:is_empty()) or (input1:is_empty() and not input2:is_empty()) then
		-- Just rename item
		if new_name == nil then
			new_name = ""
		end
		if input1:is_empty() then
			name_item = input2
		else
			name_item = input1
		end
	else
		new_output = ""
	end

	-- Rename handling
	if name_item then
		-- No renaming allowed with group no_rename=1
		if minetest.get_item_group(name_item:get_name(), "no_rename") == 1 then
			new_output = ""
		else
			local meta = name_item:get_meta()
			-- Limit name length
			new_name = string.sub(new_name, 1, MAX_NAME_LENGTH)
			-- Rename item
			meta:set_string("description", new_name)
			-- Double-save the name internally, too
			meta:set_string("name", new_name)
			new_output = name_item
		end
	end

	-- Set the new output slot
	if new_output ~= nil then
		inv:set_stack("output", 1, new_output)
	end
end

local anvildef = {
	groups = {pickaxey=1, falling_node=1, crush_after_fall=1, deco_block=1, anvil=1},
	tiles = {"mcl_anvils_anvil_top_damaged_0.png^[transformR90", "mcl_anvils_anvil_base.png", "mcl_anvils_anvil_side.png"},
	paramtype = "light",
	sunlight_propagates = true,
	is_ground_content = false,
	paramtype2 = "facedir",
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
			{-8/16, 2/16, -5/16, 8/16, 8/16, 5/16}, --  top
			{-5/16, -4/16, -2/16, 5/16, 5/16, 2/16}, -- middle
			{-8/16, -8/16, -5/16, 8/16, -4/16, 5/16}, -- base
		}
	},
	sounds = mcl_sounds.node_sound_metal_defaults(),
	_mcl_blast_resistance = 6000,
	_mcl_hardness = 5,
	allow_metadata_inventory_put = function(pos, listname, index, stack, player)
		if listname == "output" then
			return 0
		else
			return stack:get_count()
		end
	end,
	allow_metadata_inventory_move = function(pos, from_list, from_index, to_list, to_index, count, player)
		if to_list == "output" then
			return 0
		elseif from_list == "output" and to_list == "input" then
			local meta = minetest.get_meta(pos)
			local inv = meta:get_inventory()
			if inv:get_stack(to_list, to_index):is_empty() then
				return count
			else
				return 0
			end
		else
			return count
		end
	end,
	on_metadata_inventory_put = function(pos, listname, index, stack, player)
		local meta = minetest.get_meta(pos)
		update_anvil_slots(meta)
	end,
	on_metadata_inventory_move = function(pos, from_list, from_index, to_list, to_index, count, player)
		local meta = minetest.get_meta(pos)
		if from_list == "output" and to_list == "input" then
			local inv = meta:get_inventory()
			inv:set_stack("output", 1, "")
			for i=1, inv:get_size("input") do
				if i ~= to_index then
					inv:set_stack("input", i, "")
				end
			end
		end
		update_anvil_slots(meta)
	end,
	on_metadata_inventory_take = function(pos, listname, index, stack, player)
		local meta = minetest.get_meta(pos)
		if listname == "output" then
			local inv = meta:get_inventory()
			inv:set_list("input", {"",""})
		end
		update_anvil_slots(meta)
	end,
	on_construct = function(pos)
		local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()
		inv:set_size("input", 2)
		inv:set_size("output", 1)
		local form = "size[9,8.75]"..
		"background[-0.19,-0.25;9.41,9.49;mcl_anvils_inventory.png]"..
		mcl_vars.inventory_header..
		"list[current_player;main;0,4.5;9,3;9]"..
		"list[current_player;main;0,7.74;9,1;]"..
		"list[context;input;1,2.5;1,1;]"..
		"list[context;input;4,2.5;1,1;1]"..
		"list[context;output;8,2.5;1,1;]"..
		"field[3.25,1;4,1;name;;]"..
		"button[7,0.7;2,1;name_button;Set name]"..
		"listring[context;output]"..
		"listring[current_player;main]"..
		"listring[context;input]"..
		"listring[current_player;main]"
		meta:set_string("formspec", form)
	end,
	on_receive_fields = function(pos, formname, fields, sender)
		if fields.name_button then
			local set_name
			if fields.name == nil then
				set_name = ""
			else
				set_name = fields.name
			end
			local meta = minetest.get_meta(pos)
			-- Limit name length
			set_name = string.sub(set_name, 1, MAX_NAME_LENGTH)
			meta:set_string("set_name", set_name)
			update_anvil_slots(meta)
			meta:set_string("formspec", get_anvil_formspec(set_name))
		end
	end,
}
if minetest.get_modpath("screwdriver") then
	anvildef.on_rotate = screwdriver.rotate_simple
end

local anvildef0 = table.copy(anvildef)
anvildef0.description = "Anvil"

local anvildef1 = table.copy(anvildef)
anvildef1.description = "Slightly Damaged Anvil"
anvildef1.groups.not_in_creative_inventory = 1
anvildef1._doc_items_create_entry = false
anvildef1.tiles = {"mcl_anvils_anvil_top_damaged_1.png^[transformR90", "mcl_anvils_anvil_base.png", "mcl_anvils_anvil_side.png"}

local anvildef2 = table.copy(anvildef)
anvildef2.description = "Very Damaged Anvil"
anvildef2.groups.not_in_creative_inventory = 1
anvildef2._doc_items_create_entry = false
anvildef2.tiles = {"mcl_anvils_anvil_top_damaged_2.png^[transformR90", "mcl_anvils_anvil_base.png", "mcl_anvils_anvil_side.png"}

minetest.register_node("mcl_anvils:anvil", anvildef0)
minetest.register_node("mcl_anvils:anvil_damage_1", anvildef1)
minetest.register_node("mcl_anvils:anvil_damage_2", anvildef2)

minetest.register_craft({
	output = "mcl_anvils:anvil",
	recipe = {
		{ "mcl_core:ironblock", "mcl_core:ironblock", "mcl_core:ironblock" },
		{ "", "mcl_core:iron_ingot", "" },
		{ "mcl_core:iron_ingot", "mcl_core:iron_ingot", "mcl_core:iron_ingot" },
	}
})

dofile(minetest.get_modpath(minetest.get_current_modname()).."/falling_anvil.lua")
