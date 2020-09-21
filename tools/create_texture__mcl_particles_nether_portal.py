import png

s = [
	'0000010',
	'0101100',
	'0010111',
	'0101010',
	'1010111',
	'0001100',
	'0010100',
]

s = [[int(c) for c in row] for row in s]

# R, G, B, Alpha (0xFF = opaque):
palette=[(0x00,0x00,0x00,0x00), (0xcf,0x00,0xcf,0xe0)]

w = png.Writer(len(s[0]), len(s), palette=palette, bitdepth=1)
f = open('mcl_particles_nether_portal.png', 'wb')
w.write(f, s)

