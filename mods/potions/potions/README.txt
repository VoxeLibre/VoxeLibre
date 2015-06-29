--Potions by Traxie21--
--This mod provides no default potions.  If you would like some, download potionspack at github.com/Traxie21/potionspack--


--API DOCUMENTATION--

Potion Registering Format:

potions.register_potion(NAME, COLOR, EXPIRE TIME, ACTIVATION FUNCTION, EXPIRE FUNCTION)

NAME: Name of potion. Invalid characeters are automagically stripped from it.

COLOR: Color of potion image in-game, available colors: black, brown, cyan, darkblue, darkgrey, lightgrey, darkred, dull, green, orange, pink, purple, red, white, and yellow.

EXPIRE TIME: Number in seconds.

ACTIVATION FUNCTION: The function that is run when the ground is right-clicked with the potion.

EXPIRE FUNCTION: The function that is run when the expire time runs out.


--EXAMPLE--

potions.register_potion("Anti Gravity", "purple", 60,
function(itemstack, user, pointed_thing) 
	user:set_physics_override(3, 1.5, 0.5)
	minetest.chat_send_player(user:get_player_name(), "You have been blessed with Anti Gravity for 60 seconds!")
end,

function(itemstack, user, pointed_thing)
	user:set_physics_override(1,1,1)
	minetest.chat_send_player(user:get_player_name(), "Anti Gravity has worn off.")
end)
