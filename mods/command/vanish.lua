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
        else
            -- default player size
            prop = {visual_size = {x=1, y=1},
            collisionbox = {-0.35, -1, -0.35, 0.35, 1, 0.35}}
        end

        minetest.get_player_by_name(name):set_properties(prop)
    end
})
