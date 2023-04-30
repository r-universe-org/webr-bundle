FROM georgestagg/webr-flang

RUN git clone https://github.com/r-wasm/webr

WORKDIR webr 

RUN curl -sL https://deb.nodesource.com/setup_18.x -o nodesource_setup.sh &&\
  bash nodesource_setup.sh &&\
  apt install nodejs

RUN echo "BASE_URL=https://webr.r-wasm.org/v0.1.2/" > "$HOME/.webr-config.mk"

RUN ./configure

RUN cp -r /opt/flang/wasm .; cp -r /opt/flang/host .;cp /opt/flang/emfc ./host/bin/emfc

RUN git clone https://github.com/cran/jsonlite packages/jsonlite &&\
    git clone https://github.com/cran/writexl packages/writexl &&\
  sed -i.bak 's/PKGS = webr/PKGS = webr jsonlite writexl/' packages/Makefile

RUN PATH="/opt/emsdk:/opt/emsdk/upstream/emscripten:$PATH" EMSDK=/opt/emsdk make


