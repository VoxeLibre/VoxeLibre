local core_register_item = core.register_item
local core_register_node = core.register_node
local core_register_tool = core.register_tool
local core_register_craftitem = core.register_craftitem

core.register_node = function(name, def)
	if def.type and def.type ~= "node" then
		core.log("warning", "Node "..name.." has invalid type "..tostring(def.type))
	end
	core_register_node(name, def) -- sets type="node" and calls register_item
end

core.register_tool = function(name, def)
	if def.type and def.type ~= "tool" then
		core.log("warning", "Tool "..name.." has invalid type "..tostring(def.type))
	end
	core_register_tool(name, def) -- sets type="tool" and calls register_item
end

core.register_craftitem = function(name, def)
	if def.type and def.type ~= "craft" then
		core.log("warning", "Craftitem "..name.." has invalid type "..tostring(def.type))
	end
	core_register_craftitem(name, def) -- sets type="craft" and calls register_item
end

core.register_item = function(name, def)
	-- Name must agree. Disabled, because this was mostly fine; name was set by core.register_node, not the mod, then the table was copied.
	--[[if def.name and def.name ~= name then
		core.log("warning", "Inconsistent "..tostring(def.type or 'item').." name: "..tostring(name).." vs. "..tostring(def.name))
	end]]
	if def.type == "node" then
		-- Flowing must use paramtype2, overwritten in core.register_item
		if def.liquidtype == "flowing" and def.paramtype2 and def.paramtype2 ~= "flowingliquid" then
			core.log("warning", "Node "..tostring(name).." paramtype2 "..tostring(def.paramtype2).." ignored, must be 'flowingliquid'.")
		end
		for k,v in pairs(def) do
			if v == core.nodedef_default[k] and k ~= "type" then
				core.log("warning", "Unnecessary: node "..tostring(name).." "..k.." = "..tostring(v).." is the default.")
			end
		end
	elseif def.type == "tool" then
		for k,v in pairs(def) do
			if v == core.tooldef_default[k] and k ~= "type" then
				core.log("warning", "Unnecessary: tool "..tostring(name).." "..k.." = "..tostring(v).." is the default.")
			end
		end
	elseif def.type == "craft" then
		for k,v in pairs(def) do
			if v == core.craftitemdef_default[k] and k ~= "type" then
				core.log("warning", "Unnecessary: craftitem "..tostring(name).." "..k.." = "..tostring(v).." is the default.")
			end
		end
	elseif def.type == "none" then
		for k,v in pairs(def) do
			if v == core.noneitemdef_default[k] and k ~= "type" then
				core.log("warning", "Unnecessary: bare item "..tostring(name).." "..k.." = "..tostring(v).." is the default.")
			end
		end
	end
	-- Report if groups.xyz is no numeric or 0
	for k, v in pairs(def.groups or {}) do
		if type(v) ~= "number" or v == 0 then
			core.log("warning", "Item "..tostring(name).." has group "..tostring(k).." with bad value "..tostring(v))
		end
		if v == 0 then def.groups[k] = nil end -- Avoid that this causes issues
	end
	core_register_item(name, def)
end
