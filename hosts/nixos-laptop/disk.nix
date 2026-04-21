{
  disko.devices = {
    disk.main = {
      type = "disk";
      device = "/dev/nvme0n1";
      content = {
        type = "gpt";
        partitions = {
          ESP = {
            size = "1G";
            type = "EF00";
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
              mountOptions = [ "umask=0077" ];
            };
          };
          # Encrypted swap partition for hibernation. Sized well above typical
          # working set (~50–60 GB) with headroom for spikes; smaller than RAM
          # because the hibernation image is compressed and only contains
          # actually-used pages. zramSwap in configuration.nix handles everyday
          # in-memory compression; this partition is the hibernation target.
          #
          # Current setup prompts for the LUKS passphrase TWICE at boot (once
          # for swap, once for root). Follow-up: derive the swap key from a
          # keyfile inside root LUKS to eliminate the double prompt.
          swap = {
            size = "64G";
            content = {
              type = "luks";
              name = "crypted-swap";
              extraOpenArgs = [ "--allow-discards" ];
              content = {
                type = "swap";
                resumeDevice = true;
              };
            };
          };
          luks = {
            size = "100%";
            content = {
              type = "luks";
              name = "crypted";
              extraOpenArgs = [ "--allow-discards" ];
              # passwordFile = "/tmp/disk.key";  # set during install if you want non-interactive
              content = {
                type = "btrfs";
                extraArgs = [ "-L" "nixos" "-f" ];
                subvolumes = {
                  "@" = {
                    mountpoint = "/";
                    mountOptions = [ "compress=zstd" "noatime" ];
                  };
                  "@home" = {
                    mountpoint = "/home";
                    mountOptions = [ "compress=zstd" "noatime" ];
                  };
                  "@nix" = {
                    mountpoint = "/nix";
                    mountOptions = [ "compress=zstd" "noatime" ];
                  };
                  "@log" = {
                    mountpoint = "/var/log";
                    mountOptions = [ "compress=zstd" "noatime" ];
                  };
                };
              };
            };
          };
        };
      };
    };
  };
}
