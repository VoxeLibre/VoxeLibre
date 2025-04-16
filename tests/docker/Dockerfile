FROM alpine

ENTRYPOINT ["/bin/sh"]

RUN apk add --no-cache luajit luarocks5.3 git lua-language-server x11vnc xdotool minetest gettext sqlite sdl2 libjpeg-turbo libpng zstd freetype

RUN apk add --no-cache --virtual=build-dependencies build-base lua5.3-dev luajit-dev cmake zlib-dev freetype-dev libjpeg-turbo-dev libpng-dev zstd-dev gettext-dev mesa-dev

RUN luarocks-5.3 install busted
RUN luarocks-5.3 install luacov
RUN luarocks-5.3 install luacheck
RUN luarocks-5.3 install luaposix
RUN luarocks-5.3 install lunajson

RUN git clone https://github.com/AlberTajuelo/bitop-lua.git && \
    cd bitop-lua && \
    sed -i 's/"lua >= 5.1, < 5.3"/"lua >= 5.1"/' bitop-lua-1.0-0.rockspec && \
    luarocks-5.3 make

RUN apk add --no-cache --virtual=build-dependencies build-base lua5.3-dev luajit-dev cmake zlib-dev freetype-dev libjpeg-turbo-dev libpng-dev zstd-dev gettext-dev mesa-dev xorg-server-dev xinput libxi-dev hiredis-dev curl-dev libogg-dev libvorbis-dev openal-soft-dev openssl-dev>3 samurai bzip2-dev sdl2-dev

COPY . /VoxeLibre
RUN cd /VoxeLibre/tests/docker/ && sh build-luanti-versions.sh
#RUN cd /VoxeLibre/tests/docker/ && sh build-luanti-head.sh

#RUN apk del --purge build-dependencies && \
#    rm /VoxeLibre/Dockerfile

