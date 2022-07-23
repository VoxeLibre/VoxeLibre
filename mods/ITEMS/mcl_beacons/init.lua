--[[
there are strings in meta, which are being used to see which effect will be given to the player(s)
Valid strings:
    swiftness
    leaping
    strenght
    regeneration
]]--
--TODO: add beacon beam
--TODO: add translation


local formspec_string=
    "size[11,14]"..

    "label[4.5,0.5;Beacon:]"..
    "label[0.5,1;Primary Power:]"..
    "label[0.5,8.25;Inventory:]"..

    "image[1,1.5;1,1;custom_beacom_symbol_4.png]"..
    "image[1,3;1,1;custom_beacom_symbol_3.png]"..
    "image[1,4.5;1,1;custom_beacom_symbol_2.png]"..
    "image[1,6;1,1;custom_beacom_symbol_1.png]"..

    "image_button[5.2,1.5;1,1;mcl_potions_effect_swift.png;swiftness;]"..
    "image_button[5.2,3;1,1;mcl_potions_effect_leaping.png;leaping;]"..
    "image_button[5.2,4.5;1,1;mcl_potions_effect_strong.png;strenght;]"..
    "image_button[5.2,6;1,1;mcl_potions_effect_regenerating.png;regeneration;]"..

    "item_image[1,7;1,1;mcl_core:diamond]"..
    "item_image[2.2,7;1,1;mcl_core:emerald]"..
    "item_image[3.4,7;1,1;mcl_core:iron_ingot]"..
    "item_image[4.6,7;1,1;mcl_core:gold_ingot]"..

    mcl_formspec.get_itemslot_bg(6,7,1,1)..
	"list[context;input;6,7;1,1;]"..
	mcl_formspec.get_itemslot_bg(1,9,9,3)..
    "list[current_player;main;1,9;9,3;9]"..
	mcl_formspec.get_itemslot_bg(1,12.5,9,1)..
    "list[current_player;main;1,12.5;9,1;]"



local function beacon_blockcheck(pos)
    for y_offset = 1,4 do
        local block_y = pos.y - y_offset
        for block_x = (pos.x-y_offset),(pos.x+y_offset) do
            for block_z = (pos.z-y_offset),(pos.z+y_offset) do
                local valid_block = false --boolean to which stores if block is valid or not
                for _, beacon_block in pairs(beacon_blocklist) do
                    if beacon_block == minetest.get_node({x=block_x,y=block_y,z=block_z}).name and not valid_block then --is the block in the pyramid a valid beacon block
                        valid_block =true
                    end
                end
                if not valid_block then
                    return y_offset -1 --the last layer is complete, this one is missing or incomplete
                end
            end
        end
        if y_offset == 4 then --all checks are done, beacon is maxed
            return y_offset
        end
    end
end

local function effect_player(effect,pos,power_level, effect_level)
    local all_objects = minetest.get_objects_inside_radius(pos, (power_level+1)*10)
    for _,obj2 in ipairs(all_objects) do
        if obj2:is_player() then
            if effect == "swiftness" then
                mcl_potions.swiftness_func(obj2,effect_level,16)
               return
           elseif effect == "leaping" then
               mcl_potions.leaping_func(obj2, effect_level, 16)
               return
           elseif effect == "strenght" then
               mcl_potions.strength_func(obj2, effect_level, 16)
               return
           elseif effect == "regeneration" then
               mcl_potions.regeneration_func(obj2, effect_level, 16)
               return
           end
        end
    end
end

local function globalstep_function(pos)
    local meta = minetest.get_meta(pos) 
    local power_level = beacon_blockcheck(pos)
    local effect_string =  meta:get_string("effect") 
    if meta:get_int("effect_level") == 2 and power_level < 4 then
        return
    else
        local obstructed = false
        for y=pos.y+1, pos.y+301 do
            if y >= 31000 then return end
            local nodename = minetest.get_node({x=pos.x,y=y, z = pos.z}).name
            if nodename ~= "mcl_core:bedrock" and nodename ~= "air" and nodename ~= "ignore" then --ignore means not loaded, let's just assume that's air
                obstructed = true
                return
            end
        end
        if obstructed then return end
        effect_player(effect_string,pos,power_level,meta:get_int("effect_level"))
    end
