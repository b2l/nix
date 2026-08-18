{ pkgs, pkgs-unstable, pkgs-tf129, lib, ... }:

# Global dev toolchain — replaces the old flake devShells.
# Repos no longer eval nix on cd; the .envrc files that remain only activate
# a project venv or source one of the env files generated at the bottom.

let
  # Pinned pnpm — the version every LCDP repo expects.
  pnpm_11_5 = pkgs-unstable.pnpm_11.overrideAttrs (old: rec {
    version = "11.5.2";
    src = pkgs.fetchurl {
      url = "https://registry.npmjs.org/pnpm/-/pnpm-${version}.tgz";
      hash = "sha256-dJ3FT709zenkFLquMsF3yoR3DT/NaciBbVea3D5qLJk=";
    };
  });

  # lcdp-versioning is still pinned on pnpm 10. Both versions ship bin/pnpm,
  # so this one lives outside the profile; its .envrc does
  #   PATH_add "$HOME/.local/share/pnpm10/bin"
  pnpm_10_24 = pkgs.pnpm_10.overrideAttrs (old: rec {
    version = "10.24.0";
    src = pkgs.fetchurl {
      url = "https://registry.npmjs.org/pnpm/-/pnpm-${version}.tgz";
      hash = "sha256-GW9L0XTry9mXhrM0UvFEyy3DLvTnE47URJHp1D1wLXU=";
    };
  });

  # Runtime libs for prebuilt Electron binaries (front, lcdp-e2e-test),
  # exposed through nix-ld via dev-env/electron.sh.
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

  # Tauri (mora) build deps. PKG_CONFIG_PATH must cover the *transitive*
  # closure of these — gtk3.pc Requires pango.pc which Requires harfbuzz.pc,
  # etc. — which mkShell used to resolve via stdenv propagation. Reproduce it
  # by walking propagatedBuildInputs.
  tauriLibs = with pkgs; [
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
  ];
  toClosureItem = p: { key = p.outPath; drv = p; };
  tauriClosure = map (x: x.drv) (builtins.genericClosure {
    startSet = map toClosureItem tauriLibs;
    operator = item: map toClosureItem
      (builtins.filter (p: p != null && builtins.isAttrs p && p ? outPath)
        (lib.flatten ((item.drv.propagatedBuildInputs or [ ])
          ++ (item.drv.propagatedNativeBuildInputs or [ ]))));
  });
  tauriPkgConfigPath = lib.concatStringsSep ":" [
    (lib.makeSearchPathOutput "dev" "lib/pkgconfig" tauriClosure)
    (lib.makeSearchPathOutput "dev" "share/pkgconfig" tauriClosure)
  ];
  # Runtime lib dirs for the linker (.pc files reference libs like -lz without
  # a -L; mkShell's cc-wrapper used to inject these via NIX_LDFLAGS). The
  # closure items are mostly .dev outputs (propagatedBuildInputs), and
  # makeLibraryPath keeps an explicitly-specified output as-is, so force the
  # runtime output by hand: lib if it exists, else out.
  tauriLibraryPath = lib.makeSearchPath "lib"
    (map (p: p.lib or p.out or p) tauriClosure);
in
{
  home.packages = with pkgs; [
    # JS / TS (nodejs_24 and bun are in default.nix)
    pnpm_11_5
    vtsls
    deno

    # Java / Scala — JAVA_HOME via programs.java below
    maven
    sbt
    jdt-language-server

    # Python (python3 is in default.nix)
    uv
    # Build poetry against 3.12 so the venvs it creates use 3.12, not the
    # 3.13 that pkgs.poetry is built against by default.
    (poetry.override { python3 = python312; })

    # Infra (awscli2 is in default.nix)
    opentofu
    pkgs-tf129.terraform # terraform 1.2.9, pinned nixpkgs input
    terraform-docs

    # Rust / native builds (mora)
    cargo
    rustc
    rustfmt
    clippy
    gcc
    gnumake
    pkg-config
    notmuch

    # Scripting / DB (ex lcdp-script shell)
    kotlin
    postgresql_16
  ];

  # Installs jdk21 and sets JAVA_HOME.
  programs.java = {
    enable = true;
    package = pkgs.jdk21;
  };

  # Poetry creates .venv/ in the project root instead of
  # ~/.cache/pypoetry/virtualenvs/, so per-repo .envrc venv activation works.
  home.sessionVariables.POETRY_VIRTUALENVS_IN_PROJECT = "true";

  home.file.".local/share/pnpm10/bin/pnpm".source = "${pnpm_10_24}/bin/pnpm";

  # Sourced by per-repo .envrc — plain env exports, no nix eval on cd.
  # Store paths stay GC-rooted through the home-manager profile.
  xdg.configFile."dev-env/electron.sh".text = ''
    export NIX_LD_LIBRARY_PATH="${electronLibs}''${NIX_LD_LIBRARY_PATH:+:$NIX_LD_LIBRARY_PATH}"
  '';

  xdg.configFile."dev-env/tauri.sh".text = ''
    export WEBKIT_DISABLE_DMABUF_RENDERER=1
    export GIO_EXTRA_MODULES="${pkgs.glib-networking}/lib/gio/modules"
    export XDG_DATA_DIRS="${pkgs.gsettings-desktop-schemas}/share/gsettings-schemas/${pkgs.gsettings-desktop-schemas.name}:${pkgs.gtk3}/share/gsettings-schemas/${pkgs.gtk3.name}:$XDG_DATA_DIRS"
    export LIBRARY_PATH="${pkgs.notmuch}/lib:${tauriLibraryPath}''${LIBRARY_PATH:+:$LIBRARY_PATH}"
    export PKG_CONFIG_PATH="${tauriPkgConfigPath}''${PKG_CONFIG_PATH:+:$PKG_CONFIG_PATH}"
  '';
}
