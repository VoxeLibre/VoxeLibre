import png

s = [
	'0010010',
	'0101100',
	'0010111',
	'0101010',
	'1010111',
	'0101100',
	'0010101',
]

s = [[int(c) for c in row] for row in s]

# R, G, B, Alpha (0xFF = opaque):
palette=[(0x00,0x00,0x00,0x00), (0x9f,0x00,0xdf,0x92)]

w = png.Writer(len(s[0]), len(s), palette=palette, bitdepth=1)
f = open('mcl_particles_nether_portal_t.png', 'wb')
w.write(f, s)

