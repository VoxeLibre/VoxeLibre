vl_volume = {}
local vl_volume = vl_volume

local storage = core.get_mod_storage()
local function save_volume_metadata(self)
	storage:set_string(self.uuid, core.serialize(self.volume))
end

---@class vl_volume.Volume
---@field minp vector.Vector
---@field maxp vector.Vector
---@field data table

---@type table<string, vl_volume.Volume>
local volume_list = {}

-- Load volumes from mod storage
do
	local uuids = storage:get_keys()
	for _,uuid in ipairs(uuids) do
		local volume_stub = {
		}
		volume_list[uuid] = volume_stub
	end
end

---@type {pos: vector.Vector, meta: core.MetaDataRef}
local cache = {}

---@param pos vector.Vector
---@return core.MetaDataRef
function vl_volume.get_meta(pos)
	local hash = mcl_util.hash_pos(pos.x, pos.y, pos.z, 15)
	local cached = cache[hash]
	if cached and vector.equals(cached.pos, pos) then
		return cached.meta
	end

	local data = {}

	-- Create a table containing the union of all volumes that contain 'pos'
	-- TODO: make this more efficient
	for uuid,volume in pairs(volume_list) do
		if vector.in_area(pos, volume.minp, volume.maxp) then
			if not volume.table then
				volume.table = core.deserialize(storage:get_string(uuid))
			end

			table.update(data, volume.table)
		end
	end

	local meta = mcl_util.make_fake_metadata({table = data, readonly = true})
	cache[hash] = {meta = meta, pos = pos}
	return meta
end

---@param minp vector.Vector
---@param maxp vector.Vector
---@return core.MetaDataRef
function vl_volume.get_area_meta(minp, maxp)
	local data = {}

	-- Create a table containing the union of all volume metadata that overlap the area minp,maxp
	-- TODO: make this more efficient
	for uuid,volume in pairs(volume_list) do
		if mcl_util.area_overlaps(minp, maxp, volume.minp, volume.maxp) then
			if not volume.table then
				volume.table = core.deserialize(storage:get_string(uuid))
			end

			table.update(data, volume.table)
		end
	end

	return mcl_util.make_fake_metadata({table = data, readonly = true})
end

---@param minp vector.Vector
---@param maxp vector.Vector
---@return core.MetaDataRef
function vl_volume.create_volume(minp, maxp)
	-- Create the volume
	local uuid = string.format("%d,%d,%d-%d,%d,%d", minp.x, minp.y, minp.z, maxp.x, maxp.y, maxp.z)

	---@class vl_volume.Volume
	local volume = {
		minp = vector.copy(minp),
		maxp = vector.copy(maxp),
		uuid = uuid,
		table = {},
	}
	volume_list[uuid] = volume
	storage:set_string(uuid, core.serialize(volume))

	-- Create a metadata-like object
	local metadata = mcl_util.make_fake_metadata({
		volume = volume,
		table = volume.table,
		on_save = save_volume_metadata,
	})
	volume.meta = metadata

	-- Clear position cache
	cache = {}

	return metadata
end
