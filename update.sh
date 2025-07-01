#!/bin/bash

SEEKER_PROMPT="[🔍SEEKER] "
USER_PROMPT="> "
COLOR_RED="\e[31m"
COLOR_YELLOW="\e[33m"
COLOR_GREEN="\e[32m"
COLOR_RESET="\e[0m"

function v1() {
    while true; do
        printf "\n${COLOR_YELLOW}%s${COLOR_RESET}\n" "${SEEKER_PROMPT}What is the module name? Please make sure the module name is exactly the filename"
        printf "%s" "${USER_PROMPT}"
        read MODULE_NAME
        printf "\n${COLOR_YELLOW}%s${COLOR_RESET}\n" "${SEEKER_PROMPT}What is the module type? Only accept: file, url, cmd"
        printf "%s" "${USER_PROMPT}"
        read MODULE_TYPE

        printf "\n${COLOR_YELLOW}%s${COLOR_RESET}\n" "${SEEKER_PROMPT}Is the following information correct? (y/n)"
        printf "%s${COLOR_GREEN}%s${COLOR_RESET}\n%s${COLOR_GREEN}%s${COLOR_RESET}\n" \
        "Module Name: " "${MODULE_NAME}" \
        "Module Type: " "${MODULE_TYPE}"
        printf "${USER_PROMPT}"
        read CONFIRM

        if [[ ${CONFIRM} == "y" || ${CONFIRM} == "Y" ]]; then
            printf "\n${MODULE_NAME},${MODULE_TYPE}" >> DB
            printf "\n%s\n" "✅ Successfully update seeker.db!"
            break
        fi
        printf "\n${COLOR_YELLOW}${SEEKER_PROMPT}Try one more time...${COLOR_RESET}"
    done
}


function v2() {
    DB_FILE="seeker.db"
    DATABASE_DIR="database"
    TYPES=("file" "cmd" "url")

    touch "$DB_FILE"

    for type in "${TYPES[@]}"; do
        folder="${DATABASE_DIR}/${type}"
        if [[ -d "$folder" ]]; then
            for filepath in "$folder"/*; do
                [[ -f "$filepath" ]] || continue
                filename=$(basename "$filepath")
                name="${filename%.*}"
                entry="${name},${type}"
                if ! grep -qFx "$entry" "$DB_FILE"; then
                    echo "$entry" >> "$DB_FILE"
                    printf "${COLOR_GREEN}%s${COLOR_RESET}\n" "➕ Added: $entry"
                # else
                #     printf "${COLOR_YELLOW}%s${COLOR_RESET}\n" "➖ Skipped (duplicate): $entry"
                fi
            done
        fi
    done
    printf "${COLOR_GREEN}%s${COLOR_RESET}\n" "✅ DB update complete."
}

v2