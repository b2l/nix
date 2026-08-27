{ lib, stdenv, fetchurl
, dpkg, asar, autoPatchelfHook, makeWrapper, wrapGAppsHook3, perl
, alsa-lib, at-spi2-core, cairo, cups, dbus, expat, fontconfig, freetype
, gdk-pixbuf, glib, gtk3, libayatana-appindicator, libcap_ng, libdrm, libgbm
, libGL, libnotify, libpulseaudio, libsecret, libseccomp, libuuid, libva
, libxkbcommon, libx11, libxscrnsaver, libxcomposite, libxcursor, libxdamage
, libxext, libxfixes, libxi, libxrandr, libxrender, libxtst, libxcb
, mesa, nspr, nss, OVMF, pango, qemu, systemd, trash-cli, vulkan-loader
, wayland, xdg-utils
}:

# Anthropic's official Claude Desktop Linux beta, repackaged from the .deb
# they publish on their own apt repo (downloads.claude.ai). The binary comes
# straight from Anthropic with a pinned hash — the only third-party code here
# is this Nix expression.
#
# Vendored (x86_64-only, trimmed) from poeck/claude-desktop-nix-flake
# @ 6a5669b, audited 2026-08-27. Vendored rather than used as a flake input
# because the maintainer is unknown to the Nix community, and his "hourly
# auto-update" CI had already been dead for two months at audit time.
#
# The perl block patches the app's JS bundle (app.asar): Claude's Cowork
# feature probes FHS paths (/usr/share/OVMF, /usr/bin/virtiofsd) for its VM
# runtime; we point them at Nix store paths instead. The substitutions `die`
# if upstream's minified code changes shape, so a version bump can fail
# loudly here — grep the extracted asar for AAVMF_CODE to find the new shape
# (already moved once from index.js to a hashed chunk, and from "" to ``
# string literals, between 1.18286 and 1.37937).
# Cowork drags qemu into the closure (~1 GB); virt-manager already pulls it
# on this setup, so the marginal cost is nil.
#
# Upgrading
# ---------
# 1. Latest version + hash from Anthropic's apt index:
#      curl -s https://downloads.claude.ai/claude-desktop/apt/stable/dists/stable/main/binary-amd64/Packages \
#        | grep -E "^(Version|SHA256):" | paste - - | sort -V -k2 | tail -1
# 2. Update `version` below; convert the hash:
#      nix hash convert --hash-algo sha256 --to sri <hex>
# 3. `nhs` to activate, then smoke-test: launch Claude Desktop, sign in.
#
# Note: `nix flake update` does NOT bump this — fetchurl pins are literals,
# outside the lock file.

let
  runtimeLibs = [
    alsa-lib at-spi2-core cairo cups dbus expat fontconfig freetype
    gdk-pixbuf glib gtk3 libayatana-appindicator libcap_ng libdrm libgbm
    libGL libnotify libpulseaudio libsecret libseccomp libuuid libva
    libxkbcommon mesa nspr nss pango stdenv.cc.cc.lib systemd vulkan-loader
    wayland libx11 libxscrnsaver libxcomposite libxcursor libxdamage libxext
    libxfixes libxi libxrandr libxrender libxtst libxcb
  ];

  runtimeBins = [ glib qemu trash-cli xdg-utils ];
in
stdenv.mkDerivation (finalAttrs: {
  pname = "claude-desktop";
  version = "1.37937.3";

  src = fetchurl {
    url = "https://downloads.claude.ai/claude-desktop/apt/stable/pool/main/c/claude-desktop/claude-desktop_${finalAttrs.version}_amd64.deb";
    hash = "sha256-U1kMVyX7NIcpn5QPW4nVUYKw+u4Uyhvz41utrg9hE18=";
  };

  nativeBuildInputs = [ dpkg asar autoPatchelfHook makeWrapper perl wrapGAppsHook3 ];

  buildInputs = runtimeLibs;

  dontConfigure = true;
  dontBuild = true;
  dontStrip = true;
  dontWrapGApps = true;

  unpackPhase = ''
    runHook preUnpack
    dpkg-deb --fsys-tarfile "$src" | tar --extract --file - --no-same-permissions
    runHook postUnpack
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p "$out/lib" "$out/share"
    cp -a usr/lib/claude-desktop "$out/lib/"
    cp -a usr/share/applications usr/share/icons usr/share/doc "$out/share/"

    substituteInPlace "$out/share/applications/com.anthropic.Claude.desktop" \
      --replace-fail "Exec=claude-desktop" "Exec=$out/bin/claude-desktop"

    asarRoot="$(mktemp -d)"
    asar extract "$out/lib/claude-desktop/resources/app.asar" "$asarRoot"

    # The Cowork VM code lives in a content-hashed chunk — locate it by marker.
    coworkFile=$(grep -rl "AAVMF_CODE" "$asarRoot/.vite/build" | head -1)
    [ -n "$coworkFile" ] || { echo "cowork chunk not found in app.asar" >&2; exit 1; }

    FIRMWARE_CODE_PATH="${OVMF.fd}/FV/OVMF_CODE.fd" \
    VIRTIOFSD_PATH="$out/lib/claude-desktop/resources/virtiofsd" \
    perl -0pi -e '
      s{([A-Za-z0-9_\$]+)=process\.arch===[`"]arm64[`"]\?\[[`"]/usr/share/AAVMF/AAVMF_CODE\.fd[`"]\]:\[[`"]/usr/share/OVMF/OVMF_CODE_4M\.fd[`"],[`"]/usr/share/OVMF/OVMF_CODE\.fd[`"]\]}{$1=["$ENV{FIRMWARE_CODE_PATH}"]} or die "failed to patch firmware path\n";
      s{([A-Za-z0-9_\$]+)=\[[`"]/usr/libexec/virtiofsd[`"],[`"]/usr/bin/virtiofsd[`"]\]}{$1=["$ENV{VIRTIOFSD_PATH}"]} or die "failed to patch virtiofsd path\n";
    ' "$coworkFile"

    # The asar ships precompiled V8 bytecode per chunk (compile-cache/*.jsc).
    # Drop the entry for the chunk we just patched so the app can never load
    # the stale pre-patch bytecode instead of our modified source.
    rm -f "$asarRoot/compile-cache/$(basename "$coworkFile")".*.jsc

    rm "$out/lib/claude-desktop/resources/app.asar"
    asar pack --unpack "*.node" "$asarRoot" "$out/lib/claude-desktop/resources/app.asar"

    runHook postInstall
  '';

  preFixup = ''
    gappsWrapperArgs+=(
      --prefix PATH : ${lib.makeBinPath runtimeBins}
      --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath runtimeLibs}
      --set-default ELECTRON_OZONE_PLATFORM_HINT auto
    )
  '';

  postFixup = ''
    makeWrapper "$out/lib/claude-desktop/claude-desktop" "$out/bin/claude-desktop" \
      "''${gappsWrapperArgs[@]}"
  '';

  meta = {
    description = "Official Claude Desktop Linux beta";
    homepage = "https://claude.ai";
    changelog = "https://code.claude.com/docs/en/desktop-linux";
    license = lib.licenses.unfree;
    mainProgram = "claude-desktop";
    platforms = [ "x86_64-linux" ];
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
})
