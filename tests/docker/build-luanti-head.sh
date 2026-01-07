#!/bin/bash
VERSIONS="HEAD HEAD-nojit"

set -ex

mkdir -p build
(
	cd build
	test -e luanti || git clone https://github.com/luanti-org/luanti.git
	(cd luanti; git checkout master; git pull)
)

build-HEAD()
{
	git checkout master
	git pull
	cmake . -DRUN_IN_PLACE=TRUE
	make -j$(nproc) && ln -sf $PWD/bin/luanti $INSTALL_BIN/luanti-HEAD
}
build-HEAD-nojit()
{
	git checkout master
	git pull
	cmake . -DRUN_IN_PLACE=TRUE -DENABLE_LUAJIT=OFF
	make -j$(nproc) && ln -sf $PWD/bin/luanti $INSTALL_BIN/luanti-HEAD-nojit
}

mkdir -p bin build
INSTALL_BIN=$PWD/bin
for VERSION in $VERSIONS; do
	rm -f bin/luanti-$VERSION
	(
		cd build/
		rm -Rvf luanti-$VERSION || true

		# Checkout the specific version desired
		git clone luanti/ luanti-$VERSION
		cd luanti-$VERSION

		# Build the server
		rm $INSTALL_BIN/luanti-$VERSION || true
		build-$VERSION

		# Setup games and worlds
		ln -s ../../ games/VoxeLibre-Test
		rm -Rvf worlds || true
		mkdir -p ../worlds
		ln -s ../worlds worlds
	)
done
