{ pkgs }:

pkgs.mkShell {
  name = "scala-shell";

  buildInputs = with pkgs; [
    jdk21
    sbt
  ];

  shellHook = ''
    export JAVA_HOME="${pkgs.jdk21}"
  '';
}
