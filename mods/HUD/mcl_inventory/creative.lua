-- Original code (circa 2013) released under WTFPL License by BlockMen
-- Code added for item priority system & major restructuring for performance optimizations by Thomas Conway (c.2025)
local mod_name = minetest.get_current_modname()
local S = minetest.get_translator(mod_name)
local F = minetest.formspec_escape
local C = minetest.colorize

-- Prepare player info table
---@type table<string, {page: string, filter: string, start_i: integer, inv_size: integer}>
local players = {}

-- Containing all the items for each Creative Mode tab
---@type table<string, string[]>
local inventory_lists = {}

-- Create tables
---@type string[]
local builtin_filter_ids = {
	"blocks", "deco", "redstone", "rail", "food", "tools",
	"combat", "mobs", "brew", "matr", "misc", "all"
}

for _, f in ipairs(builtin_filter_ids) do
	inventory_lists[f] = {}
end
--- START of item sorting system code by Thomas Conway
--- Define mod family priorities for each category
--- NOTE: priority is in descending order for technical reasons (non-numbered mod families at the end are 0) Higher numbered mod families appear first in tab. You can use decimal places too not just integers.
local mod_family_priorities = {
	blocks = {
		["mcl_core"] = {
			mod_priority = 10,  -- Mod family priority
			items = {
				["mcl_core:dirt_with_grass"] = 10,
				["mcl_core:cobble"] = 9,
				["mcl_core:diorite"] = 9,
				["mcl_core:andersite"] = 9,
				["mcl_core:granite"] = 9,
				["mcl_core:gravel"] = 8,
				["mcl_core:sand"] = 8,
				["mcl_core:obsidian"] = 7,
				["mcl_core:ironblock"] = 6.9,
				["mcl_core:goldblock"] = 6.8,
				["mcl_core:diamondblock"] = 6.7,
				["mcl_core:emeraldblock"] = 6.6,
			}
		},
		["vl_hollow_logs"] = 9,
		["mcl_villages"] = 8,
		["mcl_wool"] = 7,
	},

	deco = {
		["mcl_crafting_table"] = 13,
		["mcl_torches"] = 12,
		["mcl_blackstone"] = 11,
		["mcl_lanterns"] = 10,
		["mcl_anvils"] = 9.9,
		["mcl_cauldrons"] = 9.8,
		["mcl_mobspawners"] = 9.8,
		["mcl_portals"] = 9.8,
		["mcl_composters"] = 9.78,
		["mcl_bells"] = 9.75,
		["mcl_beehives"] = 9.7,
		["mcl_honey"] = 9.6,
		["mcl_armor_stand"] = 9,
		["mcl_books"] = 9,
		["mcl_jukebox"] = 9,
		["mcl_itemframes"] = 9,
		["mcl_enchanting"] = 8.9,
		["mcl_cartography_table"] = 8.8,
		["mcl_fletching_table"] = 8.8,
		["mcl_loom"] = 8.8,
		["mcl_grindstone"] = 8.8,
		["mcl_stonecutter"] = 8.8,
		["mcl_smithing_table"] = 8.8,
		["mcl_furnaces"] = 7.9,
		["mcl_blast_furnace"] = 7.8,
		["mcl_smoker"] = 7.7,
		["mcl_barrels"] = 7.1,
		["mcl_chests"] = {
			mod_priority = 7,
			items = {
				["mcl_chests:chest"] = 10,
				["mcl_chests:ender_chest"] = 10,
				["mcl_chests:trapped_chest"] = 10,
			}
		},
		["mcl_wool"] = 6.9,
		["mcl_beds"] = 6.8,
		["mcl_banners"] = 6.7,
		["mcl_signs"] = 6,
		["xpanes"] = 4,
		["mcl_amethyst"] = {
			mod_priority = 3.8,
			items = {
				["mcl_amethyst:tinted_glass"] = 10,
			}
		},
		["mcl_heads"] = 3,
		["mcl_end"] = 3,
		["mcl_flowerpots"] = 2.1,
		["mcl_flowers"] = 2,
		["mcl_core"] = 1.9,
		["mcl_cherry_blossom"] = 1.8,
		["mcl_fences"] = 1,
		["mclx_fences"] = 1,
		["mcl_walls"] = 1,
	},

	all = {
		["doc_identifier"] = 2,
		["mcl_core"] = 1,
	},

	matr = {
		["mcl_copper"] = 11,
		["mcl_core"] = {
			mod_priority = 10,
			items = {
				["mcl_core:iron_ingot"] = 10,
				["mcl_core:iron_nugget"] = 9.9,
				["mcl_core:gold_ingot"] = 9.8,
				["mcl_core:gold_nugget"] = 9.7,
				["mcl_core:diamond"] = 9.6,
				["mcl_core:emerald"] = 9.5,
			}
		},
		["mcl_dye"] = -1,
	},

	redstone = {
		["mesecons"] = 13,
		["mcl_hoppers"] = 12.5,
		["mesecons_torch"] = 12,
		["mesecons_walllever"] = 11,
		["mcl_comparators"] = 10,
		["mesecons_delayer"] = 10,
		["mesecons_solarpanel"] = 10,
		["mesecons_pistons"] = 9,
		["mcl_observers"] = 9,
		["mcl_dispensers"] = 8,
		["mcl_droppers"] = 8,
		["mcl_tnt"] = 8,
		["mcl_chests"] = 8,
		["mesecons_noteblock"] = 7,
		["mcl_lightning_rods"] = 7,
		["mcl_target"] = 7,
		["mesecons_commandblock"] = 7,
		["mcl_bells"] = 7,
		["mcl_minecarts"] = 7,
		["mesecons_lightstone"] = 6,
		["mesecons_button"] = 5,
		["mesecons_pressureplates"] = 5,
	},

	rail = {
		["mcl_minecarts"] = {
			mod_priority = 3,
			items = {
				["mcl_minecarts:rail_v2"] = 9.99,
				["mcl_minecarts:golden_rail_v2"] = 9.9,
				["mcl_minecarts:activator_rail_v2"] = 9.8,
				["mcl_minecarts:detector_rail_v2"] = 9.7,
			}
		},
		["mcl_boats"] = 2,
		["mcl_mobitems"] = 1,
	},

	food = {
		["mesecons"] = 2,
		["mcl_core"] = 1,
	},

	tools = {
		["mcl_tools"] = 4, -- axe pickaxe shovel
		["mcl_farming"] = 3, -- hoe
		["vl_deepslate_tools"] = 2.9,
		["mcl_shepherd"] = 2.2, -- shepherd staff
		["mcl_fishing"] = 2.1, -- fishing rod
		["mcl_fire"] = 2.05, -- flint and steel
		["mcl_clock"] = 2,
		["mcl_compass"] = 1.9,
		["doc_identifier"] = 1,
	},

	combat = {
		["mcl_tools"] = 10,     --swords
		["vl_weaponry"] = 9,    --hammer spear
		["vl_deepslate_tools"] = 8.9,
		["mcl_shepherd"] = 8,   --shepherd staff
		["mcl_shields"] = 7,
		["mcl_totems"] = 6,
		["mcl_armor"] = 5,   -- armor
		["mcl_mobitems"] = 4,   --horse armor
	},

	mobs = {
		["mesecons"] = 2,
		["mcl_core"] = 1,
	},

	brew = {
		["mcl_brewing"] = 2,
		["mcl_core"] = 1.2,
		["mcl_mobitems"] = 1.1,
		["mesecons"] = 1,
		["mcl_nether"] = 0.9,
		["mcl_fishing"] = 0.3,
		["mcl_farming"] = 0.2,
		["mcl_potions"] = {
			mod_priority = 0.1,
			items = {
				["mcl_potions:speckled_melon"] = 10,
				["mcl_potions:fermented_spider_eye"] = 9,
				["mcl_potions:river_water"] = 8,
				["mcl_potions:water"] = 7.3,
				["mcl_potions:water_splash"] = 7.2,
				["mcl_potions:water_lingering"] = 7.1,
				["mcl_potions:awkward"] = 6.3,
				["mcl_potions:awkward_splash"] = 6.2,
				["mcl_potions:awkward_lingering"] = 6.1,
				["mcl_potions:thick"] = 5.3,
				["mcl_potions:thick_splash"] = 5.2,
				["mcl_potions:thick_lingering"] = 5.1,
				["mcl_potions:mundane"] = 4.3,
				["mcl_potions:mundane_splash"] = 4.2,
				["mcl_potions:mundane_lingering"] = 4.1,
			}
		},
	},

	misc = {
		["mcl_buckets"] = 20,
		["mcl_jukebox"] = 19,
		["mcl_beacons"] = 18,
		["mcl_books"] = 17,
		["mcl_end"] = 17,
		["mcl_campfires"] = 16,
		["mcl_compass"] = 15,
		["mcl_paintings"] = 14,
		["mcl_experience"] = 13,
		["mcl_blackstone"] = 12,
		["mcl_bamboo"] = 11,
		["mcl_spyglass"] = 10,
		["mcl_stonecutter"] = 9,
		["mcl_lectern"] = 8,
		["mcl_maps"] = 7,
		["mcl_beds"] = 6,
	},
}

