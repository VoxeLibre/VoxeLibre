Sprint Mod for MineClone 2
Forked from [sprint] by GunshipPenguin  

Allows the player to sprint by either double tapping w or pressing e. 
By default, sprinting will make the player travel 80% faster and 
allow him/her to jump 10% higher. 

Licence: CC0 (see COPYING file)

---

This mod can be configured by changing the variables declared in 
the start of init.lua. The following is a brief explanation of each 
one.

mcl_sprint.METHOD (default 1)

What a player has to do to start sprinting. 0 = double tap w, 1 = press e.
Note that if you have the fast privlige, and have the fast 
speed turned on, you will run very, very fast. You can toggle this 
by pressing j.
NOTE: Method 0 is UNTESTED!
 
mcl_sprint.SPEED (default 1.5)
 
How fast the player will move when sprinting as opposed to normal 
movement speed. 1.0 represents normal speed so 1.5 would mean that a 
sprinting player would travel 50% faster than a walking player and 
2.4 would mean that a sprinting player would travel 140% faster than 
a walking player.

mcl_sprint.JUMP (default 1.1)

How high the player will jump when sprinting as opposed to normal 
jump height. Same as mcl_sprint.SPEED, just controls jump height while 
sprinting rather than speed.

mcl_sprint.STAMINA (default 20)

How long the player can sprint for in seconds. Each player has a 
stamina variable assigned to them, it is initially set to 
mcl_sprint.STAMINA and can go no higher. When the player is sprinting, 
this variable ticks down once each second, and when it reaches 0, 
the player stops sprinting. It ticks back up when the player isn't 
sprinting and stops at mcl_sprint.STAMINA. Set this to a huge value if 
you want unlimited sprinting.

mcl_sprint.TIMEOUT (default 0.5)

Only used if mcl_sprint.METHOD = 0.
How much time the player has after releasing w, to press w again and 
start sprinting. Setting this too high will result in unwanted 
sprinting and setting it too low will result in it being 
difficult/impossible to sprint.
