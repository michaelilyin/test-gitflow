#!/usr/bin/env bash

# This script contains common functions and defines common variables which may be used in another files.

# Root directory.
ROOT_DIR=$(git rev-parse --show-toplevel 2> /dev/null)
# Directory with hooks.
HOOKS_DIR=$(dirname $SCRIPT_PATH)

function __print_fail {
    echo -e " $1"
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