# Steps to run Claude Code on HPC in a container

## Build Docker image locally, move to HPC, make Singularity image

Dockerfile

```
FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive
ENV LC_ALL=C.UTF-8

RUN apt-get update && apt-get install -y \
        curl ca-certificates git ripgrep jq \
    && rm -rf /var/lib/apt/lists/*

RUN set -eux; \
    VERSION=$(curl -fsSL https://downloads.claude.ai/claude-code-releases/latest); \
    curl -fsSL -o /usr/local/bin/claude \
        "https://downloads.claude.ai/claude-code-releases/${VERSION}/linux-x64/claude"; \
    EXPECTED=$(curl -fsSL "https://downloads.claude.ai/claude-code-releases/${VERSION}/manifest.json" \
        | jq -r '.platforms["linux-x64"].checksum'); \
    ACTUAL=$(sha256sum /usr/local/bin/claude | cut -d' ' -f1); \
    [ "$EXPECTED" = "$ACTUAL" ] || { echo "checksum mismatch"; exit 1; }; \
    chmod +x /usr/local/bin/claude

CMD ["claude"]
```

Commands to build it, move it and make a Singularity image on the HPC.

```
# On your laptop
# --platform flag matters if you're on an Apple Silicon Mac
docker build --platform linux/amd64 -t claude-code . 
docker save claude-code -o claude-code.tar
scp claude-code.tar zenkavi@hopper:~/

# On Hopper
apptainer build claude_code.sif docker-archive://claude-code.tar
```

## Shell function for `.bashrc`

```
claude() {
    singularity exec \
        --bind "$HOME/.claude:/root/.claude" \
        --bind "$PWD:$PWD" \
        --pwd "$PWD" \
        /path/to/claude_code.sif claude "$@"
}
```

You could work with a virtualenv in the container using the follows:

```
claude() {
    singularity exec \
        --bind "$HOME/.claude:/root/.claude" \
	    --bind "$PWD:$PWD" \
        --bind "/hopper/groups/enkavilab/pyenvs:/hopper/groups/enkavilab/pyenvs" \
        --pwd "$PWD" \
        /hopper/home/zenkavi/claude_code.sif claude "$@"
}
```

## Authenticate account on HPC 

For Hopper we can use the JupyterHub browser

```
mkdir -p ~/.claude
apptainer exec \
    --bind ~/.claude:/root/.claude \
    --bind $PWD:$PWD \
    claude_code.sif claude
```

Claude Code will print an OAuth URL. Copy it, paste it into a new browser tab in the same browser session that's running JupyterHub. Sign in with your Pro account, approve, and the browser shows you a code to paste back into the terminal. 
