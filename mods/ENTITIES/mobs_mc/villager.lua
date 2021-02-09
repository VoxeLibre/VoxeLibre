--MCmobs v0.4
--maikerumine
--made for MC like Survival game
--License for code WTFPL and otherwise stated in readmes

--###################
--################### VILLAGER
--###################
-- Summary: Villagers are complex NPCs, their main feature allows players to trade with them.

-- TODO: Particles
-- TODO: 4s Regeneration I after trade unlock
-- TODO: Breeding
-- TODO: Baby villagers
-- TODO: Spawning in villages
-- TODO: Behaviour:
--     TODO: Walk around village, but do not leave it intentionally
--     TODO: Run into house on rain or danger, open doors
--     TODO: Internal inventory, pick up items, trade with other villagers
--     TODO: Farm stuff

local S = minetest.get_translator("mobs_mc")
local N = function(s) return s end
local F = minetest.formspec_escape

-- playername-indexed table containing the previously used tradenum
local player_tradenum = {}
-- playername-indexed table containing the objectref of trader, if trading formspec is open
local player_trading_with = {}

local DEFAULT_WALK_CHANCE = 33 -- chance to walk in percent, if no player nearby
local PLAYER_SCAN_INTERVAL = 5 -- every X seconds, villager looks for players nearby
local PLAYER_SCAN_RADIUS = 4 -- scan radius for looking for nearby players

--[=======[ TRADING ]=======]

-- LIST OF VILLAGER PROFESSIONS AND TRADES

-- TECHNICAL RESTRICTIONS (FIXME):
-- * You can't use a clock as requested item
-- * You can't use a compass as requested item if its stack size > 1
-- * You can't use a compass in the second requested slot
-- This is a problem in the mcl_compass and mcl_clock mods,
-- these items should be implemented as single items, then everything
-- will be much easier.

local COMPASS = "mcl_compass:compass"
if minetest.registered_aliases[COMPASS] then
	COMPASS = minetest.registered_aliases[COMPASS]
end

local E1 = { "mcl_core:emerald", 1, 1 } -- one emerald

-- Special trades for v6 only
-- NOTE: These symbols MUST only be added at the end of a tier
local TRADE_V6_RED_SANDSTONE, TRADE_V6_DARK_OAK_SAPLING, TRADE_V6_ACACIA_SAPLING, TRADE_V6_BIRCH_SAPLING
if minetest.get_mapgen_setting("mg_name") == "v6" then
	TRADE_V6_RED_SANDSTONE = { E1, { "mcl_core:redsandstone", 12, 16 } }
	TRADE_V6_DARK_OAK_SAPLING = { { "mcl_core:emerald", 6, 9 }, { "mcl_core:darksapling", 1, 1 } }
	TRADE_V6_ACACIA_SAPLING = { { "mcl_core:emerald", 14, 17 }, { "mcl_core:acaciasapling", 1, 1 } }
	TRADE_V6_BIRCH_SAPLING = { { "mcl_core:emerald", 8, 11 }, { "mcl_core:birchsapling", 1, 1 } }
end

