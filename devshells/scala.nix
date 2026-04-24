{ pkgs }:

pkgs.mkShell {
  name = "scala-shell";

  buildInputs = with pkgs; [
    jdk21
    jdt-language-server
    sbt
    maven
  ];

  shellHook = ''
    export JAVA_HOME="${pkgs.jdk21}"
  '';
}
