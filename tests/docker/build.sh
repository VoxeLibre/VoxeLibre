#!/bin/bash

echo "Enter repo: "
read REPO

sed -i "s#REPO#$REPO#" Dockerfile
docker build . -t 127.0.0.1:5000/voxelibre-test:latest
git restore Dockerfile

