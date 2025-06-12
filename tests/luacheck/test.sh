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
cp tests/luacheck/check.lst tests/luacheck/check.lst.orig
cat luacheck-passed.lst tests/luacheck/check.lst.orig | sort > tests/luacheck/check.lst
rm tests/luacheck/check.lst.orig
rm luacheck-passed.lst

