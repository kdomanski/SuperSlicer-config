#!/bin/sh

set -eu
set -o pipefail

TMP_FILE="$(mktemp)"
trap "rm -f $TMP_FILE" EXIT
FILE='vendor/Voron.ini'

SECTION="$1"
OPTION="$2"
VALUE="$3"

find_section() {
    fgrep -n "$1" "$FILE" | cut -d: -f1 | head -n1
}

find_opt_in_section() {
    local SECT_NAME="$1"
    local OPT_NAME="$2"

    local SECT_LINE="$(find_section "$SECT_NAME")"
    local LINE_AFTER_SECT="$(tail -n "+$SECT_LINE" "$FILE" | grep -nE "^$OPT_NAME = "  | cut -d: -f1 | head -n1)"
    echo $((SECT_LINE + LINE_AFTER_SECT - 1))
}

is_line_empty() {
    local LINE_NUMBER="$1"
    local LINE="$(sed "$LINE_NUMBER!d" "$FILE")"
    if [ -z "$LINE" ]; then
        return 0
    else
        return 1
    fi
}

OPT_LINE="$(find_opt_in_section "$SECTION" "$OPTION")"

if is_line_empty "$OPT_LINE"; then
    VALUE+="\n"
fi
(head -n $((OPT_LINE - 1)) "$FILE"; echo "$OPTION = $VALUE"; tail -n +$((OPT_LINE + 1)) "$FILE") > "$TMP_FILE" && mv "$TMP_FILE" "$FILE"
