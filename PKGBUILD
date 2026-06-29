# Maintainer: DBeidachazi
pkgname=liblhdcv5
pkgver=0.1.0
pkgrel=1
pkgdesc="AOSP LHDC v5 Bluetooth encoder library for Linux"
arch=('x86_64')
url="https://github.com/DBeidachazi/liblhdcv5"
license=('Apache-2.0')
depends=('glibc' 'gcc-libs')
makedepends=('rust' 'gcc')
options=('!strip')
_aosp_tag=android-17.0.0_r1
_aosp_commit=c77db469de80f86660bc053bec4dee0c5d4b947c
source=(
  "lhdcv5-${_aosp_tag}.tar.gz::https://android.googlesource.com/platform/packages/modules/Bluetooth/+archive/refs/tags/${_aosp_tag}/system/audio/codecs/lhdcv5.tar.gz"
  'Cargo.lock'
  'LICENSE-APACHE'
  'log.h'
  'lhdcv5.pc.in'
  'README.md'
)
sha256sums=(
  'SKIP'
  '6c81d5bbb1ae9018409e0f7d44f7bb62e5a87b3330c9da48080463826dbdf81f'
  '074e6e32c86a4c0ef8b3ed25b721ca23aca83df277cd88106ef7177c354615ff'
  'b7701c95e8e2e4f037709567c7c03d53de29ecf8a2a97d110cac65854df65e1c'
  '5f70672df8c6794d9c158bf708a6075d268116d5d45a59cedf648e174b3a0c35'
  '7a4794ce1462b167c9a60eb51f8350837b747712b234da3beddf25279fb42c78'
)

prepare() {
  cd "$srcdir"
  install -Dm644 log.h "$srcdir/linux-log-shim/log/log.h"
  sed -i 's/crate-type = \["rlib", "cdylib"\]/crate-type = ["staticlib"]/' Cargo.toml
  sed -i 's/void lhdcv5_enc_ffi_init();/void lhdcv5_enc_ffi_init(void);/' include/lhdcv5_api.h
}

build() {
  cd "$srcdir"
  cargo build --release --locked --lib

  gcc -Wall -Wextra -O2 -fPIC -shared \
    -I"$srcdir/include" \
    -I"$srcdir/linux-log-shim" \
    "$srcdir/src/lhdcv5BT_enc.c" \
    "$srcdir/target/release/liblhdcv5.a" \
    -Wl,-soname,liblhdcv5.so \
    -o "$srcdir/liblhdcv5.so"

  sed "s/@PKGVER@/$pkgver/g" "$srcdir/lhdcv5.pc.in" > "$srcdir/lhdcv5.pc"
}

package() {
  install -Dm755 "$srcdir/liblhdcv5.so" \
    "$pkgdir/usr/lib/liblhdcv5.so"
  install -Dm644 "$srcdir/include/lhdcv5BT.h" \
    "$pkgdir/usr/include/lhdcv5/lhdcv5BT.h"
  install -Dm644 "$srcdir/include/lhdcv5_api.h" \
    "$pkgdir/usr/include/lhdcv5/lhdcv5_api.h"
  install -Dm644 "$srcdir/lhdcv5.pc" \
    "$pkgdir/usr/lib/pkgconfig/lhdcv5.pc"
  install -Dm644 LICENSE-APACHE \
    "$pkgdir/usr/share/licenses/$pkgname/LICENSE"
  install -Dm644 README.md \
    "$pkgdir/usr/share/doc/$pkgname/README.md"
}
