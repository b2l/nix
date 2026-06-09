{ lib, stdenv, fetchurl
, autoPatchelfHook, dpkg, wrapGAppsHook3
, webkitgtk_4_1, gtk3, libappindicator-gtk3
, glib-networking, openssl, librsvg, alsa-lib
}:

# Mindwtr is a Tauri-based GTD app. We repackage upstream's .deb against
# nixpkgs's WebKit/GTK rather than wrapping the AppImage. Reason: the AppImage
# bundles its own libwebkit2gtk-4.1.so, which lacks the Hyprland/wlroots
# rendering fixes shipped in nixpkgs — the AppImage opens with EGL_BAD_PARAMETER
# on pure-Wayland Hyprland, and even with WEBKIT_DISABLE_DMABUF_RENDERER=1
# renders glitchy on this setup.
#
# Trade-off vs. AppImage wrap:
#   + WebKit/GTK get patched in lockstep with nixpkgs (security + bug fixes)
#   + ~15 MB in the store instead of ~91 MB
#   - More moving parts: if upstream adds a new dynamic dep, autoPatchelfHook
#     will fail loudly at build time and you'll need to add it to buildInputs
#
# Upgrading
# ---------
# 1. Find the latest tag:
#      gh release view --repo dongdongbh/Mindwtr --json tagName -q .tagName
# 2. Update `version` below.
# 3. Get the new hash from the release's SHA256SUMS:
#      curl -sL https://github.com/dongdongbh/Mindwtr/releases/download/vX.Y.Z/SHA256SUMS \
#        | awk '/_amd64\.deb/ {print $1}' \
#        | xargs nix hash convert --hash-algo sha256 --to sri
# 4. `nhs` to activate, then smoke-test: launch Mindwtr, confirm window renders.
#
# Note: `nix flake update` does NOT bump this — fetchurl pins are literals,
# outside the lock file.
stdenv.mkDerivation rec {
  pname = "mindwtr";
  version = "0.9.8";

  src = fetchurl {
    url = "https://github.com/dongdongbh/Mindwtr/releases/download/v${version}/mindwtr_${version}_amd64.deb";
    hash = "sha256-xGi88inb18Vt2zgYu5ako21ZSUeK6CuGqxuIvh/cUhI=";
  };

  nativeBuildInputs = [ autoPatchelfHook dpkg wrapGAppsHook3 ];

  # Upstream .deb declares: libappindicator3-1, libwebkit2gtk-4.1-0, libgtk-3-0.
  # glib-networking is required at runtime for WebKit's HTTPS stack (TLS over
  # libsoup); librsvg for SVG icon rendering; openssl for Tauri's HTTP client;
  # alsa-lib because WebKit pulls libasound for <audio>.
  buildInputs = [
    webkitgtk_4_1
    gtk3
    glib-networking
    openssl
    librsvg
    alsa-lib
  ];

  # The binary doesn't directly link libappindicator — Tauri dlopen's it when
  # creating the tray icon. Forcing it into RPATH ensures the dlopen resolves.
  runtimeDependencies = [ libappindicator-gtk3 ];

  unpackPhase = ''
    runHook preUnpack
    dpkg-deb -x $src .
    runHook postUnpack
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p $out
    cp -r usr/bin $out/
    cp -r usr/share $out/
    runHook postInstall
  '';

  meta = {
    description = "Complete Getting Things Done (GTD) productivity system — local-first, no account required";
    homepage = "https://github.com/dongdongbh/Mindwtr";
    license = lib.licenses.agpl3Only;
    mainProgram = pname;
    platforms = [ "x86_64-linux" ];
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
  };
}
