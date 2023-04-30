FROM georgestagg/webr-flang

RUN bash <(curl -sL https://deb.nodesource.com/setup_18.x) &&\
  apt install nodejs &&\
  echo "Running nodejs $(node --version)"

RUN git clone https://github.com/r-wasm/webr

WORKDIR webr

RUN ./configure

RUN cp -r /opt/flang/wasm .; cp -r /opt/flang/host .;cp /opt/flang/emfc ./host/bin/emfc

RUN git clone https://github.com/cran/jsonlite packages/jsonlite &&\
    git clone https://github.com/cran/writexl packages/writexl &&\
  sed -i.bak 's/PKGS = webr/PKGS = webr jsonlite writexl/' packages/Makefile

RUN PATH="/opt/emsdk:/opt/emsdk/upstream/emscripten:$PATH" EMSDK=/opt/emsdk make


