#/bin/sh

set -e

sh tests/server-startup.sh
sh tests/unit-tests.sh
sh tests/luacheck/test.sh || true
sh tests/lua-language-server.sh || true
