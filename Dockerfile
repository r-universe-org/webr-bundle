FROM georgestagg/webr-flang

# Install latest nodejs
RUN curl -L https://deb.nodesource.com/setup_18.x -o setup &&\
  bash setup && \
  apt install nodejs &&\
  echo "Running nodejs $(node --version)"

# Needed to publish to npm (copied from setup-node action)
ADD npmrc /root/.npmrc

RUN git clone https://github.com/r-wasm/webr

WORKDIR webr

COPY datatool /datatool

# Update npm metadata
RUN sed -i.bak 's/@r-wasm/@r-universe/g' src/package.json &&\
  sed -i.bak "s|\"version\":.*|\"version\": \"$(date +'%Y.%m.%d')\",|" src/package.json &&\
  curl -sSOL https://github.com/r-universe-org/webr-bundle/raw/master/README.md &&\
  cat src/package.json

RUN ./configure

RUN cp -r /opt/flang/wasm .; cp -r /opt/flang/host .;cp /opt/flang/emfc ./host/bin/emfc

# Add packages to the bundle
RUN git clone --depth 1 https://github.com/cran/jsonlite packages/jsonlite &&\
    git clone --depth 1 https://github.com/ropensci/writexl packages/writexl &&\
    git clone --depth 1 https://github.com/cran/data.table packages/data.table &&\
    git clone --depth 1 https://github.com/cran/zip packages/zip && \
    cp -Rf /datatool packages/datatool && \
    sed -i.bak 's/PKGS = webr/PKGS = webr jsonlite writexl data.table zip datatool/' packages/Makefile

RUN PATH="/opt/emsdk:/opt/emsdk/upstream/emscripten:$PATH" EMSDK=/opt/emsdk EM_NODE_JS=$(which node) make
