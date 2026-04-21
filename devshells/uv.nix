{ pkgs }:

# Per-project .envrc to use this shell and auto-activate the venv.
# We don't `source .venv/bin/activate` — direnv captures env vars but not
# the shell functions activate installs, so it's flaky. Setting VIRTUAL_ENV
# + PATH_add does the two things that actually matter:
#
#   use flake ~/Perso/nix#uv
#   if [ -d .venv ]; then
#     export VIRTUAL_ENV="$PWD/.venv"
#     PATH_add "$VIRTUAL_ENV/bin"
#   fi
#
# First-time setup inside the project:
#
#   uv venv                              # create .venv/
#   uv pip install -r requirements.txt   # or: uv sync  (with pyproject.toml + lockfile)
#   direnv reload                        # pick up the now-existing .venv

pkgs.mkShell {
  name = "uv-shell";

  packages = with pkgs; [
    python3
    uv
  ];
}
