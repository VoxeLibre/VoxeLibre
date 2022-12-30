
-- this is to make the register_mob and register egg functions commonly used by mods not break
-- when they use the weird old : notation AND self as first argument
local oldregmob = mcl_mobs.register_mob
function mcl_mobs.register_mob(self,name,def)
	if type(self) == "string" then
		def = name
		name = self
	end
	return oldregmob(name,def)
end
local oldregegg = mcl_mobs.register_egg
function mcl_mobs.register_egg(self, mob, desc, background_color, overlay_color, addegg, no_creative)
	if type(self) == "string" then
		no_creative = addegg
		addegg = overlay_color
		overlay_color = background_color
		background_color = desc
		desc = mob
		mob = self
	end
	return oldregegg(mob, desc, background_color, overlay_color, addegg, no_creative)
end

local oldregarrow = mcl_mobs.register_mob
function mcl_mobs.register_mob(self,name,def)
	if type(self) == "string" then
		def = name
		name = self
	end
	return oldregarrow(name,def)
end
