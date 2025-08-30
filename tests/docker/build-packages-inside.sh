#!/bin/sh

set -ex

build_head()
{
	export VERSION=HEAD
	cd /opt

	REBUILD=false
	if ! tar xf /opt/luanti-ci/luanti-$VERSION-1.tar.gz; then REBUILD=true; fi
	if ! tar xf /opt/luanti-ci/luanti-$VERSION-nojit-1.tar.gz; then REBUILD=true; fi

	LUANTI_REPO=https://github.com/luanti-org/luanti.git
	LAST_BUILT="$(cat /opt/luanti-$VERSION/LAST_BUILT || true )"
	UPSTREAM="$(git ls-remote $LUANTI_REPO refs/heads/master | awk '{ print $1 }')"
	if [[ "$UPSTREAM" != "$LAST_BUILT" ]]; then
		echo "Changes to upstream ($LAST_BUILT -> $UPSTREAM), rebuilding"
		REBUILD=true
	fi

	if ! $REBUILD; then return; fi

	rm -Rf /opt/luanti-HEAD
	git clone --single-branch --branch master --depth 1 $LUANTI_REPO luanti-$VERSION
	cp -Rf luanti-$VERSION luanti-$VERSION-nojit

	set -x

	(
		cd /opt/luanti-$VERSION
		cmake . -DRUN_IN_PLACE=TRUE
		make -j$(nproc)
		git rev-parse HEAD > LAST_BUILT
		rm -Rf src po lib irr misc android CMakeFiles .git games/devtest cmake .github
	)

	# Make package tarball
	tar czf /opt/luanti-ci/luanti-$VERSION-1.tar.gz luanti-$VERSION
	rm -Rf /opt/luanti-$VERSION

	# Build without luajit
	VERSION=HEAD-nojit

	(
		cd /opt/luanti-$VERSION-nojit
		cmake . -DRUN_IN_PLACE=TRUE
		make -j$(nproc)
		git rev-parse HEAD > LAST_BUILT

		rm -Rf src po lib irr misc android CMakeFiles .git games/devtest cmake .github
	)

	# Make package tarball
	tar czf /opt/luanti-ci/luanti-$VERSION-1.tar.gz luanti-$VERSION
	rm -Rf /opt/luanti-$VERSION
}


build_new()
{
	export VERSION=$1
	IRRLICHT=$2
	PATCH="$3"
	cd /opt
	if tar xvf /opt/luanti-ci/luanti-$VERSION-1.tar.gz; then return; fi

	set -x
	git clone --depth 1 --branch $VERSION https://github.com/luanti-org/luanti.git /opt/luanti-$VERSION

	(
		cd /opt/luanti-$VERSION

		if [[ -n "$IRRLICHT" ]]; then
			git clone --depth 1 --branch $IRRLICHT https://github.com/minetest/irrlicht.git lib/irrlichtmt
		fi
		if [[ -n "$PATCH" ]]; then
			eval "$PATCH"
		fi

		cmake . -DRUN_IN_PLACE=TRUE
		make -j$(nproc)

		rm -Rvf src po lib irr misc android CMakeFiles .git games/devtest cmake .github
	)

	# Make package tarball
	tar czvf /opt/luanti-ci/luanti-$VERSION-1.tar.gz luanti-$VERSION
	rm -Rv /opt/luanti-$VERSION
}


build_head
for VERSION in 5.13.0 5.12.0 5.11.0 5.10.0 5.9.1 5.9.0; do
	build_new $VERSION
done

build_new 5.8.0 1.9.0mt13 "sed -e '27i#include <algorithm>' -i src/client/sound/sound_data.cpp; export CXX_FLAGS=-std=c++20"
build_new 5.7.0 1.9.0mt10
