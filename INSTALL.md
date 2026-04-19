# NixOS install (laptop)

End-to-end install procedure for `hosts/nixos-laptop`. Disk gets wiped — backup first.

## Prerequisites

- NixOS minimal ISO on USB.
- `~/.config/sops/age/keys.txt` from current machine, on a USB stick (or another reachable host via scp). **Without this, sops secrets are gone.**
- Backup of:
  - `~/Projects/` (work code, in-progress branches)
  - `~/Documents/`, `~/Downloads/`, etc.
  - `~/.ssh/` (private keys)
  - `~/.gnupg/` (if used)
  - Browser profiles (`~/.mozilla`, `~/.config/google-chrome`)
  - Slack/Signal config (`~/.config/Slack`, `~/.config/Signal`) — losing means re-login/re-pair
  - Anything in `/etc` you customized that's not in the flake

## Procedure

### 1. Boot, network

Boot ISO. NetworkManager usually auto-DHCPs. Test:
```bash
ping -c2 1.1.1.1
```
If down: `sudo systemctl start NetworkManager && nmtui`.

### 2. Set keymap to dvorak

So the LUKS passphrase you type during disko matches what you'll type at every boot.
```bash
sudo loadkeys dvorak
```

### 3. Run disko (WIPES /dev/nvme0n1)

```bash
sudo nix-shell -p git
git clone https://github.com/<you>/nix /tmp/nix

# Triple-check the device first
lsblk

sudo nix --extra-experimental-features 'nix-command flakes' \
  run github:nix-community/disko -- \
  --mode disko \
  --flake /tmp/nix#nixos-laptop
```

You'll be prompted for a LUKS passphrase. Pick something memorable; you'll type it on every boot.

### 4. Move repo into the new install

```bash
sudo mkdir -p /mnt/home/nicolas/Perso
sudo cp -r /tmp/nix /mnt/home/nicolas/Perso/nix
```

### 5. Generate hardware config

```bash
sudo nixos-generate-config --root /mnt --no-filesystems
sudo cp /mnt/etc/nixos/hardware-configuration.nix \
        /mnt/home/nicolas/Perso/nix/hosts/nixos-laptop/

# Stage so the flake sees it
sudo git -C /mnt/home/nicolas/Perso/nix add hosts/nixos-laptop/hardware-configuration.nix
```

### 6. Restore age key

USB stick mounted at `/run/media/nixos/USB`:
```bash
sudo mkdir -p /mnt/home/nicolas/.config/sops/age
sudo cp /run/media/nixos/USB/keys.txt /mnt/home/nicolas/.config/sops/age/
```

### 7. Install

```bash
sudo nixos-install --flake /mnt/home/nicolas/Perso/nix#nixos-laptop
```

When prompted for the **root password**: keymap is still dvorak from step 2. Type accordingly.

### 8. Reboot

```bash
sudo reboot
```
Remove the USB before BIOS hands off.

## First boot post-install

1. LUKS passphrase prompt — dvorak (set by your config's `console.keyMap`).
2. SDDM login as `root` (you have no user password yet).
3. Set user password:
   ```bash
   passwd nicolas
   ```
4. Log out, log in as `nicolas` via SDDM.
5. Verify:
   - Wi-Fi works (`nmcli` or NetworkManager applet)
   - Audio (`pavucontrol`)
   - Hyprland session loads with your config
   - `home-manager` activated (your bash prompt, neovim plugins, etc.)
6. Restore data from backup.
7. Generate per-machine SSH key, add to GitHub:
   ```bash
   ssh-keygen -t ed25519 -C "nicolas@nixos-laptop"
   gh ssh-key add ~/.ssh/id_ed25519.pub
   ```

## Recovery

### Lost password

At the systemd-boot menu, edit kernel cmdline and append:
```
systemd.unit=emergency.target systemd.setenv=SYSTEMD_SULOGIN_FORCE=1
```
Boot, `passwd <user>`, reboot.

### Broken config (won't boot)

systemd-boot menu → previous generation → boot.

### Lost LUKS passphrase

No recovery. Restore from backup. Consider `sudo cryptsetup luksHeaderBackup` post-install and store the header somewhere safe.

### Repo gone, want to reinstall

Same procedure. Disko produces identical layout. Hardware-config will be regenerated.
