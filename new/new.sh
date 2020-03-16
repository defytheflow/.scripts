#!/bin/bash

# Absolute imports
. $(dirname $(realpath $0))/settings.sh
. $(dirname $(realpath $0))/helpers.sh

# If templates directory does not exist:
if [[ ! -d "$TEMPLATES_DIR" ]]; then
    echo "$SCRIPT_NAME: unable to find '$TEMPLATES_DIR' directory" >&2
    echo "Create '$TEMPLATES_DIR' directory and fill it with default  templates." >&2
    exit 1
fi

# '--edit' flag expects to find at least one <file>.
if [[ ${FLAGS[edit]} -eq 1 ]]; then
    # If no <file> arguments were given:
    if [[ $# -eq 0 ]]; then
        echo "$SCRIPT_NAME: missing <file> argument" >&2
        echo "$HELP" >&2
        exit 1
    fi
fi

# '--make' option doesn't need a <file>, but can use it too.
if [[ -n ${OPTS[make]} ]]; then
    # If no <file>s were given or <file> has an extension:
    if [[ $# -eq 0 || "$1" =~ ^.+\..+$ ]]; then
        copy_template "makefiles/${OPTS[make]}" "$MAKEFILE_NAME"
    else
        copy_template "makefiles/${OPTS[make]}" "$1"
        shift
    fi
fi

# If '--make' option and '--edit' flag were not used, we need to check for a <file>.
if [[ -z ${OPTS[make]} && ${FLAGS[edit]} -eq 0 ]]; then
    # If no <file>s were given:
    if [[ $# -eq 0 ]]; then
        echo "$SCRIPT_NAME: missing <file> argument" >&2
        echo "$HELP" >&2
        exit 1
    fi
fi

# If  have files to create:
if [[ $# -gt 0 ]]; then
    # For each <file>:
    for file in "$@"; do

        ext=${file#${file%.*}}  # get file extension
        ext=${ext:1}            # remove leading '.'

        case "$ext" in
            c | cpp | html | py)
                copy_template "$ext"  "$file"  ;;
            *)
                touch "$file"  ;;
        esac
    done
fi

# If '--edit' flag is on"
if [[ ${FLAGS[edit]} -eq 1 ]]; then
    # If only one <file>:
    if [[ $# -eq 1 ]]; then
        # Open one file for editing.
        vim -c 'startinsert' "$1" "+${CURSOR_LINE_NUMBERS[$ext]}"
    # If more then one <file>:
    elif [[ $# -gt 1 ]]; then
        # Open multiple files for editing in vertical split.
        vim -c 'startinsert' -O "$@" "+${CURSOR_LINE_NUMBERS[$ext]}"
    fi
fi

exit 0