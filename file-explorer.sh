#!/bin/bash

debug=false

while getopts ":d" opt; do
  case $opt in
    d)
      debug=true
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      exit 1
      ;;
  esac
done

# Find the rows and columns. Will default to 80x24 if it can not be detected.
screen_size=$(stty size 2>/dev/null || echo 24 80)
rows=$(echo $screen_size | awk '{print $1}')
columns=$(echo $screen_size | awk '{print $2}')

# Divide by two so the dialogs take up half of the screen, which looks nice.
r=$(( rows / 2 ))
c=$(( columns / 2 ))
# Unless the screen is tiny
r=$(( r < 20 ? 20 : r ))
c=$(( c < 70 ? 70 : c ))

if ${debug}; then
  whiptail --title "Debug" --msgbox "Screen size: ${columns}:${rows}
  Box size: ${c}:${r}
  Number of arguments: ${#}
  Arguments: ${*}
  Arguments: ${@}" ${r} ${c}
fi

files=$(find -maxdepth 1 -type f -iname "*.txt" -printf "%f TXT \n" | sort)

if [ "${files}" = "" ]; then
  whiptail --msgbox "No file found" ${r} ${c}
else
  choosing=true
  while $choosing; do
    choosed=$(whiptail --title "Found files" --cancel-button "Cancel" --menu "" ${r} ${c} $((${r}-8)) ${files} 3>&1 1>&2 2>&3)

    if [ $? -eq 0 ]; then
      whiptail --title ${choosed} --textbox ${choosed} ${r} ${c} --scrolltext
    else
      choosing=false
    fi
  done
fi
