{ pkgs, ... }:

{
  programs.fish = {
    enable = true;

    shellAliases = {
      # nix
      nhs = "nh home switch -c work-pc";

      # safe commands
      cp = "cp -iv";
      mv = "mv -iv";
      rm = "rm -vI";
      bc = "bc -ql";
      mkd = "mkdir -pv";

      # lsd
      ls = "lsd";
      l = "lsd -l";
      la = "lsd -a";
      lla = "lsd -la";
      lt = "lsd --tree";

      # tool replacements
      cat = "bat";
      grep = "grep --color=always";
      locate = "plocate";

      # apps
      v = "$EDITOR";
      vim = "$EDITOR";
      nb = "newsboat";
      za = "zathura";
      code = "vscodium";
      ytdl = "yt-dlp --no-mtime";

      # neovim configs
      avante = "NVIM_APPNAME=nvim-avante nvim";
      nvchad = "NVIM_APPNAME=nvim-nvchad nvim";

      # docker
      dps = ''docker ps -a --format "table {{.ID}}\t{{.Names}}\t{{.Status}}"'';

      # git
      gf = "git-flow";

      # misc
      chrome-debug = ''google-chrome --remote-debugging-port=9222 --user-data-dir="$HOME/.chrome-debug-profile" --no-first-run --no-default-browser-check'';
      kill-chrome-mcp = "pkill -f chrome-devtools-mcp";
      hy = "nvim $HOME/.config/hypr/hyprland.conf";
      fix-dock-display = "sudo modprobe -r typec_displayport && sleep 1 && sudo modprobe typec_displayport && hyprctl reload";

      # audio profile switching
      audio-speakers = ''pactl set-card-profile alsa_card.pci-0000_00_1f.3-platform-skl_hda_dsp_generic "HiFi (HDMI1, HDMI2, HDMI3, Mic1, Mic2, Speaker)"'';
      audio-headphones = ''pactl set-card-profile alsa_card.pci-0000_00_1f.3-platform-skl_hda_dsp_generic "HiFi (HDMI1, HDMI2, HDMI3, Headphones, Mic1, Mic2)"'';
    };

    functions = {
      # lcdp docker commands
      lcdp-setup-kafka = ''
        cd "$PROJ_DIR/lcdp-docker-compose/base"; or return 1
        docker compose --env-file ../.env -f docker-compose.yml -f docker-compose.kafka.yml --profile setup run --rm -it kafka-setup
        echo "Stopping containers..."
        docker compose -p base down
        echo "Kafka setup complete. Topics persisted in volumes."
      '';

      lcdp-up = ''
        cd "$PROJ_DIR/lcdp-docker-compose/base"; or return 1
        set -l compose_files --env-file ../.env -f docker-compose.yml -f docker-compose.kafka.yml
        set -l extra_args

        test -f "../.env.local"; and set -a compose_files --env-file ../.env.local

        for arg in $argv
          if string match -q -- '-*' $arg
            set -a extra_args $arg
          else if test -f "../customs/$arg.txt"
            for line in (cat "../customs/$arg.txt")
              set -a compose_files -f "overrides/$line"
            end
          else if test -f "overrides/$arg.yml"
            set -a compose_files -f "overrides/$arg.yml"
          else
            echo "Unknown custom: $arg" >&2
            return 1
          end
        end

        echo "docker compose $compose_files up $extra_args"
        docker compose $compose_files up $extra_args
      '';

      lcdp-prod = ''
        cd "$PROJ_DIR/lcdp-docker-compose/base"; or return 1
        set -l compose_files --env-file ../.env -f docker-compose.yml -f docker-compose.kafka.yml -f docker-compose.production.yml
        set -l extra_args

        test -f "../.env.local"; and set -a compose_files --env-file ../.env.local

        for arg in $argv
          if string match -q -- '-*' $arg
            set -a extra_args $arg
          else if test -f "../customs/$arg.txt"
            for line in (cat "../customs/$arg.txt")
              set -a compose_files -f "overrides/$line"
            end
          else if test -f "overrides/$arg.yml"
            set -a compose_files -f "overrides/$arg.yml"
          else
            echo "Unknown custom: $arg" >&2
            return 1
          end
        end

        echo "docker compose $compose_files up $extra_args"
        docker compose $compose_files up $extra_args
      '';

      lcdp-pull = ''
        cd "$PROJ_DIR/lcdp-docker-compose/base"; or return 1
        set -l compose_files --env-file ../.env -f docker-compose.yml -f docker-compose.kafka.yml
        set -l services

        test -f "../.env.local"; and set -a compose_files --env-file ../.env.local

        for arg in $argv
          if test -f "../customs/$arg.txt"
            for line in (cat "../customs/$arg.txt")
              set -a compose_files -f "overrides/$line"
            end
          else if test -f "overrides/$arg.yml"
            set -a compose_files -f "overrides/$arg.yml"
          end

          switch $arg
            case monolith
              set -a services monolith_service
            case front
              set -a services front_service
            case af admin-front
              set -a services admin_front_service
            case maf
              set -a services monolith_service admin_front_service front_service
          end
        end

        docker compose $compose_files pull $services
      '';

      lcdp-kpow-license = ''
        echo "export KPOW_CE_LICENSE_ID="(aws ssm get-parameter --profile staging --name /kpow-ce/license_id --query Parameter.Value --output text)
        echo "export KPOW_CE_LICENSE_CODE="(aws ssm get-parameter --profile staging --name /kpow-ce/license_code --query Parameter.Value --output text)
        echo "export KPOW_CE_LICENSEE="(aws ssm get-parameter --profile staging --name /kpow-ce/licensee --query Parameter.Value --output text)
        echo "export KPOW_CE_LICENSE_EXPIRY="(aws ssm get-parameter --profile staging --name /kpow-ce/license_expiry --query Parameter.Value --output text)
        echo "export KPOW_CE_LICENSE_SIGNATURE="(aws ssm get-parameter --profile staging --name /kpow-ce/license_signature --query Parameter.Value --output text)
      '';

      # claude code PR workflows
      review-pr = ''
        set -l pr $argv[1]
        test -z "$pr"; and echo "Usage: review-pr <PR_NUMBER>" && return 1
        claude --tmux \
          --allowedTools "Read,Glob,Grep,Bash(gh *),Bash(git *),Bash(ls *)" \
          -p "Read .claude/review-pr.md and follow its instructions for PR #$pr."
      '';

      fix-pr = ''
        set -l pr $argv[1]
        test -z "$pr"; and echo "Usage: fix-pr <PR_NUMBER>" && return 1
        claude --tmux --worktree "fix-$pr" \
          --allowedTools "Edit,Write,Read,Glob,Grep,Bash(git *),Bash(gh *),Bash(pnpm *),Bash(ls *)" \
          -p "Read .claude/fix-pr.md and follow its instructions for PR #$pr."
      '';
    };

    interactiveShellInit = ''
      # vi mode
      fish_vi_key_bindings

      # timezone
      set -gx TZ Europe/Paris

      # paths
      set -gx PROJ_DIR $HOME/Projects
      set -gx PNPM_HOME $HOME/.local/share/pnpm
      set -gx BUN_INSTALL $HOME/.bun
      set -gx PKG_CONFIG_PATH /usr/local/lib64/pkgconfig /usr/lib64/pkgconfig $PKG_CONFIG_PATH

      fish_add_path $HOME/.nix-profile/bin
      fish_add_path $HOME/.cargo/bin
      fish_add_path $PNPM_HOME
      fish_add_path $BUN_INSTALL/bin
      fish_add_path $HOME/.local/bin

      # flake path for nh
      set -gx NH_HOME_FLAKE "$HOME/Perso/nix"

      # lcdp work aliases
      alias dc="cd $PROJ_DIR/lcdp-docker-compose"
      alias front="cd $PROJ_DIR/lcdp-front-mono"
      alias teraf="cd $PROJ_DIR/terraform"
      alias mono="cd $PROJ_DIR/lcdp-monolith-sve"
      alias start="dc && python ./script/start.py"
      alias lcdp-aws-login='aws ecr get-login-password --profile staging | docker login --password-stdin --username AWS 721041490777.dkr.ecr.us-east-1.amazonaws.com'
      alias lcdp-down='docker compose -p base down --remove-orphans'

      # source lcdp env (decrypted by sops-nix)
      if test -f ~/.config/sops-nix/secrets/lcdp_env
        source ~/.config/sops-nix/secrets/lcdp_env
      end

      # safe-chain
      if test -f ~/.safe-chain/scripts/init-fish.fish
        source ~/.safe-chain/scripts/init-fish.fish
      end
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
    enableFishIntegration = true;
  };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };
}
