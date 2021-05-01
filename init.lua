tga_encoder = {}

local LUA_ARGS_LIMIT = 1000

local image = setmetatable({}, {
	__call = function(self, ...)
		local t = setmetatable({}, {__index = self})
		t:constructor(...)
		return t
	end,
})

function image:constructor(pixels)
	self.bytes = {}
	self.chunks = {self.bytes}
	self.pixels = pixels
	self.width = #pixels[1]
	self.height = #pixels

	self:encode()
end

function image:insert(byte)
	table.insert(self.bytes, byte)
	if #self.bytes == LUA_ARGS_LIMIT then
		self.bytes = {}
		table.insert(self.chunks, self.bytes)
	end
end

function image:littleendian(size, value)
	for i = 1, size do
		local byte = value % 256
		value = value - byte
		value = value / 256
		self:insert(byte)
	end
end

function image:encode_colormap_spec()
	-- first entry index
	self:littleendian(2, 0)
	-- number of entries
	self:littleendian(2, 0)
	-- number of bits per pixel
	self:insert(0)
end

function image:encode_image_spec()
	-- X- and Y- origin
	self:littleendian(2, 0)
	self:littleendian(2, 0)
	-- width and height
	self:littleendian(2, self.width)
	self:littleendian(2, self.height)
	-- pixel depth
	self:insert(24)
	-- image descriptor
	self:insert(0)
end

function image:encode_header()
	-- id length
	self:insert(0) -- no image id info
	-- color map type
	self:insert(0) -- no color map
	-- image type
	self:insert(2) -- uncompressed true-color image
	-- color map specification
	self:encode_colormap_spec()
	-- image specification
	self:encode_image_spec()
end

function image:encode_data()
	for _, row in ipairs(self.pixels) do
		for _, pixel in ipairs(row) do
			self:insert(pixel[3])
			self:insert(pixel[2])
			self:insert(pixel[1])
		end
	end
end

function image:encode()
	-- encode header
	self:encode_header()
	-- no color map and image id data
	-- encode data
	self:encode_data()
	-- no extension area
end

function image:get_data()
	local data = ""
	for _, bytes in ipairs(self.chunks) do
		data = data .. string.char(unpack(bytes))
	end
	return data .. string.char(0, 0, 0, 0) .. string.char(0, 0, 0, 0) .. "TRUEVISION-XFILE." .. string.char(0)
end

function image:save(filename)
	self.data = self.data or self:get_data()
	local f = assert(io.open(filename, "w"))
	f:write(self.data)
	f:close()
end

tga_encoder.image = image
