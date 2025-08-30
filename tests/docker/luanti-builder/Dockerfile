FROM node:20-alpine

ENTRYPOINT /bin/sh

RUN apk add --no-cache git build-base lua5.3-dev luajit-dev cmake zlib-dev freetype-dev    \
		libjpeg-turbo-dev libpng-dev zstd-dev gettext-dev mesa-dev xorg-server-dev \
		xinput libxi-dev hiredis-dev curl-dev libogg-dev libvorbis-dev             \
		openal-soft-dev openssl-dev>3 samurai bzip3-dev sdl2-dev cmake
