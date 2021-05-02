local Png = {}
Png.__index = Png

local DEFLATE_MAX_BLOCK_SIZE = 65535

local function putBigUint32(val, tbl, index)
    for i=0,3 do
        tbl[index + i] = bit.band(bit.rshift(val, (3 - i) * 8), 0xFF)
    end
end

function Png:writeBytes(data, index, len)
    index = index or 1
    len = len or #data
    for i=index,index+len-1 do
        table.insert(self.output, string.char(data[i]))
    end
end

function Png:write(pixels)
    local count = #pixels  -- Byte count
    local pixelPointer = 1
    while count > 0 do
        if self.positionY >= self.height then
            error("All image pixels already written")
        end

        if self.deflateFilled == 0 then -- Start DEFLATE block
            local size = DEFLATE_MAX_BLOCK_SIZE;
            if (self.uncompRemain < size) then
                size = self.uncompRemain
            end
            local header = {  -- 5 bytes long
                bit.band((self.uncompRemain <= DEFLATE_MAX_BLOCK_SIZE and 1 or 0), 0xFF),
                bit.band(bit.rshift(size, 0), 0xFF),
                bit.band(bit.rshift(size, 8), 0xFF),
                bit.band(bit.bxor(bit.rshift(size, 0), 0xFF), 0xFF),
                bit.band(bit.bxor(bit.rshift(size, 8), 0xFF), 0xFF),
            }
            self:writeBytes(header)
            self:crc32(header, 1, #header)
        end
        assert(self.positionX < self.lineSize and self.deflateFilled < DEFLATE_MAX_BLOCK_SIZE);

        if (self.positionX == 0) then  -- Beginning of line - write filter method byte
            local b = {0}
            self:writeBytes(b)
            self:crc32(b, 1, 1)
            self:adler32(b, 1, 1)
            self.positionX = self.positionX + 1
            self.uncompRemain = self.uncompRemain - 1
            self.deflateFilled = self.deflateFilled + 1
        else -- Write some pixel bytes for current line
            local n = DEFLATE_MAX_BLOCK_SIZE - self.deflateFilled;
            if (self.lineSize - self.positionX < n) then
                n = self.lineSize - self.positionX
            end
            if (count < n) then
                n = count;
            end
            assert(n > 0);

            self:writeBytes(pixels, pixelPointer, n)

            -- Update checksums
            self:crc32(pixels, pixelPointer, n);
            self:adler32(pixels, pixelPointer, n);

            -- Increment positions
            count = count - n;
            pixelPointer = pixelPointer + n;
            self.positionX = self.positionX + n;
            self.uncompRemain = self.uncompRemain - n;
            self.deflateFilled = self.deflateFilled + n;
        end

        if (self.deflateFilled >= DEFLATE_MAX_BLOCK_SIZE) then
            self.deflateFilled = 0; -- End current block
        end

        if (self.positionX == self.lineSize) then  -- Increment line
            self.positionX = 0;
            self.positionY = self.positionY + 1;
            if (self.positionY == self.height) then -- Reached end of pixels
                local footer = {  -- 20 bytes long
                    0, 0, 0, 0,  -- DEFLATE Adler-32 placeholder
                    0, 0, 0, 0,  -- IDAT CRC-32 placeholder
                    -- IEND chunk
                    0x00, 0x00, 0x00, 0x00,
                    0x49, 0x45, 0x4E, 0x44,
                    0xAE, 0x42, 0x60, 0x82,
                }
                putBigUint32(self.adler, footer, 1)
                self:crc32(footer, 1, 4)
                putBigUint32(self.crc, footer, 5)
                self:writeBytes(footer)
                self.done = true
            end
        end
    end
end

function Png:crc32(data, index, len)
    self.crc = bit.bnot(self.crc)
    for i=index,index+len-1 do
        local byte = data[i]
        for j=0,7 do  -- Inefficient bitwise implementation, instead of table-based
            local nbit = bit.band(bit.bxor(self.crc, bit.rshift(byte, j)), 1);
            self.crc = bit.bxor(bit.rshift(self.crc, 1), bit.band((-nbit), 0xEDB88320));
        end
    end
    self.crc = bit.bnot(self.crc)
end
function Png:adler32(data, index, len)
    local s1 = bit.band(self.adler, 0xFFFF)
    local s2 = bit.rshift(self.adler, 16)
    for i=index,index+len-1 do
        s1 = (s1 + data[i]) % 65521
        s2 = (s2 + s1) % 65521
    end
    self.adler = bit.bor(bit.lshift(s2, 16), s1)
end

local function begin(width, height, colorMode)
    -- Default to rgb
    colorMode = colorMode or "rgb"

    -- Determine bytes per pixel and the PNG internal color type
    local bytesPerPixel, colorType
    if colorMode == "rgb" then
        bytesPerPixel, colorType = 3, 2
    elseif colorMode == "rgba" then
        bytesPerPixel, colorType = 4, 6
    else
        error("Invalid colorMode")
    end

    local state = setmetatable({ width = width, height = height, done = false, output = {} }, Png)

    -- Compute and check data siezs
    state.lineSize = width * bytesPerPixel + 1
    -- TODO: check if lineSize too big

    state.uncompRemain = state.lineSize * height

    local numBlocks = math.ceil(state.uncompRemain / DEFLATE_MAX_BLOCK_SIZE)

    -- 5 bytes per DEFLATE uncompressed block header, 2 bytes for zlib header, 4 bytes for zlib Adler-32 footer
    local idatSize = numBlocks * 5 + 6
    idatSize = idatSize + state.uncompRemain;

    -- TODO check if idatSize too big

    local header = {  -- 43 bytes long
        -- PNG header
        0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A,
        -- IHDR chunk
        0x00, 0x00, 0x00, 0x0D,
        0x49, 0x48, 0x44, 0x52,
        0, 0, 0, 0,  -- 'width' placeholder
        0, 0, 0, 0,  -- 'height' placeholder
        0x08, colorType, 0x00, 0x00, 0x00,
        0, 0, 0, 0,  -- IHDR CRC-32 placeholder
        -- IDAT chunk
        0, 0, 0, 0,  -- 'idatSize' placeholder
        0x49, 0x44, 0x41, 0x54,
        -- DEFLATE data
        0x08, 0x1D,
    }
    putBigUint32(width, header, 17)
    putBigUint32(height, header, 21)
    putBigUint32(idatSize, header, 34)

    state.crc = 0
    state:crc32(header, 13, 17)
    putBigUint32(state.crc, header, 30)
    state:writeBytes(header)

    state.crc = 0
    state:crc32(header, 38, 6);  -- 0xD7245B6B
    state.adler = 1

    state.positionX = 0
    state.positionY = 0
    state.deflateFilled = 0

    return state
end

return begin
