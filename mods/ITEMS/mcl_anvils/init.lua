local S = minetest.get_translator("mcl_anvils")

local MAX_NAME_LENGTH = 35
local MAX_WEAR = 65535
local SAME_TOOL_REPAIR_BOOST = math.ceil(MAX_WEAR * 0.12) -- 12%
local MATERIAL_TOOL_REPAIR_BOOST = {
	math.ceil(MAX_WEAR * 0.25), -- 25%
	math.ceil(MAX_WEAR * 0.5), -- 50%
	math.ceil(MAX_WEAR * 0.75), -- 75%
	MAX_WEAR, -- 100%
}
local NAME_COLOR = "#FFFF4C"

local function get_anvil_formspec(set_name)
	if not set_name then
		set_name = ""
	end
	return "size[9,8.75]"..
	"background[-0.19,-0.25;9.41,9.49;mcl_anvils_inventory.png]"..
	"label[0,4.0;"..minetest.formspec_escape(minetest.colorize("#313131", S("Inventory"))).."]"..
	"list[current_player;main;0,4.5;9,3;9]"..
	mcl_formspec.get_itemslot_bg(0,4.5,9,3)..
	"list[current_player;main;0,7.74;9,1;]"..
	mcl_formspec.get_itemslot_bg(0,7.74,9,1)..
	"list[context;input;1,2.5;1,1;]"..
	mcl_formspec.get_itemslot_bg(1,2.5,1,1)..
	"list[context;input;4,2.5;1,1;1]"..
	mcl_formspec.get_itemslot_bg(4,2.5,1,1)..
	"list[context;output;8,2.5;1,1;]"..
	mcl_formspec.get_itemslot_bg(8,2.5,1,1)..
	"label[3,0.1;"..minetest.formspec_escape(minetest.colorize("#313131", S("Repair and Name"))).."]"..
	"field[3.25,1;4,1;name;;"..minetest.formspec_escape(set_name).."]"..
	"field_close_on_enter[name;false]"..
	"button[7,0.7;2,1;name_button;"..minetest.formspec_escape(S("Set Name")).."]"..
	"listring[context;output]"..
	"listring[current_player;main]"..
	"listring[context;input]"..
	"listring[current_player;main]"
end

-- Given a tool and material stack, returns how many items of the material stack
-- needs to be used up to repair the tool.
local function get_consumed_materials(tool, material)
	local wear = tool:get_wear()
	if wear == 0 then
		return 0
	end
	local health = (MAX_WEAR - wear)
	local matsize = material:get_count()
	local materials_used = 0
	for m=1, math.min(4, matsize) do
		materials_used = materials_used + 1
		if (wear - MATERIAL_TOOL_REPAIR_BOOST[m]) <= 0 then
			break
		end
	end
	return materials_used
end

