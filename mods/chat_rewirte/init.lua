
-- config zone {{{
formats = {
-- ["MATCH"]        = {"FORMAT"                   COLOR     PRIV}, --
   ["#(.+)"]       = {"*** %s: %s ***",          0xFFFF00, "server"},
}
DEFAULT_FORMAT     = "%s: %s" 
DEFAULT_COLOR      = 0xEEF3EE
GM_PREFIX          = "[Admin] "
MESSAGES_ON_SCREEN = 10
MAX_LENGTH         = 100
LEFT_INDENT        = 0.01
TOP_INDENT         = 0.92
FONT_WIDTH         = 12
FONT_HEIGHT        = 24
-- config zone }}}

firsthud = nil

function addMessage(player, new_text, new_color)
    local temp_text
    local temp_color
    local hud
    for id = firsthud, (firsthud+MESSAGES_ON_SCREEN-1) do
        hud = player:hud_get(id)
        if hud and hud.name == "chat" then
            temp_text = hud.text
            temp_color = hud.number
            player:hud_change(id, "number", new_color)
            player:hud_change(id, "text", new_text)
            new_text = temp_text
            new_color = temp_color
        end
    end
end

function sendMessage(player, message, color)
    local splitter
    while message:len() > MAX_LENGTH do
        splitter = string.find (message, " ", MAX_LENGTH)
        if splitter == nil then
            splitter = MAX_LENGTH
        end
        addMessage(player, message:sub(0,splitter), color)
        message = message:sub(splitter+1)
    end
    addMessage(player, message, color)
end

minetest.register_on_joinplayer(function(player)
    minetest.after(2, function(player)
        for i = 1, MESSAGES_ON_SCREEN do
            local hud_id = player:hud_add({
                hud_elem_type = "text",
                text = "",
                position = {x = LEFT_INDENT, y = TOP_INDENT},
                name = "chat",
                scale = {x=500, y=50},
                number = 0xFFFFFF,
                item = 0,
                direction = 0,
                alignment = {x=1, y=0},
                offset = {x=0, y=-i*FONT_HEIGHT}
            })
            if not firsthud then
                firsthud = hud_id
            end
        end
        end, player)
end)


minetest.register_on_chat_message(function(name, message)
    fmt = DEFAULT_FORMAT 
    color = DEFAULT_COLOR
    pl = minetest.get_player_by_name(name)
    pls = minetest.get_connected_players()
    -- formats (see config zone)
    for m, f in pairs(formats) do
        submes = string.match(message, m)
        if submes then
            if not f[3] then  -- if PRIV==nil
                fmt = f[1]
                color = f[2]
                break
            elseif minetest.check_player_privs(name, {[f[3]]=true}) then
                fmt = f[1]
                color = f[2]
                break
            end
        end
    end

    if not submes then
        submes = message
    end

    
    if minetest.check_player_privs(name, {["server"]=true,}) then
        name = GM_PREFIX .. name
    end
	
    for i = 1, #pls do
        sendMessage(pls[i], string.format(fmt, name, submes), color)
    end

    return true
end)
