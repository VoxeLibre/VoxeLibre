--[[                         .__               .__
         ____ ___  _________ |  |   ____  _____|__| ____   ____   ______
       _/ __ \\  \/  /\____ \|  |  /  _ \/  ___/  |/  _ \ /    \ /  ___/
       \  ___/ >    < |  |_> >  |_(  <_> )___ \|  (  <_> )   |  \\___ \
        \___  >__/\_ \|   __/|____/\____/____  >__|\____/|___|  /____  >
            \/      \/|__|                   \/               \/     \/

            Explosion API mod for Minetest (adapted to MineClone 2)

    This mod is based on the Minetest explosion API mod, but has been changed
    to have the same explosion mechanics as Minecraft and work with MineClone.
    The computation-intensive parts of the mod has been optimized to allow for
    larger explosions and faster world updating.

    This mod was created by Elias Astrom <ryvnf@riseup.net> and is released
    under the LGPLv2.1 license.
--]]


mcl_explosions = {}

-- Saved sphere explosion shapes for various radiuses
local sphere_shapes = {}

-- Saved node definitions in table using cid-keys for faster look-up.
local node_br = {}

local AIR_CID = minetest.get_content_id('air')

-- The step length for the rays (Minecraft uses 0.3)
local STEP_LENGTH = 0.3

minetest.after(0, function()
  -- Store blast resistance values by content ids to improve performance.
  for name, def in pairs(minetest.registered_nodes) do
    node_br[minetest.get_content_id(name)] = def._mcl_blast_resistance or 0
  end
end)