local professions = {
	farmer = {
		name = N("Farmer"),
		texture = "mobs_mc_villager_farmer.png",
		trades = {
			{
			{ { "mcl_farming:wheat_item", 18, 22, }, E1 },
			{ { "mcl_farming:potato_item", 15, 19, }, E1 },
			{ { "mcl_farming:carrot_item", 15, 19, }, E1 },
			{ E1, { "mcl_farming:bread", 2, 4 } },
			},

			{
			{ { "mcl_farming:pumpkin_face", 8, 13 }, E1 },
			{ E1, { "mcl_farming:pumpkin_pie", 2, 3} },
			},

			{
			{ { "mcl_farming:melon", 7, 12 }, E1 },
			{ E1, { "mcl_core:apple", 5, 7 }, },
			},

			{
			{ E1, { "mcl_farming:cookie", 6, 10 } },
			{ E1, { "mcl_cake:cake", 1, 1 } },
			TRADE_V6_BIRCH_SAPLING,
			TRADE_V6_DARK_OAK_SAPLING,
			TRADE_V6_ACACIA_SAPLING,
			},
		}
	},
	fisherman = {
		name = N("Fisherman"),
		texture = "mobs_mc_villager_farmer.png",
		trades = {
			{
			{ { "mcl_fishing:fish_raw", 6, 6, "mcl_core:emerald", 1, 1 }, { "mcl_fishing:fish_cooked", 6, 6 } },
			{ { "mcl_mobitems:string", 15, 20 }, E1 },
			{ { "mcl_core:emerald", 3, 11 }, { "mcl_fishing:fishing_rod_enchanted", 1, 1} },
			},
		},
	},
	fletcher = {
		name = N("Fletcher"),
		texture = "mobs_mc_villager_farmer.png",
		trades = {
			{
			{ { "mcl_mobitems:string", 15, 20 }, E1 },
			{ E1, { "mcl_bows:arrow", 8, 12 } },
			},

			{
			{ { "mcl_core:gravel", 10, 10, "mcl_core:emerald", 1, 1 }, { "mcl_core:flint", 6, 10 } },
			{ { "mcl_core:emerald", 2, 3 }, { "mcl_bows:bow", 1, 1 } },
			},
		}
	},
	shepherd ={
		name = N("Shepherd"),
		texture = "mobs_mc_villager_farmer.png",
		trades = {
			{
			{ { "mcl_wool:white", 16, 22 }, E1 },
			{ { "mcl_core:emerald", 3, 4 }, { "mcl_tools:shears", 1, 1 } },
			},

			{
			{ { "mcl_core:emerald", 1, 2 }, { "mcl_wool:white", 1, 1 } },
			{ { "mcl_core:emerald", 1, 2 }, { "mcl_wool:grey", 1, 1 } },
			{ { "mcl_core:emerald", 1, 2 }, { "mcl_wool:silver", 1, 1 } },
			{ { "mcl_core:emerald", 1, 2 }, { "mcl_wool:black", 1, 1 } },
			{ { "mcl_core:emerald", 1, 2 }, { "mcl_wool:yellow", 1, 1 } },
			{ { "mcl_core:emerald", 1, 2 }, { "mcl_wool:orange", 1, 1 } },
			{ { "mcl_core:emerald", 1, 2 }, { "mcl_wool:red", 1, 1 } },
			{ { "mcl_core:emerald", 1, 2 }, { "mcl_wool:magenta", 1, 1 } },
			{ { "mcl_core:emerald", 1, 2 }, { "mcl_wool:purple", 1, 1 } },
			{ { "mcl_core:emerald", 1, 2 }, { "mcl_wool:blue", 1, 1 } },
			{ { "mcl_core:emerald", 1, 2 }, { "mcl_wool:cyan", 1, 1 } },
			{ { "mcl_core:emerald", 1, 2 }, { "mcl_wool:lime", 1, 1 } },
			{ { "mcl_core:emerald", 1, 2 }, { "mcl_wool:green", 1, 1 } },
			{ { "mcl_core:emerald", 1, 2 }, { "mcl_wool:pink", 1, 1 } },
			{ { "mcl_core:emerald", 1, 2 }, { "mcl_wool:light_blue", 1, 1 } },
			{ { "mcl_core:emerald", 1, 2 }, { "mcl_wool:brown", 1, 1 } },
			},
		},
	},
	librarian = {
		name = N("Librarian"),
		texture = "mobs_mc_villager_librarian.png",
		trades = {
			{
			{ { "mcl_core:paper", 24, 36 }, E1 },
			{ { "mcl_books:book", 8, 10 }, E1 },
			{ { "mcl_core:emerald", 10, 12 }, { "mcl_compass:compass", 1 ,1 }},
			{ { "mcl_core:emerald", 3, 4 }, { "mcl_books:bookshelf", 1 ,1 }},
			{ { "mcl_core:emerald", 5, 64 }, { "mcl_enchanting:book_enchanted", 1 ,1 }},
			},

			{
			{ { "mcl_books:written_book", 2, 2 }, E1 },
			{ { "mcl_core:emerald", 10, 12 }, { "mcl_clock:clock", 1, 1 } },
			{ E1, { "mcl_core:glass", 3, 5 } },
			{ { "mcl_core:emerald", 5, 64 }, { "mcl_enchanting:book_enchanted", 1 ,1 }},
			},

			{
			{ E1, { "mcl_core:glass", 3, 5 } },
			{ { "mcl_core:emerald", 5, 64 }, { "mcl_enchanting:book_enchanted", 1 ,1 }},
			},

			{
			{ { "mcl_core:emerald", 5, 64 }, { "mcl_enchanting:book_enchanted", 1 ,1 }},
			},

			{
			{ { "mcl_core:emerald", 20, 22 }, { "mcl_mobs:nametag", 1, 1 } },
			}
		},
	},
	cartographer = {
		name = N("Cartographer"),
		texture = "mobs_mc_villager_librarian.png",
		trades = {
			{
			{ { "mcl_core:paper", 24, 36 }, E1 },
			},

			{
			-- subject to special checks
			{ { "mcl_compass:compass", 1, 1 }, E1 },
			},

			{
			-- TODO: replace with empty map
			{ { "mcl_core:emerald", 7, 11}, { "mcl_maps:filled_map", 1, 1 } },
			},

			-- TODO: special maps
		},
	},
	armorer = {
		name = N("Armorer"),
		texture = "mobs_mc_villager_smith.png",
		trades = {
			{
			{ { "mcl_core:coal_lump", 16, 24 }, E1 },
			{ { "mcl_core:emerald", 4, 6 }, { "mcl_armor:helmet_iron", 1, 1 } },
			},

			{
			{ { "mcl_core:iron_ingot", 7, 9 }, E1 },
			{ { "mcl_core:emerald", 10, 14 }, { "mcl_armor:chestplate_iron", 1, 1 } },
			},

			{
			{ { "mcl_core:diamond", 3, 4 }, E1 },
			{ { "mcl_core:emerald", 16, 19 }, { "mcl_armor:chestplate_diamond_enchanted", 1, 1 } },
			},

			{
			{ { "mcl_core:emerald", 5, 7 }, { "mcl_armor:boots_chain", 1, 1 } },
			{ { "mcl_core:emerald", 9, 11 }, { "mcl_armor:leggings_chain", 1, 1 } },
			{ { "mcl_core:emerald", 5, 7 }, { "mcl_armor:helmet_chain", 1, 1 } },
			{ { "mcl_core:emerald", 11, 15 }, { "mcl_armor:chestplate_chain", 1, 1 } },
			},
		},
	},
	leatherworker = {
		name = N("Leatherworker"),
		texture = "mobs_mc_villager_butcher.png",
		trades = {
			{
			{ { "mcl_mobitems:leather", 9, 12 }, E1 },
			{ { "mcl_core:emerald", 2, 4 }, { "mcl_armor:leggings_leather", 2, 4 } },
			},

			{
			{ { "mcl_core:emerald", 7, 12 }, { "mcl_armor:chestplate_leather_enchanted", 1, 1 } },
			},

			{
			{ { "mcl_core:emerald", 8, 10 }, { "mcl_mobitems:saddle", 1, 1 } },
			},
		},
	},
	butcher = {
		name = N("Butcher"),
		texture = "mobs_mc_villager_butcher.png",
		trades = {
			{
			{ { "mcl_mobitems:beef", 14, 18 }, E1 },
			{ { "mcl_mobitems:chicken", 14, 18 }, E1 },
			},

			{
			{ { "mcl_core:coal_lump", 16, 24 }, E1 },
			{ E1, { "mcl_mobitems:cooked_beef", 5, 7 } },
			{ E1, { "mcl_mobitems:cooked_chicken", 6, 8 } },
			},
		},
	},
	weapon_smith = {
		name = N("Weapon Smith"),
		texture = "mobs_mc_villager_smith.png",
		trades = {
			{
			{ { "mcl_core:coal_lump", 16, 24 }, E1 },
			{ { "mcl_core:emerald", 6, 8 }, { "mcl_tools:axe_iron", 1, 1 } },
			},

			{
			{ { "mcl_core:iron_ingot", 7, 9 }, E1 },
			{ { "mcl_core:emerald", 9, 10 }, { "mcl_tools:sword_iron_enchanted", 1, 1 } },
			},

			{
			{ { "mcl_core:diamond", 3, 4 }, E1 },
			{ { "mcl_core:emerald", 12, 15 }, { "mcl_tools:sword_diamond_enchanted", 1, 1 } },
			{ { "mcl_core:emerald", 9, 12 }, { "mcl_tools:axe_diamond_enchanted", 1, 1 } },
			},
		},
	},
	tool_smith = {
		name = N("Tool Smith"),
		texture = "mobs_mc_villager_smith.png",
		trades = {
			{
			{ { "mcl_core:coal_lump", 16, 24 }, E1 },
			{ { "mcl_core:emerald", 5, 7 }, { "mcl_tools:shovel_iron_enchanted", 1, 1 } },
			},

			{
			{ { "mcl_core:iron_ingot", 7, 9 }, E1 },
			{ { "mcl_core:emerald", 9, 11 }, { "mcl_tools:pick_iron_enchanted", 1, 1 } },
			},

			{
			{ { "mcl_core:diamond", 3, 4 }, E1 },
			{ { "mcl_core:emerald", 12, 15 }, { "mcl_tools:pick_diamond_enchanted", 1, 1 } },
			},
		},
	},
	cleric = {
		name = N("Cleric"),
		texture = "mobs_mc_villager_priest.png",
		trades = {
			{
			{ { "mcl_mobitems:rotten_flesh", 36, 40 }, E1 },
			{ { "mcl_core:gold_ingot", 8, 10 }, E1 },
			},

			{
			{ E1, { "mesecons:redstone", 1, 4  } },
			{ E1, { "mcl_dye:blue", 1, 2 } },
			},

			{
			{ E1, { "mcl_nether:glowstone", 1, 3 } },
			{ { "mcl_core:emerald", 4, 7 }, { "mcl_throwing:ender_pearl", 1, 1 } },
			TRADE_V6_RED_SANDSTONE,
			},

			{
			 { { "mcl_nether:nether_wart_item", 22, 22 }, E1 },
			 { { "mcl_core:emerald", 3, 3 }, { "mcl_experience:bottle", 1, 1 } },
			},
		},
	},
	nitwit = {
		name = N("Nitwit"),
		texture = "mobs_mc_villager.png",
		-- No trades for nitwit
		trades = nil,
	}
}

