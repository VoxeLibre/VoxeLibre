tga_encoder = {}

local image = setmetatable({}, {
	__call = function(self, ...)
		local t = setmetatable({}, {__index = self})
		t:constructor(...)
		return t
	end,
})

function image:constructor(pixels)
	self.pixels = pixels
	self.width = #pixels[1]
	self.height = #pixels
	self.pixel_depth = #pixels[1][1]
end

function image:encode_colormap_spec()
	self.data = self.data
		.. string.char(0, 0) -- first entry index
		.. string.char(0, 0) -- number of entries
		.. string.char(0) -- bits per pixel
end

function image:encode_image_spec(properties)
	local colors = properties.colors
	local pixel_depth = properties.pixel_depth
	assert(
		"BW" == colors and 8 == pixel_depth or -- (8 bit grayscale = 1 byte = 8 bits)
		"RGB" == colors and 16 == pixel_depth or -- (A1R5G5B5 = 2 bytes = 16 bits)
		"RGB" == colors and 24 == pixel_depth -- (B8G8R8 = 3 bytes = 24 bits)
	)
	self.data = self.data
		.. string.char(0, 0) -- X-origin
		.. string.char(0, 0) -- Y-origin
		.. string.char(self.width  % 256, math.floor(self.width  / 256)) -- width
		.. string.char(self.height % 256, math.floor(self.height / 256)) -- height
		.. string.char(pixel_depth)
		.. string.char(0) -- image descriptor
end

function image:encode_header(properties)
	local colors = properties.colors
	local compression = properties.compression
	local pixel_depth = properties.pixel_depth
	local image_type
	if "BW" == colors and "RAW" == compression and 8 == pixel_depth then
		image_type = 3 -- grayscale
	elseif (
		"RGB" == colors and 16 == pixel_depth or
		"RGB" == colors and 24 == pixel_depth
	) then
		if "RAW" == compression then
			image_type = 2 -- RAW RGB
		elseif "RLE" == compression then
			image_type = 10 -- RLE RGB
		end
	end
	self.data = self.data
		.. string.char(0) -- image id
		.. string.char(0) -- color map type
		.. string.char(image_type)
	self:encode_colormap_spec() -- color map specification
	self:encode_image_spec(properties) -- image specification
end

function image:encode_data(properties)
	local colors = properties.colors
	local compression = properties.compression
	local pixel_depth = properties.pixel_depth

	if "BW" == colors and "RAW" == compression and 8 == pixel_depth then
		if 1 == self.pixel_depth then
			self:encode_data_bw8_to_bw8_raw()
		elseif 3 == self.pixel_depth then
			self:encode_data_r8g8b8_to_bw8_raw()
		end
	elseif "RGB" == colors and 16 == pixel_depth then
		if "RAW" == compression then
			self:encode_data_a1r5g5b5_raw()
		elseif "RLE" == compression then
			self:encode_data_a1r5g5b5_rle()
		end
	elseif "RGB" == colors and 24 == pixel_depth then
		if "RAW" == compression then
			self:encode_data_r8g8b8_raw()
		elseif "RLE" == compression then
			self:encode_data_r8g8b8_rle()
		end
	end
end