-- Compute the rays which make up a sphere with radius.  Returns a list of rays
-- which can be used to trace explosions.  This function is not efficient
-- (especially for larger radiuses), so the generated rays for various radiuses
-- should be cached and reused.
--
-- Should be possible to improve by using a midpoint circle algorithm multiple
-- times to create the sphere, currently uses more of a brute-force approach.
local function compute_sphere_rays(radius)
  local rays = {}
  local sphere = {}

  for y = -radius, radius do
    for z = -radius, radius do
      for x = -radius, 0, 1 do
        local d = x * x + y * y + z * z
        if d <= radius * radius then
          local pos = { x = x, y = y, z = z }
          sphere[minetest.hash_node_position(pos)] = pos
          break
        end
      end
    end
  end

  for y = -radius, radius do
    for z = -radius, radius do
      for x = radius, 0, -1 do
        local d = x * x + y * y + z * z
        if d <= radius * radius then
          local pos = { x = x, y = y, z = z }
          sphere[minetest.hash_node_position(pos)] = pos
          break
        end
      end
    end
  end

  for x = -radius, radius do
    for z = -radius, radius do
      for y = -radius, 0, 1 do
        local d = x * x + y * y + z * z
        if d <= radius * radius then
          local pos = { x = x, y = y, z = z }
          sphere[minetest.hash_node_position(pos)] = pos
          break
        end
      end
    end
  end

  for x = -radius, radius do
    for z = -radius, radius do
      for y = radius, 0, -1 do
        local d = x * x + y * y + z * z
        if d <= radius * radius then
          local pos = { x = x, y = y, z = z }
          sphere[minetest.hash_node_position(pos)] = pos
          break
        end
      end
    end
  end

  for x = -radius, radius do
    for y = -radius, radius do
      for z = -radius, 0, 1 do
        local d = x * x + y * y + z * z
        if d <= radius * radius then
          local pos = { x = x, y = y, z = z }
          sphere[minetest.hash_node_position(pos)] = pos
          break
        end
      end
    end
  end

  for x = -radius, radius do
    for y = -radius, radius do
      for z = radius, 0, -1 do
        local d = x * x + y * y + z * z
        if d <= radius * radius then
          local pos = { x = x, y = y, z = z }
          sphere[minetest.hash_node_position(pos)] = pos
          break
        end
      end
    end
  end

  for _, pos in pairs(sphere) do
    rays[#rays + 1] = vector.normalize(pos)
  end

  return rays
end

-- Add particles from explosion
--
-- Parameters:
--   pos - The position of the explosion
--   radius - The radius of the explosion
local function add_particles(pos, radius)
	minetest.add_particlespawner({
		amount = 64,
		time = 0.125,
		minpos = pos,
		maxpos = pos,
		minvel = {x = -radius, y = -radius, z = -radius},
		maxvel = {x = radius, y = radius, z = radius},
		minacc = vector.new(),
		maxacc = vector.new(),
		minexptime = 0.5,
		maxexptime = 1.0,
		minsize = radius * 0.5,
		maxsize = radius * 1.0,
		texture = "tnt_smoke.png",
	})
end

-- Get position from hash.  This should be identical to
-- 'minetest.get_position_from_hash' but is used in case the hashing function
-- would change.
local function get_position_from_hash(hash)
  local pos = {}
  pos.x = (hash % 65536) - 32768
  hash  = math.floor(hash / 65536)
  pos.y = (hash % 65536) - 32768
  hash  = math.floor(hash / 65536)
  pos.z = (hash % 65536) - 32768
  return pos
end

-- Traces the rays of an explosion, and updates the environment.
--
-- Parameters:
--   pos - Where the rays in the explosion should start from
--   strength - The strength of each ray
--   raydirs - The directions for each ray
--   radius - The maximum distance each ray will go
--   drop_chance - The chance that destroyed nodes will drop their items
--
-- Note that this function has been optimized, it contains code which has been
-- inlined to avoid function calls and unnecessary table creation.  This was
-- measured to give a significant performance increase.
local function trace_explode(pos, strength, raydirs, radius, drop_chance)
  local vm = minetest.get_voxel_manip()

  local emin, emax = vm:read_from_map(vector.subtract(pos, radius),
    vector.add(pos, radius))
  local emin_x = emin.x
  local emin_y = emin.y
  local emin_z = emin.z

  local ystride = (emax.x - emin_x + 1)
  local zstride = ystride * (emax.y - emin_y + 1)
  local pos_x = pos.x
  local pos_y = pos.y
  local pos_z = pos.z

  local area = VoxelArea:new {
    MinEdge = emin,
    MaxEdge = emax
  }
  local data = vm:get_data()
  local destroy = {}

  -- Trace rays
  for i = 1, #raydirs do
    local rpos_x = pos.x
    local rpos_y = pos.y
    local rpos_z = pos.z
    local rdir_x = raydirs[i].x
    local rdir_y = raydirs[i].y
    local rdir_z = raydirs[i].z
    local rstr = (0.7 + math.random() * 0.6) * strength

    for r = 0, math.ceil(radius * (1.0 / STEP_LENGTH)) do
      local npos_x = math.floor(rpos_x + 0.5)
      local npos_y = math.floor(rpos_y + 0.5)
      local npos_z = math.floor(rpos_z + 0.5)
      local idx = (npos_z - emin_z) * zstride + (npos_y - emin_y) * ystride +
          npos_x - emin_x + 1

      local cid = data[idx]
      local br = node_br[cid]
      local hash = (npos_z + 32768) * 65536 * 65536 +
          (npos_y + 32768) * 65536 +
          npos_x + 32768

      rpos_x = rpos_x + STEP_LENGTH * rdir_x
      rpos_y = rpos_y + STEP_LENGTH * rdir_y
      rpos_z = rpos_z + STEP_LENGTH * rdir_z

      rstr = rstr - 0.75 * STEP_LENGTH - (br + 0.3) * STEP_LENGTH

      if rstr <= 0 then
        break
      end

      if cid ~= AIR_CID then
          destroy[hash] = idx
      end
    end
  end

  -- Remove destroyed blocks and drop items
  for hash, idx in pairs(destroy) do
    if math.random() <= drop_chance then
      local name = minetest.get_name_from_content_id(data[idx])
      local drop = minetest.get_node_drops(name, "")
      for _, item in ipairs(drop) do
	if type(item) == "string" then
	  minetest.add_item(get_position_from_hash(hash), item)
        end
      end
    end
    data[idx] = AIR_CID
  end

  -- Log explosion
  minetest.log('action', 'Explosion at ' .. minetest.pos_to_string(pos) ..
    ' with strength ' .. strength .. ' and radius ' .. radius)

  -- Update environment
  vm:set_data(data)
  vm:write_to_map(data)
  vm:update_liquids()
end

-- Create an explosion with strength at pos.
--
-- Parameters:
--   pos - The position where the explosion originates from
--   strength - The blast strength of the explosion (a TNT explosion uses 4)
--   info - Table containing information about explosion.
--
-- Values in info:
--   drop_chance - If specified becomes the drop chance of all nodes in the
--                 explosion (defaults to 1.0 / strength)
--   no_sound    - If true then the explosion will not play a sound
--   no_particle - If true then the explosion will not create particles
function mcl_explosions.explode(pos, strength, info)
  -- The maximum blast radius (in the air)
  local radius = math.ceil(1.3 * strength / (0.3 * 0.75) * 0.3)

  if not sphere_shapes[radius] then
    sphere_shapes[radius] = compute_sphere_rays(radius)
  end
  shape = sphere_shapes[radius]

  trace_explode(pos, strength, shape, radius, (info and info.drop_chance) or 1 / strength)

  if not (info and info.no_sound) then
    add_particles(pos, radius)
  end
  if not (info and info.no_particle) then
    minetest.sound_play("tnt_explode", {
      pos = pos, gain = 1.0,
      max_hear_distance = strength * 16
    }, true)
  end
end
