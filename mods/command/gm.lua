local god_mode = false

vanished_players = {}

minetest.register_privilege("vanish", "Allow to use /vanish command")

minetest.register_chatcommand("vanish", {
    params = "",
    description = "Make user invisible at eye of all",
    privs = {vanish = true},
    func = function(name, param)
        local prop
        vanished_players[name] = not vanished_players[name]
        
        if vanished_players[name] then
            prop = {visual_size = {x=0, y=0}, collisionbox = {0,0,0,0,0,0}}
	    minetest.chat_send_player(name, "Vannish Command: You are Invisible now")
        else
            -- default player size
            prop = {visual_size = {x=1, y=1},
            collisionbox = {-0.35, -1, -0.35, 0.35, 1, 0.35}}
	    minetest.chat_send_player(name, "Vannish Command: You are Visible now")
        end

        minetest.get_player_by_name(name):set_properties(prop)
    end
})

minetest.register_privilege("god", "Allow to use /god command")

minetest.register_chatcommand("god", {

    params = "",
    description = "Make you invincible",
    privs = {god = true},
    func = function(name, param)
        local prop
        
	local player = minetest.get_player_by_name(name)
        
        if god_mode == false then
            player:set_hp(9999)
	    minetest.item_eat(9999)
	    minetest.chat_send_player(name, "God Command: You are Invincible")
        else
            player:set_hp(20)
	    minetest.chat_send_player(name, "God Command: You can die now")
        end

        minetest.get_player_by_name(name):set_properties(prop)
    end
})

