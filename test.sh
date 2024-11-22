#!/bin/sh

set -ex
which luarocks && eval $(luarocks path)
which luarocks-5.3 && eval $(luarocks-5.3 path)

sh tests/luacheck/test.sh || true

# Run unit tests
find ./ -name 'unit-test.lua' | while read TEST; do
	(
		cd $(dirname $TEST)
		busted unit-test.lua
	)
done
