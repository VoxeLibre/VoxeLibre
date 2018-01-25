-- Node is currently defined in mobs_mc.
-- TODO: Add full item definition here when status effects become a thing.

-- Add group for Creative Mode.
minetest.override_item("mobs_mc:totem", {groups = { combat_item=1}})
