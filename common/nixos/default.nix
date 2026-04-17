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

  # Firmware updates
  services.fwupd.enable = true;

  # OpenSSH — convenient for VM, safe on laptop (key-auth only)
  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = false;
  };

  # Polkit — GUI auth prompts (paired with hyprpolkitagent from home-manager)
  security.polkit.enable = true;

  # nix-ld: run dynamically-linked binaries (LSPs, prebuilt Node native deps, …)
  programs.nix-ld.enable = true;

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
}
