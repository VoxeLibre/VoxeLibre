FROM teknomunk/luanti-server:latest

ADD luanti-5.7.0-1.tar.gz /opt/
ADD luanti-5.8.0-1.tar.gz /opt/
ADD luanti-5.9.0-1.tar.gz /opt/
ADD luanti-5.9.1-1.tar.gz /opt/
ADD luanti-5.10.0-1.tar.gz /opt/
ADD luanti-5.11.0-1.tar.gz /opt/
ADD luanti-5.12.0-1.tar.gz /opt/
ADD luanti-5.13.0-1.tar.gz /opt/

RUN apk add --no-cache luarocks5.3 git lua-language-server x11vnc xdotool

RUN apk add --no-cache --virtual=build-dependencies build-base lua5.3-dev luajit-dev cmake zlib-dev freetype-dev libjpeg-turbo-dev libpng-dev zstd-dev gettext-dev mesa-dev && \
    luarocks-5.3 install busted && \
    luarocks-5.3 install luacov && \
    luarocks-5.3 install luacheck && \
    luarocks-5.3 install luaposix && \
    luarocks-5.3 install lunajson && \
    luarocks-5.3 install LuaBitOp-53plus && \
    apk del --purge build-dependencies

ADD luanti-HEAD-1.tar.gz /opt/
ADD luanti-HEAD-nojit-1.tar.gz /opt/
