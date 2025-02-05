#!/bin/sh

# Server Startup Test
((
	minetestserver --world tests/tmp --gameid VoxeLibre
) 2>&1 | cat > setup.log ) &
PID=$!

DONE=false
SUCCESS=false
COUNT=30
while ! $DONE; do
	if cat setup.log | grep -q 'listening on'; then
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

kill $PID
killall minetestserver

echo $SUCCESS
if ! $SUCCESS; then
	exit 1
fi
