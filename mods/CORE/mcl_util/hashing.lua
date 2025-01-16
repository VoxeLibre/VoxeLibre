---- Hashing related functions
-- The bitop is avilable both in luaJIT and in non-JIT Luanti since 5.5, so safe to use
local tobit = bit.tobit
local band = bit.band
local lshift = bit.lshift
local rshift = bit.rshift

-- u32 multiplication in luas double data types, via 16 bit multiplications
local function u32_mul(a, b)
	return (band(a, 0xffff) * b) + lshift(band(rshift(a, 16) * b,  0xffff), 16)
end

--- Simple and cheap bit mixing operation
--- to use with a seed, do bitmix32(bitmix32(seed, a), b)
--- @param a number: first value
--- @param b number: second value
--- @return number: combined hash code in signed int32 range
local function bitmix32(a, b)
	return tobit(u32_mul(tobit(a), 0xc2b2ae35) + tobit(b))
end
mcl_util.bitmix32 = bitmix32

--- Simple position hash function.
--- Use this with a custom seed to avoid coincidences with other mods.
--- @param x number: X coordinate (only integer part is used)
--- @param y number: Y coordinate (only integer part is used)
--- @param z number: Z coordinate (only integer part is used)
--- @param seed number: Seed value
--- @return number: combined hash code (signed int32)
local function hash_pos(x, y, z, seed)
	if not seed then return bitmix32(bitmix32(x, y), z) end
	return bitmix32(bitmix32(bitmix32(seed, x), y), z)
end
mcl_util.hash_pos = hash_pos

--- DJ Bernstein hash function.
--- @param str string: Input
--- @return number: combined hash code
mcl_util.djb_hash = function(str)
	str = tostring(str)
	local hash = 5381
	for i = 1, #str do
		-- we don't do the h<<5+h trick here, as lua only supports doubles!
		hash = band(hash * 33 + str:byte(i), 0xffffffff)
	end
	-- by default, the values would be signed, we want u32
	return hash >= 0 and hash or (0x100000000 + hash)
end
-- Compare to a value obtained from a Python implementation
assert(mcl_util.djb_hash("VoxeLibre") == 2331368085)

