all: ./build/zstd.asyncify.wasm

WASI_SDK_PATH := ./build/wasi-sdk-14.0
WASI_SYSROOT  := $(abspath $(WASI_SDK_PATH)/share/wasi-sysroot)

export CC  := $(abspath $(WASI_SDK_PATH)/bin/clang)  -target wasm32-wasi --sysroot=$(WASI_SYSROOT)
export LDFLAGS :=              \
   -lwasi-emulated-signal      \
   -lwasi-emulated-process-clocks

export MOREFLAGS :=                \
   -D_WASI_EMULATED_SIGNAL         \
   -D_WASI_EMULATED_PROCESS_CLOCKS \
   -D'chmod(...)=0'                \
   -D'chown(...)=0'                \
   -Wno-unused-parameter

clean:
	$(MAKE) -C ./zstd clean
	rm -rf ./build

ZSTD_BIN := ./zstd/programs/zstd
$(ZSTD_BIN): $(WASI_SDK_PATH)
	cd ./zstd && $(MAKE) zstd-release

WASM_OPT := ./build/binaryen/bin/wasm-opt
%.asyncify.wasm: %.wasm $(WASM_OPT)
	$(WASM_OPT) -g -O --asyncify $< -o $@

./build/zstd.wasm: $(ZSTD_BIN)
	mkdir -p $(@D)
	cp $< $@

$(WASI_SDK_PATH):
	mkdir -p $(@D)
	curl -sLo wasi-sdk.tar.gz https://github.com/WebAssembly/wasi-sdk/releases/download/wasi-sdk-14/wasi-sdk-14.0-linux.tar.gz
	echo '8c8ebb7f71dcccbb8b1ab384499a53913b0b6d1b7b3281c3d70165e0f002e821  ./wasi-sdk.tar.gz' | sha256sum -c
	tar zxf wasi-sdk.tar.gz --touch -C build
	rm wasi-sdk.tar.gz

$(WASM_OPT):
	mkdir -p build/binaryen
	curl -sLo binaryen.tar.gz https://github.com/WebAssembly/binaryen/releases/download/version_100/binaryen-version_100-x86_64-linux.tar.gz
	echo '9057c8f3f0bbfec47a95985c8f0faad8cc2aa3932e94a7d6b705e245ed140e19  binaryen.tar.gz' | sha256sum -c
	tar zxf binaryen.tar.gz --strip-components=1 --touch -C ./build/binaryen
	rm binaryen.tar.gz

