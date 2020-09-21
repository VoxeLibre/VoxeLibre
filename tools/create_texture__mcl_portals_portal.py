import png
w, h = 64, 256;
s = [[int(0) for c in range(w)] for c in range(h)] 

def line(y1, x1, y2, x2, v):
	signx = 1
	signy = 1
	dx = x2 - x1
	dy = y2 - y1
	if dx < 0:
		dx = - dx
		signx = -1
	if dy < 0:
		dy = - dy
		signy = -1
	offsx = dx/2
	offsy = dy/2
	dir1 = 0
	if dx >= dy:
		dir1 = 1
	for i in range(max(dx, dy)+1):
		if v==2:
			s[x1][y1]=1-s[x1][y1]
		else:
			s[x1][y1] = v
		if dir1 == 1:
			x1 += signx
			offsy += dy
			if offsy >= dx:
				y1 += signy
				offsy -= dx
		else:
			y1 += signy
			offsx += dx
			if offsx >= dy:
				x1 += signx
				offsx -= dy

# R, G, B, Alpha (0xFF = opaque):
palette=[(0x00,0x00,0xaf,0xa0), (0x7f,0x0f,0xaf,0xb8)]

for j in range(16):
	i = j * 4
	line(i, 0, 63-i, 63, 2)
	line(63, i, 0, 63-i, 2)
	i+=1
	line(i, 64, 63-i, 127, 2)
	line(63, 64+i, 0, 127-i, 2)
	i+=1
	line(i, 128, 63-i, 191, 2)
	line(63, 128+i, 0, 191-i, 2)
	i+=1
	line(i, 192, 63-i, 255, 2)
	line(63, 192+i, 0, 255-i, 2)

w = png.Writer(len(s[0]), len(s), palette=palette, bitdepth=1)
f = open('mcl_portals_portal.png', 'wb')
w.write(f, s)
