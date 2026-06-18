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
    # Build poetry against 3.12 so the venvs it creates use 3.12, not the
    # 3.13 that pkgs.poetry is built against by default.
    (poetry.override { python3 = python312; })
  ];

  shellHook = ''
    export POETRY_VIRTUALENVS_IN_PROJECT=true
  '';
}
