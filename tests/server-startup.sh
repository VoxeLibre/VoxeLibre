#!/bin/sh

# Record version information
minetest --version

# Setup minetest/luanti config directory
mkdir -p ~/.minetest/games
ln -s /VoxeLibre ~/.minetest/games

# Server Startup Test
((
	minetest --server --worldname test --gameid VoxeLibre
) 2>&1 | cat > /tmp/setup.log ) &
PID=$!

# Wait for the server to complete startup or timeout after 15 seconds
DONE=false
SUCCESS=false
COUNT=30
while ! $DONE; do
	if cat /tmp/setup.log | grep -q 'listening on'; then
		DONE=true
		SUCCESS=true
	fi
	COUNT=$(( $COUNT - 1 ))
	if [ "$COUNT" == "0" ]; then
		DONE=true
		SUCCESS=false
	fi
	sleep 0.5
done

# Stop the server
kill $PID
killall minetestserver

# Display log contents
cat /tmp/setup.log
rm /tmp/setup.log

echo $SUCCESS
if ! $SUCCESS; then
	exit 1
fi
