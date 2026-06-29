PREFIX ?= /usr
LIBDIR ?= $(PREFIX)/lib
INCLUDEDIR ?= $(PREFIX)/include
PKGCONFIGDIR ?= $(LIBDIR)/pkgconfig
VERSION ?= 0.1.0
BUILD_DIR ?= build

CARGO ?= cargo
CC ?= cc
CFLAGS ?= -Wall -Wextra -O2 -fPIC
LDFLAGS ?=

.PHONY: all clean install

all: $(BUILD_DIR)/liblhdcv5.so $(BUILD_DIR)/lhdcv5.pc

$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

$(BUILD_DIR)/log/log.h: log.h | $(BUILD_DIR)
	install -Dm644 $< $@

aosp/target/release/liblhdcv5.a:
	cd aosp && $(CARGO) build --release --locked --lib

$(BUILD_DIR)/liblhdcv5.so: aosp/target/release/liblhdcv5.a aosp/src/lhdcv5BT_enc.c $(BUILD_DIR)/log/log.h | $(BUILD_DIR)
	$(CC) $(CFLAGS) -shared \
		-Iaosp/include \
		-I$(BUILD_DIR) \
		aosp/src/lhdcv5BT_enc.c \
		aosp/target/release/liblhdcv5.a \
		-Wl,-soname,liblhdcv5.so \
		$(LDFLAGS) \
		-o $@

$(BUILD_DIR)/lhdcv5.pc: lhdcv5.pc.in | $(BUILD_DIR)
	sed "s/@PKGVER@/$(VERSION)/g" $< > $@

install: all
	install -Dm755 $(BUILD_DIR)/liblhdcv5.so "$(DESTDIR)$(LIBDIR)/liblhdcv5.so"
	install -Dm644 aosp/include/lhdcv5BT.h "$(DESTDIR)$(INCLUDEDIR)/lhdcv5/lhdcv5BT.h"
	install -Dm644 aosp/include/lhdcv5_api.h "$(DESTDIR)$(INCLUDEDIR)/lhdcv5/lhdcv5_api.h"
	install -Dm644 $(BUILD_DIR)/lhdcv5.pc "$(DESTDIR)$(PKGCONFIGDIR)/lhdcv5.pc"

clean:
	rm -rf $(BUILD_DIR) aosp/target
