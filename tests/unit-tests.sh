#!/bin/sh

set -e

which luarocks && eval $(luarocks path)
which luarocks-5.3 && eval $(luarocks-5.3 path)

find ./ -name 'unit-test.lua' | sort | while read TEST; do
	(
		set -e
		cd $(dirname $TEST)
		busted unit-test.lua
	)
done
