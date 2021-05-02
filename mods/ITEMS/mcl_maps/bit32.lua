bit32 = {}

local N = 32
local P = 2^N

function bit32.bnot(x)
	x = x % P
	return P - 1 - x
end

function bit32.band(x, y)
	-- Common usecases, they deserve to be optimized
	if y == 0xff then return x % 0x100 end
	if y == 0xffff then return x % 0x10000 end
	if y == 0xffffffff then return x % 0x100000000 end
	
	x, y = x % P, y % P
	local r = 0
	local p = 1
	for i = 1, N do
		local a, b = x % 2, y % 2
		x, y = math.floor(x / 2), math.floor(y / 2)
		if a + b == 2 then
			r = r + p
		end
		p = 2 * p
	end
	return r
end

function bit32.bor(x, y)
	-- Common usecases, they deserve to be optimized
	if y == 0xff then return x - (x%0x100) + 0xff end
	if y == 0xffff then return x - (x%0x10000) + 0xffff end
	if y == 0xffffffff then return 0xffffffff end
	
	x, y = x % P, y % P
	local r = 0
	local p = 1
	for i = 1, N do
		local a, b = x % 2, y % 2
		x, y = math.floor(x / 2), math.floor(y / 2)
		if a + b >= 1 then
			r = r + p
		end
		p = 2 * p
	end
	return r
end

function bit32.bxor(x, y)
	x, y = x % P, y % P
	local r = 0
	local p = 1
	for i = 1, N do
		local a, b = x%2, y%2
		x, y = math.floor(x/2), math.floor(y/2)
		if a + b == 1 then
			r = r + p
		end
		p = 2 * p
	end
	return r
end

function bit32.lshift(x, s_amount)
	if math.abs(s_amount) >= N then return 0 end
	x = x % P
	if s_amount < 0 then
		return math.floor(x * (2 ^ s_amount))
	else
		return (x * (2 ^ s_amount)) % P
	end
end

function bit32.rshift(x, s_amount)
	if math.abs(s_amount) >= N then return 0 end
	x = x % P
	if s_amount > 0 then
		return math.floor(x * (2 ^ - s_amount))
	else
		return (x * (2 ^ -s_amount)) % P
	end
end

function bit32.arshift(x, s_amount)
	if math.abs(s_amount) >= N then return 0 end
	x = x % P
	if s_amount > 0 then
		local add = 0
		if x >= P/2 then
			add = P - 2 ^ (N - s_amount)
		end
		return math.floor(x * (2 ^ -s_amount)) + add
	else
		return (x * (2 ^ -s_amount)) % P
	end
end
