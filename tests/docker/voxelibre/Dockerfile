FROM teknomunk/luanti-server:latest

RUN cd /opt && \
    wget https://git.minetest.land/VoxeLibre/VoxeLibre/archive/0.91.1.tar.gz && \
    tar xvf 0.91.1.tar.gz && \
    ln -s /opt/voxelibre /opt/luanti-5.14.0/games/

CMD ["--server", "--worldname", "game", "--gameid", "voxelibre"]
