{ pkgs }:

pkgs.mkShell {
  name = "java-legacy-shell";

  buildInputs = with pkgs; [
    jdk8
    maven
    gradle
  ];

  shellHook = ''
    export JAVA_HOME="${pkgs.jdk8}"
  '';
}
