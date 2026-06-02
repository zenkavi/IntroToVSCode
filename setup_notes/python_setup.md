# Options for Python version and package management

I don't like that `conda` (a popular package management system for Python) changes the python paths in `{PATH}`. I also don't like the difficulty of installing different versions of Python with it and how its ability to install from different channels can interfere with dependencies.

I used to use `pyenv` and its associated `pyenv-virtualenv` to install different versions of Python and create virtual environments, tracking dependencies by hand with `pip freeze > requirements.txt`. I have since migrated to [`uv`](https://docs.astral.sh/uv/), which replaces that whole stack (`pyenv` + `pyenv-virtualenv` + `pip` + `requirements.txt`) with a single, very fast tool.

`uv` can:

- install and manage multiple Python versions (replacing `pyenv install`),
- create and manage virtual environments (replacing `pyenv-virtualenv`),
- resolve, install, and lock dependencies via `pyproject.toml` + `uv.lock` (replacing manual `requirements.txt`),
- and run commands inside the right environment automatically (`uv run`).

Unlike `conda`, it does not hijack your `PATH`: there are no shims to initialize in your startup script. The migration also means the `pyenv` initialization and the `pyenv` build-dependency flags (`LDFLAGS`, `CPPFLAGS`, etc.) can be removed from your startup script — `uv` downloads prebuilt standalone Python binaries, so those build dependencies are no longer needed.

Here is a [useful overview](https://stackoverflow.com/questions/41573587/what-is-the-difference-between-venv-pyvenv-pyenv-virtualenv-virtualenvwrappe) of the older virtual env options for context.

# Installation

1. Install Homebrew

```zsh
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

2. Install uv

https://docs.astral.sh/uv/getting-started/installation/

```zsh
brew update
brew install uv
```

Alternatively, the standalone installer (not tied to Homebrew):

```zsh
curl -LsSf https://astral.sh/uv/install.sh | sh
```

3. (Optional) Enable shell completion

```zsh
echo 'eval "$(uv generate-shell-completion zsh)"' >> ~/.zshrc
```

That's it — no `PATH` shims or build-dependency flags to add to your startup script.

## Installation check

Check that uv is in your PATH:

```zsh
which uv
uv --version
```

`which uv` should not return an empty string.

If you are in a VSCode Terminal and the wrong interpreter is being picked up, select the project's interpreter with the **Python: Select Interpreter** command and point it at the project's `.venv/bin/python`. See `vscode_kernels.md` for kernel selection in notebooks.

# Migrating an existing pyenv + requirements.txt project

In the existing project directory:

1. Pin the Python version you want the project to use (writes a `.python-version` file, the same file `pyenv local` used):

```zsh
uv python pin 3.12
```

2. Create a project environment from your existing `requirements.txt`:

```zsh
uv venv
uv pip install -r requirements.txt
```

This gives you a working `.venv` with the `pip`-compatible interface and is the lowest-friction path.

3. (Recommended) Convert to a managed `pyproject.toml` so dependencies are declared and locked. Initialize project metadata, then add your dependencies:

```zsh
uv init --bare        # creates pyproject.toml without touching your code
uv add -r requirements.txt
```

`uv add` writes the dependencies into `pyproject.toml`, resolves them, creates/updates `uv.lock`, and installs them into `.venv`. Commit both `pyproject.toml` and `uv.lock` to version control. You can then delete `requirements.txt`.

# Helpful commands

## Upgrade uv

```zsh
brew upgrade uv
# or, if installed via the standalone installer:
uv self update
```

## Install / list / pin Python versions

```zsh
uv python install 3.12        # replaces `pyenv install 3.12`
uv python install 3.10 3.11   # several at once
uv python list                # installed and available versions
uv python pin 3.12            # pin the version for the current project (.python-version)
```

## Start a new project

```zsh
uv init my-project            # creates pyproject.toml, .python-version, etc.
cd my-project
```

## Create a virtual environment

```zsh
uv venv                       # creates .venv using the pinned Python
uv venv --python 3.11         # or a specific version
```

`uv` automatically creates and uses `.venv` in the project root, so you usually do not need to activate it manually — `uv run` and `uv add`/`uv sync` find it. To activate it explicitly:

```zsh
source .venv/bin/activate
deactivate
```

## Add / remove dependencies

```zsh
uv add numpy pandas           # adds to pyproject.toml, updates uv.lock, installs
uv add "scipy>=1.11"          # with a version constraint
uv add --dev pytest ruff      # development-only dependency
uv remove pandas
```

## Sync an environment (the "clone a virtual env" workflow)

Where you used to `pip freeze > requirements.txt` and `pip install -r requirements.txt`, the lockfile now does this reproducibly. After cloning a repo that has a `pyproject.toml` + `uv.lock`:

```zsh
uv sync                       # creates .venv and installs the exact locked versions
```

To update the lockfile to the latest allowed versions:

```zsh
uv lock --upgrade
uv sync
```

## Run a command in the project environment

No activation needed — `uv run` ensures the environment is in sync first:

```zsh
uv run python my_script.py
uv run pytest
uv run jupyter lab
```

## pip-compatible interface

For ad hoc installs or to mirror old habits, `uv pip` mirrors `pip`:

```zsh
uv pip install -r requirements.txt
uv pip install numpy
uv pip freeze
uv pip list
```

Prefer `uv add` / `uv sync` for project work so dependencies stay declared in `pyproject.toml` and locked in `uv.lock`; use `uv pip` mainly for migration or quick experiments.

## Tools (formerly global pip installs / pipx)

Run or install command-line tools in isolated environments without polluting a project:

```zsh
uvx ruff check .              # run a tool one-off (ephemeral env)
uv tool install ruff          # install a tool globally for your user
```
