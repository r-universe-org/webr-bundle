FROM ghcr.io/r-wasm/flang-wasm:main

ENV PATH="/opt/emsdk:/opt/emsdk/upstream/emscripten:${PATH}"
ENV EMSDK="/opt/emsdk"
ENV WEBR_ROOT="/opt/webr"
ENV EM_NODE_JS="/usr/bin/node"
ENV EMFC="/opt/flang/host/bin/flang"

# Install nodeJS
RUN apt-get update && apt-get install nodejs npm -y

RUN git clone --branch v0.5.2 --single-branch https://github.com/r-wasm/webr /opt/webr

WORKDIR /opt/webr

COPY datatool /datatool

# Update npm metadata
RUN sed -i.bak 's|"name": "webr"|"name": "@r-universe/webr"|' src/package.json &&\
    sed -i.bak "s|\"version\":.*|\"version\": \"$(date +'%Y.%m.%d')\",|" src/package.json &&\
    curl -sSOL https://github.com/r-universe-org/webr-bundle/raw/master/README.md &&\
    cat src/package.json

RUN ./configure

# Add packages to the bundle
RUN git clone --depth 1 https://github.com/cran/jsonlite packages/jsonlite &&\
    git clone --depth 1 https://github.com/ropensci/writexl packages/writexl &&\
    git clone --depth 1 https://github.com/cran/data.table packages/data.table &&\
    git clone --depth 1 https://github.com/cran/zip packages/zip && \
    cp -Rf /datatool packages/datatool && \
    sed -i.bak 's/PKGS = webr/PKGS = webr jsonlite writexl data.table zip datatool/' packages/Makefile

RUN make
