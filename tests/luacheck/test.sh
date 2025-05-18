#!/bin/sh

. tests/env.sh
set -e

if test -z "$LUA"; then
	echo "Unable to find lua interpreter"
	exit 1
fi
echo -n > luacheck-passed.lst
(
	find ./ -name mod.conf
	echo EOF
) | $LUA tests/luacheck/test.lua | sh
cat luacheck-passed.lst | sort > check.lst
rm luacheck-passed.lst

