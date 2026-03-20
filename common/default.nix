{ pkgs, ... }:

{
  imports = [ ./fish.nix ./tmux.nix ./foot.nix ./hyprland.nix ./secrets.nix ./neovim.nix ];

  catppuccin = {
    enable = true;
    flavor = "mocha";
  };

  home.packages = with pkgs; [
    nh
    lsd
    bat
    nodejs_22
    pnpm
  ];

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
