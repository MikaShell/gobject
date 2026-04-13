{
  lib,
  mkShell,
  glib,
  gobject-introspection,
  libsoup_3,
  libxslt,
  wpewebkit,
  zig,
  ...
}: let
  gir_dir = lib.makeSearchPathOutput "share/gir-1.0" "share/gir-1.0" [
    wpewebkit.dev
    glib.dev
    gobject-introspection.dev
    libsoup_3.dev
  ];
in
  mkShell {
    buildInputs = [libxslt zig];
    GIR_DIR = gir_dir;
  }
