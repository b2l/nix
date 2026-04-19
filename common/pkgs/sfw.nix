{ lib, stdenv, fetchurl }:

# Socket Firewall Free ships as a Node.js Single-Executable-App (V8 embedded +
# postject'd resource blob). patchelf rewriting sections breaks its integrity
# fuse and causes an immediate segfault. We therefore install the raw binary
# unmodified and rely on:
#   - Fedora / FHS distros: /lib64/ld-linux-x86-64.so.2 exists natively
#   - NixOS: programs.nix-ld.enable provides the loader shim
#
# Upgrading
# ---------
# The malware DB lives server-side, so bumping is only needed for binary
# fixes/features — no weekly treadmill. Check roughly quarterly, or when you
# want something from the changelog.
#
# 1. Find the latest tag:
#      gh release view --repo SocketDev/sfw-free --json tagName -q .tagName
# 2. Update `version` below.
# 3. Get the new hash — easiest path: set `hash = lib.fakeHash;`, run `nhs`,
#    copy the `got:` value from the error. Or prefetch:
#      nix-prefetch-url "https://github.com/SocketDev/sfw-free/releases/download/vX.Y.Z/sfw-free-linux-x86_64" \
#        | xargs nix hash convert --hash-algo sha256 --to sri
# 4. `nhs` to activate, then smoke-test: `sfw --help`.
#
# Note: `nix flake update` does NOT bump this — fetchurl pins are literals,
# outside the lock file.
stdenv.mkDerivation rec {
  pname = "sfw";
  version = "1.6.1";

  src = fetchurl {
    url = "https://github.com/SocketDev/sfw-free/releases/download/v${version}/sfw-free-linux-x86_64";
    hash = "sha256-Sh6LZekPzn1f0GbPCvbJPVEgZfpCIqR1yNlZprwUuf8=";
  };

  dontUnpack = true;
  dontFixup = true;

  installPhase = ''
    runHook preInstall
    install -Dm755 $src $out/bin/sfw
    runHook postInstall
  '';

  meta = {
    description = "Socket Firewall Free: ephemeral proxy that blocks malicious packages during install";
    homepage = "https://github.com/SocketDev/sfw-free";
    license = {
      fullName = "PolyForm Shield License 1.0.0";
      url = "https://polyformproject.org/licenses/shield/1.0.0/";
      free = false;
      redistributable = true;
    };
    mainProgram = "sfw";
    platforms = [ "x86_64-linux" ];
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
  };
}
