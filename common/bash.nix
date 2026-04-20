{ pkgs, ... }:

{
  programs.bash = {
    enable = true;
    enableCompletion = true;

    shellAliases = {
      # neovim configs
      avante = "NVIM_APPNAME=nvim-avante nvim";
      nvchad = "NVIM_APPNAME=nvim-nvchad nvim";

      # docker
      dps = ''docker ps -a --format "table {{.ID}}\t{{.Names}}\t{{.Status}}"'';

      # misc
      chrome-debug = ''google-chrome --remote-debugging-port=9222 --user-data-dir="$HOME/.chrome-debug-profile" --no-first-run --no-default-browser-check'';
      kill-chrome-mcp = "pkill -f chrome-devtools-mcp";
      hy = "nvim $HOME/.config/hypr/hyprland.conf";
      fix-dock-display = "sudo modprobe -r typec_displayport && sleep 1 && sudo modprobe typec_displayport && hyprctl reload";

      # audio profile switching
      audio-speakers = ''pactl set-card-profile alsa_card.pci-0000_00_1f.3-platform-skl_hda_dsp_generic "HiFi (HDMI1, HDMI2, HDMI3, Mic1, Mic2, Speaker)"'';
      audio-headphones = ''pactl set-card-profile alsa_card.pci-0000_00_1f.3-platform-skl_hda_dsp_generic "HiFi (HDMI1, HDMI2, HDMI3, Headphones, Mic1, Mic2)"'';
    };

    initExtra = ''
      # vi mode, but keep Ctrl-P/N for history in insert mode
      set -o vi
      bind -m vi-insert '"\C-p": previous-history'
      bind -m vi-insert '"\C-n": next-history'
      bind -m vi-insert '"\C-l": clear-screen'

      # timezone
      export TZ=Europe/Paris

      # paths
      export PROJ_DIR="$HOME/Projects"
      export PNPM_HOME="$HOME/.local/share/pnpm"
      export BUN_INSTALL="$HOME/.bun"
      export PKG_CONFIG_PATH="/usr/local/lib64/pkgconfig:/usr/lib64/pkgconfig:''${PKG_CONFIG_PATH:-}"

      _prepend_path() {
        case ":$PATH:" in
          *":$1:"*) ;;
          *) PATH="$1:$PATH" ;;
        esac
      }
      _prepend_path "$HOME/.nix-profile/bin"
      _prepend_path "$HOME/.cargo/bin"
      _prepend_path "$PNPM_HOME"
      _prepend_path "$BUN_INSTALL/bin"
      _prepend_path "$HOME/.local/bin"
      export PATH
      unset -f _prepend_path

      # flake path for nh — NH_FLAKE covers both `nh os` and `nh home`.
      export NH_FLAKE="$HOME/Perso/nix"

      # lcdp work aliases
      alias dc="cd $PROJ_DIR/lcdp-docker-compose"
      alias front="cd $PROJ_DIR/lcdp-front-mono"
      alias teraf="cd $PROJ_DIR/terraform"
      alias mono="cd $PROJ_DIR/lcdp-monolith-sve"
      alias start="dc && python ./script/start.py"
      alias lcdp-aws-login='aws ecr get-login-password --profile staging | docker login --password-stdin --username AWS 721041490777.dkr.ecr.us-east-1.amazonaws.com'
      alias lcdp-down='docker compose -p base down --remove-orphans'

      # lcdp docker functions
      lcdp-setup-kafka() {
        cd "$PROJ_DIR/lcdp-docker-compose/base" || return 1
        docker compose --env-file ../.env -f docker-compose.yml -f docker-compose.kafka.yml --profile setup run --rm -it kafka-setup
        echo "Stopping containers..."
        docker compose -p base down
        echo "Kafka setup complete. Topics persisted in volumes."
      }

      _lcdp_collect_up_args() {
        # Fills global arrays __compose_files and __extra_args from "$@"
        __compose_files=(--env-file ../.env -f docker-compose.yml -f docker-compose.kafka.yml)
        __extra_args=()
        [ -f "../.env.local" ] && __compose_files+=(--env-file ../.env.local)
        local arg line
        for arg in "$@"; do
          if [[ "$arg" == -* ]]; then
            __extra_args+=("$arg")
          elif [ -f "../customs/$arg.txt" ]; then
            while IFS= read -r line; do
              __compose_files+=(-f "overrides/$line")
            done < "../customs/$arg.txt"
          elif [ -f "overrides/$arg.yml" ]; then
            __compose_files+=(-f "overrides/$arg.yml")
          else
            echo "Unknown custom: $arg" >&2
            return 1
          fi
        done
      }

      lcdp-up() {
        cd "$PROJ_DIR/lcdp-docker-compose/base" || return 1
        _lcdp_collect_up_args "$@" || return 1
        echo "docker compose ''${__compose_files[*]} up ''${__extra_args[*]}"
        docker compose "''${__compose_files[@]}" up "''${__extra_args[@]}"
      }

      lcdp-prod() {
        cd "$PROJ_DIR/lcdp-docker-compose/base" || return 1
        local compose_files=(--env-file ../.env -f docker-compose.yml -f docker-compose.kafka.yml -f docker-compose.production.yml)
        local extra_args=()
        [ -f "../.env.local" ] && compose_files+=(--env-file ../.env.local)
        local arg line
        for arg in "$@"; do
          if [[ "$arg" == -* ]]; then
            extra_args+=("$arg")
          elif [ -f "../customs/$arg.txt" ]; then
            while IFS= read -r line; do
              compose_files+=(-f "overrides/$line")
            done < "../customs/$arg.txt"
          elif [ -f "overrides/$arg.yml" ]; then
            compose_files+=(-f "overrides/$arg.yml")
          else
            echo "Unknown custom: $arg" >&2
            return 1
          fi
        done
        echo "docker compose ''${compose_files[*]} up ''${extra_args[*]}"
        docker compose "''${compose_files[@]}" up "''${extra_args[@]}"
      }

      lcdp-pull() {
        cd "$PROJ_DIR/lcdp-docker-compose/base" || return 1
        local compose_files=(--env-file ../.env -f docker-compose.yml -f docker-compose.kafka.yml)
        local services=()
        [ -f "../.env.local" ] && compose_files+=(--env-file ../.env.local)
        local arg line
        for arg in "$@"; do
          if [ -f "../customs/$arg.txt" ]; then
            while IFS= read -r line; do
              compose_files+=(-f "overrides/$line")
            done < "../customs/$arg.txt"
          elif [ -f "overrides/$arg.yml" ]; then
            compose_files+=(-f "overrides/$arg.yml")
          fi
          case "$arg" in
            monolith)           services+=(monolith_service) ;;
            front)              services+=(front_service) ;;
            af|admin-front)     services+=(admin_front_service) ;;
            maf)                services+=(monolith_service admin_front_service front_service) ;;
          esac
        done
        docker compose "''${compose_files[@]}" pull "''${services[@]}"
      }

      lcdp-kpow-license() {
        echo "export KPOW_CE_LICENSE_ID=$(aws ssm get-parameter --profile staging --name /kpow-ce/license_id --query Parameter.Value --output text)"
        echo "export KPOW_CE_LICENSE_CODE=$(aws ssm get-parameter --profile staging --name /kpow-ce/license_code --query Parameter.Value --output text)"
        echo "export KPOW_CE_LICENSEE=$(aws ssm get-parameter --profile staging --name /kpow-ce/licensee --query Parameter.Value --output text)"
        echo "export KPOW_CE_LICENSE_EXPIRY=$(aws ssm get-parameter --profile staging --name /kpow-ce/license_expiry --query Parameter.Value --output text)"
        echo "export KPOW_CE_LICENSE_SIGNATURE=$(aws ssm get-parameter --profile staging --name /kpow-ce/license_signature --query Parameter.Value --output text)"
      }

      # claude code PR workflows
      review-pr() {
        local pr="$1"
        [ -z "$pr" ] && echo "Usage: review-pr <PR_NUMBER>" && return 1
        claude --tmux \
          --allowedTools "Read,Glob,Grep,Bash(gh *),Bash(git *),Bash(ls *)" \
          -p "Read .claude/review-pr.md and follow its instructions for PR #$pr."
      }

      fix-pr() {
        local pr="$1"
        [ -z "$pr" ] && echo "Usage: fix-pr <PR_NUMBER>" && return 1
        claude --tmux --worktree "fix-$pr" \
          --allowedTools "Edit,Write,Read,Glob,Grep,Bash(git *),Bash(gh *),Bash(pnpm *),Bash(ls *)" \
          -p "Read .claude/fix-pr.md and follow its instructions for PR #$pr."
      }

      # source lcdp env (bash syntax; user-managed, not sops-nix)
      [ -f "$HOME/.config/lcdp_env.bash" ] && . "$HOME/.config/lcdp_env.bash"

      # safe-chain
      [ -f "$HOME/.safe-chain/scripts/init-bash.sh" ] && . "$HOME/.safe-chain/scripts/init-bash.sh"
    '';
  };

  programs.starship = {
    enable = true;
    settings = {
      nix_shell = {
        format = "via [$symbol$name]($style) ";
        symbol = "❄️ ";
      };
    };
  };

  programs.fzf = {
    enable = true;
    enableBashIntegration = true;
  };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };
}
