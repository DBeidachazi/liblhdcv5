PREFIX ?= /usr
LIBDIR ?= $(PREFIX)/lib
INCLUDEDIR ?= $(PREFIX)/include
PKGCONFIGDIR ?= $(LIBDIR)/pkgconfig
VERSION ?= 0.1.0
BUILD_DIR ?= build
EXPORT_MAP ?= lhdcv5.map

CARGO ?= cargo
CC ?= cc
STRIP ?= strip
WARN_CFLAGS ?= -Wall -Wextra
OPT_CFLAGS ?= -O3
CFLAGS ?=
LDFLAGS ?=
LDLIBS ?= -lm -lpthread -ldl
RUSTFLAGS ?=
LHDC_RUSTFLAGS ?= -C relocation-model=pic
LHDC_X86_RUSTFLAGS ?= -C target-feature=-fma
RUST_TARGET ?=

RUST_HOST := $(shell rustc -vV | sed -n 's/^host: //p')
EFFECTIVE_RUST_TARGET := $(if $(strip $(RUST_TARGET)),$(RUST_TARGET),$(RUST_HOST))
RUST_ARCH := $(firstword $(subst -, ,$(EFFECTIVE_RUST_TARGET)))
RUST_TARGET_ARG := $(if $(strip $(RUST_TARGET)),--target $(RUST_TARGET))
RUST_RELEASE_DIR := aosp/target/$(if $(strip $(RUST_TARGET)),$(RUST_TARGET)/)release
RUST_STATICLIB := $(RUST_RELEASE_DIR)/liblhdcv5.a
RUST_SOURCES := $(shell find aosp/src -type f -name '*.rs') aosp/Cargo.toml aosp/Cargo.lock
LHDC_TARGET_RUSTFLAGS := $(if $(filter x86_64 i686,$(RUST_ARCH)),$(LHDC_X86_RUSTFLAGS))
LHDC_LDFLAGS ?= -Wl,--gc-sections -Wl,--version-script=$(abspath $(EXPORT_MAP)) -Wl,-z,defs

.PHONY: all clean install strip FORCE

all: $(BUILD_DIR)/liblhdcv5.so $(BUILD_DIR)/lhdcv5.pc

$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

$(BUILD_DIR)/log/log.h: log.h | $(BUILD_DIR)
	install -Dm644 $< $@

$(RUST_STATICLIB): $(RUST_SOURCES)
	cd aosp && RUSTFLAGS="$(RUSTFLAGS) $(LHDC_RUSTFLAGS) $(LHDC_TARGET_RUSTFLAGS)" $(CARGO) build --release --locked --lib $(RUST_TARGET_ARG)

$(BUILD_DIR)/liblhdcv5.so: $(RUST_STATICLIB) aosp/src/lhdcv5BT_enc.c $(BUILD_DIR)/log/log.h $(EXPORT_MAP) | $(BUILD_DIR)
	$(CC) $(WARN_CFLAGS) $(OPT_CFLAGS) $(CFLAGS) -fPIC -ffunction-sections -fdata-sections -shared \
		-Iaosp/include \
		-I$(BUILD_DIR) \
		aosp/src/lhdcv5BT_enc.c \
		$(RUST_STATICLIB) \
		-Wl,-soname,liblhdcv5.so \
		$(LHDC_LDFLAGS) \
		$(LDFLAGS) \
		$(LDLIBS) \
		-o $@

# Regenerated every run so install-time PREFIX/LIBDIR/INCLUDEDIR are honored.
$(BUILD_DIR)/lhdcv5.pc: lhdcv5.pc.in FORCE | $(BUILD_DIR)
	sed -e "s|@PKGVER@|$(VERSION)|g" \
		-e "s|@PREFIX@|$(PREFIX)|g" \
		-e "s|@LIBDIR@|$(LIBDIR)|g" \
		-e "s|@INCLUDEDIR@|$(INCLUDEDIR)|g" \
		$< > $@

FORCE:

install: all
	install -Dm755 $(BUILD_DIR)/liblhdcv5.so "$(DESTDIR)$(LIBDIR)/liblhdcv5.so"
	install -Dm644 aosp/include/lhdcv5BT.h "$(DESTDIR)$(INCLUDEDIR)/lhdcv5/lhdcv5BT.h"
	install -Dm644 aosp/include/lhdcv5_api.h "$(DESTDIR)$(INCLUDEDIR)/lhdcv5/lhdcv5_api.h"
	install -Dm644 $(BUILD_DIR)/lhdcv5.pc "$(DESTDIR)$(PKGCONFIGDIR)/lhdcv5.pc"

strip: all
	$(STRIP) --strip-unneeded $(BUILD_DIR)/liblhdcv5.so

clean:
	rm -rf $(BUILD_DIR) aosp/target