--- Temporary storage for items with their priorities
local temp_inventory_lists = {}
for _, category in ipairs(builtin_filter_ids) do
	temp_inventory_lists[category] = {}
end

--- Helper function to get priority for an item in a category
---@param category string
---@param item_name string
---@return integer priority
local function get_item_priority(category, item_name)
	local mod_family = item_name:match("^(.-):")

	-- Check if this category has item-specific priorities
	if mod_family_priorities[category] and mod_family_priorities[category][mod_family] then
		local mod_data = mod_family_priorities[category][mod_family]

		-- Handle new style priority (with item-level granularity)
		if type(mod_data) == "table" and mod_data.items then
			return mod_data.items[item_name] or 0
		-- Handle old style priority (mod-level only)
		else
			return 0
		end
	end

	return 0
end

--- Helper function to get mod priority for a mod family in a category
---@param category string
---@param mod_family string|nil
---@return integer priority
local function get_mod_priority(category, mod_family)
	if mod_family and mod_family_priorities[category] then
		local mod_data = mod_family_priorities[category][mod_family]

		-- Handle new style priority (with item-level granularity)
		if type(mod_data) == "table" then
			return mod_data.mod_priority or 0
		-- Handle old style priority (mod-level only)
		else
			return mod_data or 0
		end
	end
	return 0
end

--- Process fireworks variants efficiently
---@param name string
---@param def mt.ItemDef
---@param mod_family string
---@param category string
local function process_fireworks(name, def, mod_family, category)
	if not def._vl_fireworks_std_durs_forces then return end

	local mod_priority = get_mod_priority(category, mod_family)
	local item_priority = get_item_priority(category, name)
	local combined_priority = mod_priority * 100 + item_priority
	local generic = core.serialize({{fn="generic"}})

	for _, tbl in ipairs(def._vl_fireworks_std_durs_forces) do
		local stack = ItemStack(name)
		local meta = stack:get_meta()
		meta:set_float("vl_fireworks:duration", tbl[1])
		meta:set_int("vl_fireworks:force", tbl[2])
		local item_str = stack:to_string()
		table.insert(temp_inventory_lists["misc"], {name = item_str, priority = combined_priority})
		table.insert(temp_inventory_lists["all"], {name = item_str, priority = combined_priority})

		meta:set_string("vl_fireworks:stars", generic)
		item_str = stack:to_string()
		table.insert(temp_inventory_lists["misc"], {name = item_str, priority = combined_priority})
		table.insert(temp_inventory_lists["all"], {name = item_str, priority = combined_priority})
	end
