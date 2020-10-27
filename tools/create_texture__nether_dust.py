import png

s = [
	[
		'1',
	],
	[
		'11',
	],
	[
		'111',
		'111',
	],
]

# R, G, B, Alpha (0xFF = opaque):
palette=[(0x00,0x00,0x00,0x00), (0x8F,0x69,0x66,0x9F)]
#palette=[(0x00,0x00,0x00,0x00), (0xF0,0xF0,0xF0,0x80)]

for i in range(0, len(s)):
	print(str(i)+"/"+str(len(s)))
	q = [[int(c) for c in row] for row in s[i]]
	w = png.Writer(len(q[0]), len(q), palette=palette, bitdepth=1)
	f = open('mcl_particles_nether_dust'+str(i+1)+'.png', 'wb')
	w.write(f, q)
