#!/bin/bash

# User Settings
readonly SHELL_PATH='..'
readonly LOG_FILE='results.txt'
readonly OUTPUT_DIR="$(pwd)/outputs"

# Flags
CREATE_FILES=0
PASS=0
FAIL=0

# Colors
RESET="\033[0m"
RED="\033[31m"
GREEN="\033[32m"
BLUE="\033[34m"
CYAN="\033[36m"
WHITE="\033[37m"

source scripts/run_test.sh
source scripts/test_all.sh
source scripts/test_builtins.sh

init_files () {
    echo > "${LOG_FILE}"
    echo > ".files_before"
    echo > ".files_after"

    ls >> ".files_before"
}

build_executable () {
    if ! make -C "${SHELL_PATH}" > /dev/null; then
        echo "Unable to run make at '${SHELL_PATH}'"
        exit 1
    fi

    cp "${SHELL_PATH}/minishell" .
}

test_all () {
    test_syntax_error
    test_command_not_found
    test_paths
    test_shlvl
    test_builtins
    test_separator
    test_pipe
    test_redirections
    test_quotes
    test_vars
}

test_custom () {
    if [[ -f "$1" ]]; then
        while IFS= read -r line; do
            run_test "${line}"
        done < "$1"
    else
        echo "$1: file does not exist"
    fi
}

print_score () {
	SUM=PASS
	let SUM+=$FAIL
    if (( "${FAIL}" != 0 )); then
	echo -ne "$RED
    $PASS / $SUM
    \"The goal is to make your own shell
    If it moves like bash,
    If it doesn't crash
    It's a beautiful, one and only, minishell.\" - Brian Fox

$RESET"
    elif (( "${PASS}" != 0 )); then
        echo -ne "$GREEN@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@..... ...  ...,@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@,.... ....... ........,@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@,,.........,,,*,,,..,,,,,..#@@@@@@@@@@@@@
@@@@@@@@@@@@/,,,.,,,,,,,,*,******,**,,,...,@@@@@@@@@@@@
@@@@@@@@@@@*,/,,,,,,,*********//////***,,,.,@@@@@@@@@@@
@@@@@@@@@@*,,*,,,,,,,,****////////////***,,.%@@@@@@@@@@
@@@@@@@@@@*,,,,,,,,,,,******,*****/////**,,,,@@@@@@@@@@
@@@@@@@@@(*,*,,,*,**/*****/**//(((//**///***,(@@@@@@@@@
@@@@@@@@@(//,,,.. ..,,**//**,,.,,*///*///*,*,,@@@@@@@@@
@@@@@@@%*(*/,.,,....,..*/((*,,,,**/**////**,,*##@@@@@@@
@@@@@@@*(*,.....,.....,*///*..,,.#,.***////,*((,(@@@@@@  $PASS / $SUM
@@@@@@@/(/,,,,,,,..,,,*///(/(**////*****///*///(/&@@@@@  Great!
@@@@@@@(#/,,,,,**,,.,**/(/((/*//****/////*/*(*(/&@@@@@@
@@@@@@@/(/****,**,,,.,*/((#(**/*//(//((//***/*/(@@@@@@@
@@@@@@@@((*,,,**,,,. ...,,*/////(/(/(((//**//((@@@@@@@@
@@@@@@@@%/,,,,..        .  ..,////(/(((//////(@@@@@@@@@
@@@@@@@@@(,,,..  .....,,*,/,, . ,*//((/(*/**(@@@@@@@@@@
@@@@@@@@@@/...   ....,.,**/(//*. ./*//(///**/@@@@@@@@@@
@@@@@@@@@@@,,.    .       .,***,,.**,**,****/@@@@@@@@@@
@@@@@@@@@@@%,..  . .,,,,,/,,*,*..,,,,,,,,.,**.@@@@@@@@@
@@@@@@@@@@@(/..    ,..,,,/....   .,,.....,,   ...*@@@@@
@@@@@@@@(,*/,, .    .     .     ... ....       .,,,,,,.
/**,* . . *,...         .     .. .             ...,,,..
,*.      .......          .                   ...,,,.,.
.        ........                              ..,.....
$RESET"
	fi
    echo
    echo "Please do your own signal testing."
}

cleanup () {
    local file_diff

    ls >> ".files_after"
    file_diff=$(diff .files_before .files_after | grep ">" | sed "s|> ||g" | tr '\n' ' ')
    if [[ -n "${file_diff}" ]]; then
        rm "${file_diff}"
    fi
    rm ".files_before" ".files_after"
}

main () {
    init_files
    build_executable

    if (( $# == 0 )); then
        test_all
        return
    fi

    for arg in "$@"; do
        case "${arg}" in
            echo) test_echo ;;
            cd) test_cd ;;
            pwd) test_pwd ;;
            export) test_export ;;
            unset) test_unset ;;
            env) test_env ;;
            exit) test_exit ;;
            *) test_custom "${arg}" ;;
        esac
    done

    print_score
    cleanup
}

main "$@"
