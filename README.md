# liblhdcv5

Native Linux build wrapper for the AOSP LHDC v5 encoder.

This package builds the Android 17 `system/audio/codecs/lhdcv5` source locally
and installs a normal system library for desktop audio stacks:

```text
/usr/lib/liblhdcv5.so
/usr/include/lhdcv5/lhdcv5BT.h
/usr/include/lhdcv5/lhdcv5_api.h
/usr/lib/pkgconfig/lhdcv5.pc
```

The encoder implementation is built from the AOSP Rust crate and linked with
the AOSP C wrapper into one shared library. The public ABI is `lhdcv5BT.h`, so
C consumers such as PipeWire can link it without knowing that the encoder
internals are Rust.

Source:

```text
https://android.googlesource.com/platform/packages/modules/Bluetooth
tag: android-17.0.0_r1
commit: c77db469de80f86660bc053bec4dee0c5d4b947c
path: system/audio/codecs/lhdcv5
license: Apache-2.0
```
