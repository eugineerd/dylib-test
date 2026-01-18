GAME_LIB_PATH:=../game_lib/target/debug
GAME_LIB_DYLIB:="libgame_lib.so"
GAME_LIB_RLIB:="libgame_lib.rlib"
BEVY_PROXY_PATH:=../bevy-proxy/target/debug
BEVY_PROXY_DYLIB:="libbevy_proxy.so"
BEVY_PROXY_RLIB:="libbevy_proxy.rlib"

# we need libstd + all the other dynamic libs to launch, so just add all of them to library path
LIBRARY_PATH:=$(shell rustc --print target-libdir):$(GAME_LIB_PATH):$(GAME_LIB_PATH)/deps:$(BEVY_PROXY_PATH)/debug/:$(BEVY_PROXY_PATH)/deps:

.PHONY: run
# Linux-specific method of adding to library path
run: export LD_LIBRARY_PATH=$(LIBRARY_PATH)
run: compile_game_bin
	cd game_bin && target/debug/game_bin

.PHONY: compile_game_bin
compile_game_bin: compile_game_lib
	cd game_bin && cargo rustc -- -Cprefer-dynamic --extern game_lib=$(GAME_LIB_PATH)/$(GAME_LIB_DYLIB) --extern game_lib=$(GAME_LIB_PATH)/$(GAME_LIB_RLIB) -L dependency=$(GAME_LIB_PATH)/deps -L dependency=$(BEVY_PROXY_PATH)/deps

.PHONY: compile_game_lib
compile_game_lib: compile_bevy_proxy
	cd game_lib && cargo rustc -- -Cprefer-dynamic --extern bevy=$(BEVY_PROXY_PATH)/$(BEVY_PROXY_DYLIB) --extern bevy=$(BEVY_PROXY_PATH)/$(BEVY_PROXY_RLIB) -L dependency=$(BEVY_PROXY_PATH)/deps

.PHONY: compile_bevy_proxy
compile_bevy_proxy: export RUSTFLAGS=-Cprefer-dynamic
compile_bevy_proxy:
	cd bevy-proxy && cargo build