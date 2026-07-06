#!/bin/bash

destFolder="$HOME"

if [[ $# -ge 1 ]]; then
    while [[ $# -gt 0 ]]; do
        if [[ $1 = "--color" ]] || [[ $1 = "-c" ]]; then
            RED='\033[0;31m'
            GREEN='\033[0;32m'
            WHITE='\033[0m'
        fi

        if [[ $1 = "--destination" ]] || [[ $1 = "-d" ]]; then
            if [[ -z $2 ]] || [[ ! -d $2 ]]; then
                exit 0
            fi
            destFolder="$2"
        fi
        shift
    done
else
    RED=''
    GREEN=''
    WHITE=''
fi

# Recreation of @ThePrimeagen Script to copy over files from his dev/ to his $HOME.

if [[ -z $DEV_ENV ]]; then
    echo "No DEV_ENV set!"
    exit 0
fi
#
# --- PRE-NOTICE:

echo -e "Target folder (env) :\t$DEV_ENV"
echo -e "Destination folder  :\t$destFolder\n"

# ------------- PARENTs EXISTENCE TEST -------------

find $DEV_ENV -mindepth 1 -maxdepth 1 -type d -path '.git' | while read -r parentFolder; do
parentName=$(basename $parentFolder)
destParentPath="$destFolder/$parentName"

if [[ ! -d $destParentPath ]]; then
    echo "Creating: \"$parentName\" at \"$destFolder\""
    mkdir $destParentPath
fi
done

# -------------- CHILD FOLDERS PAST PARENT EXISTENCE TEST ---------

# For example: folder="$DEV_ENV/.../nvim" with $DEV_ENV being most of the time: `pwd`
# So: folder="/home/$USER/dev/env/.config/nvim
find $DEV_ENV -mindepth 2 -type d -path '.git'| while read -r folder; do
    # aka: nvim
    folder_name=$(basename $folder)

    # Path without $DEV_ENV
    # aka: .config/nvim
    relative_path=$(echo $folder | sed "s|^$DEV_ENV/||")

    # Name of the root folder holding the folder "folder"
    # aka: .config
    rootFolder=$(echo $relative_path | sed "s|/$folder_name||")

    # aka: /home/$USER/.config/nvim
    homePath="$destFolder/$relative_path"

    # aka: /home/$USER/.config
    homeRootPath="$destFolder/$rootFolder"
    # echo -e "${RED}Removing: rm -rf $destFolder/$relative_path${WHITE}"
    if [[ -d $homePath ]]; then
        rm -rf $homePath
    fi

    # echo -e "${GREEN}Copying env: $folder_name ---> $homeRootPath${WHITE}"
    mkdir -p "$homeRootPath" >/dev/null 2>/dev/null
    cp -rf "$folder" "$homeRootPath"
done

# ----------- FILES COVERAGE -----------

find $DEV_ENV -maxdepth 1 -type f -path '.git' | while read -r file; do
    filename=$(basename $file)
    destPath="$destFolder/$filename"
    if [[ -f $destPath ]]; then
        # echo -e "${RED}Removing: $destPath${WHITE}"
        rm $destPath
    fi

    # echo -e "${GREEN}Copying: $file ---> $destPath${WHITE}"
    cp -f "$file" "$destFolder"
done

# Running in hyprland
if command -v hyprctl &>/dev/null; then
    hyprctl reload &>/dev/null
fi
