--- Make `core.get_node_raw` public. It's safe to use and stable.
--
-- This code is based on the work by halon for mineclonia, but encapsulated differently
-- Check if `core.get_node_raw` is public by now.
if not core.get_node_raw then
	-- try to un-hide the function
	local ie = core.request_insecure_environment()
	if not ie then
		core.log("action", "[vl_trusted] cannot unhide get_node_raw, please add vl_trusted to secure.trusted_mods to improve performance (optional).")
	elseif not ie.debug or not ie.debug.getupvalue then
		core.log("warning", "[vl_trusted] debug.getupvalue is not available, unhiding does not work. Version: "..dump(core.get_version(),""))
	else
		for i=1,5 do -- will not be five levels deep
			local name, upvalue = ie.debug.getupvalue(core.get_node, i)
			if not name then break end
			if name == "get_node_raw" then
				core.get_node_raw = upvalue
				break
			end
		end
		if core.get_node_raw then
			core.log("action", "[vl_trusted] get_node_raw unhiding successful.")
		else
			core.log("warning", "[vl_trusted] get_node_raw unhiding NOT successful. Version: "..dump(core.get_version(),""))
		end
	end
else
	core.log("verbose", "[vl_trusted] get_node_raw available without workaround.")
end

