{ inputs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./disk.nix
    ../../common/nixos
    inputs.disko.nixosModules.disko
  ];

  networking.hostName = "nixos-vm";

  # Bootloader — UEFI via systemd-boot. Flip to grub if your VM is legacy BIOS.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # spice-vdagent: clipboard + resolution sync with the QEMU host
  services.spice-vdagentd.enable = true;
  services.qemuGuest.enable = true;

  # Pinned at first install — do NOT bump blindly, changes stateful defaults
  system.stateVersion = "25.05";
}
