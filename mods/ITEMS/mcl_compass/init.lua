local stereotype_frame = 18


local S = minetest.get_translator(minetest.get_current_modname())

mcl_compass = {}

local compass_frames = 32

local function get_far_node(pos, itemstack) --code from minetest dev wiki: https://dev.minetest.net/minetest.get_node, some edits have been made to add a cooldown for force loads
	local node = minetest.get_node(pos)
	if node.name == "ignore" then
		tstamp = tonumber(itemstack:get_meta():get_string("last_forceload"))
		if tstamp == nil then --this is only relevant for new lodestone compasses, the ones that have never performes a forceload yet
			itemstack:get_meta():set_string("last_forceload", tostring(os.time(os.date("!*t"))))
			tstamp = tonumber(os.time(os.date("!*t")))
		end
		if tonumber(os.time(os.date("!*t"))) - tstamp > 180 then --current time in secounds - old time in secounds, if it is over 180 (3 mins): forceload
			itemstack:get_meta():set_string("last_forceload", tostring(os.time(os.date("!*t"))))
			minetest.get_voxel_manip():read_from_map(pos, pos)
			node = minetest.get_node(pos)
			minetest.log("forceloaded, cooldown reset!")
		else
			minetest.log("cooldown not over yet")
			node = {name="mcl_compass:lodestone"} --cooldown not over yet, pretend like there is something...
		end
	end
	return node
end


--Not sure spawn point should be dymanic (is it in mc?)
--local default_spawn_settings = minetest.settings:get("static_spawnpoint")

-- Timer for random compass spinning
local random_timer = 0
local random_timer_trigger = 0.5 -- random compass spinning tick in seconds. Increase if there are performance problems

local random_frame = math.random(0, compass_frames-1)

function mcl_compass.get_compass_image(pos, dir, itemstack)
	if not itemstack then
		minetest.log("WARNING: mcl_compass.get_compass_image() was called without itemstack, returning random frame!")
		return random_frame
	end

	local lodestone_pos = minetest.string_to_pos(itemstack:get_meta():get_string("pointsto"))

	if lodestone_pos then --lodestone meta present
		local _, dim = mcl_worlds.y_to_layer(lodestone_pos.y)
		local _, playerdim = mcl_worlds.y_to_layer(pos.y)
		
		if dim == playerdim then --Check if player and compass target are in the same dimension, above check is just if the diemension is valid for the non lodestone compass

			if get_far_node(lodestone_pos, itemstack).name == "mcl_compass:lodestone" then --check if lodestone still exists
  				local angle_north = math.deg(math.atan2(lodestone_pos.x - pos.x, lodestone_pos.z - pos.z))
				if angle_north < 0 then angle_north = angle_north + 360 end
				local angle_dir = -math.deg(dir)
				local angle_relative = (angle_north - angle_dir + 180) % 360
				return math.floor((angle_relative/11.25) + 0.5) % compass_frames .. "_lodestone"
			else -- lodestone got destroyed
				return random_frame .. "_lodestone"
			end		   
		else
			return random_frame .. "_lodestone"
		end
	else --no lodestone meta, normal compass....
		local spawn = {x = 0, y=0, z=0} --before you guys tell me that the normal compass no points to real spawn, it always pointed to 0 0
		local ssp = minetest.setting_get_pos("static_spawnpoint")
		if ssp then
			spawn = ssp
			if type(spawn) ~= "table" or type(spawn.x) ~= "number" or type(spawn.y) ~= "number" or type(spawn.z) ~= "number" then
				spawn = {x=0,y=0,z=0}
			end
		end

		if mcl_worlds.compass_works(pos) then --is the player in the overworld?
			local angle_north = math.deg(math.atan2(spawn.x - pos.x, spawn.z - pos.z))
			if angle_north < 0 then angle_north = angle_north + 360 end
			local angle_dir = -math.deg(dir)
			local angle_relative = (angle_north - angle_dir + 180) % 360
			return math.floor((angle_relative/11.25) + 0.5) % compass_frames
		else
			return random_frame
		end

	end
end

