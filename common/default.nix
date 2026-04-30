{ pkgs, ... }:

let
  sfw = pkgs.callPackage ./pkgs/sfw.nix {};
in
{
  imports = [ ./bash.nix ./tmux.nix ./foot.nix ./hyprland.nix ./secrets.nix ./neovim.nix ./scripts.nix ./pomodoro.nix ./nvchecker.nix ./mail.nix ];

  # Shared aliases — applied to every shell home-manager manages.
  home.shellAliases = {
    # nix
    nhs = "nh os switch";

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
    code = "vscodium";

    # git
    gf = "git-flow";
  };

  catppuccin = {
    enable = true;
    flavor = "mocha";
    rofi.enable = false;
    cursors.enable = false;
  };

  home.pointerCursor = {
    name = "Adwaita";
    package = pkgs.adwaita-icon-theme;
    size = 24;
    gtk.enable = true;
  };

  home.packages = with pkgs; [
    nh
    lsd
    nodejs_22
    pnpm
    sfw
    btop
    mpv
    lazygit
    playerctl
    gh
    wlogout
    tofi
    jq
    ripgrep
    fd
    rbw
    go-passbolt-cli
    claude-code
    jetbrains.datagrip
    # (pkgs.papirus-icon-theme.overrideAttrs { meta.priority = 10; })

    # GUI apps
    google-chrome
    slack
    vscodium
    firefox
    signal-desktop
    spotify
    gimp
    libreoffice
    pavucontrol
    virt-manager

    # Wayland / Hyprland utilities
    wl-clipboard
    cliphist
    grimblast
    hyprpicker
    hyprpaper
    hypridle
    hyprlock
    dunst
    rofi
    grim
    slurp
    satty
    wlr-randr
    wlsunset
    sox

    # CLI tools
    httpie
    ansible
    pandoc
    warpd
  ];

  home.sessionVariables.TERMINAL = "foot";

  # PATH for GUI sessions started by systemd (e.g. via SDDM). Bash rcs are not
  # sourced by systemd user services, so Hyprland/Waybar/dunst would otherwise
  # miss ~/.local/bin (user scripts) and ~/.nix-profile/bin (rofi, rbw, jq, …).
  xdg.configFile."environment.d/20-path.conf".text = ''
    PATH=''${HOME}/.nix-profile/bin:''${HOME}/.local/bin:''${PATH}
  '';

  home.file.".local/share/wall.jpg".source = ./theme/wallpaper.jpg;

  # rbw (Bitwarden CLI) — uses custom pinentry that reads master password from gnome-keyring
  xdg.configFile."rbw/config.json".text = builtins.toJSON {
    email = "nicolas@ling.fr";
    base_url = "https://api.bitwarden.eu";
    identity_url = "https://identity.bitwarden.eu";
    lock_timeout = 3600;
    sync_interval = 3600;
    pinentry = "pinentry-rbw-keyring";
  };

  # Global gitignore — git picks up ~/.config/git/ignore automatically (XDG default)
  xdg.configFile."git/ignore".text = ''
    .envrc
    .direnv/
    .nvimrc
    .tern-port
    .vim/.netrwhist
    .config/dconf/user
    .nx
    .claude
  '';

  services.ssh-agent.enable = true;

  programs.ssh = {
    enable = true;
    addKeysToAgent = "yes";
    matchBlocks = {
      "e2e-jump" = {
        hostname = "54.237.177.143";
        user = "ec2-user";
        identityFile = "~/.ssh/ec2-jump-host";
      };
      "e2e-runner" = {
        hostname = "172.16.10.224";
        user = "ec2-user";
        identityFile = "~/.ssh/ec2-runner";
        proxyJump = "e2e-jump";
      };
    };
  };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  # Bat — catppuccin theme applied globally
  programs.bat.enable = true;

  # Lazygit — catppuccin theme via catppuccin.enable
  programs.lazygit = {
    enable = true;
    settings = {
      git.pagers = [
        {
          pager = "delta --dark --paging=never --line-numbers --hyperlinks --hyperlinks-file-link-format=\"lazygit-edit://{path}:{line}\"";
          colorArg = "never";
        }
      ];
    };
  };

  # GTK theming — catppuccin handles theme and icons
  gtk = {
    enable = true;
    font.name = "Adwaita Sans";
    font.size = 11;
    gtk3.extraConfig = {
      gtk-cursor-theme-size = 24;
      gtk-application-prefer-dark-theme = true;
    };
    gtk4.extraConfig = {
      gtk-cursor-theme-size = 24;
      gtk-application-prefer-dark-theme = true;
    };
  };

  programs.delta = {
    enable = true;
    enableGitIntegration = true;
    options = {
      navigate = true;
      light = false;
      side-by-side = true;
      line-numbers = true;
      interactive.keep-plus-minus-markers = true;
    };
  };

  programs.git = {
    enable = true;
    settings = {
      user = {
        name = "Nicolas Medda";
        email = "nicolas@lecomptoirdespharmacies.fr";
      };
      core = {
        autocrlf = "input";
        editor = "nvim";
        excludesFile = "~/.config/git/ignore";
      };
      gui.encoding = "utf-8";
      color.ui = true;
      alias = {
        lg = "log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit";
        grog = "log --graph --abbrev-commit --decorate --all --format=format:'%C(bold blue)%h%C(reset) - %C(bold cyan)%aD%C(dim white) - %an%C(reset) %C(bold green)(%ar)%C(reset)%C(bold yellow)%d%C(reset)%n %C(white)%s%C(reset)'";
        sh = "show -- . ':(exclude)*.storyshot'";
        df = "diff -- . ':(exclude)*.storyshot'";
        st = "status";
        ci = "commit";
        co = "checkout";
        br = "branch";
        plz = "push --force-with-lease";
        up = "!git co develop && git pull && git co - && git rebase develop";
      };
      pull.rebase = true;
      branch.autosetuprebase = "always";
      rerere.enabled = true;
      fetch = {
        writeCommitGraph = true;
        prune = true;
      };
      push.autoSetupRemote = true;
      init.defaultBranch = "main";
      transfer.fsckObjects = true;
      log.date = "iso";
      stash.showPatch = true;
      remote.pushDefault = "origin";
      credential.helper = "cache --timeout 3600";
      advice.detachedHead = false;
      diff.context = 10;
    };
    includes = [
      {
        condition = "gitdir:~/Perso/";
        contents.user.email = "nicolas@ling.fr";
      }
    ];
  };

  programs.jujutsu = {
    enable = true;
    settings = {
      user = {
        name = "Nicolas Medda";
        email = "nicolas@lecomptoirdespharmacies.fr";
      };
      ui = {
        default-command = "log";
        diff-editor = ":builtin";
        pager = "delta";
      };
      "--scope" = [
        {
          "--when".repositories = [ "~/Perso" ];
          user.email = "nicolas@ling.fr";
        }
      ];
    };
  };
}
