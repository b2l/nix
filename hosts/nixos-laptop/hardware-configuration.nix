{ ... }:

# PLACEHOLDER — overwrite this file during install with the output of:
#   sudo nixos-generate-config --root /mnt --no-filesystems
#
# Filesystems are declared in ./disk.nix via disko, so --no-filesystems is correct.

{
  boot.initrd.availableKernelModules = [
    "xhci_pci"
    "thunderbolt"
    "nvme"
    "usb_storage"
    "sd_mod"
  ];
  boot.kernelModules = [ "kvm-intel" ];

  nixpkgs.hostPlatform = "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = true;
}
