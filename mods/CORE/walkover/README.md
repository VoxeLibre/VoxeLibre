WalkOver
--------

Some mode developers have shown an interest in having an on_walk_over event. This is useful for pressure-plates and the like.

See this issue - https://github.com/minetest/minetest/issues/247

I have implemented a server_side version in lua using globalstep which people might find useful. Of course this would better implemented via a client-based "on walk over", but it is sufficient for my needs now.

Example Usage
-------------

    minetest.register_node("somemod:someblock", {
           description = key,
           tiles = {"somemod_someblock.png"},
               groups = {cracky=1},
                 on_walk_over = function(pos, node, player)
                
                        minetest.chat_send_player(player, "Hey! Watch it!")
                 end
    })

 