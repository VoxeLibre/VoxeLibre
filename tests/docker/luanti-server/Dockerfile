FROM node:20-alpine

RUN apk add --no-cache sqlite-libs sdl2 libjpeg-turbo libpng zstd freetype gettext openal-soft-libs libvorbis luajit libcurl hiredis mesa-gl

ADD luanti-5.13.0-1.tar.gz /opt/

EXPOSE 30000/udp

ENTRYPOINT ["/opt/luanti-5.13.0/bin/luanti"]
CMD ["--server", "--worldname", "game"]
