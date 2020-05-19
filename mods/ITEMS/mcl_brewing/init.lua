local S = minetest.get_translator("mcl_brewing")

local MAX_NAME_LENGTH = 30
local MAX_WEAR = 65535
local SAME_TOOL_REPAIR_BOOST = math.ceil(MAX_WEAR * 0.12) -- 12%
local MATERIAL_TOOL_REPAIR_BOOST = {
	math.ceil(MAX_WEAR * 0.25), -- 25%
	math.ceil(MAX_WEAR * 0.5), -- 50%
	math.ceil(MAX_WEAR * 0.75), -- 75%
	MAX_WEAR, -- 100%
}
local NAME_COLOR = "#FFFF4C"

local function get_brewing_stand_formspec()

	return "size[9,8.75]"..
	"background[-0.19,-0.25;9.41,9.49;mcl_brewing_inventory.png]"..
	"label[0,4.0;"..minetest.formspec_escape(minetest.colorize("#313131", S("Inventory"))).."]"..
	"list[current_player;main;0,4.5;9,3;9]"..
	mcl_formspec.get_itemslot_bg(0,4.5,9,3)..
	"list[current_player;main;0,7.75;9,1;]"..
	mcl_formspec.get_itemslot_bg(0,7.75,9,1)..
	"list[current_name;fuel;0.5,1.75;1,1;]"..
	mcl_formspec.get_itemslot_bg(0.5,1.75,1,1).."image[0.5,1.75;1,1;mcl_brewing_fuel_bg.png]"..
	"list[current_name;input;2.75,0.5;1,1;]"..
	mcl_formspec.get_itemslot_bg(2.75,0.5,1,1)..
	"list[context;stand;4.5,2.5;1,1;]"..
	mcl_formspec.get_itemslot_bg(4.5,2.5,1,1).."image[4.5,2.5;1,1;mcl_brewing_bottle_bg.png]"..
	"list[context;stand;6,2.8;1,1;1]"..
	mcl_formspec.get_itemslot_bg(6,2.8,1,1).."image[6,2.8;1,1;mcl_brewing_bottle_bg.png]"..
	"list[context;stand;7.5,2.5;1,1;2]"..
	mcl_formspec.get_itemslot_bg(7.5,2.5,1,1).."image[7.5,2.5;1,1;mcl_brewing_bottle_bg.png]"..

	"listring[current_player;main]"..
	"listring[current_name;fuel]"..
	"listring[current_name;input]"..
	-- "listring[context;stand1]"..
	-- "listring[context;stand2]"..
	"listring[context;stand]"
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



-- Drop input items of brewing_stand at pos with metadata meta
local function drop_brewing_stand_items(pos, meta)

	local inv = meta:get_inventory()

	local stack = inv:get_stack("fuel", 1)
	if not stack:is_empty() then
		local p = {x=pos.x+math.random(0, 10)/10-0.5, y=pos.y, z=pos.z+math.random(0, 10)/10-0.5}
		minetest.add_item(p, stack)
	end

	local stack = inv:get_stack("input", 1)
	if not stack:is_empty() then
		local p = {x=pos.x+math.random(0, 10)/10-0.5, y=pos.y, z=pos.z+math.random(0, 10)/10-0.5}
		minetest.add_item(p, stack)
	end

	for i=1, inv:get_size("stand") do
		local stack = inv:get_stack("stand", i)
		if not stack:is_empty() then
			local p = {x=pos.x+math.random(0, 10)/10-0.5, y=pos.y, z=pos.z+math.random(0, 10)/10-0.5}
			minetest.add_item(p, stack)
		end
	end
end




