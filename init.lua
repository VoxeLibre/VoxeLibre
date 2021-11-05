tga_encoder = {}

local image = setmetatable({}, {
	__call = function(self, ...)
		local t = setmetatable({}, {__index = self})
		t:constructor(...)
		return t
	end,
})

function image:constructor(pixels)
	self.data = ""
	self.pixels = pixels
	self.width = #pixels[1]
	self.height = #pixels

	self:encode()
end

function image:encode_colormap_spec()
	self.data = self.data
		.. string.char(0, 0) -- first entry index
		.. string.char(0, 0) -- number of entries
		.. string.char(0) -- bits per pixel
end

function image:encode_image_spec()
	self.data = self.data
		.. string.char(0, 0) -- X-origin
		.. string.char(0, 0) -- Y-origin
		.. string.char(self.width  % 256, math.floor(self.width  / 256)) -- width
		.. string.char(self.height % 256, math.floor(self.height / 256)) -- height
		.. string.char(16) -- pixel depth (ARRRRRGGGGGBBBBB = 2 bytes = 16 bits)
		.. string.char(0) -- image descriptor
end

function image:encode_header()
	self.data = self.data
		.. string.char(0) -- image id
		.. string.char(0) -- color map type
		.. string.char(10) -- image type (RLE RGB = 10)
	self:encode_colormap_spec() -- color map specification
	self:encode_image_spec() -- image specification
end

function image:encode_data()
	local colorword = nil
	local previous_r = nil
	local previous_g = nil
	local previous_b = nil
	local count = 1
	local packets = {}
	local rle_packet = ''
	-- Sample depth rescaling is done according to the algorithm presented in:
	-- <https://www.w3.org/TR/2003/REC-PNG-20031110/#13Sample-depth-rescaling>
	local max_sample_in = math.pow(2, 8) - 1
	local max_sample_out = math.pow(2, 5) - 1
	for _, row in ipairs(self.pixels) do
		for _, pixel in ipairs(row) do
			if pixel[1] ~= previous_r or pixel[2] ~= previous_g or pixel[3] ~= previous_b or count == 128 then
			   if nil ~= previous_r then
					colorword = 32768 +
						((math.floor((previous_r * max_sample_out / max_sample_in) + 0.5)) * 1024) +
						((math.floor((previous_g * max_sample_out / max_sample_in) + 0.5)) * 32) +
						((math.floor((previous_b * max_sample_out / max_sample_in) + 0.5)) * 1)
					rle_packet = string.char(128 + count - 1, colorword % 256, math.floor(colorword / 256))
					packets[#packets +1] = rle_packet
				end
				count = 1
				previous_r = pixel[1]
				previous_g = pixel[2]
				previous_b = pixel[3]
			else
				count = count + 1
			end
		end
	end
	colorword = 32768 +
		((math.floor((previous_r * max_sample_out / max_sample_in) + 0.5)) * 1024) +
		((math.floor((previous_g * max_sample_out / max_sample_in) + 0.5)) * 32) +
		((math.floor((previous_b * max_sample_out / max_sample_in) + 0.5)) * 1)
	rle_packet = string.char(128 + count - 1, colorword % 256, math.floor(colorword / 256))
	packets[#packets +1] = rle_packet
	self.data = self.data .. table.concat(packets)
end

function image:encode_footer()
	self.data = self.data
		.. string.char(0, 0, 0, 0) -- extension area offset
		.. string.char(0, 0, 0, 0) -- developer area offset
		.. "TRUEVISION-XFILE"
		.. "."
		.. string.char(0)
end

function image:encode()
	self:encode_header() -- header
	-- no color map and image id data
	self:encode_data() -- encode data
	-- no extension or developer area
	self:encode_footer() -- footer
end

function image:save(filename)
	local f = assert(io.open(filename, "wb"))
	f:write(self.data)
	f:close()
end

tga_encoder.image = image