-- Given 2 input stacks, tells you which is the tool and which is the material.
-- Returns ("tool", input1, input2) if input1 is tool and input2 is material.
-- Returns ("material", input2, input1) if input1 is material and input2 is tool.
-- Returns nil otherwise.
local function distinguish_tool_and_material(input1, input2)
	local def1 = input1:get_definition()
	local def2 = input2:get_definition()
	if def1.type == "tool" and def1._repair_material then
		return "tool", input1, input2
	elseif def2.type == "tool" and def2._repair_material then
		return "material", input2, input1
	else
		return nil
	end
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
	local just_rename = false

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
		if input1:get_name() == input2:get_name() and def1.type == "tool" and (input1:get_wear() > 0 or input2:get_wear() > 0) then
			-- Add tool health together plus a small bonus
			-- TODO: Combine tool enchantments
			local new_wear = calculate_repair(input1:get_wear(), input2:get_wear(), SAME_TOOL_REPAIR_BOOST)
			input1:set_wear(new_wear)
			name_item = input1
			new_output = name_item
		-- Tool + repair item
		else
			-- Any tool can have a repair item. This may be defined in the tool's item definition
			-- as an itemstring in the field `_repair_material`. Only if this field is set, the
			-- tool can be repaired with a material item.
			-- Example: Iron Pickaxe + Iron Ingot. `_repair_material = mcl_core:iron_ingot`

			-- Big repair bonus
			-- TODO: Combine tool enchantments
			local distinguished, tool, material = distinguish_tool_and_material(input1, input2)
			if distinguished then
				local tooldef = tool:get_definition()
				local has_correct_material = false
				if string.sub(tooldef._repair_material, 1, 6) == "group:" then
					has_correct_material = minetest.get_item_group(material:get_name(), string.sub(tooldef._repair_material, 7)) ~= 0
				elseif material:get_name() == tooldef._repair_material then
					has_correct_material = true
				end
				if has_correct_material and tool:get_wear() > 0 then
					local materials_used = get_consumed_materials(tool, material)
					local new_wear = calculate_repair(tool:get_wear(), MAX_WEAR, MATERIAL_TOOL_REPAIR_BOOST[materials_used])
					tool:set_wear(new_wear)
					name_item = tool
					new_output = name_item
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
		if input1:is_empty() then
			name_item = input2
		else
			name_item = input1
		end
		just_rename = true
	else
		new_output = ""
	end

	-- Rename handling
	if name_item then
		-- No renaming allowed with group no_rename=1
		if minetest.get_item_group(name_item:get_name(), "no_rename") == 1 then
			new_output = ""
		else
			if new_name == nil then
				new_name = ""
			end
			local meta = name_item:get_meta()
			local old_name = meta:get_string("name")
			-- Limit name length
			new_name = string.sub(new_name, 1, MAX_NAME_LENGTH)
			-- Don't rename if names are identical
			if new_name ~= old_name then
				-- Rename item
				if new_name == "" then
					-- Empty name
					if name_item:get_definition()._mcl_generate_description then
						-- _mcl_generate_description(itemstack): If defined, set custom item description of itemstack.
						name_item:get_definition()._mcl_generate_description(name_item)
					else
						-- Otherwise, just clear description
						meta:set_string("description", "")
					end
				else
					-- Custom name set. Colorize it!
					-- This makes the name visually different from unnamed items
					meta:set_string("description", minetest.colorize(NAME_COLOR, new_name))
				end
				-- Save the raw name internally, too
				meta:set_string("name", new_name)
				new_output = name_item
			elseif just_rename then
				new_output = ""
			end
		end
	end

	-- Set the new output slot
	if new_output ~= nil then
		inv:set_stack("output", 1, new_output)
	end
end

-- Drop input items of anvil at pos with metadata meta
local function drop_anvil_items(pos, meta)
	local inv = meta:get_inventory()
	for i=1, inv:get_size("input") do
		local stack = inv:get_stack("input", i)
		if not stack:is_empty() then
			local p = {x=pos.x+math.random(0, 10)/10-0.5, y=pos.y, z=pos.z+math.random(0, 10)/10-0.5}
			minetest.add_item(p, stack)
		end
	end
end

-- Damage the anvil by 1 level.
-- Destroy anvil when at highest damage level.
-- Returns true if anvil was destroyed.
local function damage_anvil(pos)
	local node = minetest.get_node(pos)
	local new
	if node.name == "mcl_anvils:anvil" then
		minetest.swap_node(pos, {name="mcl_anvils:anvil_damage_1", param2=node.param2})
		minetest.sound_play(mcl_sounds.node_sound_metal_defaults().dig, {pos=pos, max_hear_distance=16}, true)
		return false
	elseif node.name == "mcl_anvils:anvil_damage_1" then
		minetest.swap_node(pos, {name="mcl_anvils:anvil_damage_2", param2=node.param2})
		minetest.sound_play(mcl_sounds.node_sound_metal_defaults().dig, {pos=pos, max_hear_distance=16}, true)
		return false
	elseif node.name == "mcl_anvils:anvil_damage_2" then
		-- Destroy anvil
		local meta = minetest.get_meta(pos)
		drop_anvil_items(pos, meta)
		minetest.sound_play(mcl_sounds.node_sound_metal_defaults().dug, {pos=pos, max_hear_distance=16}, true)
		minetest.remove_node(pos)
		minetest.check_single_for_falling({x=pos.x, y=pos.y+1, z=pos.z})
		return true
	end
end

-- Roll a virtual dice and damage anvil at a low chance.
local function damage_anvil_by_using(pos)
	local r = math.random(1, 100)
	-- 12% chance
	if r <= 12 then
		return damage_anvil(pos)
	else
		return false
	end
end

