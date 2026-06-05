{ pkgs }:

# Per-project .envrc to use this shell and auto-activate the venv:
#
#   use flake ~/Perso/nix#poetry
#   if [ -d .venv ]; then
#     export VIRTUAL_ENV="$PWD/.venv"
#     PATH_add "$VIRTUAL_ENV/bin"
#   fi
#
# POETRY_VIRTUALENVS_IN_PROJECT forces poetry to create .venv/ in the
# project root instead of ~/.cache/pypoetry/virtualenvs/, so the .envrc
# pattern above can pick it up.
#
# First-time setup inside the project:
#
#   poetry install
#   direnv reload

pkgs.mkShell {
  name = "poetry-shell";

  packages = with pkgs; [
    python312
    poetry
  ];

  shellHook = ''
    export POETRY_VIRTUALENVS_IN_PROJECT=true
  '';
}