minetest.register_globalstep(function(dtime)
	random_timer = random_timer + dtime

	if random_timer >= random_timer_trigger then
		random_frame = (random_frame + math.random(-1, 1)) % compass_frames
		random_timer = 0
	end
	for _,player in pairs(minetest.get_connected_players()) do
		local function has_compass(player)
			for _,stack in pairs(player:get_inventory():get_list("main")) do
				if minetest.get_item_group(stack:get_name(), "compass") ~= 0 then
					return true
				end
			end
			return false
		end
		if has_compass(player) then
			local pos = player:get_pos()

			for j,stack in pairs(player:get_inventory():get_list("main")) do
				if minetest.get_item_group(stack:get_name(), "compass") ~= 0 then
					local compass_image = mcl_compass.get_compass_image(pos, player:get_look_horizontal(), stack)
					if minetest.get_item_group(stack:get_name(), "compass")-1 ~= compass_image and minetest.get_item_group(stack:get_name(), "compass")-1 .. "_lodestone" ~=compass_image then --Explaination: First check for normal compasses, secound check for lodestone ones
						local itemname = "mcl_compass:"..compass_image
						--minetest.log(os.time(os.date("!*t")))
						stack:set_name(itemname)
						player:get_inventory():set_stack("main", j, stack)
					end
				end

			end
		end
	end
end)

local images = {}
for frame = 0, compass_frames-1 do
	local s = string.format("%02d", frame)
	table.insert(images, "mcl_compass_compass_"..s..".png")
end

local doc_mod = minetest.get_modpath("doc")

for i,img in ipairs(images) do
	local inv = 1
	if i == stereotype_frame then
		inv = 0
	end
	local use_doc, longdesc, tt
	--Why is there no usage help? This should be fixed.
	--local usagehelp
	use_doc = i == stereotype_frame
	if use_doc then
		tt = S("Points to the world origin")
		longdesc = S("Compasses are tools which point to the world origin (X=0, Z=0) or the spawn point in the Overworld.")
	end
	local itemstring = "mcl_compass:"..(i-1)
	minetest.register_craftitem(itemstring, {
		description = S("Compass"),
		_tt_help = tt,
		_doc_items_create_entry = use_doc,
		_doc_items_longdesc = longdesc,
		--_doc_items_usagehelp = usagehelp,
		inventory_image = img,
		wield_image = img,
		stack_max = 64,
		groups = {not_in_creative_inventory=inv, compass=i, tool=1, disable_repair=1 }
	})
	
	minetest.register_craftitem(itemstring .. "_lodestone", {
		description = S("Lodestone Compass"),
		_tt_help = tt,
		_doc_items_create_entry = use_doc,
		_doc_items_longdesc = longdesc,
		--_doc_items_usagehelp = usagehelp,
		inventory_image = img .. "^[colorize:purple:50",
		wield_image = img .. "^[colorize:purple:50",
		stack_max = 64,
		groups = {not_in_creative_inventory=1, compass=i, tool=1, disable_repair=1 }
	})

	-- Help aliases. Makes sure the lookup tool works correctly
	if not use_doc and doc_mod then
		doc.add_entry_alias("craftitems", "mcl_compass:"..(stereotype_frame-1), "craftitems", itemstring)
	end
end

minetest.register_craft({
	output = "mcl_compass:"..stereotype_frame,
	recipe = {
		{"", "mcl_core:iron_ingot", ""},
		{"mcl_core:iron_ingot", "mesecons:redstone", "mcl_core:iron_ingot"},
		{"", "mcl_core:iron_ingot", ""}
	}
})

minetest.register_craft({
	output = "mcl_compass:lodestone",
	recipe = {
		{"mcl_core:stonebrickcarved","mcl_core:stonebrickcarved","mcl_core:stonebrickcarved"},
		{"mcl_core:stonebrickcarved", "mcl_core:diamondblock", "mcl_core:stonebrickcarved"},
		{"mcl_core:stonebrickcarved", "mcl_core:stonebrickcarved", "mcl_core:stonebrickcarved"}
	}
})

minetest.register_alias("mcl_compass:compass", "mcl_compass:"..stereotype_frame)

-- Export stereotype item for other mods to use
mcl_compass.stereotype = "mcl_compass:"..tostring(stereotype_frame)


minetest.register_node("mcl_compass:lodestone",{
	description=S("Lodestone"),
	on_rightclick = function(pos, node, player, itemstack)
		if itemstack.get_name(itemstack).match(itemstack.get_name(itemstack),"mcl_compass:") then
			if itemstack.get_name(itemstack) ~= "mcl_compass:lodestone" then
				itemstack:get_meta():set_string("pointsto", minetest.pos_to_string(pos))
			end
		end
	end,
	tiles = {
		"lodestone_top.png",
		"lodestone_bottom.png",
		"lodestone_side1.png",
		"lodestone_side2.png",
		"lodestone_side3.png",
		"lodestone_side4.png"
	},
	groups = {pickaxey=1, material_stone=1},
	_mcl_hardness = 1.5,
	_mcl_blast_resistance = 6,
	sounds = mcl_sounds.node_sound_stone_defaults()
})
