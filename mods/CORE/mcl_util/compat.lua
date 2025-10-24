if not vector.in_area then
	-- backport from minetest 5.8, can be removed when the minimum version is 5.8
    --- @diagnostic disable-next-line: duplicate-set-field
	vector.in_area = function(pos, min, max)
		return (pos.x >= min.x) and (pos.x <= max.x) and
		       (pos.y >= min.y) and (pos.y <= max.y) and
		       (pos.z >= min.z) and (pos.z <= max.z)
	end
end

if not core.bulk_swap_node then
    --- @diagnostic disable-next-line: duplicate-set-field
	function core.bulk_swap_node(positions, node)
		for _,pos in ipairs(positions) do
			core.swap_node(pos, node)
		end
	end
end

if not core.ipc_set then
    -- This adds a compatibility shim using files for Luanti 5.9.0. Native IPC was added in 5.10.0
    local world_path = core.get_worldpath()
    core.mkdir(world_path .. "/mcl_util/ipc/")

    local function real_ipc_set(key,value)
        local key_hash = mcl_util.djb2_hash(tostring(key))

        local f = io.open(world_path.."/mcl_util/ipc/"..key_hash, "w+")
        if f then
            local data = core.serialize(value)
            f:write(data)
            f:flush()
            f:close()
        else
            core.log("[compat] core.ipc_set("..tostring(key)..", ...) - failed to open file")
        end
    end
    local function real_ipc_get(key)
        local key_hash = mcl_util.djb2_hash(tostring(key))
        local f = io.open(world_path.."/mcl_util/ipc/"..key_hash)
        if f then
            local data = f:read("*a")
            if data then
                return core.deserialize(data,true)
            end
        end

        return nil
    end

    local function ipc_warning()
        core.log("warning", "Using IPC compatability shim for Luanti before 5.10.0")
        core.ipc_set = real_ipc_set
        core.ipc_get = real_ipc_get
    end

    --- @diagnostic disable-next-line: duplicate-set-field
    function core.ipc_set(key,value)
        ipc_warning()
        return real_ipc_set(key,value)
    end

    --- @diagnostic disable-next-line: duplicate-set-field
    function core.ipc_get(key)
        ipc_warning()
        return real_ipc_get(key)
    end

    --- @diagnostic disable-next-line: duplicate-set-field
    function core.ipc_poll(key, timeout)
        local end_time = core.get_us_time() + timeout * 1e3
        while core.get_us_time() < end_time do
            local val = core.ipc_get(key)
            if val then return val end
        end

        return nil
    end

    -- There is no way to implement a compatibility shim for core.ipc_cas() that is an atomic operation
end