{ pkgs, ... }:

{
  # Flakes + new CLI
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    auto-optimise-store = true;
    trusted-users = [ "root" "nicolas" ];
  };

  nixpkgs.config.allowUnfree = true;

  # Locale / time / console
  time.timeZone = "Europe/Paris";
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_TIME = "fr_FR.UTF-8";
    LC_MONETARY = "fr_FR.UTF-8";
    LC_NUMERIC = "fr_FR.UTF-8";
    LC_MEASUREMENT = "fr_FR.UTF-8";
  };
  console.keyMap = "dvorak";

  # Primary user
  users.users.nicolas = {
    isNormalUser = true;
    description = "Nicolas";
    extraGroups = [ "wheel" "networkmanager" "docker" "libvirtd" "video" "audio" "input" ];
    shell = pkgs.bashInteractive;
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEi9c3chna9YVlX6kMWy0ilgUsfL9X8H0iZ2/Clo2mkq"
    ];
  };

  # Networking
  networking.networkmanager.enable = true;
  networking.firewall.enable = true;

  networking.firewall.trustedInterfaces = [ "docker0" "br-+" ];

  # Hyprland + SDDM (Wayland)
  programs.hyprland.enable = true;
  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
  };
  services.displayManager.defaultSession = "hyprland";

  # XDG portals (screen-share, file pickers)
  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-hyprland pkgs.xdg-desktop-portal-gtk ];
  };

  # Graphics — base stack; host-specific drivers go in hosts/<name>/configuration.nix
  hardware.graphics.enable = true;

  # Audio — PipeWire
  security.rtkit.enable = true;
  services.pulseaudio.enable = false;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
  };

  # Bluetooth
  hardware.bluetooth.enable = true;
  services.blueman.enable = true;

  # Docker
  virtualisation.docker.enable = true;

  # Libvirt / QEMU (virt-manager)
  virtualisation.libvirtd.enable = true;
  programs.virt-manager.enable = true;

  # Printing
  services.printing.enable = true;

  # Power profiles (performance / balanced / power-saver)
  services.power-profiles-daemon.enable = true;

  # Firmware updates
  services.fwupd.enable = true;

  # OpenSSH — convenient for VM, safe on laptop (key-auth only)
  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = false;
  };

  # Polkit — GUI auth prompts (paired with hyprpolkitagent from home-manager)
  security.polkit.enable = true;

  # GNOME Keyring — provides org.freedesktop.secrets for rbw pinentry, etc.
  services.gnome.gnome-keyring.enable = true;

  # nix-ld: run dynamically-linked binaries (LSPs, prebuilt Node native deps, …)
  programs.nix-ld.enable = true;

  # AppImage support — `./foo.AppImage` runs directly, plus `appimage-run`.
  programs.appimage = {
    enable = true;
    binfmt = true;
  };

  # uinput access for warpd (keyboard-driven virtual pointer).
  # warpd uses Wayland protocol for key input but needs /dev/uinput to
  # inject mouse events.
  boot.kernelModules = [ "uinput" ];
  services.udev.extraRules = ''
    KERNEL=="uinput", GROUP="input", MODE:="0660", OPTIONS+="static_node=uinput"
    KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{serial}=="*vial:f64c2b3c*", MODE="0660", GROUP="users", TAG+="uaccess", TAG+="udev-acl"
  '';

  # Fonts
  fonts.packages = with pkgs; [
    nerd-fonts.fira-code
    nerd-fonts.symbols-only
    noto-fonts
    noto-fonts-color-emoji
  ];

  # System packages — keep minimal; apps belong in home-manager
  environment.systemPackages = with pkgs; [
    git
    neovim
    curl
    wget
    pciutils
    usbutils
  ];

  # Pinentry over Wayland for rbw/gnupg
  programs.gnupg.agent = {
    enable = true;
    pinentryPackage = pkgs.pinentry-gnome3;
  };

  # GUI file browser (optional, removable)
  programs.thunar.enable = true;

  # Automatic garbage collection
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };

  # Automatic system upgrade — tracks the pinned nixos-25.11 branch in flake.nix.
  # Picks up point-release fixes without manual intervention. Does NOT cross
  # major versions (25.11 → 26.05) — that bump is manual in flake.nix.
  system.autoUpgrade = {
    enable = true;
    flake = "/home/nicolas/Perso/nix";
    flags = [ "-L" ];
    dates = "04:00";
    persistent = true;              # run on wake if the slot was missed
    randomizedDelaySec = "45min";
    allowReboot = false;            # never auto-reboot; new kernel lands on next boot
    operation = "switch";
  };

  # The upgrade service runs as root but the flake lives in ~nicolas.
  # 1) git safe.directory so root can read the repo
  # 2) Pre-start: update flake inputs before building (replaces deprecated --update-input)
  systemd.services.nixos-upgrade = {
    environment.GIT_DISCOVERY_ACROSS_FILESYSTEM = "1";
    serviceConfig.ExecStartPre = let
      flakePath = "/home/nicolas/Perso/nix";
      inputs = [ "nixpkgs" "home-manager" "catppuccin" "sops-nix" "nixgl" "nixpkgs-unstable" "nixos-hardware" ];
    in "+nix flake update ${builtins.concatStringsSep " " inputs} --flake ${flakePath}";
  };
  environment.etc."gitconfig".text = ''
    [safe]
      directory = /home/nicolas/Perso/nix
  '';
}