local function damage_anvil_by_falling(pos, distance)
	local chance
	local r = math.random(1, 100)
	if distance > 1 then
		if r <= (5*distance) then
			damage_anvil(pos)
		end
	end
end

local anvildef = {
	groups = {pickaxey=1, falling_node=1, falling_node_damage=1, crush_after_fall=1, deco_block=1, anvil=1},
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
	_mcl_blast_resistance = 1200,
	_mcl_hardness = 5,
	_mcl_after_falling = damage_anvil_by_falling,

	after_dig_node = function(pos, oldnode, oldmetadata, digger)
		local meta = minetest.get_meta(pos) 
		local meta2 = meta 
		meta:from_table(oldmetadata)
		drop_anvil_items(pos, meta)
		meta:from_table(meta2:to_table())
	end,
	allow_metadata_inventory_take = function(pos, listname, index, stack, player)
		local name = player:get_player_name()
		if minetest.is_protected(pos, name) then
			minetest.record_protection_violation(pos, name)
			return 0
		else
			return stack:get_count()
		end
	end,
	allow_metadata_inventory_put = function(pos, listname, index, stack, player)
		local name = player:get_player_name()
		if minetest.is_protected(pos, name) then
			minetest.record_protection_violation(pos, name)
			return 0
		elseif listname == "output" then
			return 0
		else
			return stack:get_count()
		end
	end,
	allow_metadata_inventory_move = function(pos, from_list, from_index, to_list, to_index, count, player)
		local name = player:get_player_name()
		if minetest.is_protected(pos, name) then
			minetest.record_protection_violation(pos, name)
			return 0
		elseif to_list == "output" then
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
			for i=1, inv:get_size("input") do
				if i ~= to_index then
					local istack = inv:get_stack("input", i)
					istack:set_count(math.max(0, istack:get_count() - count))
					inv:set_stack("input", i, istack)
				end
			end
		end
		update_anvil_slots(meta)

		if from_list == "output" then
			local destroyed = damage_anvil_by_using(pos)
			-- Close formspec if anvil was destroyed
			if destroyed then
				--[[ Closing the formspec w/ emptyformname is discouraged. But this is justified
				because node formspecs seem to only have an empty formname in MT 0.4.16.
				Also, sice this is on_metadata_inventory_take, we KNOW which formspec has
				been opened by the player. So this should be safe nonetheless.
				TODO: Update this line when node formspecs get proper identifiers in Minetest. ]]
				minetest.close_formspec(player:get_player_name(), "")
			end
		end
	end,
	on_metadata_inventory_take = function(pos, listname, index, stack, player)
		local meta = minetest.get_meta(pos)
		if listname == "output" then
			local inv = meta:get_inventory()
			local input1 = inv:get_stack("input", 1)
			local input2 = inv:get_stack("input", 2)
			-- Both slots occupied?
			if not input1:is_empty() and not input2:is_empty() then
				-- Take as many items as needed
				local distinguished, tool, material = distinguish_tool_and_material(input1, input2)
				if distinguished then
					-- Tool + material: Take tool and as many materials as needed
					local materials_used = get_consumed_materials(tool, material)
					material:set_count(material:get_count() - materials_used)
					tool:take_item()
					if distinguished == "tool" then
						input1, input2 = tool, material
					else
						input1, input2 = material, tool
					end
					inv:set_stack("input", 1, input1)
					inv:set_stack("input", 2, input2)
				else
					-- Else take 1 item from each stack
					input1:take_item()
					input2:take_item()
					inv:set_stack("input", 1, input1)
					inv:set_stack("input", 2, input2)
				end
			else
				-- Otherwise: Rename mode. Remove the same amount of items from input
				-- as has been taken from output
				if not input1:is_empty() then
					input1:set_count(math.max(0, input1:get_count() - stack:get_count()))
					inv:set_stack("input", 1, input1)
				end
				if not input2:is_empty() then
					input2:set_count(math.max(0, input2:get_count() - stack:get_count()))
					inv:set_stack("input", 2, input2)
				end
			end
			local destroyed = damage_anvil_by_using(pos)
			-- Close formspec if anvil was destroyed
			if destroyed then
				-- See above for justification.
				minetest.close_formspec(player:get_player_name(), "")
			end
		elseif listname == "input" then
			update_anvil_slots(meta)
		end
	end,
	on_construct = function(pos)
		local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()
		inv:set_size("input", 2)
		inv:set_size("output", 1)
		local form = get_anvil_formspec()
		meta:set_string("formspec", form)
	end,
	on_receive_fields = function(pos, formname, fields, sender)
		local sender_name = sender:get_player_name()
		if minetest.is_protected(pos, sender_name) then
			minetest.record_protection_violation(pos, sender_name)
			return
		end
		if fields.name_button or fields.name then
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
anvildef0.description = S("Anvil")
anvildef0._doc_items_longdesc =
S("The anvil allows you to repair tools and armor, and to give names to items. It has a limited durability, however. Don't let it fall on your head, it could be quite painful!")
anvildef0._doc_items_usagehelp =
S("To use an anvil, rightclick it. An anvil has 2 input slots (on the left) and one output slot.").."\n"..
S("To rename items, put an item stack in one of the item slots while keeping the other input slot empty. Type in a name, hit enter or “Set Name”, then take the renamed item from the output slot.").."\n"..
S("There are two possibilities to repair tools (and armor):").."\n"..
S("• Tool + Tool: Place two tools of the same type in the input slots. The “health” of the repaired tool is the sum of the “health” of both input tools, plus a 12% bonus.").."\n"..
S("• Tool + Material: Some tools can also be repaired by combining them with an item that it's made of. For example, iron pickaxes can be repaired with iron ingots. This repairs the tool by 25%.").."\n"..
S("Armor counts as a tool. It is possible to repair and rename a tool in a single step.").."\n\n"..
S("The anvil has limited durability and 3 damage levels: undamaged, slightly damaged and very damaged. Each time you repair or rename something, there is a 12% chance the anvil gets damaged. Anvils also have a chance of being damaged when they fall by more than 1 block. If a very damaged anvil is damaged again, it is destroyed.")
anvildef0._tt_help = S("Repair and rename items")

local anvildef1 = table.copy(anvildef)
anvildef1.description = S("Slightly Damaged Anvil")
anvildef1._doc_items_create_entry = false
anvildef1.groups.not_in_creative_inventory = 1
anvildef1.groups.anvil = 2
anvildef1._doc_items_create_entry = false
anvildef1.tiles = {"mcl_anvils_anvil_top_damaged_1.png^[transformR90", "mcl_anvils_anvil_base.png", "mcl_anvils_anvil_side.png"}

local anvildef2 = table.copy(anvildef)
anvildef2.description = S("Very Damaged Anvil")
anvildef2._doc_items_create_entry = false
anvildef2.groups.not_in_creative_inventory = 1
anvildef2.groups.anvil = 3
anvildef2._doc_items_create_entry = false
anvildef2.tiles = {"mcl_anvils_anvil_top_damaged_2.png^[transformR90", "mcl_anvils_anvil_base.png", "mcl_anvils_anvil_side.png"}

minetest.register_node("mcl_anvils:anvil", anvildef0)
minetest.register_node("mcl_anvils:anvil_damage_1", anvildef1)
minetest.register_node("mcl_anvils:anvil_damage_2", anvildef2)

if minetest.get_modpath("mcl_core") then
	minetest.register_craft({
		output = "mcl_anvils:anvil",
		recipe = {
			{ "mcl_core:ironblock", "mcl_core:ironblock", "mcl_core:ironblock" },
			{ "", "mcl_core:iron_ingot", "" },
			{ "mcl_core:iron_ingot", "mcl_core:iron_ingot", "mcl_core:iron_ingot" },
		}
	})
end

if minetest.get_modpath("doc") then
	doc.add_entry_alias("nodes", "mcl_anvils:anvil", "nodes", "mcl_anvils:anvil_damage_1")
	doc.add_entry_alias("nodes", "mcl_anvils:anvil", "nodes", "mcl_anvils:anvil_damage_2")
end

-- Legacy
minetest.register_lbm({
	label = "Update anvil formspecs (0.60.0",
	name = "mcl_anvils:update_formspec_0_60_0",
	nodenames = { "group:anvil" },
	run_at_every_load = false,
	action = function(pos, node)
		local meta = minetest.get_meta(pos)
		local set_name = meta:get_string("set_name")
		meta:set_string("formspec", get_anvil_formspec(set_name))
	end,
})
