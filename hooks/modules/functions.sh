#!/usr/bin/env bash

COLOR_RED=$(printf '\e[0;31m')
COLOR_DEFAULT=$(printf '\e[m')

ROOT_DIR=$(git rev-parse --show-toplevel 2> /dev/null)
HOOKS_DIR=$(dirname $SCRIPT_PATH)

function __print_fail {
    echo -e "  $1"
}

function __get_commit_files {
    echo $(git diff-index --name-only --diff-filter=ACM --cached HEAD --)
}

function __is_binary {
    P=$(printf '%s\t-\t' -)
    T=$(git diff --no-index --numstat /dev/null "$1")

    case "$T" in "$P"*) return 0 ;; esac

    return 1
}