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

    # GSettings schemas (required for WebKitGTK font/DPI defaults on NixOS)
    gsettings-desktop-schemas

    # GPU wrapper for non-NixOS
    nixgl.nixGLIntel
  ];

  shellHook = ''
    export WEBKIT_DISABLE_DMABUF_RENDERER=1
    export GIO_EXTRA_MODULES="${pkgs.glib-networking}/lib/gio/modules"
    export XDG_DATA_DIRS="${pkgs.gsettings-desktop-schemas}/share/gsettings-schemas/${pkgs.gsettings-desktop-schemas.name}:${pkgs.gtk3}/share/gsettings-schemas/${pkgs.gtk3.name}:$XDG_DATA_DIRS"
    export LIBRARY_PATH="${pkgs.notmuch}/lib:$LIBRARY_PATH"
  '';
}
