#!/bin/sh

SUCCESS_FF=$(mktemp)
LOG=$(mktemp)

set -e
set -x

if [[ -z "$BUILD_DIR" ]]; then
	BUILD_DIR=$PWD/opt/
	if ! test -d $BUILD_DIR; then
		BUILD_DIR=/opt/
	fi
fi

GAMES_DIR=/luanti/games
if ! test -d $GAMES_DIR; then
	GAMES_DIR=~/.minetest/games
fi

WORLD=$(mktemp -d)

PORT=30010
VERSIONS="HEAD HEAD-nojit 5.14.0 5.13.0 5.12.0 5.11.0 5.10.0 5.9.1 5.9.0 5.8.0 5.7.0"

for VERSION in $VERSIONS; do
	BIN=$BUILD_DIR/luanti-$VERSION/bin/luanti
	if ! test -f $BIN; then
		BIN=$BUILD_DIR/luanti-$VERSION/bin/minetest
	fi

	if ! test -e $BIN; then
		echo "Missing executable for $VERSION"
		rm $SUCCESS_FF || true
	fi
done

if test -f $SUCCESS_FF; then
	for VERSION in $VERSIONS; do
		BIN=$BUILD_DIR/luanti-$VERSION/bin/luanti
		if ! test -f $BIN; then
			BIN=$BUILD_DIR/luanti-$VERSION/bin/minetest
		fi

		# Record version information
		$BIN --version
		PORT=$(( $PORT + 1))

		# Setup game link
		rm $BUILD_DIR/luanti-$VERSION/games/VoxeLibre-Test || true
		ln -s $PWD $BUILD_DIR/luanti-$VERSION/games/VoxeLibre-Test

		# Server Startup Test
		((
			$BIN --server --world $WORLD --gameid VoxeLibre-Test --port $PORT
		) 2>&1 | cat > $LOG ) &
		PID=$!

		# Wait for the server to complete startup or timeout after 15 seconds
		DONE=false
		SUCCESS=false
		COUNT=60
		set +x
		while ! $DONE; do
			if cat $LOG | grep -q 'ERROR'; then
				echo "An error occured while starting VoxeLibre on Luanti $VERSION:"
				cat $LOG | grep -q 'ERROR'

				DONE=true
				SUCCESS=false
			fi
			if cat $LOG | grep -q 'listening on'; then
				DONE=true
				SUCCESS=true
			fi
			COUNT=$(( $COUNT - 1 ))
			if [ "$COUNT" == "0" ]; then
				echo "Timeout while starting VoxeLibre on Luanti $VERSION"
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
		rm $LOG || true
		rm -Rvf $WORLD || true

		echo $SUCCESS
		if ! $SUCCESS; then
			rm $SUCCESS_FF || true
		fi
	done
fi

rm $LOG || true

if ! test -f $SUCCESS_FF; then
	echo "Startup test failed"
	exit 1
else
	rm $SUCCESS_FF || true
	exit 0
fi
