#!/bin/bash

: "

 ____ _____ ____  ____  ____            _             
|  _ \_   _/ ___||  _ \/ ___|  ___  ___| | _____ _ __ 
| |_) || | \___ \| |_) \___ \ / _ \/ _ \ |/ / _ \ '__|
|  __/ | |  ___) |  __/ ___) |  __/  __/   <  __/ |   
|_|    |_| |____/|_|   |____/ \___|\___|_|\_\___|_|   
Pentest Script Seeker - PTSPSeeker

PTSPSeeker is a useful and light tool that searches for scripts, commands, and url-links that's related to the input keyword.
PTSPSeeker returns either:
    1. script
    2. url-link
    3. command
The config file is represented as seeker.db:
    - type=url, meaning that the source is provided as URL link
    - type=file, meaning that the source is provided as a file
    - type=cmd, meaning that the source is provided as a command

⚠️ Warning: seeker.db file must contain a new line at the end of the file. Otherwise the update bash file would encounter the issue.
"

DIVIDED_LINE="-----------------"
SEEKER_PROMPT="[🔍SEEKER] "
COLOR_RED="\e[31m"
COLOR_GREEN="\e[32m"
COLOR_YELLOW="\e[33m"
COLOR_RESET="\e[0m"
USER_PROMPT="> "
INVALID_PROMPT="${COLOR_RED}Invalid input. Please make sure your input is correct...${COLOR_RESET}"

print_divider() {
    local width=$(tput cols)
    printf '%*s\n' "$width" '' | tr ' ' '-'
}

search_files_by_keyword() {
    local keyword="$1"
    local search_path="${2:-.}"

    mapfile -t files < <(find "$search_path" -type f -iname "*$keyword*" 2>/dev/null)

    for file in "${files[@]}"; do
        while true; do
            filename=$(basename "${file}")
            printf "\n${COLOR_YELLOW}%s${COLOR_RESET}\n%s\n%s\n" "${SEEKER_PROMPT}Which one would you prefer?" \
            "(1) Standard output" \
            "(2) Stored as File: ${filename}.bak"
            printf "%s" "${USER_PROMPT}"
            read TMP_CHOICE
            if [[ "${TMP_CHOICE}" == "1" ]]; then
                content=$(< "${file}")
                print_divider
                printf "${COLOR_GREEN}%s${COLOR_RESET}\n" "${content}"
                print_divider
                break
            elif [[ "${TMP_CHOICE}" == "2" ]]; then
                cp "$file" "${filename}.bak"
                break
            else
                printf "%s\n" "${INVALID_PROMPT}"
            fi
        done
        break
    done
}


function search_top_10_related() {
    local -n input_array=$1
    local keyword="$2"
    local matches=()

    for item in "${!input_array[@]}"; do
        score=0
        if [[ "$item" == "$keyword" ]]; then
            score=100
        elif [[ "$item" == "$keyword"* ]]; then
            score=90
        elif [[ "$item" == *"$keyword"* ]]; then
            score=75
        else
            len_diff=$(( ${#item} > ${#keyword} ? ${#item} - ${#keyword} : ${#keyword} - ${#item} ))
            score=$((60 - len_diff))
            (( score < 0 )) && score=0
        fi
        matches+=("$score:$item")
    done
    printf "\n%s\n" "${DIVIDED_LINE}SEARCH RESULTS${DIVIDED_LINE}"
    readarray -t matched_results < <(
        printf "%s\n" "${matches[@]}" | sort -t: -k1,1nr | head -n 10 | cut -d: -f2
    )
    for result in "${matched_results[@]}"; do
        printf "> ${COLOR_GREEN}%s${COLOR_RESET}\n" "${result}"
    done
}

function show_banner() {
    printf "${COLOR_YELLOW}%s${COLOR_RESET}\n\n%s\n${COLOR_RED}%s${COLOR_RESET}\n\n" "
 ____ _____ ____  ____  ____            _             
|  _ \_   _/ ___||  _ \/ ___|  ___  ___| | _____ _ __ 
| |_) || | \___ \| |_) \___ \ / _ \/ _ \ |/ / _ \ '__|
|  __/ | |  ___) |  __/ ___) |  __/  __/   <  __/ |   
|_|    |_| |____/|_|   |____/ \___|\___|_|\_\___|_|   
Pentest Script Seeker - PTSPSeeker" \
    "PTSPSeeker is a useful and light tool that searches for scripts, commands, and url-links that's related to the input keyword.
PTSPSeeker returns either:
    1. script
    2. url-link
    3. command
The config file is represented as seeker.db:
    - type=url, meaning that the source is provided as URL link
    - type=file, meaning that the source is provided as a file
    - type=cmd, meaning that the source is provided as a command" \
    "⚠️ Warning: seeker.db file must contain a new line at the end of the file. Otherwise the update bash file would encounter the issue."
}


function main() {
    printf "${COLOR_YELLOW}%s${COLOR_RESET}\n> " "${SEEKER_PROMPT}what do you want to search for today?"
    read SEARCH_STR
    readarray -t raw_items < seeker.db
    declare -A items
    for line in "${raw_items[@]}"; do
        IFS="," read -r key value <<< ${line}
        items[${key}]=${value}
    done
    search_top_10_related items "${SEARCH_STR}"
    
    printf "\n${COLOR_YELLOW}%s %s${COLOR_RESET}\n" "${SEEKER_PROMPT}Which one are you trying to search for exactly?"  \
    "Please input the exact module name provided above"
    printf "${USER_PROMPT}"
    while true; do
        read EXACT_STR
        if [[ -v items[${EXACT_STR}] ]]; then
            break
        else
            printf "%s\n" "${SEEKER_PROMPT}Please make sure to input the exact module name provided above"
            printf "${USER_PROMPT}"
        fi
    done

    search_files_by_keyword ${EXACT_STR} ./database

}

show_banner
main