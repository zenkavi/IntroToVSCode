# Prompt coloring
export CLICOLOR=1
export LSCOLORS=ExFxBxDxCxegedabagacad
export PROMPT='%B%F{magenta}%/%f%b %# '

alias ls='ls -aGFh'

# Homebrew initialization
eval "$(/opt/homebrew/bin/brew shellenv)"

# Python build dependencies recommended by pyenv
# Uncomment when you want to run pyenv install {version}
# Then source via `exec "$SHELL"`
# Flags for readline
export LDFLAGS="-L/opt/homebrew/opt/readline/lib -L/opt/homebrew/opt/sqlite/lib -L/opt/homebrew/opt/zlib/lib"
export CPPFLAGS="-I/opt/homebrew/opt/readline/include -I/opt/homebrew/opt/sqlite/include -I/opt/homebrew/opt/zlib/include"

# PATH and flags for sqlite
export PATH="/opt/homebrew/opt/sqlite/bin:$PATH"


# Git helpers
alias gitdefault='git rev-parse --abbrev-ref origin/HEAD | sed "s/origin\///"'
alias gitprune='git fetch --all --prune && git branch -v | grep "gone]" | awk "{print \$1}" | xargs git branch -D'
alias gitp='git checkout `gitdefault` && git pull && gitprune'
alias gitb='git rev-parse --abbrev-ref HEAD'

# Get current branch, switch to main, pull, back to branch, rebase
alias gitr='X=`gitb`; gitp && git checkout $X && git rebase `gitdefault`'
# Push new branch to origin under the same name
alias gitpb='X=`gitb`; git push -u origin $X'
alias gitpu='gitpb'
alias gti='git'
alias cdroot='cd `git rev-parse --show-toplevel`'
alias gitsetdefault='X=`gitb`; git update-ref --no-deref -d refs/remotes/origin/HEAD && git symbolic-ref refs/remotes/origin/HEAD refs/remotes/origin/$X'