local profession_names = {}
for id, _ in pairs(professions) do
	table.insert(profession_names, id)
end

local stand_still = function(self)
	self.walk_chance = 0
	self.jump = false
end

local update_max_tradenum = function(self)
	if not self._trades then
		return
	end
	local trades = minetest.deserialize(self._trades)
	for t=1, #trades do
		local trade = trades[t]
		if trade.tier > self._max_trade_tier then
			self._max_tradenum = t - 1
			return
		end
	end
	self._max_tradenum = #trades
end

local init_trader_vars = function(self)
	if not self._profession then
		-- Select random profession from all professions with matching clothing
		local texture = self.base_texture[1]
		local matches = {}
		for prof_id, prof in pairs(professions) do
			if texture == prof.texture then
				table.insert(matches, prof_id)
			end
		end
		local p = math.random(1, #matches)
		self._profession = matches[p]
	end
	if not self._max_trade_tier then
		self._max_trade_tier = 1
	end
	if not self._locked_trades then
		self._locked_trades = 0
	end
	if not self._trading_players then
		self._trading_players = {}
	end
end

local init_trades = function(self, inv)
	local profession = professions[self._profession]
	local trade_tiers = profession.trades
	if trade_tiers == nil then
		-- Empty trades
		self._trades = false
		return
	end

	local max_tier = #trade_tiers
	local trades = {}
	for tiernum=1, max_tier do
		local tier = trade_tiers[tiernum]
		for tradenum=1, #tier do
			local trade = tier[tradenum]
			local wanted1_item = trade[1][1]
			local wanted1_count = math.random(trade[1][2], trade[1][3])
			local offered_item = trade[2][1]
			local offered_count = math.random(trade[2][2], trade[2][3])

			local offered_stack = ItemStack({name = offered_item, count = offered_count})
			if mcl_enchanting.is_enchanted(offered_item) then
				if mcl_enchanting.is_book(offered_item) then
					offered_stack = mcl_enchanting.get_uniform_randomly_enchanted_book({"soul_speed"})
				else
					mcl_enchanting.enchant_randomly(offered_stack, math.random(5, 19), false, false, true)
				end
			end

			local wanted = { wanted1_item .. " " ..wanted1_count }
			if trade[1][4] then
				local wanted2_item = trade[1][4]
				local wanted2_count = math.random(trade[1][5], trade[1][6])
				table.insert(wanted, wanted2_item .. " " ..wanted2_count)
			end

			table.insert(trades, {
				wanted = wanted,
				offered = offered_stack:to_table(),
				tier = tiernum, -- tier of this trade
				traded_once = false, -- true if trade was traded at least once
				trade_counter = 0, -- how often the this trade was mate after the last time it got unlocked
				locked = false, -- if this trade is locked. Locked trades can't be used
			})
		end
	end
	self._trades = minetest.serialize(trades)
	minetest.deserialize(self._trades)
end

local set_trade = function(trader, player, inv, concrete_tradenum)
	local trades = minetest.deserialize(trader._trades)
	if not trades then
		init_trades(trader)
		trades = minetest.deserialize(trader._trades)
		if not trades then
			minetest.log("error", "[mobs_mc] Failed to select villager trade!")
			return
		end
	end
	local name = player:get_player_name()

	-- Stop tradenum from advancing into locked tiers or out-of-range areas
	if concrete_tradenum > trader._max_tradenum then
		concrete_tradenum = trader._max_tradenum
	elseif concrete_tradenum < 1 then
		concrete_tradenum = 1
	end
	player_tradenum[name] = concrete_tradenum
	local trade = trades[concrete_tradenum]
	inv:set_stack("wanted", 1, ItemStack(trade.wanted[1]))
	inv:set_stack("offered", 1, ItemStack(trade.offered))
	if trade.wanted[2] then
		local wanted2 = ItemStack(trade.wanted[2])
		inv:set_stack("wanted", 2, wanted2)
	else
		inv:set_stack("wanted", 2, "")
	end

end

local function show_trade_formspec(playername, trader, tradenum)
	if not trader._trades then
		return
	end
	if not tradenum then
		tradenum = 1
	end
	local trades = minetest.deserialize(trader._trades)
	local trade = trades[tradenum]
	local profession = professions[trader._profession].name
	local disabled_img = ""
	if trade.locked then
		disabled_img = "image[4.3,2.52;1,1;mobs_mc_trading_formspec_disabled.png]"..
			"image[4.3,1.1;1,1;mobs_mc_trading_formspec_disabled.png]"
	end
	local tradeinv_name = "mobs_mc:trade_"..playername
	local tradeinv = F("detached:"..tradeinv_name)

	local b_prev, b_next = "", ""
	if #trades > 1 then
		if tradenum > 1 then
			b_prev = "button[1,1;0.5,1;prev_trade;<]"
		end
		if tradenum < trader._max_tradenum then
			b_next = "button[7.26,1;0.5,1;next_trade;>]"
		end
	end

	local inv = minetest.get_inventory({type="detached", name="mobs_mc:trade_"..playername})
	if not inv then
		return
	end
	local wanted1 = inv:get_stack("wanted", 1)
	local wanted2 = inv:get_stack("wanted", 2)
	local offered = inv:get_stack("offered", 1)

	local w2_formspec = ""
	if not wanted2:is_empty() then
		w2_formspec = "item_image[3,1;1,1;"..wanted2:to_string().."]"
		.."tooltip[3,1;0.8,0.8;"..F(wanted2:get_description()).."]"
	end

	local formspec =
	"size[9,8.75]"
	.."background[-0.19,-0.25;9.41,9.49;mobs_mc_trading_formspec_bg.png]"
	..disabled_img
	.."label[4,0;"..F(minetest.colorize("#313131", S(profession))).."]"
	.."list[current_player;main;0,4.5;9,3;9]"
	.."list[current_player;main;0,7.74;9,1;]"
	..b_prev..b_next
	.."["..tradeinv..";wanted;2,1;2,1;]"
	.."item_image[2,1;1,1;"..wanted1:to_string().."]"
	.."tooltip[2,1;0.8,0.8;"..F(wanted1:get_description()).."]"
	..w2_formspec
	.."item_image[5.76,1;1,1;"..offered:get_name().." "..offered:get_count().."]"
	.."tooltip[5.76,1;0.8,0.8;"..F(offered:get_description()).."]"
	.."list["..tradeinv..";input;2,2.5;2,1;]"
	.."list["..tradeinv..";output;5.76,2.55;1,1;]"
	.."listring["..tradeinv..";output]"
	.."listring[current_player;main]"
	.."listring["..tradeinv..";input]"
	.."listring[current_player;main]"
	minetest.sound_play("mobs_mc_villager_trade", {to_player = playername}, true)
	minetest.show_formspec(playername, tradeinv_name, formspec)
end

local update_offer = function(inv, player, sound)
	local name = player:get_player_name()
	local trader = player_trading_with[name]
	local tradenum = player_tradenum[name]
	if not trader or not tradenum then
		return false
	end
	local trades = minetest.deserialize(trader._trades)
	if not trades then
		return false
	end
	local trade = trades[tradenum]
	if not trade then
		return false
	end
	local wanted1, wanted2 = inv:get_stack("wanted", 1), inv:get_stack("wanted", 2)
	local input1, input2 = inv:get_stack("input", 1), inv:get_stack("input", 2)

	-- BEGIN OF SPECIAL HANDLING OF COMPASS
	-- These 2 functions are a complicated check to check if the input contains a
	-- special item which we cannot check directly against their name, like
	-- compass.
	-- TODO: Remove these check functions when compass and clock are implemented
	-- as single items.
	local check_special = function(special_item, group, wanted1, wanted2, input1, input2)
		if minetest.registered_aliases[special_item] then
			special_item = minetest.registered_aliases[special_item]
		end
		if wanted1:get_name() == special_item then
			local check_input = function(input, wanted, group)
				return minetest.get_item_group(input:get_name(), group) ~= 0 and input:get_count() >= wanted:get_count()
			end
			if check_input(input1, wanted1, group) then
				return true
			elseif check_input(input2, wanted1, group) then
				return true
			else
				return false
			end
		end
		return false
	end
	-- Apply above function to all items which we consider special.
	-- This function succeeds if ANY item check succeeds.
	local check_specials = function(wanted1, wanted2, input1, input2)
		return check_special(COMPASS, "compass", wanted1, wanted2, input1, input2)
	end
	-- END OF SPECIAL HANDLING OF COMPASS

	if (
			((inv:contains_item("input", wanted1) and
			(wanted2:is_empty() or inv:contains_item("input", wanted2))) or
			-- BEGIN OF SPECIAL HANDLING OF COMPASS
			check_specials(wanted1, wanted2, input1, input2)) and
			-- END OF SPECIAL HANDLING OF COMPASS
			(trade.locked == false)) then
		inv:set_stack("output", 1, inv:get_stack("offered", 1))
		if sound then
			minetest.sound_play("mobs_mc_villager_accept", {to_player = name}, true)
		end
		return true
	else
		inv:set_stack("output", 1, ItemStack(""))
		if sound then
			minetest.sound_play("mobs_mc_villager_deny", {to_player = name}, true)
		end
		return false
	end
end

-- Returns a single itemstack in the given inventory to the player's main inventory, or drop it when there's no space left
local function return_item(itemstack, dropper, pos, inv_p)
	if dropper:is_player() then
		-- Return to main inventory
		if inv_p:room_for_item("main", itemstack) then
			inv_p:add_item("main", itemstack)
		else
			-- Drop item on the ground
			local v = dropper:get_look_dir()
			local p = {x=pos.x, y=pos.y+1.2, z=pos.z}
			p.x = p.x+(math.random(1,3)*0.2)
			p.z = p.z+(math.random(1,3)*0.2)
			local obj = minetest.add_item(p, itemstack)
			if obj then
				v.x = v.x*4
				v.y = v.y*4 + 2
				v.z = v.z*4
				obj:set_velocity(v)
				obj:get_luaentity()._insta_collect = false
			end
		end
	else
		-- Fallback for unexpected cases
		minetest.add_item(pos, itemstack)
	end
	return itemstack
end

local return_fields = function(player)
	local name = player:get_player_name()
	local inv_t = minetest.get_inventory({type="detached", name = "mobs_mc:trade_"..name})
	local inv_p = player:get_inventory()
	if not inv_t or not inv_p then
		return
	end
	for i=1, inv_t:get_size("input") do
		local stack = inv_t:get_stack("input", i)
		return_item(stack, player, player:get_pos(), inv_p)
		stack:clear()
		inv_t:set_stack("input", i, stack)
	end
	inv_t:set_stack("output", 1, "")
end

minetest.register_on_player_receive_fields(function(player, formname, fields)
	if string.sub(formname, 1, 14) == "mobs_mc:trade_" then
		local name = player:get_player_name()
		if fields.quit then
			-- Get input items back
			return_fields(player)
			-- Reset internal "trading with" state
			local trader = player_trading_with[name]
			if trader then
				trader._trading_players[name] = nil
			end
			player_trading_with[name] = nil
		elseif fields.next_trade or fields.prev_trade then
			local trader = player_trading_with[name]
			if not trader or not trader.object:get_luaentity() then
				return
			end
			local trades = trader._trades
			if not trades then
				return
			end
			local dir = 1
			if fields.prev_trade then
				dir = -1
			end
			local tradenum = player_tradenum[name] + dir
			local inv = minetest.get_inventory({type="detached", name="mobs_mc:trade_"..name})
			if not inv then
				return
			end
			set_trade(trader, player, inv, tradenum)
			update_offer(inv, player, false)
			show_trade_formspec(name, trader, player_tradenum[name])
		end
	end
end)

minetest.register_on_leaveplayer(function(player)
	local name = player:get_player_name()
	return_fields(player)
	player_tradenum[name] = nil
	local trader = player_trading_with[name]
	if trader then
		trader._trading_players[name] = nil
	end
	player_trading_with[name] = nil

end)

-- Return true if player is trading with villager, and the villager entity exists
local trader_exists = function(playername)
	local trader = player_trading_with[playername]
	return trader ~= nil and trader.object:get_luaentity() ~= nil
end

local trade_inventory = {
	allow_take = function(inv, listname, index, stack, player)
		if listname == "input" then
			return stack:get_count()
		elseif listname == "output" then
			if not trader_exists(player:get_player_name()) then
				return 0
			end
			-- Only allow taking full stack
			local count = stack:get_count()
			if count == inv:get_stack(listname, index):get_count() then
				-- Also update output stack again.
				-- If input has double the wanted items, the
				-- output will stay because there will be still
				-- enough items in input after the trade
				local wanted1 = inv:get_stack("wanted", 1)
				local wanted2 = inv:get_stack("wanted", 2)
				local input1 = inv:get_stack("input", 1)
				local input2 = inv:get_stack("input", 2)
				wanted1:set_count(wanted1:get_count()*2)
				wanted2:set_count(wanted2:get_count()*2)
				-- BEGIN OF SPECIAL HANDLING FOR COMPASS
				local special_checks = function(wanted1, input1, input2)
					if wanted1:get_name() == COMPASS then
						local compasses = 0
						if (minetest.get_item_group(input1:get_name(), "compass") ~= 0) then
							compasses = compasses + input1:get_count()
						end
						if (minetest.get_item_group(input2:get_name(), "compass") ~= 0) then
							compasses = compasses + input2:get_count()
						end
						return compasses >= wanted1:get_count()
					end
					return false
				end
				-- END OF SPECIAL HANDLING FOR COMPASS
				if (inv:contains_item("input", wanted1) and
					(wanted2:is_empty() or inv:contains_item("input", wanted2)))
					-- BEGIN OF SPECIAL HANDLING FOR COMPASS
					or special_checks(wanted1, input1, input2) then
					-- END OF SPECIAL HANDLING FOR COMPASS
					return -1
				else
					-- If less than double the wanted items,
					-- remove items from output (final trade,
					-- input runs empty)
					return count
				end
			else
				return 0
			end
		else
			return 0
		end
	end,
	allow_move = function(inv, from_list, from_index, to_list, to_index, count, player)
		if from_list == "input" and to_list == "input" then
			return count
		elseif from_list == "output" and to_list == "input" then
			if not trader_exists(player:get_player_name()) then
				return 0
			end
			local move_stack = inv:get_stack(from_list, from_index)
			if inv:get_stack(to_list, to_index):item_fits(move_stack) then
				return count
			end
		end
		return 0
	end,
	allow_put = function(inv, listname, index, stack, player)
		if listname == "input" then
			if not trader_exists(player:get_player_name()) then
				return 0
			else
				return stack:get_count()
			end
		else
			return 0
		end
	end,
	on_put = function(inv, listname, index, stack, player)
		update_offer(inv, player, true)
	end,
	on_move = function(inv, from_list, from_index, to_list, to_index, count, player)
		if from_list == "output" and to_list == "input" then
			inv:remove_item("input", inv:get_stack("wanted", 1))
			local wanted2 = inv:get_stack("wanted", 2)
			if not wanted2:is_empty() then
				inv:remove_item("input", inv:get_stack("wanted", 2))
			end
			minetest.sound_play("mobs_mc_villager_accept", {to_player = player:get_player_name()}, true)
		end
		update_offer(inv, player, true)
	end,
	on_take = function(inv, listname, index, stack, player)
		local accept
		local name = player:get_player_name()
		if listname == "output" then
			local wanted1 = inv:get_stack("wanted", 1)
			inv:remove_item("input", wanted1)
			local wanted2 = inv:get_stack("wanted", 2)
			if not wanted2:is_empty() then
				inv:remove_item("input", inv:get_stack("wanted", 2))
			end
			-- BEGIN OF SPECIAL HANDLING FOR COMPASS
			if wanted1:get_name() == COMPASS then
				for n=1, 2 do
					local input = inv:get_stack("input", n)
					if minetest.get_item_group(input:get_name(), "compass") ~= 0 then
						input:set_count(input:get_count() - wanted1:get_count())
						inv:set_stack("input", n, input)
						break
					end
				end
			end
			-- END OF SPECIAL HANDLING FOR COMPASS
			local trader = player_trading_with[name]
			local tradenum = player_tradenum[name]
			local trades
			if trader and trader._trades then
				trades = minetest.deserialize(trader._trades)
			end
			if trades then
				local trade = trades[tradenum]
				local unlock_stuff = false
				if not trade.traded_once then
					-- Unlock all the things if something was traded
					-- for the first time ever
					unlock_stuff = true
					trade.traded_once = true
				elseif trade.trade_counter == 0 and math.random(1,5) == 1 then
					-- Otherwise, 20% chance to unlock if used freshly reset trade
					unlock_stuff = true
				end
				local update_formspec = false
				if unlock_stuff then
					-- First-time trade unlock all trades and unlock next trade tier
					if trade.tier + 1 > trader._max_trade_tier then
						trader._max_trade_tier = trader._max_trade_tier + 1
						update_max_tradenum(trader)
						update_formspec = true
					end
					for t=1, #trades do
						trades[t].locked = false
						trades[t].trade_counter = 0
					end
					trader._locked_trades = 0
					-- Also heal trader for unlocking stuff
					-- TODO: Replace by Regeneration I
					trader.health = math.min(trader.hp_max, trader.health + 4)
				end
				trade.trade_counter = trade.trade_counter + 1
				-- Semi-randomly lock trade for repeated trade (not if there's only 1 trade)
				if trader._max_tradenum > 1 then
					if trade.trade_counter >= 12 then
						trade.locked = true
					elseif trade.trade_counter >= 2 then
						local r = math.random(1, math.random(4, 10))
						if r == 1 then
							trade.locked = true
						end
					end
				end

				if trade.locked then
					inv:set_stack("output", 1, "")
					update_formspec = true
					trader._locked_trades = trader._locked_trades + 1
					-- Check if we managed to lock ALL available trades. Rare but possible.
					if trader._locked_trades >= trader._max_tradenum then
						-- Emergency unlock! Unlock all other trades except the current one
						for t=1, #trades do
							if t ~= tradenum then
								trades[t].locked = false
								trades[t].trade_counter = 0
							end
						end
						trader._locked_trades = 1
						-- Also heal trader for unlocking stuff
						-- TODO: Replace by Regeneration I
						trader.health = math.min(trader.hp_max, trader.health + 4)
					end
				end
				trader._trades = minetest.serialize(trades)
				if update_formspec then
					show_trade_formspec(name, trader, tradenum)
				end
			else
				minetest.log("error", "[mobs_mc] Player took item from trader output but player_trading_with or player_tradenum is nil!")
			end

			accept = true
		elseif listname == "input" then
			update_offer(inv, player, false)
		end
		if accept then
			minetest.sound_play("mobs_mc_villager_accept", {to_player = name}, true)
		else
			minetest.sound_play("mobs_mc_villager_deny", {to_player = name}, true)
		end
	end,
}

minetest.register_on_joinplayer(function(player)
	local name = player:get_player_name()
	player_tradenum[name] = 1
	player_trading_with[name] = nil

	-- Create or get player-specific trading inventory
	local inv = minetest.get_inventory({type="detached", name="mobs_mc:trade_"..name})
	if not inv then
		inv = minetest.create_detached_inventory("mobs_mc:trade_"..name, trade_inventory, name)
	end
	inv:set_size("input", 2)
	inv:set_size("output", 1)
	inv:set_size("wanted", 2)
	inv:set_size("offered", 1)
end)

--[=======[ MOB REGISTRATION AND SPAWNING ]=======]

mobs:register_mob("mobs_mc:villager", {
	type = "npc",
	spawn_class = "passive",
	hp_min = 20,
	hp_max = 20,
	collisionbox = {-0.3, -0.01, -0.3, 0.3, 1.94, 0.3},
	visual = "mesh",
	mesh = "mobs_mc_villager.b3d",
	textures = {
	{
		"mobs_mc_villager.png",
		"mobs_mc_villager.png", --hat
	},
	{
		"mobs_mc_villager_farmer.png",
		"mobs_mc_villager_farmer.png", --hat
	},
	{
		"mobs_mc_villager_priest.png",
		"mobs_mc_villager_priest.png", --hat
	},
	{
		"mobs_mc_villager_librarian.png",
		"mobs_mc_villager_librarian.png", --hat
	},
	{
		"mobs_mc_villager_butcher.png",
		"mobs_mc_villager_butcher.png", --hat
	},
	{
		"mobs_mc_villager_smith.png",
		"mobs_mc_villager_smith.png", --hat
	},
	},
	visual_size = {x=3, y=3},
	makes_footstep_sound = true,
	walk_velocity = 1.2,
	run_velocity = 2.4,
	drops = {},
	can_despawn = false,
	-- TODO: sounds
	animation = {
		stand_speed = 25,
		stand_start = 40,
		stand_end = 59,
		walk_speed = 25,
		walk_start = 0,
		walk_end = 40,
		run_speed = 25,
		run_start = 0,
		run_end = 40,
		die_speed = 15,
		die_start = 210,
		die_end = 220,
		die_loop = false,
	},
	view_range = 16,
	fear_height = 4,
	jump = true,
	walk_chance = DEFAULT_WALK_CHANCE,
	on_rightclick = function(self, clicker)
		-- Initiate trading
		local name = clicker:get_player_name()
		self._trading_players[name] = true

		init_trader_vars(self)
		if self._trades == nil then
			init_trades(self)
		end
		update_max_tradenum(self)
		if self._trades == false then
			-- Villager has no trades, rightclick is a no-op
			return
		end

		player_trading_with[name] = self

		local inv = minetest.get_inventory({type="detached", name="mobs_mc:trade_"..name})
		if not inv then
			return
		end

		set_trade(self, clicker, inv, 1)

		show_trade_formspec(name, self)

		-- Behaviour stuff:
		-- Make villager look at player and stand still
		local selfpos = self.object:get_pos()
		local clickerpos = clicker:get_pos()
		local dir = vector.direction(selfpos, clickerpos)
		self.object:set_yaw(minetest.dir_to_yaw(dir))
		stand_still(self)
	end,

	_player_scan_timer = 0,
	_trading_players = {}, -- list of playernames currently trading with villager (open formspec)
	do_custom = function(self, dtime)
		-- Stand still if player is nearby.
		if not self._player_scan_timer then
			self._player_scan_timer = 0
		end
		self._player_scan_timer = self._player_scan_timer + dtime
		-- Check infrequently to keep CPU load low
		if self._player_scan_timer > PLAYER_SCAN_INTERVAL then
			self._player_scan_timer = 0
			local selfpos = self.object:get_pos()
			local objects = minetest.get_objects_inside_radius(selfpos, PLAYER_SCAN_RADIUS)
			local has_player = false
			for o, obj in pairs(objects) do
				if obj:is_player() then
					has_player = true
					break
				end
			end
			if has_player then
				minetest.log("verbose", "[mobs_mc] Player near villager found!")
				stand_still(self)
			else
				minetest.log("verbose", "[mobs_mc] No player near villager found!")
				self.walk_chance = DEFAULT_WALK_CHANCE
				self.jump = true
			end
		end
	end,

	on_spawn = function(self)
		init_trader_vars(self)
	end,
	on_die = function(self, pos)
		-- Close open trade formspecs and give input back to players
		local trading_players = self._trading_players
		for name, _ in pairs(trading_players) do
			minetest.close_formspec(name, "mobs_mc:trade_"..name)
			local player = minetest.get_player_by_name(name)
			if player then
				return_fields(player)
			end
		end
	end,
})



mobs:spawn_specific("mobs_mc:villager", mobs_mc.spawn.village, {"air"}, 0, minetest.LIGHT_MAX+1, 30, 20, 4, mobs_mc.spawn_height.water+1, mobs_mc.spawn_height.overworld_max)

-- spawn eggs
mobs:register_egg("mobs_mc:villager", S("Villager"), "mobs_mc_spawn_icon_villager.png", 0)
