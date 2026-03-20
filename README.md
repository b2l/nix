This is the clean, high-level `README.md` for your new "System as Code" repository. It’s designed to be your primary reference for **Fedora 42** and sets the foundation for your future transition.

---

# 🛰️ System-as-Code: Universal Environment

This repository manages a declarative, high-performance development environment using **Nix** and **Home Manager**. It replaces the traditional "dotenv" approach with a reproducible, version-controlled system.

## 🎯 Core Principles

1.  **Declarative Truth:** The configuration in this repository *is* the state of the system. If it isn't in the code, it doesn't exist.
2.  **Atomic Rollbacks:** Every change creates a new "generation." If a change breaks the workflow, rolling back takes seconds.
3.  **Encrypted Secrets:** All sensitive environment variables and API keys are stored encrypted via `sops-nix`.

---

## 🛠️ The Stack

| Component | Tool | Description |
| :--- | :--- | :--- |
| **Package Manager** | **Nix (Flakes)** | Handles software installation with bit-for-bit reproducibility. |
| **Config Manager** | **Home Manager** | Manages `~/.config` files as read-only symlinks from the Nix store. |
| **Secret Manager** | **sops-nix** | Uses `age` to encrypt secrets in Git, decrypted via local SSH keys. |
| **Workflow** | **"Workflow B"** | A background watcher (`entr`) that auto-rebuilds on file save. |

---

## 📂 Repository Structure

```text
.
├── flake.nix            # Entry point: defines inputs and system outputs
├── flake.lock           # Dependency lockfile (Do not edit manually)
├── common/              # Shared logic (Neovim, Tmux, Git, Shell)
│   ├── default.nix      # Core package list
│   └── nvim.nix         # Neovim specific configuration
├── hosts/               # Machine-specific overrides
│   └── fedora/
│       └── home.nix     # Fedora 42 specifics (Monitors, Work apps)
└── secrets/             # Encrypted YAML files (SOPS)
```

---

## 🚀 Getting Started (Fedora 42)

### 1. Install the Nix Package Manager
Use the Determinate Systems installer for the most robust setup:
```bash
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
```

### 2. Prepare Secrets (Age Key)
Convert your existing SSH key to an Age key for `sops-nix`:
```bash
mkdir -p ~/.config/sops/age
nix shell nixpkgs#ssh-to-age -c ssh-to-age -private-key -i ~/.ssh/id_ed25519 -o ~/.config/sops/age/keys.txt
```

### 3. Initialize the Environment
Clone this repo and apply the configuration for the first time:
```bash
nix run home-manager/master -- init --flake .#work-pc
```

---

## 🔄 The "Hot-Reload" Workflow (Workflow B)

To enable instant feedback while tweaking **Hyprland** or **Tmux**, run the watcher script in a background terminal/tmux pane:

```bash
# watch.sh
find . -name "*.nix" | entr -r home-manager switch --flake .#work-pc
```

---

## ⚠️ Important Notes

* **Read-Only Files:** Files managed by Home Manager are symlinked to the Nix store. They are **read-only**. To change them, edit the `.nix` source and save; the watcher will update the symlink.
* **Neovim Exception:** For active plugin development, the Neovim directory can be linked via `mkOutOfStoreSymlink` to maintain write access for `lazy.nvim`.
* **Garbage Collection:** To free up space from old generations:
    ```bash
    nix-collect-garbage -d
    ```

---

**Would you like me to generate the first `flake.nix` that matches this exact structure so you can run your first "switch"?**