end

--- Process potion variants efficiently
---@param name string
---@param def mt.ItemDef
---@param mod_family string
local function process_potions(name, def, mod_family)
	if def.groups._mcl_potion ~= 1 then return end

	-- Get priorities for base item
	local mod_priority = get_mod_priority("brew", mod_family)
	local base_item_priority = get_item_priority("brew", name)
	local base_combined_priority = mod_priority * 100 + base_item_priority

	local variants = {}
	if def.has_potent then
		table.insert(variants, {
			key = "mcl_potions:potion_potent",
			value = def._default_potent_level - 1
		})
	end
	if def.has_plus then
		table.insert(variants, {
			key = "mcl_potions:potion_plus",
			value = def._default_extend_level
		})
	end

	local all_priority = get_mod_priority("all", mod_family)

	for _, variant in ipairs(variants) do
		local stack = ItemStack(name)
		stack:get_meta():set_int(variant.key, variant.value)
		local item_str = stack:to_string()

		table.insert(temp_inventory_lists["brew"], {name = item_str, priority = base_combined_priority})
		table.insert(temp_inventory_lists["all"], {name = item_str, priority = all_priority})
	end
end

--- Process enchanted books from enchantment definitions
local function process_enchanted_books()
	for ench, def in pairs(mcl_enchanting.enchantments) do
		local stack = mcl_enchanting.enchant(ItemStack("mcl_enchanting:book_enchanted"), ench, def.max_level)
		local item_str = stack:to_string()

		if def.inv_tool_tab then
			table.insert(inventory_lists["tools"], item_str)
		end
		if def.inv_combat_tab then
			table.insert(inventory_lists["combat"], item_str)
		end
		table.insert(inventory_lists["all"], item_str)
	end
end

minetest.register_on_mods_loaded(function()
	-- Local references for frequently accessed tables
	local reg_items = minetest.registered_items

	-- Precompute group checks
	local function is_redstone(def)
		return def.mesecons or def.groups.mesecon or
				def.groups.mesecon_conductor_craftable or
				def.groups.mesecon_effector_off
	end

	local function is_tool(def)
		return def.groups.tool or (def.tool_capabilities and def.tool_capabilities.damage_groups == nil)
	end

	local function is_weapon_or_armor(def)
		return def.groups.weapon or def.groups.weapon_ranged or
				def.groups.ammo or def.groups.combat_item or
				((def.groups.armor_head or def.groups.armor_torso or
				def.groups.armor_legs or def.groups.armor_feet or
				def.groups.horse_armor) and def.groups.non_combat_armor ~= 1)
	end

	-- Process registered items
	for name, def in pairs(reg_items) do
		local groups = def.groups
		local not_in_creative = groups.not_in_creative_inventory or 0
		local has_description = def.description and def.description ~= ""

		if not_in_creative == 0 and has_description then
			local mod_family = name:match("^(.-):")
			local nonmisc = false
			local all_handled = false
			local mod_priority, item_priority, combined_priority

			-- Precompute category flags
			local is_redstone_item = is_redstone(def)
			local is_tool_item = is_tool(def)
			local is_combat_item = is_weapon_or_armor(def)

			-- Category handlers
			if groups.building_block then
				mod_priority = get_mod_priority("blocks", mod_family)
				item_priority = get_item_priority("blocks", name)
				combined_priority = mod_priority * 100 + item_priority
				table.insert(temp_inventory_lists["blocks"], {name = name, priority = combined_priority})
				nonmisc = true
			end
			if groups.deco_block then
				mod_priority = get_mod_priority("deco", mod_family)
				item_priority = get_item_priority("deco", name)
				combined_priority = mod_priority * 100 + item_priority
				table.insert(temp_inventory_lists["deco"], {name = name, priority = combined_priority})
				nonmisc = true
			end
			if is_redstone_item then
				mod_priority = get_mod_priority("redstone", mod_family)
				item_priority = get_item_priority("redstone", name)
				combined_priority = mod_priority * 100 + item_priority
				table.insert(temp_inventory_lists["redstone"], {name = name, priority = combined_priority})
				nonmisc = true
			end
			if groups.transport then
				mod_priority = get_mod_priority("rail", mod_family)
				item_priority = get_item_priority("rail", name)
				combined_priority = mod_priority * 100 + item_priority
				table.insert(temp_inventory_lists["rail"], {name = name, priority = combined_priority})
				nonmisc = true
			end
			if (groups.food and not groups.brewitem) or groups.eatable then
				mod_priority = get_mod_priority("food", mod_family)
				item_priority = get_item_priority("food", name)
				combined_priority = mod_priority * 100 + item_priority
				table.insert(temp_inventory_lists["food"], {name = name, priority = combined_priority})
				nonmisc = true
			end
			if is_tool_item then
				mod_priority = get_mod_priority("tools", mod_family)
				item_priority = get_item_priority("tools", name)
				combined_priority = mod_priority * 100 + item_priority
				table.insert(temp_inventory_lists["tools"], {name = name, priority = combined_priority})
				nonmisc = true
			end
			if is_combat_item then
				mod_priority = get_mod_priority("combat", mod_family)
				item_priority = get_item_priority("combat", name)
				combined_priority = mod_priority * 100 + item_priority
				table.insert(temp_inventory_lists["combat"], {name = name, priority = combined_priority})
				nonmisc = true
			end
			if groups.spawn_egg == 1 then
				mod_priority = get_mod_priority("mobs", mod_family)
				item_priority = get_item_priority("mobs", name)
				combined_priority = mod_priority * 100 + item_priority
				table.insert(temp_inventory_lists["mobs"], {name = name, priority = combined_priority})
				nonmisc = true
			end
			if groups.brewitem then
				mod_priority = get_mod_priority("brew", mod_family)
				item_priority = get_item_priority("brew", name)
				combined_priority = mod_priority * 100 + item_priority
				table.insert(temp_inventory_lists["brew"], {name = name, priority = combined_priority})
				nonmisc = true
			end
			if groups.craftitem then
				mod_priority = get_mod_priority("matr", mod_family)
				item_priority = get_item_priority("matr", name)
				combined_priority = mod_priority * 100 + item_priority
				table.insert(temp_inventory_lists["matr"], {name = name, priority = combined_priority})
				nonmisc = true
			end

			-- Special item handling
			if def._vl_fireworks_std_durs_forces then
				process_fireworks(name, def, mod_family, "misc")
				nonmisc = true
				all_handled = true
			end

			-- Potion handling
			if groups._mcl_potion == 1 then
				process_potions(name, def, mod_family)
			end

			-- Misc category for uncategorized items
			if not nonmisc then
				mod_priority = get_mod_priority("misc", mod_family)
				item_priority = get_item_priority("misc", name)
				combined_priority = mod_priority * 100 + item_priority
				table.insert(temp_inventory_lists["misc"], {name = name, priority = combined_priority})
			end

			-- Add to 'all' category if not handled by special cases
			if not all_handled then
				mod_priority = get_mod_priority("all", mod_family)
				item_priority = get_item_priority("all", name)
				combined_priority = mod_priority * 100 + item_priority
				table.insert(temp_inventory_lists["all"], {name = name, priority = combined_priority})
			end
		end
	end

	-- Sort and populate inventory_lists
	for category, t in pairs(temp_inventory_lists) do
		table.sort(t, function(a, b)
			return a.priority > b.priority or (a.priority == b.priority and a.name < b.name)
		end)

		-- Convert to final item list
		for _, entry in ipairs(t) do
			-- Process enchanted books immediately
			if entry.name:find("mcl_enchanting:book_enchanted", 1, true) then
				local _, enchantment, level = entry.name:match("(%a+) ([_%w]+) (%d+)")
				if enchantment and level then
					local stack = mcl_enchanting.enchant(
						ItemStack("mcl_enchanting:book_enchanted"),
						enchantment,
						tonumber(level)
					)
					tt.reload_itemstack_description(stack)
					table.insert(inventory_lists[category], stack:to_string())
				else
					table.insert(inventory_lists[category], entry.name)
				end
			else
				-- Tooltip reloading for dynamically added text
				local stack = ItemStack(entry.name)
				local stack_name = stack:get_name()
				tt.reload_itemstack_description(stack)
				table.insert(inventory_lists[category], stack:to_string())
			end
		end
	end

	-- Process enchanted books from definitions
	process_enchanted_books()

	-- Clean up temporary data
	temp_inventory_lists = nil
	collectgarbage("collect")
end)

