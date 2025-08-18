#/bin/sh

set -e

if ! test -d /opt/luanti-HEAD; then
	tests/docker/build-luanti-versions.sh
	tests/docker/build-luanti-head.sh
	export PATH=$PATH:$PWD/bin/
fi

sh tests/server-startup.sh
sh tests/unit-tests.sh
sh tests/luacheck/test.sh || true
sh tests/lua-language-server.sh || true
