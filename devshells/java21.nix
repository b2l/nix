{ pkgs }:

pkgs.mkShell {
  name = "java21-shell";

  buildInputs = with pkgs; [
    jdk21
    maven
  ];

  shellHook = ''
    export JAVA_HOME="${pkgs.jdk21}"
  '';
}
