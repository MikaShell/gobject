{
  lib,
  pkgs,
  mkShell,
  glib,
  gobject-introspection,
  libsoup_3,
  libxslt,
  wpewebkit,
  ...
}: let
  gir_dir = lib.makeSearchPathOutput "share/gir-1.0" "share/gir-1.0" [
    wpewebkit.dev
    glib.dev
    gobject-introspection.dev
    libsoup_3.dev
  ];
  zig = pkgs.zig_0_15;
in
  mkShell {
    buildInputs = [libxslt zig];
    GIR_DIR = gir_dir;
  }
