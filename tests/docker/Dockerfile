FROM alpine

RUN apk add --no-cache --virtual=build-dependencies build-base lua5.3-dev luajit-dev && \
    apk add --no-cache luajit luarocks5.3 git && \
    luarocks-5.3 install busted && \
    luarocks-5.3 install luacov && \
    luarocks-5.3 install luacheck && \
    luarocks-5.3 install luaposix && \
    git clone https://github.com/AlberTajuelo/bitop-lua.git && \
    cd bitop-lua && \
    sed -i 's/"lua >= 5.1, < 5.3"/"lua >= 5.1"/' bitop-lua-1.0-0.rockspec && \
    luarocks-5.3 make && \
    apk del --purge build-dependencies
ENTRYPOINT ["/bin/sh"]

RUN git config --global http.postBuffer 52428800 && \
    git clone REPO && \
    apk add minetest x11vnc xdotool

