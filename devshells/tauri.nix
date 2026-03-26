{ pkgs }:

let
  libraries = with pkgs; [
    webkitgtk_4_1
    gtk3
    cairo
    gdk-pixbuf
    glib
    dbus
    openssl
    librsvg
    libsoup_3
  ];
in
pkgs.mkShell {
  name = "tauri-shell";

  buildInputs = with pkgs; [
    # Rust
    cargo
    rustc
    rustfmt
    clippy

    # Build deps
    pkg-config

    # Notmuch (email indexing)
    notmuch

    # Tauri / WebKitGTK
    webkitgtk_4_1
    gtk3
    cairo
    gdk-pixbuf
    glib
    dbus
    openssl
    librsvg
    libsoup_3
    glib-networking

    # GPU wrapper for non-NixOS
    nixgl.nixGLIntel
  ];

  shellHook = ''
    export WEBKIT_DISABLE_DMABUF_RENDERER=1
    export GIO_EXTRA_MODULES="${pkgs.glib-networking}/lib/gio/modules"
    export LIBRARY_PATH="${pkgs.notmuch}/lib:$LIBRARY_PATH"
  '';
}
