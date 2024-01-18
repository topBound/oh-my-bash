# Common Bash setup

## Disable Ctrl-s (Software Flow Control)
stty stop ""

# fzf fuzzy finder (https://github.com/junegunn/fzf) default options.
export FZF_DEFAULT_OPTS='--height 50% --layout=reverse --border'

declare -A MYGIT_FUNCTIONS

# Add helper functions here using this template:
# function foo() {
#   ...
# }
# MY_FUNCTIONS[foo]="my awesome function"

function git_sb() {
    git branch -v |
    fzf --cycle --pointer='→' --nth=2 --height 25% |
    cut -c 3- | cut -d " " -f 1 |
    xargs -r -o -I{} git switch "{}"
}
MYGIT_FUNCTIONS[git_sb]="switch to a branch"

function git_sc() {
    git status --porcelain -u |
    fzf --cycle --pointer='→' --nth=2 --height 25% |
    cut -c 4- |
    xargs -r -o -I{} git add ":/{}"
}
MYGIT_FUNCTIONS[git_sc]="stage changes"

## Aliases
alias git_help="_help MYGIT_FUNCTIONS MYGIT_"