function image:encode_data_bw8_to_bw8_raw()
	assert(1 == self.pixel_depth)
	local raw_pixels = {}
	for _, row in ipairs(self.pixels) do
		for _, pixel in ipairs(row) do
			local raw_pixel = string.char(pixel[1])
			raw_pixels[#raw_pixels + 1] = raw_pixel
		end
	end
	self.data = self.data .. table.concat(raw_pixels)
end

function image:encode_data_r8g8b8_to_bw8_raw()
	assert(3 == self.pixel_depth)
	local raw_pixels = {}
	for _, row in ipairs(self.pixels) do
		for _, pixel in ipairs(row) do
			-- the HSP RGB to brightness formula is
			-- sqrt( 0.299 r² + .587 g² + .114 b² )
			-- see <https://alienryderflex.com/hsp.html>
			local gray = math.floor(
				math.sqrt(
					0.299 * pixel[1]^2 +
					0.587 * pixel[2]^2 +
					0.114 * pixel[3]^2
				) + 0.5
			)
			local raw_pixel = string.char(gray)
			raw_pixels[#raw_pixels + 1] = raw_pixel
		end
	end
	self.data = self.data .. table.concat(raw_pixels)
end

function image:encode_data_a1r5g5b5_raw()
	assert(3 == self.pixel_depth)
	local raw_pixels = {}
	-- Sample depth rescaling is done according to the algorithm presented in:
	-- <https://www.w3.org/TR/2003/REC-PNG-20031110/#13Sample-depth-rescaling>
	local max_sample_in = math.pow(2, 8) - 1
	local max_sample_out = math.pow(2, 5) - 1
	for _, row in ipairs(self.pixels) do
		for _, pixel in ipairs(row) do
			local colorword = 32768 +
				((math.floor((pixel[1] * max_sample_out / max_sample_in) + 0.5)) * 1024) +
				((math.floor((pixel[2] * max_sample_out / max_sample_in) + 0.5)) * 32) +
				((math.floor((pixel[3] * max_sample_out / max_sample_in) + 0.5)) * 1)
			local raw_pixel = string.char(colorword % 256, math.floor(colorword / 256))
			raw_pixels[#raw_pixels + 1] = raw_pixel
		end
	end
	self.data = self.data .. table.concat(raw_pixels)
end

function image:encode_data_a1r5g5b5_rle()
	assert(3 == self.pixel_depth)
	local colorword = nil
	local previous_r = nil
	local previous_g = nil
	local previous_b = nil
	local raw_pixel = ''
	local raw_pixels = {}
	local count = 1
	local packets = {}
	local raw_packet = ''
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
					if 1 == count then
						-- remember pixel verbatim for raw encoding
						raw_pixel = string.char(colorword % 256, math.floor(colorword / 256))
						raw_pixels[#raw_pixels + 1] = raw_pixel
						if 128 == #raw_pixels then
							raw_packet = string.char(#raw_pixels - 1)
							packets[#packets + 1] = raw_packet
							for i=1, #raw_pixels do
								packets[#packets +1] = raw_pixels[i]
							end
							raw_pixels = {}
						end
					else
						-- encode raw pixels, if any
						if #raw_pixels > 0 then
							raw_packet = string.char(#raw_pixels - 1)
							packets[#packets + 1] = raw_packet
							for i=1, #raw_pixels do
								packets[#packets +1] = raw_pixels[i]
							end
							raw_pixels = {}
						end
						-- RLE encoding
						rle_packet = string.char(128 + count - 1, colorword % 256, math.floor(colorword / 256))
						packets[#packets +1] = rle_packet
					end
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
	if 1 == count then
		raw_pixel = string.char(colorword % 256, math.floor(colorword / 256))
		raw_pixels[#raw_pixels + 1] = raw_pixel
		raw_packet = string.char(#raw_pixels - 1)
		packets[#packets + 1] = raw_packet
		for i=1, #raw_pixels do
			packets[#packets +1] = raw_pixels[i]
		end
		raw_pixels = {}
	else
		-- encode raw pixels, if any
		if #raw_pixels > 0 then
			raw_packet = string.char(#raw_pixels - 1)
			packets[#packets + 1] = raw_packet
			for i=1, #raw_pixels do
				packets[#packets +1] = raw_pixels[i]
			end
			raw_pixels = {}
		end
		-- RLE encoding
		rle_packet = string.char(128 + count - 1, colorword % 256, math.floor(colorword / 256))
		packets[#packets +1] = rle_packet
	end
	self.data = self.data .. table.concat(packets)
end

function image:encode_data_r8g8b8_raw()
	assert(3 == self.pixel_depth)
	local raw_pixels = {}
	for _, row in ipairs(self.pixels) do
		for _, pixel in ipairs(row) do
			local raw_pixel = string.char(pixel[3], pixel[2], pixel[1])
			raw_pixels[#raw_pixels + 1] = raw_pixel
		end
	end
	self.data = self.data .. table.concat(raw_pixels)
end

function image:encode_data_r8g8b8_rle()
	assert(3 == self.pixel_depth)
	local previous_r = nil
	local previous_g = nil
	local previous_b = nil
	local raw_pixel = ''
	local raw_pixels = {}
	local count = 1
	local packets = {}
	local raw_packet = ''
	local rle_packet = ''
	for _, row in ipairs(self.pixels) do
		for _, pixel in ipairs(row) do
			if pixel[1] ~= previous_r or pixel[2] ~= previous_g or pixel[3] ~= previous_b or count == 128 then
				if nil ~= previous_r then
					if 1 == count then
						-- remember pixel verbatim for raw encoding
						raw_pixel = string.char(previous_b, previous_g, previous_r)
						raw_pixels[#raw_pixels + 1] = raw_pixel
						if 128 == #raw_pixels then
							raw_packet = string.char(#raw_pixels - 1)
							packets[#packets + 1] = raw_packet
							for i=1, #raw_pixels do
								packets[#packets +1] = raw_pixels[i]
							end
							raw_pixels = {}
						end
					else
						-- encode raw pixels, if any
						if #raw_pixels > 0 then
							raw_packet = string.char(#raw_pixels - 1)
							packets[#packets + 1] = raw_packet
							for i=1, #raw_pixels do
								packets[#packets +1] = raw_pixels[i]
							end
							raw_pixels = {}
						end
						-- RLE encoding
						rle_packet = string.char(128 + count - 1, previous_b, previous_g, previous_r)
						packets[#packets +1] = rle_packet
					end
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
	if 1 == count then
		raw_pixel = string.char(previous_b, previous_g, previous_r)
		raw_pixels[#raw_pixels + 1] = raw_pixel
		raw_packet = string.char(#raw_pixels - 1)
		packets[#packets + 1] = raw_packet
		for i=1, #raw_pixels do
			packets[#packets +1] = raw_pixels[i]
		end
		raw_pixels = {}
	else
		-- encode raw pixels, if any
		if #raw_pixels > 0 then
			raw_packet = string.char(#raw_pixels - 1)
			packets[#packets + 1] = raw_packet
			for i=1, #raw_pixels do
				packets[#packets +1] = raw_pixels[i]
			end
			raw_pixels = {}
		end
		-- RLE encoding
		rle_packet = string.char(128 + count - 1, previous_b, previous_g, previous_r)
		packets[#packets +1] = rle_packet
	end
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

function image:encode(properties)
	self.data = ""
	self:encode_header(properties) -- header
	-- no color map and image id data
	self:encode_data(properties) -- encode data
	-- no extension or developer area
	self:encode_footer() -- footer
end

function image:save(filename, properties)
	local properties = properties or {}
	properties.colors = properties.colors or "RGB"
	properties.compression = properties.compression or "RAW"
	properties.pixel_depth = properties.pixel_depth or 24

	self:encode(properties)

	local f = assert(io.open(filename, "wb"))
	f:write(self.data)
	f:close()
end

tga_encoder.image = image
