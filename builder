#!/bin/bash

function build() {
    local WAT="$1"
    local WASM="$(echo "$WAT" | sed 's/\wat$//g')wasm"
    if [ "$WAT" -nt "$WASM" ]; then
        rm -f "$WASM"
        echo -en "\e[1;33m[BUILD]\e[1;37m $WAT -> $WASM\e[0m"
        STATUS=0
        BUILD_LOG="$(wat2wasm --enable-all "$WAT" -o "$WASM" 2>&1 )" || STATUS=$?
        if [[ "$STATUS" == "0" ]]; then
            echo -e "\r[\e[1;32mOK\e[0m]   "
        else
            echo -e "\r[\e[1;31mFAIL\e[0m] "
        fi
        if [[ "$BUILD_LOG" != "" ]]; then
            echo "$BUILD_LOG"
        fi
    else
        echo -e "\e[1;30mSkipping $WAT ($WASM up to date)\e[0m"
    fi
}

if [[ "$1" != "" ]]; then
    build $@
else
    echo -e "[ \e[34mRun builder for all wat files in $(pwd)\e[0m ]"
    find . -name '*.wat' -exec $0 {} \;
    echo ""
fi