end

minetest.register_node("mcl_beacons:beacon", {
    --glasslike drawtype?
    description = "Beacon",
    tiles = {
		"beacon_top.png",
		"beacon_bottom.png",
		"beacon_side_1.png",
		"beacon_side_2.png",
		"beacon_side_3.png",
		"beacon_side_4.png"
	},
    on_construct = function(pos)
        local meta = minetest.get_meta(pos)
        local inv = meta:get_inventory()
        inv:set_size("input", 1)
        local form = formspec_string
		meta:set_string("formspec", form)
    end,
    on_receive_fields = function(pos, formname, fields, sender)
        if fields.swiftness or fields.regeneration or fields.leaping or fields.strenght then
            local sender_name = sender:get_player_name()
            local power_level = beacon_blockcheck(pos)
            if minetest.is_protected(pos, sender_name) then
			    minetest.record_protection_violation(pos, sender_name)
			    return
		    elseif power_level == 0 then
                return
            end

            local meta = minetest.get_meta(pos)
            local inv = meta:get_inventory()
            local input = inv:get_stack("input",1)
        
            if input:is_empty() then
                return
            end

            local valid_item = false

            for _, item in ipairs(beacon_fuellist) do
                if input:get_name() == item then
                    valid_item = true
                end
            end

            if not valid_item then
                return
            end

            local successful = false
            if fields.swiftness then
                if power_level == 4 then
                    minetest.get_meta(pos):set_int("effect_level",2)
                else
                    minetest.get_meta(pos):set_int("effect_level",1)
                end
                minetest.get_meta(pos):set_string("effect","swiftness")
                successful = true
            elseif fields.leaping and power_level >= 2 then
                if power_level == 4 then
                    minetest.get_meta(pos):set_int("effect_level",2)
                else
                    minetest.get_meta(pos):set_int("effect_level",1)
                end
                minetest.get_meta(pos):set_string("effect","leaping")
                successful = true
            elseif fields.strenght and power_level >= 3 then
                if power_level == 4 then
                    minetest.get_meta(pos):set_int("effect_level",2)
                else
                    minetest.get_meta(pos):set_int("effect_level",1)
                end
                minetest.get_meta(pos):set_string("effect","strenght")
                successful = true
            elseif fields.regeneration and power_level == 4 then
                minetest.get_meta(pos):set_int("effect_level",2)
                minetest.get_meta(pos):set_string("effect","regeneration")
                successful = true
            end
            if successful then
                input:take_item()
                inv:set_stack("input",1,input)
                globalstep_function(pos)--call it once outside the globalstep so the player gets the effect right after selecting it
            end
        end
    end,
    light_source = 15,
    sounds = mcl_sounds.node_sound_glass_defaults(),
})

mesecon.register_mvps_stopper("mcl_beacons:beacon")
mcl_wip.register_wip_item("mcl_beacons:beacon")

beacon_blocklist = {"mcl_core:diamondblock","mcl_core:ironblock","mcl_core:goldblock","mcl_core:emeraldblock"}--this is supposed to be a global, don't change that! || TODO: add netherite blocks once implemented!
beacon_fuellist ={"mcl_core:diamond","mcl_core:emerald","mcl_core:iron_ingot","mcl_core:gold_ingot"}

function register_beaconblock (itemstring)--API function for other mods
    table.insert(beacon_blocklist, itemstring)
end

function register_beaconfuel(itemstring)
    table.insert(beacon_fuellist, itemstring)
end

local timer = 0

minetest.register_globalstep(function(dtime)
    timer = timer + dtime
    if timer >= 3  then
        for _, player in ipairs(minetest.get_connected_players()) do
            local player_pos = player.get_pos(player)
            local pos_list = minetest.find_nodes_in_area({x=player_pos.x-50, y=player_pos.y-50, z=player_pos.z-50}, {x=player_pos.x+50, y=player_pos.y+50, z=player_pos.z+50},"mcl_beacons:beacon")
            for _, pos in ipairs(pos_list) do
                globalstep_function(pos)
            end
        end
        timer = 0
    end
end)