local brewing_standdef = {
	groups = {pickaxey=1, falling_node=1, falling_node_damage=1, crush_after_fall=1, deco_block=1, brewing_stand=1},
	tiles = {"mcl_brewing_top.png", 	--top
					 "mcl_brewing_base.png", 	--bottom
					 "mcl_brewing_side.png", 	--right
				 	 "mcl_brewing_side.png", 	--left
					 "mcl_brewing_side.png", 	--back
				 	 "mcl_brewing_side.png^[transformFX"}, --front
	paramtype = "light",
	sunlight_propagates = true,
	is_ground_content = false,
	paramtype2 = "facedir",
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
		--TODO: add bottle hangers
			{-1/16, -5/16, -1/16, 1/16, 8/16, 1/16}, -- heat plume
			{ 2/16, -8/16, -8/16, 8/16, -6/16, -2/16}, -- base
			{-8/16, -8/16, -8/16, -2/16, -6/16, -2/16}, -- base
			{-3/16, -8/16, 2/16, 3/16, -6/16, 8/16}, -- base

			{-7/16, -6/16 ,-7/16 , -6/16,  1/16, -6/16 }, -- bottle 1
			{-6/16, -6/16 ,-6/16 , -5/16,  3/16, -5/16 }, -- bottle 1
			{-5/16, -6/16 ,-5/16 , -4/16,  3/16, -4/16 }, -- bottle 1
			{-4/16, -6/16 ,-4/16 , -3/16,  3/16, -3/16 }, -- bottle 1
			{-3/16, -6/16 ,-3/16 , -2/16,  1/16, -2/16 }, -- bottle 1

			{-5/16, 3/16 ,-5/16 , -4/16,  7/16, -4/16 }, -- line 1
			{-4/16, 6/16 ,-4/16 , -3/16,  8/16, -3/16 }, -- line 1
			{-3/16, 7/16 ,-3/16 , -2/16,  8/16, -2/16 }, -- line 1
			{-2/16, 7/16 ,-2/16 , -1/16,  8/16, -1/16 }, -- line 1


			{7/16, -6/16 ,-7/16 , 6/16,  1/16, -6/16 }, -- bottle 2
			{6/16, -6/16 ,-6/16 , 5/16,  3/16, -5/16 }, -- bottle 2
			{5/16, -6/16 ,-5/16 , 4/16,  3/16, -4/16 }, -- bottle 2
			{4/16, -6/16 ,-4/16 , 3/16,  3/16, -3/16 }, -- bottle 2
			{3/16, -6/16 ,-3/16 , 2/16,  1/16, -2/16 }, -- bottle 2

			{5/16, 3/16 ,-5/16 ,4/16,  7/16, -4/16 }, -- line 2
			{4/16, 6/16 ,-4/16 ,3/16,  8/16, -3/16 }, -- line 2
			{3/16, 7/16 ,-3/16 ,2/16,  8/16, -2/16 }, -- line 2
			{2/16, 7/16 ,-2/16 ,1/16,  8/16, -1/16 }, -- line 2

			{0/16, -6/16 , 2/16 , 1/16, 1/16, 7/16 }, -- bottle 3
			{0/16, 1/16 , 3/16 , 1/16,  3/16, 6/16 }, -- bottle 3

			{0/16, 7/16 , 1/16 , 1/16, 8/16, 3/16 }, -- line 3
			{0/16, 6/16 , 3/16 , 1/16, 7/16, 5/16 }, -- line 3
			{0/16, 3/16 , 4/16 , 1/16, 6/16, 5/16 }, -- line 3
		}
	},
	sounds = mcl_sounds.node_sound_metal_defaults(),
	_mcl_blast_resistance = 1200,
	_mcl_hardness = 5,
	_mcl_after_falling = damage_brewing_stand_by_falling,

	after_dig_node = function(pos, oldnode, oldmetadata, digger)
		local meta = minetest.get_meta(pos)
		local meta2 = meta
		meta:from_table(oldmetadata)
		drop_brewing_stand_items(pos, meta)
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
		else
			return stack:get_count()
		end
	end,
	-- allow_metadata_inventory_move = function(pos, from_list, from_index, to_list, to_index, count, player)
	-- 	local name = player:get_player_name()
	-- 	if minetest.is_protected(pos, name) then
	-- 		minetest.record_protection_violation(pos, name)
	-- 		return 0
	-- 	end
	-- end,

	on_metadata_inventory_put = function(pos, listname, index, stack, player)
		local meta = minetest.get_meta(pos)
		minetest.get_node_timer(pos):start(1.0)
		--some code here to enforce only potions getting placed on stands
	end,

	on_metadata_inventory_take = function(pos, listname, index, stack, player)
		local meta = minetest.get_meta(pos)
	end,

	on_construct = function(pos)
		local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()
		inv:set_size("input", 1)
		inv:set_size("fuel", 1)
		inv:set_size("stand", 3)
		-- inv:set_size("stand2", 1)
		-- inv:set_size("stand3", 1)
		local form = get_brewing_stand_formspec()
		meta:set_string("formspec", form)
	end,

	on_receive_fields = function(pos, formname, fields, sender)
		local sender_name = sender:get_player_name()
		if minetest.is_protected(pos, sender_name) then
			minetest.record_protection_violation(pos, sender_name)
			return
		end

	end,
}
if minetest.get_modpath("screwdriver") then
	brewing_standdef.on_rotate = screwdriver.rotate_simple
end

brewing_standdef.description = S("Brewing Stand")
brewing_standdef._doc_items_longdesc = S("The stand allows you to brew potions!")
brewing_standdef._doc_items_usagehelp =
S("To use an brewing_stand, rightclick it. An brewing_stand has 2 input slots (on the left) and one output slot.").."\n"..
S("To rename items, put an item stack in one of the item slots while keeping the other input slot empty. Type in a name, hit enter or “Set Name”, then take the renamed item from the output slot.").."\n"..
S("There are two possibilities to repair tools (and armor):").."\n"..
S("• Tool + Tool: Place two tools of the same type in the input slots. The “health” of the repaired tool is the sum of the “health” of both input tools, plus a 12% bonus.").."\n"..
S("• Tool + Material: Some tools can also be repaired by combining them with an item that it's made of. For example, iron pickaxes can be repaired with iron ingots. This repairs the tool by 25%.").."\n"..
S("Armor counts as a tool. It is possible to repair and rename a tool in a single step.").."\n\n"..
S("The brewing_stand has limited durability and 3 damage levels: undamaged, slightly damaged and very damaged. Each time you repair or rename something, there is a 12% chance the brewing_stand gets damaged. brewing_stand also have a chance of being damaged when they fall by more than 1 block. If a very damaged brewing_stand is damaged again, it is destroyed.")
brewing_standdef._tt_help = S("Repair and rename items")

minetest.register_node("mcl_brewing:stand", brewing_standdef)

if minetest.get_modpath("mcl_core") then
	minetest.register_craft({
		output = "mcl_brewing:stand",
		recipe = {
			{ "", "mcl_mobitems:blaze_rod", "" },
			{ "mcl_core:stone_smooth", "mcl_core:stone_smooth", "mcl_core:stone_smooth" },
		}
	})
end


-- Legacy
minetest.register_lbm({
	label = "Update brewing_stand formspecs (0.60.0",
	name = "mcl_brewing:update_formspec_0_60_0",
	--nodenames = { "group:brewing_stand" },
	run_at_every_load = false,
	action = function(pos, node)
		local meta = minetest.get_meta(pos)
		meta:set_string("formspec", get_brewing_stand_formspec())
	end,
})
