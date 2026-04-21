{ inputs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./disk.nix
    ../../common/nixos
    inputs.disko.nixosModules.disko
    inputs.nixos-hardware.nixosModules.common-cpu-intel-raptor-lake
    inputs.nixos-hardware.nixosModules.common-gpu-intel-raptor-lake
    inputs.nixos-hardware.nixosModules.common-pc-laptop
    inputs.nixos-hardware.nixosModules.common-pc-laptop-ssd
  ];

  networking.hostName = "nixos-laptop";

  # UEFI + systemd-boot
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # zram swap — in-RAM compressed swap for everyday memory pressure.
  # The disk swap partition (disk.nix, `resumeDevice = true`) is the
  # hibernation target and auto-wires `boot.resumeDevice` via disko.
  zramSwap.enable = true;

  # Two displays — laptop internal + external dock
  # Update names to match `hyprctl monitors` output after first boot
  # wayland.windowManager.hyprland.settings.monitor in common/hyprland.nix
  # only has the wildcard fallback; add specific lines here if desired.

  # Pinned at first install
  system.stateVersion = "25.05";
}
