local S = minetest.get_translator(minetest.get_current_modname())
--[[
there are strings in meta, which are being used to see which effect will be given to the player(s)
Valid strings:
    swiftness
    leaping
    strenght
    regeneration
]]--


local color_list = {"cdf4e9","f9fcfb","7c5e3d","1826c9","16f4f4","f483fc","9712bc","ea1212","adadad","535454","19e52a","549159","ef8813","ebf704","000000","e502d6","e8e3e3"}

local function get_beacon_beam(glass_nodename)
    if string.match(glass_nodename, "cyan") then
        return "mcl_beacons:beacon_beam_cdf4e9"
    elseif string.match(glass_nodename,"white") then
        return "mcl_beacons:beacon_beam_f9fcfb"
    elseif string.match(glass_nodename,"brown") then
        return "mcl_beacons:beacon_beam_7c5e3d"
    elseif string.match(glass_nodename,"blue") and not string.match(glass_nodename, "light") then
        return "mcl_beacons:beacon_beam_1826c9"
    elseif string.match(glass_nodename,"light_blue") then
        return "mcl_beacons:beacon_beam_16f4f4"
    elseif string.match(glass_nodename,"pink") then
        return "mcl_beacons:beacon_beam_f483fc"
    elseif string.match(glass_nodename, "purple") then
        return "mcl_beacons:beacon_beam_9712bc"
    elseif string.match(glass_nodename, "red") then
        return "mcl_beacons:beacon_beam_ea1212"
    elseif string.match(glass_nodename, "silver") then
        return "mcl_beacons:beacon_beam_adadad"
    elseif string.match(glass_nodename, "gray") then
        return "mcl_beacons:beacon_beam_535454"
    elseif string.match(glass_nodename, "lime") then
        return "mcl_beacons:beacon_beam_19e52a"
    elseif string.match(glass_nodename, "green") then
        return "mcl_beacons:beacon_beam_549159"
    elseif string.match(glass_nodename, "orange") then
        return "mcl_beacons:beacon_beam_ef8813"
    elseif string.match(glass_nodename, "yellow") then
        return "mcl_beacons:beacon_beam_ebf704"
    elseif string.match(glass_nodename, "black") then
        return "mcl_beacons:beacon_beam_000000"
    elseif string.match(glass_nodename, "magenta") then
        return "mcl_beacons:beacon_beam_e502d6"
    else
        return "mcl_beacons:beacon_beam_e8e3e3"
    end
end



for _, color in ipairs(color_list) do
    minetest.register_node("mcl_beacons:beacon_beam_"..color, {
        tiles = {"^[colorize:#"..color},
        drawtype = "nodebox",
        node_box = {
            type = "fixed",
            fixed = {
                {-0.1250, -0.5000, -0.1250, 0.1250, 0.5000, 0.1250}
            }
        },
        light_source = 15,
        walkable = false,
        groups = {not_in_creative_inventory=1},
        _mcl_blast_resistance = 1200,
    })
    mesecon.register_mvps_stopper("mcl_beacons:beacon_beam_"..color)
end


local formspec_string=
    "size[11,14]"..

    "label[4.5,0.5;"..minetest.formspec_escape(S("Beacon:")).."]"..
    "label[0.5,1;"..minetest.formspec_escape(S("Primary Power:")).."]"..
    "label[0.5,8.25;"..minetest.formspec_escape( S("Inventory:")).."]"..

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
    "item_image[5.8,7;1,1;mcl_nether:netherite_ingot]"..

    mcl_formspec.get_itemslot_bg(7.2,7,1,1)..
	"list[context;input;7.2,7;1,1;]"..
	mcl_formspec.get_itemslot_bg(1,9,9,3)..
    "list[current_player;main;1,9;9,3;9]"..
	mcl_formspec.get_itemslot_bg(1,12.5,9,1)..
    "list[current_player;main;1,12.5;9,1;]"

local function remove_beacon_beam(pos)
    for y=pos.y+1, pos.y+401 do
        local node = minetest.get_node({x=pos.x,y=y,z=pos.z})
        if node.name ~= "air" and node.name ~= "mcl_core:bedrock" and node.name ~= "mcl_core:void" then
            if node.name == "ignore" then
                minetest.get_voxel_manip():read_from_map({x=pos.x,y=y,z=pos.z}, {x=pos.x,y=y,z=pos.z})
                node = minetest.get_node({x=pos.x,y=y,z=pos.z})
            end
            
            if string.match(node.name,"mcl_beacons:beacon_beam_") then
                minetest.remove_node({x=pos.x,y=y,z=pos.z})
            end
        end
    end
end

local function beacon_blockcheck(pos)
    for y_offset = 1,4 do
        local block_y = pos.y - y_offset
        for block_x = (pos.x-y_offset),(pos.x+y_offset) do
            for block_z = (pos.z-y_offset),(pos.z+y_offset) do
                local valid_block = false --boolean which stores if block is valid or not
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

