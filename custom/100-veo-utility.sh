# Veo related Bash helpers.

## Veo directories.
export MYVEO_OE_DIR="${MY_WORKSPACE_DIR}/veo-oe"
export MYVEO_SRC_DIR="${MYVEO_OE_DIR}/src"
export MYVEO_DATA_DIR="${MYVEO_SRC_DIR}/data"
export MYVEO_DATA_REC_DIR="${MYVEO_DATA_DIR}/recordings"
export MYVEO_DATA_REC_MNT="/media/recordings"
export MYVEO_DATA_SENSOR_DIR="${MYVEO_DATA_DIR}/sensor_data"
export MYVEO_DATA_SENSOR_MNT="/media/sensor_data"
export MYVEO_DATA_CAL_DIR="${MYVEO_DATA_DIR}/calibration"
export MYVEO_STAGES_DIR="${MYVEO_OE_DIR}/tmp/stages"
export MYVEO_REPLAY_DIR="${MYVEO_STAGE_DIR}/var/spool/veo/replay"

## Helper functions.
declare -A MYVEO_FUNCTIONS

# Add helper functions here using this template:
# function foo() {
#   ...
# }
# MY_FUNCTIONS[foo]="my awesome function"

function etoon() {
    "${MYVEO_OE_DIR}/bin/eto" || logError "MYVEO_OE_DIR is ${BOLD}${MYVEO_OE_DIR}${RESET}"
}
MYVEO_FUNCTIONS[etoon]="enter eto shell"

function veo_vpnon() {
    openvpn3 session-start --config ~/.config/vpn/veo.ovpn
}
MYVEO_FUNCTIONS[veo_vpnon]="connect to Veo vpn"

function veo_vpnoff() {
    openvpn3 session-manage -D --config ~/.config/vpn/veo.ovpn
}
MYVEO_FUNCTIONS[veo_vpnoff]="disconnect from Veo vpn"

function veo_linkvfss() {
    local help="${MYVEO_FUNCTIONS[veo_linkvfss]}
Usage: ${FUNCNAME[0]} [-f <vfss_file>] [-s <stage>] [-d <depth>]

    Options:
      -h             Show help.
      -f <folder>    Root folder to search the vfss file recursively.
      -s <stage>     Stage name to link the vfss to.
      -d <depth>     Search depth for the vfss file.
    "

    local stage="stage"
    local depth=10

    local OPTIND o
    while getopts ":s:d:f:h" o; do
        case "${o}" in
        f)
            folder=${OPTARG}
            ;;
        s)
            stage=${OPTARG}
            ;;
        d)
            depth=${OPTARG}
            ;;
        h | *)
            echo -e "${help}"
            return 0
            ;;
        esac
    done
    shift $((OPTIND - 1))

    printf ${WHITE}"Target stage: "${BOLD}${stage}${RESET}"\n"
    printf ${WHITE}"Search depth: "${BOLD}${depth}${RESET}"\n"

    local replay_dir="${MYVEO_STAGES_DIR}/${stage}/var/spool/veo/replay"

    mkdir -p ${replay_dir}

    printf ${WHITE}"Replay vfss:  "${BOLD}"${replay_dir}/rec.vfss"${RESET}"\n"
    readlink -f "${replay_dir}/rec.vfss" | xargs -I{} printf ${WHITE}"Current vfss: "${BOLD}"{}"${RESET}"\n"

    find "${folder:-${MYVEO_DATA_REC_DIR}}" -name "*.vfss" -maxdepth 10 -type f -print 2>/dev/null |
        sort |
        fzf --cycle --border=double --pointer='→' |
        xargs -r -o -I{} ln -sfv {} ${replay_dir}/rec.vfss
}
MYVEO_FUNCTIONS[veo_linkvfss]="link a vfss recording to a stage replay"

function veo_stageshell() {
    [[ ${SHENV_NAME} != "eto" ]] && echo -e "Are you in eto shell?" && return 1
    eto stage ls | fzf --height 15% --reverse --border | xargs -r -o -I{} eto stage -n {} shell
}
MYVEO_FUNCTIONS[veo_stageshell]="enter the selected stage's shell"

function veo_getrecording() {
    : ${1:?Missing DEPTH argument. Usage: ${FUNCNAME[0]} DEPTH}
    find "${MYVEO_DATA_REC_MNT}" -maxdepth ${1} -type d -print 2>/dev/null |
        fzf --cycle --pointer='→' |
        xargs -r -o -I{} rsync -avzh -P "{}" "${MYVEO_DATA_REC_DIR}"
}
MYVEO_FUNCTIONS[veo_getrecording]="get a recording from remote to local"

function veo_rmrecording() {
    : ${1:?Missing DEPTH argument. Usage: ${FUNCNAME[0]} DEPTH}
    find "${MYVEO_DATA_REC_DIR}" -maxdepth ${1} -type d -print 2>/dev/null |
        fzf --cycle --pointer='→' |
        xargs -r -o -I{} rm -r "{}"
}
MYVEO_FUNCTIONS[veo_rmrecording]="rm a recording from local"

function veo_getsensordata() {
    : ${1:?Missing DEPTH argument. Usage: ${FUNCNAME[0]} DEPTH}
    find "${MYVEO_DATA_SENSOR_MNT}" -maxdepth ${1} -type d -print 2>/dev/null |
        fzf --multi --cycle --pointer='→' |
        xargs -r -o -I{} rsync -avzh -P "{}" "${MYVEO_DATA_SENSOR_DIR}"
}
MYVEO_FUNCTIONS[veo_getsensordata]="get sensor data from remote to local"

function veo_rsync() {
    : ${1:?Missing IN_PATH argument. Usage: ${FUNCNAME[0]} IN_PATH [OUT_PATH]}
    find "${1}" -maxdepth 5 -type d -print 2>/dev/null |
        fzf --multi --cycle --pointer='→' |
        tr -s " " | cut -d " " -f 5 |
        xargs -r -o -I{} rsync -avzh -P "${1}/{}/" "${2:-.}"
}
MYVEO_FUNCTIONS[veo_rsync]="sync directory from source to destination"

function veo_getcaljobs() {
    python <<EOF
import json
from pathlib import Path
root_dir = Path("${MYVEO_DATA_CAL_DIR}")
for filepath in root_dir.rglob("manifest.json"):
    with open(filepath, 'rt') as fh:
        payload = json.load(fh)
    print(f'{payload["id"]}')
EOF
}
MYVEO_FUNCTIONS[veo_getcaljobs]="get calibration job ids"

## Aliases
alias veo_help="_help MYVEO_FUNCTIONS MYVEO_"
