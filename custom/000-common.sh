# Common Bash setup

## Disable Ctrl-s (Software Flow Control)
stty stop ""

## fzf fuzzy finder (https://github.com/junegunn/fzf) default options.
export FZF_DEFAULT_OPTS='--height 50% --layout=reverse --border'

export NNN_FIFO=/tmp/nnn.fifo
export NNN_OPENER=nuke

## Color codes
## Use tput only if the shell is interactive.
if [[ $- == *i* ]]; then
    BLACK=$(tput setaf 0)
    RED=$(tput setaf 1)
    GREEN=$(tput setaf 2)
    YELLOW=$(tput setaf 190)
    POWDER_BLUE=$(tput setaf 153)
    BLUE=$(tput setaf 4)
    MAGENTA=$(tput setaf 5)
    CYAN=$(tput setaf 6)
    WHITE=$(tput setaf 7)
    BOLD=$(tput bold)
    BLINK=$(tput blink)
    REVERSE=$(tput smso)
    UNDERLINE=$(tput smul)
    RESET=$(tput sgr0)
fi

## Logging
logInfo() {
    echo -e "${GREEN}${BOLD}INFO: ${RESET}${1}"
}

logDebug() {
    echo -e "${YELLOW}${BOLD}DEBUG: ${RESET}${1}"
}

logError() {
    echo -e "${RED}${BOLD}ERROR: ${RESET}${1}" 2>&1
}

## My directories
declare -A MY_DIRS

export MY_WORKSPACE_DIR="${HOME}/Workspace"
export MY_DOCUMENTS_DIR="${MY_WORKSPACE_DIR}/documents"

## Helper functions.
function _help() {
    local -n functions=$1
    printf ${GREEN}${BOLD}"%-30s%s\n"${RESET} "Function" "Description"
    for key in "${!functions[@]}"; do
        printf ${WHITE}${BOLD}"%-30s"${RESET}"%s\n" "${key}" "${functions[$key]}"
    done
    printf ${GREEN}${BOLD}"\n%-30s%s\n"${RESET} "Variable" "Value"
    for key in `compgen -e | grep ${2}`; do
        printf ${WHITE}${BOLD}"%-30s"${RESET}"%s\n" "${key}" "${!key}"
    done
}

declare -A MY_FUNCTIONS

# Add helper functions here using this template:
# function foo() {
#   ...
# }
# MY_FUNCTIONS[foo]="my awesome function"

## Aliases
alias my_help="_help MY_FUNCTIONS MY_"
alias vi=vim
alias t1='tree --dirsfirst -a -F -h -L 1 -C'
alias t2='tree --dirsfirst -a -F -h -L 2 -C'
alias t3='tree --dirsfirst -a -F -h -L 3 -C'
alias refresh='. ~/.bashrc'
alias la='ls -lAh --group-directories-first --color=auto'
alias lds='ls -lAh --group-directories-first --color=auto'
alias bat='batcat'

## Change prompt color on a SSH connection
HOST_PROMPT="\[${CYAN}\]\[${BOLD}\]\h\[${RESET}\]"
if [[ -n $SSH_CLIENT ]]; then
    case $HOSTNAME in
    *) HOST_PROMPT="\[${RED}\]\[${REVERSE}\]\h\[${RESET}\]" ;;
    esac
fi
PS1="\[${GREEN}\]\u\[${RESET}\]@${HOST_PROMPT}"
PS1+=":\[${YELLOW}\]\w\[${RESET}\]\$ "
