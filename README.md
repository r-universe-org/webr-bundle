# webr bundle for r-universe

Custom build of [webr](https://github.com/r-wasm/webr) used in r-universe. Published to: https://www.npmjs.com/package/@r-universe/webr

## Extra packages:

This bundle contains webr with the following packages preinstalled:

 - [datatool](https://github.com/r-universe-org/webr-bundle/tree/HEAD/datatool) (wrapper function to convert data)
 - jsonlite (json export)
 - writexl (xlsx export)
 - data.table (csv export)
 - zip

## Dependencies

The upstream webr package lists its build dependencies (react, codemirror, etc) as
regular dependencies, but esbuild bundles everything that is needed into `dist`.
We remove them from package.json before publishing, so the package installs
without any dependencies. The Dockerfile has a smoke test for this.
