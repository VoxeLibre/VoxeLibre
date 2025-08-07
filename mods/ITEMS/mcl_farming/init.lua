local mod_path = core.get_modpath("mcl_farming")

mcl_farming = {}

-- IMPORTANT API AND HELPER FUNCTIONS --
-- Contain functions for planting seed, addind plant growth and gourds (melon/pumpkin-like)
dofile(mod_path.."/shared_functions.lua")

-- ========= SOIL =========
dofile(mod_path.."/soil.lua")

-- ========= HOES =========
dofile(mod_path.."/hoes.lua")

-- ========= WHEAT =========
dofile(mod_path.."/wheat.lua")

-- ======= PUMPKIN =========
dofile(mod_path.."/pumpkin.lua")

-- ========= MELON =========
dofile(mod_path.."/melon.lua")

-- ========= CARROT =========
dofile(mod_path.."/carrots.lua")

-- ========= POTATOES =========
dofile(mod_path.."/potatoes.lua")

-- ========= BEETROOT =========
dofile(mod_path.."/beetroot.lua")

-- ========= SWEET BERRY =========
dofile(mod_path.."/sweet_berry.lua")

