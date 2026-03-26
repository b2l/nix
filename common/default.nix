{ pkgs, ... }:

{
  imports = [ ./fish.nix ./tmux.nix ./foot.nix ./hyprland.nix ./secrets.nix ./neovim.nix ./scripts.nix ];

  catppuccin = {
    enable = true;
    flavor = "mocha";
    rofi.enable = false;
  };

  home.packages = with pkgs; [
    nh
    lsd
    nodejs_22
    pnpm
    btop
    mpv
    lazygit
    playerctl
    gh
    wlogout
    tofi
    jq
    rbw
    go-passbolt-cli
    (pkgs.papirus-icon-theme.overrideAttrs { meta.priority = 10; })
  ];

  home.sessionVariables.TERMINAL = "foot";

  home.file.".local/share/wall.jpg".source = ./theme/wallpaper.jpg;

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
      git.pagers.pager = "delta --dark --paging=never --line-numbers --hyperlinks --hyperlinks-file-link-format=\"lazygit-edit://{path}:{line}\"";
      git.pagers.colorArg = "never";
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
}
