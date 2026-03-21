{ ... }:

let
  scriptDir = ../scripts;
  scripts = [
    "capslock.sh"
    "docker-clean"
    "donotdisturb.sh"
    "lid.sh"
    "monitor.sh"
    "powermenu"
    "start_work.sh"
    "tofi-clip"
    "tofi-emoji"
    "volume"
    "sparkline-cpu.sh"
    "sparkline-mem.sh"
  ];
in {
  home.file = builtins.listToAttrs (map (name: {
    name = ".local/bin/${name}";
    value = {
      source = "${scriptDir}/${name}";
      executable = true;
    };
  }) scripts);
}
