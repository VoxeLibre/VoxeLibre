import png
w, h = 16, 128;
s = [[int(0) for c in range(w)] for c in range(h)] 

def drawpixel(x, y, t):
	if (x >= 0) and (x < w) and (y >= 0) and (y < h):
		if(t == 1):
			s[y][x] = 1
		elif t==2:
			s[y][x] = 1 - s[y][x]
		elif t==3:
			s[y][x] = s[y][x] + 1
			if s[y][x] > 3:
				s[y][x] =s[y][x]-4

def circle(X1, Y1, R, t):
	x = 0
	y = R
	delta = 1 - 2 * R
	error = 0
	while y >= 0:
		if Y1%w + y < w:
			drawpixel(X1 + x, Y1 + y, t)
		if Y1%w - y >= 0:
			drawpixel(X1 + x, Y1 - y, t)
		if Y1%w + y < w:
			drawpixel(X1 - x, Y1 + y, t)
		if Y1%w - y >= 0:
			drawpixel(X1 - x, Y1 - y, t)
		error = 2 * (delta + y) - 1
		if ((delta < 0) and (error <= 0)):
			x = x + 1
			delta = delta + 2 * x + 1
		elif ((delta > 0) and (error > 0)):
			y = y - 1
			delta = delta - 2 * y + 1
		else:
			x = x + 1
			y = y - 1
			delta = delta + 2 * (x - y)

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
		if(v == 1):
			s[x1][y1] = 1
		elif v==2:
			s[x1][y1] = 1 - s[x1][y1]
		elif v==3 or (v==4 and ((x1^y1)&1)) or (v==5 and (((x1|y1)&1)==0)) or (v==7 and ((((x1+1)|y1)&1)==0)) or (v==8 and ((((x1+1)|(y1+1))&1)==0)) or (v==6 and (((x1|(y1+1))&1)==0)):
			s[x1][y1] = s[x1][y1] + 1
			if s[x1][y1] > 3:
				s[x1][y1] = s[x1][y1] - 4
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
palette=[
	(0x30,0x03,0xaf,0xa4),
	(0x4f,0x1c,0xaf,0xb4),
	(0x7f,0x3d,0xa0,0xc8),
	(0x6d,0x5d,0x99,0xb1)
]

circles = h//w
maxr = w//2
for i in [1,2,3,5,9,10,11,13]:
	for c in range(circles):
		q = ((circles-c-1)+i)%w
		circle(maxr, maxr+c*w, q, 3)


linesperside = 2
linestarts = round(w / linesperside) # 8
lineoffset = round(w / linestarts) # 2
wminus = w - 1

for j in range(linesperside):
	for k in range(linestarts):
		offset = k * w
		for q in [0,1,3,4]:
#		for q in [1]:
			i = j*linestarts + ((k+q)%linestarts)
			line(i, offset, wminus-i, offset+wminus, 5+(k&3))
			line(wminus, offset+i, 0, offset+wminus-i, 5+(k&3))



w = png.Writer(len(s[0]), len(s), palette=palette, bitdepth=2)
f = open('mcl_portals_portal.png', 'wb')
w.write(f, s)