---@param name string
---@param description string
---@param lang mt.LangCode
---@param filter string
---@return integer
local function filter_item(name, description, lang, filter)
	local desc
	if not lang then
		desc = string.lower(description)
	else
		desc = string.lower(minetest.get_translated_string(lang, description))
	end
	return string.find(name, filter, nil, true) or string.find(desc, filter, nil, true)
end

---@param filter string
---@param player mt.PlayerObjectRef
local function set_inv_search(filter, player)
	local playername = player:get_player_name()
	local inv = minetest.get_inventory({ type = "detached", name = "creative_" .. playername })
	local creative_list = {}
	local lang = minetest.get_player_information(playername).lang_code

	-- Process non-book items
	for _, str in pairs(inventory_lists["all"]) do
		local stack = ItemStack(str)
		local name = stack:get_name()

		-- Skip enchanted books (they'll be handled separately)
		if name ~= "mcl_enchanting:book_enchanted" then
			if filter_item(name, minetest.strip_colors(stack:get_description()), lang, filter) then
				table.insert(creative_list, str)
			end
		end
	end

	-- Process enchanted books
	for ench, def in pairs(mcl_enchanting.enchantments) do
		for i = 1, def.max_level do
			local stack = mcl_enchanting.enchant(ItemStack("mcl_enchanting:book_enchanted"), ench, i)
			tt.reload_itemstack_description(stack)  -- Ensure description is updated

			if filter_item("mcl_enchanting:book_enchanted",
							minetest.strip_colors(stack:get_description()),
							lang, filter) then
				table.insert(creative_list, stack:to_string())
			end
		end
	end

	table.sort(creative_list)
	inv:set_size("main", #creative_list)
	inv:set_list("main", creative_list)
end

-- END of overhaul code
-- START of original code by BlockMen
---@param page string
---@param player mt.PlayerObjectRef
local function set_inv_page(page, player)
	local playername = player:get_player_name()
	local inv = minetest.get_inventory({ type = "detached", name = "creative_" .. playername })
	inv:set_size("main", 0)
	local creative_list = {}

	if inventory_lists[page] then -- Standard filter
		creative_list = inventory_lists[page]
	end

	inv:set_size("main", #creative_list)
	players[playername].inv_size = #creative_list
	inv:set_list("main", creative_list)
end

---@param player mt.PlayerObjectRef
local function init(player)
	local playername = player:get_player_name()
	minetest.create_detached_inventory("creative_" .. playername, {
		allow_move = function(inv, from_list, from_index, to_list, to_index, count, player)
			if minetest.is_creative_enabled(playername) and
			   from_list ~= to_list then
				return count
			else
				return 0
			end
		end,
		allow_put = function(inv, listname, index, stack, player)
			return 0
		end,
		allow_take = function(inv, listname, index, stack, player)
			if minetest.is_creative_enabled(player:get_player_name()) then
				return -1
			else
				return 0
			end
		end,
	}, playername)
	set_inv_page("all", player)
end

-- Create the trash field
local trash = minetest.create_detached_inventory("trash", {
	allow_put = function(inv, listname, index, stack, player)
		if minetest.is_creative_enabled(player:get_player_name()) then
			return stack:get_count()
		else
			return 0
		end
	end,
	on_put = function(inv, listname, index, stack, player)
		inv:set_stack(listname, index, "")
	end,
})

trash:set_size("main", 1)
------------------------------
-- Formspec Precalculations --
------------------------------

-- Numeric position of tab background image, indexed by tab name
---@type table<string, {[0]: number, [1]: number}>
local noffset = {}

-- String position of tab button background image, indexed by tab name
---@type table<string, string>
local offset = {}

-- String position of tab button, indexed by tab name
---@type table<string, string>
local boffset = {}

-- Used to determine the tab button background image
---@type table<string, ""|"_down">
local button_bg_postfix = {}

-- Tab caption/tooltip translated string, indexed by tab name
---@type table<string, string>
local filtername = {}

local noffset_x_start = 0.2
local noffset_x = noffset_x_start
local noffset_y = -1.34

---@param id string
---@param right? boolean
local function next_noffset(id, right)
	if right then
		noffset[id] = { 11.3, noffset_y }
	else
		noffset[id] = { noffset_x, noffset_y }
		noffset_x = noffset_x + 1.6
	end
end

-- Upper row
next_noffset("blocks")
next_noffset("deco")
next_noffset("redstone")
next_noffset("rail")
next_noffset("brew")
next_noffset("misc")
next_noffset("nix", true)

noffset_x = noffset_x_start
noffset_y = 8.64

-- Lower row
next_noffset("food")
next_noffset("tools")
next_noffset("combat")
next_noffset("mobs")
next_noffset("matr")
next_noffset("inv", true)

for k, v in pairs(noffset) do
	offset[k] = tostring(v[1]) .. "," .. tostring(v[2])
	boffset[k] = tostring(v[1] + 0.24) .. "," .. tostring(v[2] + 0.25)
end

button_bg_postfix["blocks"] = ""
button_bg_postfix["deco"] = ""
button_bg_postfix["redstone"] = ""
button_bg_postfix["rail"] = ""
button_bg_postfix["brew"] = ""
button_bg_postfix["misc"] = ""
button_bg_postfix["nix"] = ""
button_bg_postfix["default"] = ""
button_bg_postfix["food"] = "_down"
button_bg_postfix["tools"] = "_down"
button_bg_postfix["combat"] = "_down"
button_bg_postfix["mobs"] = "_down"
button_bg_postfix["matr"] = "_down"
button_bg_postfix["inv"] = "_down"

filtername["blocks"] = S("Building Blocks")
filtername["deco"] = S("Decoration Blocks")
filtername["redstone"] = S("Redstone")
filtername["rail"] = S("Transportation")
filtername["misc"] = S("Miscellaneous")
filtername["nix"] = S("Search Items")
filtername["food"] = S("Foodstuffs")
filtername["tools"] = S("Tools")
filtername["combat"] = S("Combat")
filtername["mobs"] = S("Mobs")
filtername["brew"] = S("Brewing")
filtername["matr"] = S("Materials")
filtername["inv"] = S("Survival Inventory")

--local dark_bg = "crafting_creative_bg_dark.png"

--[[local function reset_menu_item_bg()
	bg["blocks"] = dark_bg
	bg["deco"] = dark_bg
	bg["redstone"] = dark_bg
	bg["rail"] = dark_bg
	bg["misc"] = dark_bg
	bg["nix"] = dark_bg
	bg["food"] = dark_bg
	bg["tools"] = dark_bg
	bg["combat"] = dark_bg
	bg["mobs"] = dark_bg
	bg["brew"] = dark_bg
	bg["matr"] = dark_bg
	bg["inv"] = dark_bg
	bg["default"] = dark_bg
end]]

-- Item name representing a tab, indexed by tab name
---@type table<string, string>
local tab_icon = {
	blocks = "mcl_core:brick_block",
	deco = "mcl_flowers:peony",
	redstone = "mesecons:redstone",
	rail = "mcl_minecarts:golden_rail_v2",
	misc = "mcl_buckets:bucket_lava",
	nix = "mcl_compass:compass",
	food = "mcl_core:apple",
	tools = "mcl_core:axe_iron",
	combat = "mcl_core:sword_gold",
	mobs = "mobs_mc:cow",
	brew = "mcl_potions:dragon_breath",
	matr = "mcl_core:stick",
	inv = "mcl_chests:chest",
}

-- Get the player configured stack size when taking items from creative inventory
---@param player mt.PlayerObjectRef
---@return integer
local function get_stack_size(player)
	return player:get_meta():get_int("mcl_inventory:switch_stack")
end

-- Set the player configured stack size when taking items from creative inventory
---@param player mt.PlayerObjectRef
---@param n integer
local function set_stack_size(player, n)
	player:get_meta():set_int("mcl_inventory:switch_stack", n)
end

minetest.register_on_joinplayer(function(player)
	if get_stack_size(player) == 0 then
		set_stack_size(player, 64)
	end
end)

---@param player mt.PlayerObjectRef
local function is_touch_enabled(playername)
	-- Luanti < 5.7.0 support
	if not minetest.get_player_window_information then
		return false
	end
	local window = minetest.get_player_window_information(playername)
	-- Always return a boolean (not nil) to avoid false-negatives when
	-- comparing to a boolean later.
	return window and window.touch_controls or false
end

---@param player mt.PlayerObjectRef
function mcl_inventory.set_creative_formspec(player)
	local playername = player:get_player_name()
	if not players[playername] then return end

	local start_i = players[playername].start_i
	local pagenum = start_i / (9 * 5) + 1
	local page = players[playername].page
	local inv_size = players[playername].inv_size
	local filter = players[playername].filter

	if not inv_size then
		if page == "nix" then
			local inv = minetest.get_inventory({ type = "detached", name = "creative_" .. playername })
			inv_size = inv:get_size("main")
		elseif page and page ~= "inv" then
			inv_size = #(inventory_lists[page])
		else
			inv_size = 0
		end
	end
	local pagemax = math.max(1, math.floor((inv_size - 1) / (9 * 5) + 1))
	local name = "nix"
	local main_list
	local listrings = table.concat({
		"listring[detached:creative_" .. playername .. ";main]",
		"listring[current_player;main]",
		"listring[detached:trash;main]",
	})

	if page then
		name = page
		if players[playername] then
			players[playername].page = page
		end
	end

	if name == "inv" then
		-- Background images for armor slots (hide if occupied)
		local armor_slot_imgs = ""
		local inv = player:get_inventory()
		if inv:get_stack("armor", 2):is_empty() then
			armor_slot_imgs = armor_slot_imgs .. "image[3.5,0.375;1,1;mcl_inventory_empty_armor_slot_helmet.png]"
		end
		if inv:get_stack("armor", 3):is_empty() then
			armor_slot_imgs = armor_slot_imgs .. "image[3.5,2.125;1,1;mcl_inventory_empty_armor_slot_chestplate.png]"
		end
		if inv:get_stack("armor", 4):is_empty() then
			armor_slot_imgs = armor_slot_imgs .. "image[7.25,0.375;1,1;mcl_inventory_empty_armor_slot_leggings.png]"
		end
		if inv:get_stack("armor", 5):is_empty() then
			armor_slot_imgs = armor_slot_imgs .. "image[7.25,2.125;1,1;mcl_inventory_empty_armor_slot_boots.png]"
		end

		if inv:get_stack("offhand", 1):is_empty() then
			armor_slot_imgs = armor_slot_imgs .. "image[2.25,1.25;1,1;mcl_inventory_empty_armor_slot_shield.png]"
		end

		local stack_size = get_stack_size(player)

		-- Survival inventory slots
		main_list = table.concat({
			mcl_formspec.get_itemslot_bg_v4(0.375, 3.375, 9, 3),
			"list[current_player;main;0.375,3.375;9,3;9]",

			-- Armor
			mcl_formspec.get_itemslot_bg_v4(3.5, 0.375, 1, 1),
			mcl_formspec.get_itemslot_bg_v4(3.5, 2.125, 1, 1),
			mcl_formspec.get_itemslot_bg_v4(7.25, 0.375, 1, 1),
			mcl_formspec.get_itemslot_bg_v4(7.25, 2.125, 1, 1),
			"list[current_player;armor;3.5,0.375;1,1;1]",
			"list[current_player;armor;3.5,2.125;1,1;2]",
			"list[current_player;armor;7.25,0.375;1,1;3]",
			"list[current_player;armor;7.25,2.125;1,1;4]",

			-- Offhand
			mcl_formspec.get_itemslot_bg_v4(2.25, 1.25, 1, 1),
			"list[current_player;offhand;2.25,1.25;1,1]",

			armor_slot_imgs,

			-- Player preview
			"image[4.75,0.33;2.25,2.83;mcl_inventory_background9.png;2]",
			mcl_player.get_player_formspec_model(player, 4.75, 0.45, 2.25, 2.75, ""),

			-- Crafting guide button
			"image_button[11.575,0.825;1.1,1.1;craftguide_book.png;__mcl_craftguide;]",
			"tooltip[__mcl_craftguide;" .. F(S("Recipe book")) .. "]",

			-- Help button
			"image_button[11.575,2.075;1.1,1.1;doc_button_icon_lores.png;__mcl_doc;]",
			"tooltip[__mcl_doc;" .. F(S("Help")) .. "]",

			-- Advancements button
			"image_button[11.575,3.325;1.1,1.1;mcl_achievements_button.png;__mcl_achievements;]",
			--"style_type[image_button;border=;bgimg=;bgimg_pressed=]",
			"tooltip[__mcl_achievements;" .. F(S("Advancements")) .. "]",

			-- Switch stack size button
			"image_button[11.575,4.575;1.1,1.1;default_apple.png;__switch_stack;]",
			"label[12.275,5.35;" .. F(C("#FFFFFF", tostring(stack_size ~= 1 and stack_size or ""))) .. "]",
			"tooltip[__switch_stack;" .. F(S("Switch stack size")) .. "]",

			-- Skins button
			"image_button[11.575,5.825;1.1,1.1;mcl_skins_button.png;__mcl_skins;]",
			"tooltip[__mcl_skins;" .. F(S("Select player skin")) .. "]",
		})

		if core.check_player_privs(player, {server = true}) then
			main_list = main_list .. table.concat({
				-- Server Settings
				"image_button[10.325,0.825;1.1,1.1;screwdriver.png;__vl_tuning;]",
				--"style_type[image_button;border=;bgimg=;bgimg_pressed=]",
				"tooltip[__vl_tuning;" .. F(S("Server Settings")) .. "]",
			})
		end

		-- For shortcuts
		listrings = listrings ..
			"listring[detached:" .. playername .. "_armor;armor]" ..
			"listring[current_player;main]"
	else

		--local nb_lines = math.ceil(inv_size / 9)
		-- Creative inventory slots
		main_list = table.concat({
			mcl_formspec.get_itemslot_bg_v4(0.375, 0.875, 9, 5),

			-- Basic code to replace buttons by scrollbar
			-- Require Luanti 5.8
			--
			--"scroll_container[0.375,0.875;11.575,6;scroll;vertical;1.25]",
			--"list[detached:creative_" .. playername .. ";main;0,0;9," .. nb_lines .. ";]",
			--"scroll_container_end[]",
			--"scrollbaroptions[min=0;max=" .. math.max(nb_lines - 5, 0) .. ";smallstep=1;largesteps=1;arrows=hide]",
			--"scrollbar[11.75,0.825;0.75,6.1;vertical;scroll;0]",

			"list[detached:creative_" .. playername .. ";main;0.375,0.875;9,5;" .. tostring(start_i) .. "]",

			-- Page buttons
			"label[11.65,4.33;" .. F(S("@1 / @2", pagenum, pagemax)) .. "]",
			"image_button[11.575,4.58;1.1,1.1;crafting_creative_prev.png^[transformR270;creative_prev;]",
			"image_button[11.575,5.83;1.1,1.1;crafting_creative_next.png^[transformR270;creative_next;]",
		})
	end

	---@param current_tab string
	---@param this_tab string
	---@return string
	local function tab(current_tab, this_tab)
		local bg_img
		if current_tab == this_tab then
			bg_img = "crafting_creative_active" .. button_bg_postfix[this_tab] .. ".png"
		else
			bg_img = "crafting_creative_inactive" .. button_bg_postfix[this_tab] .. ".png"
		end
		return table.concat({
			"style[" .. this_tab ..       ";border=false;bgimg=;bgimg_pressed=]",
			"style[" .. this_tab .. "_outer;border=false;bgimg=" .. bg_img ..
				";bgimg_pressed=" .. bg_img .. "]",
			"button[" .. offset[this_tab] .. ";1.5,1.44;" .. this_tab .. "_outer;]",
			"item_image_button[" .. boffset[this_tab] .. ";1,1;" .. tab_icon[this_tab] .. ";" .. this_tab .. ";]",
		})
	end

	local caption = ""
	if name ~= "inv" and filtername[name] then
		caption = "label[0.375,0.375;" .. F(C(mcl_formspec.label_color, filtername[name])) .. "]"
	end

	local touch_enabled = is_touch_enabled(playername)
	players[playername].last_touch_enabled = touch_enabled

	local formspec = table.concat({
		"formspec_version[6]",
		-- Original formspec height was 8.75, increased to include tab buttons.
		-- This avoids tab buttons going off-screen with high scaling values.
		"size[13,11.43]",
		-- Use as much space as possible on mobile - the tab buttons are a lot
		-- of padding already.
		touch_enabled and "padding[-0.015,-0.015]" or "",

		"no_prepend[]", mcl_vars.gui_nonbg, mcl_vars.gui_bg_color,
		"background9[0,1.34;13,8.75;mcl_base_textures_background9.png;;7]",
		"container[0,1.34]",

		-- Hotbar
		mcl_formspec.get_itemslot_bg_v4(0.375, 7.375, 9, 1),
		"list[current_player;main;0.375,7.375;9,1;]",

		-- Trash
		mcl_formspec.get_itemslot_bg_v4(11.625, 7.375, 1, 1, nil, "crafting_creative_trash.png"),
		"list[detached:trash;main;11.625,7.375;1,1;]",

		main_list,

		caption,

		listrings,

		tab(name, "blocks") ..
		"tooltip[blocks;"..F(filtername["blocks"]).."]"..
		tab(name, "deco") ..
		"tooltip[deco;"..F(filtername["deco"]).."]"..
		tab(name, "redstone") ..
		"tooltip[redstone;"..F(filtername["redstone"]).."]"..
		tab(name, "rail") ..
		"tooltip[rail;"..F(filtername["rail"]).."]"..
		tab(name, "misc") ..
		"tooltip[misc;"..F(filtername["misc"]).."]"..
		tab(name, "nix") ..
		"tooltip[nix;"..F(filtername["nix"]).."]"..

		tab(name, "food") ..
		"tooltip[food;"..F(filtername["food"]).."]"..
		tab(name, "tools") ..
		"tooltip[tools;"..F(filtername["tools"]).."]"..
		tab(name, "combat") ..
		"tooltip[combat;"..F(filtername["combat"]).."]"..
		tab(name, "mobs") ..
		"tooltip[mobs;"..F(filtername["mobs"]).."]"..
		tab(name, "brew") ..
		"tooltip[brew;"..F(filtername["brew"]).."]"..
		tab(name, "matr") ..
		"tooltip[matr;"..F(filtername["matr"]).."]"..
		tab(name, "inv") ..
		"tooltip[inv;"..F(filtername["inv"]).."]"
	})

	if name == "nix" then
		if filter == nil then
			filter = ""
		end

		formspec = formspec .. table.concat({
			"field[5.325,0.15;6.1,0.6;search;;" .. minetest.formspec_escape(filter) .. "]",
			"field_close_on_enter[search;false]",
			"field_enter_after_edit[search;true]",
			"set_focus[search;true]",
		})
	end
	formspec = formspec .. "container_end[]"
	if pagenum then formspec = formspec .. "p" .. tostring(pagenum) end
	player:set_inventory_formspec(formspec)
end

minetest.register_on_player_receive_fields(function(player, formname, fields)
	local page = nil

	if not minetest.is_creative_enabled(player:get_player_name()) then
		return
	end
	if formname ~= "" or fields.quit == "true" then
		-- No-op if formspec closed or not player inventory (formname == "")
		return
	end

	local name = player:get_player_name()

	if fields.blocks or fields.blocks_outer then
		if players[name].page == "blocks" then return end
		set_inv_page("blocks", player)
		page = "blocks"
	elseif fields.deco or fields.deco_outer then
		if players[name].page == "deco" then return end
		set_inv_page("deco", player)
		page = "deco"
	elseif fields.redstone or fields.redstone_outer then
		if players[name].page == "redstone" then return end
		set_inv_page("redstone", player)
		page = "redstone"
	elseif fields.rail or fields.rail_outer then
		if players[name].page == "rail" then return end
		set_inv_page("rail", player)
		page = "rail"
	elseif fields.misc or fields.misc_outer then
		if players[name].page == "misc" then return end
		set_inv_page("misc", player)
		page = "misc"
	elseif fields.nix or fields.nix_outer then
		set_inv_page("all", player)
		page = "nix"
	elseif fields.food or fields.food_outer then
		if players[name].page == "food" then return end
		set_inv_page("food", player)
		page = "food"
	elseif fields.tools or fields.tools_outer then
		if players[name].page == "tools" then return end
		set_inv_page("tools", player)
		page = "tools"
	elseif fields.combat or fields.combat_outer then
		if players[name].page == "combat" then return end
		set_inv_page("combat", player)
		page = "combat"
	elseif fields.mobs or fields.mobs_outer then
		if players[name].page == "mobs" then return end
		set_inv_page("mobs", player)
		page = "mobs"
	elseif fields.brew or fields.brew_outer then
		if players[name].page == "brew" then return end
		set_inv_page("brew", player)
		page = "brew"
	elseif fields.matr or fields.matr_outer  then
		if players[name].page == "matr" then return end
		set_inv_page("matr", player)
		page = "matr"
	elseif fields.inv or fields.inv_outer then
		if players[name].page == "inv" then return end
		page = "inv"
	elseif fields.search == "" and not fields.creative_next and not fields.creative_prev then
		set_inv_page("all", player)
		page = "nix"
	elseif fields.search and not fields.creative_next and not fields.creative_prev then
		set_inv_search(string.lower(fields.search), player)
		page = "nix"
	elseif fields.__switch_stack then
		local switch = 1
		if get_stack_size(player) == 1 then
			switch = 64
		end
		set_stack_size(player, switch)
	end

	if page then
		players[name].page = page
	else
		page = players[name].page
	end

	local start_i = players[name].start_i
	if fields.creative_prev then
		start_i = start_i - 9 * 5
	elseif fields.creative_next then
		start_i = start_i + 9 * 5
	else
		-- Reset scroll bar if not scrolled
		start_i = 0
	end
	if start_i < 0 then
		start_i = start_i + 9 * 5
	end

	local inv_size
	if page == "nix" then
		local inv = minetest.get_inventory({ type = "detached", name = "creative_" .. name })
		inv_size = inv:get_size("main")
	elseif page and page ~= "inv" then
		inv_size = #(inventory_lists[page])
	else
		inv_size = 0
	end
	players[name].inv_size = inv_size

	if start_i >= inv_size then
		start_i = start_i - 9 * 5
	end
	if start_i < 0 or start_i >= inv_size then
		start_i = 0
	end
	players[name].start_i = start_i

	if not fields.nix and fields.search then
		players[name].filter = fields.search
	else
		players[name].filter = ""
	end

	mcl_inventory.set_creative_formspec(player)
end)

minetest.register_on_placenode(function(pos, newnode, placer, oldnode, itemstack)
	return placer and placer:is_player() and minetest.is_creative_enabled(placer:get_player_name())
end)

if minetest.is_creative_enabled("") then
	minetest.register_on_placenode(function(pos, newnode, placer, oldnode, itemstack)
		-- Place infinite nodes, except for shulker boxes
		local group = minetest.get_item_group(itemstack:get_name(), "shulker_box")
		return group == 0 or group == nil
	end)

	function minetest.handle_node_drops(pos, drops, digger)
		if not digger or not digger:is_player() then
			for _, item in ipairs(drops) do
				minetest.add_item(pos, item)
			end
		else
			-- If there is a player
			local inv = digger:get_inventory()
			if inv then
				for _, item in ipairs(drops) do
					if not inv:contains_item("main", item, true) then
						inv:add_item("main", item)
					end
				end
			end
		end
	end
end

minetest.register_on_joinplayer(function(player)
	-- Initialize variables and inventory
	local name = player:get_player_name()
	if not players[name] then
		players[name] = {}
		players[name].page = "nix"
		players[name].filter = ""
		players[name].start_i = 0
	end
	init(player)
	-- Setup initial creative inventory to the "nix" page.
	mcl_inventory.set_creative_formspec(player)
end)

minetest.register_on_player_inventory_action(function(player, action, inventory, inventory_info)
	if minetest.is_creative_enabled(player:get_player_name()) and get_stack_size(player) == 64 and action == "put" and
		inventory_info.listname == "main" then
		local stack = inventory_info.stack
		stack:set_count(stack:get_stack_max())
		player:get_inventory():set_stack("main", inventory_info.index, stack)
	end
end)

-- This is necessary because get_player_window_information may return nil in
-- on_joinplayer.
-- (Also, Luanti plans to add support for toggling touchscreen mode in-game.)
minetest.register_globalstep(function(dtime)
	for _, player in pairs(minetest.get_connected_players()) do
		local name = player:get_player_name()

		if minetest.is_creative_enabled(name) then
			local touch_enabled = is_touch_enabled(name)
			if not players[name] or touch_enabled ~= players[name].last_touch_enabled then
				mcl_inventory.set_creative_formspec(player)
			end
		end
	end
end)
