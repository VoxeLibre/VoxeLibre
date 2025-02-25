#!/bin/sh

set -e

which luarocks && eval $(luarocks path)
which luarocks-5.3 && eval $(luarocks-5.3 path)

find ./ -name 'mod.conf' | sort | while read MOD; do
	(
		set -e
		DIR=$(dirname $MOD)
		cd $DIR

		if [[ -d test/ ]]; then
			for TEST in test/*.lua; do
				busted $TEST
			done
		fi
	)
done
