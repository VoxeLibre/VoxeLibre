#!/bin/sh

which luarocks && eval $(luarocks path)
which luarocks-5.3 && eval $(luarocks-5.3 path)

find ./ -name 'unit-test.lua' | while read TEST; do
	(
		cd $(dirname $TEST)
		busted unit-test.lua
	)
done
