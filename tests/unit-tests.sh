#!/bin/sh

source tests/env.sh
set -e

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
