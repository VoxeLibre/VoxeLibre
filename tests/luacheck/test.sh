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
cp test/luacheck/check.lst{,.orig}
cat luacheck-passed.lst test/luacheck/check.lst.orig | sort > test/luacheck/check.lst
rm test/luacheck/check.lst.org
rm luacheck-passed.lst

