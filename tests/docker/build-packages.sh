#!/bin/sh

(
	cd luanti-builder
	docker build . -t luanti-builder
)

docker run --rm -it --entrypoint /bin/sh -v"$(dirname $(dirname $PWD))":/opt/VoxeLibre -v$PWD/luanti-ci:/opt/luanti-ci luanti-builder /opt/VoxeLibre/tests/docker/build-packages-inside.sh
