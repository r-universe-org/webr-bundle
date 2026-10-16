FROM ghcr.io/r-wasm/flang-wasm:main

ENV PATH="/opt/emsdk:/opt/emsdk/upstream/emscripten:${PATH}"
ENV EMSDK="/opt/emsdk"
ENV WEBR_ROOT="/opt/webr"
ENV EM_NODE_JS="/usr/bin/node"
ENV EMFC="/opt/flang/host/bin/flang"

# Install nodeJS
RUN apt-get update && apt-get install nodejs npm -y

RUN git clone https://github.com/r-wasm/webr /opt/webr

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

# Build the npm package. All js dependencies (react, codemirror, etc) are only
# needed for building: esbuild bundles what is used into dist. Remove them from
# package.json so that installing the package does not pull in ~70 packages.
RUN cd src && make "$PWD/dist/webr.mjs" "$PWD/dist/vfs" && npm pkg delete dependencies

# Smoke test: the packed package must work without any dependencies
RUN cd src && npm pack --pack-destination /tmp &&\
    mkdir /tmp/smoketest && cd /tmp/smoketest && npm init -y > /dev/null &&\
    npm install /tmp/*.tgz && test "$(ls node_modules | wc -l)" = "1" &&\
    PKG=$(node -p "require('/opt/webr/src/package.json').name") node -e "\
      const { WebR } = require(process.env.PKG);\
      const webR = new WebR({ interactive: false });\
      webR.init().then(() => webR.evalRString('paste(R.version.string, packageVersion(\"jsonlite\"))'))\
        .then((x) => { console.log('Smoke test OK:', x); process.exit(0); })\
        .catch((e) => { console.error(e); process.exit(1); });" &&\
    rm -rf /tmp/smoketest /tmp/*.tgz
