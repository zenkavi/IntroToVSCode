After updating Julia locally I could not start a Julia kernel in Jupyter notebooks. The problem was that vscode did not know the updated path for the Julia binary.

To debug this I changed the path in `kernel.json` in

```
~/Library/Jupyter/kernels/julia-1.9
```

Normally, adding Julia kernels should work with 

```
]add IJulia
]build IJulia
```

The second command creates a new directory `~/Library/Jupyter/kernels/julia-{VERSION}` if adding a kernel for a new version of Julia. Might need to restart VSCode to see the latest kernels.

This base path is where the `R` kernel for `.ipynb`s are as well. If using `pyenv` this is a separate path than from where Python kernels would be. Python kernels and virtual environments associated with a project managed by `uv`, places the Python kernel in the same path at the `R` and `Julia` kernels.

```
# Installing a Python kernel in a project using uv
uv add --dev ipykernel
uv run ipython kernel install --user --env VIRTUAL_ENV $(pwd)/.venv --name=project
```