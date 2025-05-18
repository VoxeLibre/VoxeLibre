#!/bin/sh

rm -Rvf $PWD/data
mkdir $PWD/data
chmod -Rvf 1000 $PWD/data
chmod 755 $PWD/data
docker run --rm -it --network=host -u 1000:1000 \
	-v data:/data \
	-v /var/run/docker.sock:/var/run/docker.sock \
	code.forgejo.org/forgejo/runner:4.0.0 sh -c "cd /data; forgejo-runner register"
