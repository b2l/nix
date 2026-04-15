# System-as-Code: Universal Environment

This repository manages a declarative, high-performance development environment using **Nix** and **Home Manager**. It replaces the traditional "dotenv" approach with a reproducible, version-controlled system.

## Core Principles

1.  **Declarative Truth:** The configuration in this repository *is* the state of the system. If it isn't in the code, it doesn't exist.
2.  **Atomic Rollbacks:** Every change creates a new "generation." If a change breaks the workflow, rolling back takes seconds.
3.  **Encrypted Secrets:** All sensitive environment variables and API keys are stored encrypted via `sops-nix`.

---

## The Stack

| Component | Tool | Description |
| :--- | :--- | :--- |
| **Package Manager** | **Nix (Flakes)** | Handles software installation with bit-for-bit reproducibility. |
| **Config Manager** | **Home Manager** | Manages `~/.config` files as read-only symlinks from the Nix store. |
| **Secret Manager** | **sops-nix** | Uses `age` to encrypt secrets in Git, decrypted via local age key. |
| **Theme** | **Catppuccin Mocha** | Consistent theming across all tools via `catppuccin/nix`. |

---

## Repository Structure

```text
.
├── flake.nix            # Entry point: defines inputs and system outputs
├── flake.lock           # Dependency lockfile (Do not edit manually)
├── .sops.yaml           # sops-nix encryption rules
├── common/              # Shared configuration modules
│   ├── default.nix      # Core package list and imports
│   ├── bash.nix         # Bash shell, aliases, functions, starship, fzf, direnv
│   ├── fish.nix         # Fish shell (kept available; not launched by default)
│   ├── tmux.nix         # Tmux configuration
│   ├── foot.nix         # Foot terminal
│   ├── hyprland.nix     # Hyprland, waybar, dunst, tofi, hypridle, hyprpaper
│   ├── neovim.nix       # Neovim (package + mutable symlink)
│   ├── secrets.nix      # sops-nix secret declarations
│   └── theme/           # Extracted theme files (CSS, conf)
├── nvim/                # Neovim config (NvChad + lazy.nvim, mutable via mkOutOfStoreSymlink)
├── devshells/           # Per-project development environments
│   └── tauri.nix        # Tauri app dependencies
├── hosts/               # Machine-specific overrides
│   └── fedora/
│       └── home.nix     # Fedora 42 specifics
└── secrets/             # Encrypted YAML files (sops-nix)
    └── lcdp.yaml        # Work environment variables
```

---

## Getting Started (Fedora 42)

### 1. Install the Nix Package Manager
Use the Determinate Systems installer for the most robust setup:
```bash
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
```

### 2. Prepare Secrets (Age Key)
Generate a standalone age key for `sops-nix`. Store the key in your password manager — it's the only thing that can't be recovered from this repo.
```bash
mkdir -p ~/.config/sops/age
nix shell nixpkgs#age -c age-keygen -o ~/.config/sops/age/keys.txt
```
Note the public key it prints (`age1...`) — you'll need it if you update `.sops.yaml`.

### 3. Initialize the Environment
Clone this repo and apply the configuration for the first time:
```bash
nix run home-manager/master -- switch --flake .#work-pc -b backup
```

### 4. Set Bash as Default Shell
Home Manager can't manage the login shell on non-NixOS systems — this is a one-time manual step:
```bash
echo "$HOME/.nix-profile/bin/bash" | sudo tee -a /etc/shells
sudo chsh -s "$HOME/.nix-profile/bin/bash" $USER
```

---

## Daily Usage

Apply configuration changes:
```bash
nhs
```

Edit encrypted secrets:
```bash
nix shell nixpkgs#sops -c sops secrets/lcdp.yaml
```

Rollback to a previous generation:
```bash
home-manager generations
home-manager switch --generation N
```

Garbage collect old generations:
```bash
home-manager expire-generations "-7 days"
nix-collect-garbage
```

---

## Per-Project Dev Environments

Projects use `devShells` defined in this repo + `direnv` for automatic activation:

```bash
# In project directory
echo "use flake ~/Perso/nix#tauri" > .envrc
direnv allow
```

Available devShells: `tauri`

---

## Important Notes

* **Read-Only Files:** Files managed by Home Manager are symlinked to the Nix store. They are **read-only**. To change them, edit the `.nix` source and run `nhs`.
* **Neovim Exception:** The Neovim directory is linked via `mkOutOfStoreSymlink` to maintain write access for `lazy.nvim`.
* **Secrets Bootstrap:** The age key at `~/.config/sops/age/keys.txt` is the one manual prerequisite — everything else is derived from this repo.