local function effect_player(effect,pos,power_level, effect_level,player)
    local distance =  vector.distance(player:get_pos(), pos)
    if distance > (power_level+1)*10 then return end
    if effect == "swiftness" then
        mcl_potions.swiftness_func(player,effect_level,16)
    elseif effect == "leaping" then
        mcl_potions.leaping_func(player, effect_level, 16)
    elseif effect == "strenght" then
        mcl_potions.strength_func(player, effect_level, 16)
    elseif effect == "regeneration" then
        mcl_potions.regeneration_func(player, effect_level, 16)
    end
end

local function globalstep_function(pos,player)
    local meta = minetest.get_meta(pos) 
    local power_level = beacon_blockcheck(pos)
    local effect_string =  meta:get_string("effect") 
    if meta:get_int("effect_level") == 2 and power_level < 4 then
        return
    else
        local obstructed = false
        for y=pos.y+1, pos.y+301 do
            local nodename = minetest.get_node({x=pos.x,y=y, z = pos.z}).name
            if nodename ~= "mcl_core:bedrock" and nodename ~= "air" and nodename ~= "ignore"  and nodename ~= "mcl_core:void" then --ignore means not loaded, let's just assume that's air
                if not string.match(nodename,"mcl_beacons:beacon_beam_") then
                    if minetest.get_item_group(nodename,"glass") == 0 then
                        obstructed = true
                        remove_beacon_beam(pos)
                        return
                    end
                end
            end
        end
        if obstructed then
            return
        end
        effect_player(effect_string,pos,power_level,meta:get_int("effect_level"),player)
    end
end

minetest.register_node("mcl_beacons:beacon", {
    description = S"Beacon",
    drawtype = "mesh",
    collisionbox = {-0.5, -0.5, -0.5, 0.5, 0.5, 0.5},
    mesh = "mcl_beacon.b3d",
    tiles = {"beacon_UV.png"},
    on_construct = function(pos)
        local meta = minetest.get_meta(pos)
        local inv = meta:get_inventory()
        inv:set_size("input", 1)
        local form = formspec_string
		meta:set_string("formspec", form)
    end,
    on_destruct = function(pos)
        local meta = minetest.get_meta(pos)
        local input = meta:get_inventory():get_stack("input",1)
        if not input:is_empty() then
            local p = {x=pos.x+math.random(0, 10)/10-0.5, y=pos.y, z=pos.z+math.random(0, 10)/10-0.5} --from mcl_anvils
            minetest.add_item(p, input)
        end
        remove_beacon_beam(pos)
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
                if power_level == 4 then
                    awards.unlock(sender:get_player_name(),"mcl:maxed_beacon")
                end
                awards.unlock(sender:get_player_name(),"mcl:beacon")
                input:take_item()
                inv:set_stack("input",1,input)
                
                local beam_itemstring = "mcl_beacons:beacon_beam_e8e3e3"
                remove_beacon_beam(pos)
                for y = pos.y +1, pos.y + 401 do
                    local node = minetest.get_node({x=pos.x,y=y,z=pos.z})
                    if node.name == ignore then
                        minetest.get_voxel_manip():read_from_map({x=pos.x,y=y,z=pos.z}, {x=pos.x,y=y,z=pos.z})
                        node = minetest.get_node({x=pos.x,y=y,z=pos.z})
                    end
                    

                    if y == pos.y+1 then
                        if  minetest.get_item_group(node.name, "glass") ~= 0 then
                            beam_itemstring = get_beacon_beam(node.name)
                        end
                    end

                    if node.name == "air" then
                        minetest.set_node({x=pos.x,y=y,z=pos.z},{name=beam_itemstring})
                    end
                end
                globalstep_function(pos,sender)--call it once outside the globalstep so the player gets the effect right after selecting it
            end
        end
    end,
    light_source = 15,
    groups = {handy=1},
    drop = "mcl_beacons:beacon",
    sounds = mcl_sounds.node_sound_glass_defaults(),
    _mcl_hardness = 3,
})

mesecon.register_mvps_stopper("mcl_beacons:beacon")
mcl_wip.register_wip_item("mcl_beacons:beacon")

beacon_blocklist = {"mcl_core:diamondblock","mcl_core:ironblock","mcl_core:goldblock","mcl_core:emeraldblock","mcl_nether:netheriteblock"}--this is supposed to be a global, don't change that!
beacon_fuellist ={"mcl_core:diamond","mcl_core:emerald","mcl_core:iron_ingot","mcl_core:gold_ingot","mcl_nether:netherite_ingot"}

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
            local player_pos = player:get_pos()
            local pos_list = minetest.find_nodes_in_area({x=player_pos.x-50, y=player_pos.y-50, z=player_pos.z-50}, {x=player_pos.x+50, y=player_pos.y+50, z=player_pos.z+50},"mcl_beacons:beacon")
            for _, pos in ipairs(pos_list) do
                globalstep_function(pos,player)
            end
        end
        timer = 0
    end
end)

minetest.register_craft({
    output = "mcl_beacons:beacon",
    recipe = { 
        {"mcl_core:glass", "mcl_core:glass", "mcl_core:glass"},
        {"mcl_core:glass", "mcl_mobitems:nether_star", "mcl_core:glass"},
        {"mcl_core:obsidian", "mcl_core:obsidian", "mcl_core:obsidian"}
    }
})