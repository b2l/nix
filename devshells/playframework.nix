{ pkgs }:

pkgs.mkShell {
  name = "playframework-shell";

  buildInputs = with pkgs; [
    python3
    jdk21
    sbt
    jdt-language-server
  ];

  shellHook = ''
    export JAVA_HOME="${pkgs.jdk21}"

    # sbt-eclipse plugin setup for JDTLS support
    _sbt_plugins="$HOME/.sbt/1.0/plugins/plugins.sbt"
    _sbt_global="$HOME/.sbt/1.0/global.sbt"

    mkdir -p "$HOME/.sbt/1.0/plugins"

    if ! grep -q "sbt-eclipse" "$_sbt_plugins" 2>/dev/null; then
      echo 'addSbtPlugin("com.github.sbt" % "sbt-eclipse" % "6.2.0")' >> "$_sbt_plugins"
      echo "[playframework-shell] sbt-eclipse plugin added to $_sbt_plugins"
    fi

    if ! grep -q "EclipseKeys" "$_sbt_global" 2>/dev/null; then
      cat >> "$_sbt_global" << 'SBTEOF'

import com.typesafe.sbteclipse.core.EclipsePlugin.EclipseKeys

EclipseKeys.projectFlavor := EclipseProjectFlavor.Java
EclipseKeys.skipParents := false
EclipseKeys.withSource := true
EclipseKeys.preTasks := Seq(Compile / compile)
EclipseKeys.createSrc := EclipseCreateSrc.ValueSet(
  EclipseCreateSrc.Unmanaged,
  EclipseCreateSrc.Source,
  EclipseCreateSrc.Resource,
  EclipseCreateSrc.ManagedSrc,
  EclipseCreateSrc.ManagedClasses,
  EclipseCreateSrc.ManagedResources
)
SBTEOF
      echo "[playframework-shell] sbt-eclipse config added to $_sbt_global"
    fi

    echo ""
    echo "Play Framework devshell ready (JDK 21 + sbt + JDTLS)"
    echo "  1. Run 'sbt eclipse' to generate .classpath/.project"
    echo "  2. After dependency changes, re-run 'sbt eclipse'"
    echo "  3. Si JDTLS ne detecte pas les changements: rm -rf ~/.cache/nvim/jdtls/workspace/"
  '';
}
