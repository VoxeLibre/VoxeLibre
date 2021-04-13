world_name = "world"
path_to_map_sqlite = "../../../worlds/" + world_name + "/map.sqlite"

import sqlite3, sys

try:
	conn = sqlite3.connect(path_to_map_sqlite)
except Error as e:
	print(e)
	sys.exit()

def unsignedToSigned(i, max_positive):
	if i < max_positive:
		return i
	else:
		return i - 2*max_positive

cursor = conn.cursor()
cursor.execute("SELECT pos FROM blocks")
poses = cursor.fetchall()
end_blocks = []
for i0 in (poses):
	i = int(i0[0])
	blockpos = i
	x = unsignedToSigned(i % 4096, 2048)
	i = int((i - x) / 4096)
	y = unsignedToSigned(i % 4096, 2048)
	i = int((i - y) / 4096)
	z = unsignedToSigned(i % 4096, 2048)

	node_pos_y = y * 16
	if node_pos_y > -28811 and node_pos_y + 15 < -67:
		end_blocks.append(blockpos)

if len(end_blocks) < 1:
	print ("End blocks not found")
	sys.exit()

counter = 0
for blockpos in end_blocks:
	print("Deleting ", blockpos)
	cursor.execute("DELETE FROM blocks WHERE pos=" + str(blockpos))
	counter += 1
conn.commit()

print(counter, " block(s) deleted")
