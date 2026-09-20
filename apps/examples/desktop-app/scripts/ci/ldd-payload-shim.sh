#!/bin/sh
# ldd shim for Linux AppImage bundling (used by desktop-linux.yml).
#
# linuxdeploy runs `ldd` over every executable in the AppDir and aborts the
# whole bundle when it exits nonzero. Bun-compiled payload binaries (the
# desktop sidecar and SSH remote helpers) fail Ubuntu 22.04's ldd, yet need
# only an ancient libc (max GLIBC_2.17 in their strings), so there is nothing
# to deploy for them. The main Rust binary passes through to the real ldd
# and gets full dependency deployment as usual.
case "$*" in
	*code-sidecar*|*remote-helper*) exit 0 ;;
esac
exec /usr/bin/ldd "$@"
