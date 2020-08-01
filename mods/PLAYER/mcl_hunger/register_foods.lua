-- Apply simple poison effect as long there are no real status effect
-- TODO: Remove this when status effects are in place
-- TODO: Consider moving these to the respective mods

mcl_hunger.register_food("mcl_farming:potato_item_poison",	2, "",  4, 1,   0, 60)

mcl_hunger.register_food("mcl_mobitems:rotten_flesh",		4, "", 30, 0, 100, 80)
mcl_hunger.register_food("mcl_mobitems:chicken",		2, "", 30, 0, 100, 30)
mcl_hunger.register_food("mcl_mobitems:spider_eye",		2, "", 4,  1,   0)

-- mcl_hunger.register_food("mcl_fishing:pufferfish_raw",		1, "", 60, 1, 300)
