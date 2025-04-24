#!/bin/sh

SUCCESS_FF=$(mktemp)
LOG=$(mktemp)

set -e
set -x

GAMES_DIR=/luanti/games
if ! test -d $GAMES_DIR; then
	GAMES_DIR=~/.minetest/games
fi

# Setup minetest/luanti config directory
mkdir -p $GAMES_DIR
unlink $GAMES_DIR/VoxeLibre-Test || true
ln -s $PWD $GAMES_DIR/VoxeLibre-Test

WORLD=$(mktemp -d)

PORT=30010
VERSIONS="5.11.0 5.10.0 5.9.1 5.9.0 5.8.0 5.7.0 head head-nojit"

for VERSION in $VERSIONS; do
	BIN=luanti-$VERSION

	# Record version information
	$BIN --version
	PORT=$(( $PORT + 1))

	# Server Startup Test
	((
		$BIN --server --world $WORLD --gameid VoxeLibre-Test --port $PORT
	) 2>&1 | cat > $LOG ) &
	PID=$!

	# Wait for the server to complete startup or timeout after 15 seconds
	DONE=false
	SUCCESS=false
	COUNT=30
	set +x
	while ! $DONE; do
		if cat $LOG | grep -q 'ERROR'; then
			DONE=true
			SUCCESS=false
		fi
		if cat $LOG | grep -q 'listening on'; then
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
	set -x

	# Stop the server
	sleep 1
	kill $PID || true
	killall $BIN || true

	# Display log contents
	cat $LOG
	rm $LOG
	rm -Rvf $WORLD || true

	echo $SUCCESS
	if ! $SUCCESS; then
		rm $SUCCESS_FF || true
	fi
done

rm $GAMES_DIR/VoxeLibre-Test || true
rm $LOG || true

if ! test -f $SUCCESS_FF; then
	exit 1
else
	rm $SUCCESS_FF || true
	exit 0
fi
