### Zstandard on WASI

Compile zstd command-line interface to WASM using WASI

Build
```
make -j
```

Test in wasmtime
```
echo "Hello world!" | wasmtime run build/zstd.wasm -- -
```

Test in a worker!
```
wrangler dev build/zstd.wasm -- -

echo "Hello world!" | curl https://<worker-endpoint> -X POST --data-binary @-
```

