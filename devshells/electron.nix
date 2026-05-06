{ pkgs }:

let
  electronLibs = pkgs.lib.makeLibraryPath (with pkgs; [
    alsa-lib
    at-spi2-atk
    atk
    cairo
    cups
    dbus
    expat
    fontconfig
    freetype
    gdk-pixbuf
    glib
    gtk3
    libgbm
    libdrm
    libGL
    libxkbcommon
    mesa
    systemd
    nss
    nspr
    pango
    stdenv.cc.cc.lib
    xorg.libX11
    xorg.libXcomposite
    xorg.libXcursor
    xorg.libXdamage
    xorg.libXext
    xorg.libXfixes
    xorg.libXi
    xorg.libXrandr
    xorg.libXrender
    xorg.libXScrnSaver
    xorg.libXtst
    xorg.libxcb
  ]);
in
pkgs.mkShell {
  name = "electron-shell";

  shellHook = ''
    export NIX_LD_LIBRARY_PATH="${electronLibs}''${NIX_LD_LIBRARY_PATH:+:$NIX_LD_LIBRARY_PATH}"
  '';
}
