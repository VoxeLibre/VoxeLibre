local assert, error, select, string_char, table_concat
	= assert, error, select, string.char, table.concat

local utf8 = {}

-- Overly permissive pattern that greedily matches a single UTF-8 codepoint
utf8.charpattern = "[%z-\127\194-\253][\128-\191]*"

function utf8.is_valid_codepoint(codepoint)
	-- Must be in bounds & must not be a surrogate
	return codepoint <= 0x10FFFF and (codepoint < 0xD800 or codepoint > 0xDFFF)
end

local function utf8_bytes(codepoint)
	if codepoint <= 0x007F then
		return codepoint
	end if codepoint <= 0x7FF then
		local payload_2 = codepoint % 0x40
		codepoint = (codepoint - payload_2) / 0x40
		return 0xC0 + codepoint, 0x80 + payload_2
	end if codepoint <= 0xFFFF then
		local payload_3 = codepoint % 0x40
		codepoint = (codepoint - payload_3) / 0x40
		local payload_2 = codepoint % 0x40
		codepoint = (codepoint - payload_2) / 0x40
		return 0xE0 + codepoint, 0x80 + payload_2, 0x80 + payload_3
	end if codepoint <= 0x10FFFF then
		local payload_4 = codepoint % 0x40
		codepoint = (codepoint - payload_4) / 0x40
		local payload_3 = codepoint % 0x40
		codepoint = (codepoint - payload_3) / 0x40
		local payload_2 = codepoint % 0x40
		codepoint = (codepoint - payload_2) / 0x40
		return 0xF0 + codepoint, 0x80 + payload_2, 0x80 + payload_3, 0x80 + payload_4
	end error"codepoint out of range"
end

function utf8.char(...)
	local n_args = select("#", ...)
	if n_args == 0 then
		return
	end if n_args == 1 then
		return string_char(utf8_bytes(...))
	end
	local chars = {}
	for i = 1, n_args do
		chars[i] = string_char(utf8_bytes(select(i, ...)))
	end
	return table_concat(chars)
end

local function utf8_next_codepoint(str, i)
	local first_byte = str:byte(i)
	if first_byte < 0x80 then
		return i + 1, first_byte
	end

	local len, head_bits
	if first_byte >= 0xC0 and first_byte <= 0xDF then -- 110_00000 to 110_11111
		len, head_bits = 2, first_byte % 0x20 -- last 5 bits
	elseif first_byte >= 0xE0 and first_byte <= 0xEF then -- 1110_0000 to 1110_1111
		len, head_bits = 3, first_byte % 0x10 -- last 4 bits
	elseif first_byte >= 0xF0 and first_byte <= 0xF7 then -- 11110_000 to 11110_111
		len, head_bits = 4, first_byte % 0x8 -- last 3 bits
	else error"invalid UTF-8" end

	local codepoint = 0
	local pow = 1
	for j = i + len - 1, i + 1, -1 do
		local byte = assert(str:byte(j), "invalid UTF-8")
		local val_bits = byte % 0x40 -- extract last 6 bits xxxxxx from 10xxxxxx
		assert(byte - val_bits == 0x80) -- assert that first two bits are 10
		codepoint = codepoint + val_bits * pow
		pow = pow * 0x40
	end
	return i + len, codepoint + head_bits * pow
end

function utf8.codepoint(str, i, j)
	i, j = i or 1, j or #str
	if i > j then return end
	local codepoint
	i, codepoint = utf8_next_codepoint(str, i)
	assert(i - j <= 1, "invalid UTF-8")
	return codepoint, utf8.codepoint(str, i)
end

-- Iterator to loop over the UTF-8 characters as `index, codepoint`
function utf8.codes(text, i)
	i = i or 1
	return function()
		if i > #text then
			return
		end
		local prev_index = i
		local codepoint
		i, codepoint = utf8_next_codepoint(text, i)
		return prev_index, codepoint
	end
end

return utf8