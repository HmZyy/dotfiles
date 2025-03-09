#!/usr/bin/env bash

type="type-1"
style="style-1"

while [[ "$#" -gt 0 ]]; do
  case "$1" in
  --type)
    type="type-$2"
    shift 2
    ;;
  --style)
    style="style-$2"
    shift 2
    ;;
  *)
    echo "Unknown argument: $1"
    exit 1
    ;;
  esac
done

dir="$HOME/.config/rofi/powermenu/$type"

lastlogin="$(last $USER | head -n1 | tr -s ' ' | cut -d' ' -f5,6,7)"
uptime="$(uptime -p | sed -e 's/up //g')"
host=$(hostname)

ROFI_OPTIONS=(
  -p "󰣇  $USER@$host"
  -mesg "󰄉  Uptime: $uptime"
  -theme-str 'listview {columns: 1; lines: 3;}'
  -theme ${dir}/${style}.rasi)
# Zenity options
ZENITY_TITLE="Power Profiles"
ZENITY_TEXT="Set Profiles:"
ZENITY_OPTIONS=(--column= --hide-header)

#######################################################################
#                             END CONFIG                              #
#######################################################################

# Whether to ask for user's confirmation
enable_confirmation=false

# Preferred launcher if both are available
preferred_launcher="rofi"

usage="$(basename "$0") [-h] [-c] [-p name] -- display a menu for shutdown, reboot, lock etc.

where:
    -h  show this help text
    -c  ask for user confirmation
    -p  preferred launcher (rofi or zenity)

This script depends on:
  - systemd,
  - i3,
  - rofi or zenity."

# Check whether the user-defined launcher is valid
launcher_list=(rofi zenity)
function check_launcher() {
  if [[ ! "${launcher_list[@]}" =~ (^|[[:space:]])"$1"($|[[:space:]]) ]]; then
    echo "Supported launchers: ${launcher_list[*]}"
    exit 1
  else
    # Get array with unique elements and preferred launcher first
    # Note: uniq expects a sorted list, so we cannot use it
    i=1
    launcher_list=($(for l in "$1" "${launcher_list[@]}"; do
      printf "%i %s\n" "$i" "$l"
      let i+=1
    done |
      sort -uk2 | sort -nk1 | cut -d' ' -f2- | tr '\n' ' '))
  fi
}

# Parse CLI arguments
while getopts "hcp:" option; do
  case "${option}" in
  h)
    echo "${usage}"
    exit 0
    ;;
  c)
    enable_confirmation=true
    ;;
  p)
    preferred_launcher="${OPTARG}"
    check_launcher "${preferred_launcher}"
    ;;
  *)
    exit 1
    ;;
  esac
done

# Check whether a command exists
function command_exists() {
  command -v "$1" &>/dev/null 2>&1
}

# systemctl required
if ! command_exists systemctl; then
  exit 1
fi

# default_menu_options defined as an associative array
typeset -A default_menu_options

# The default options with keys/commands

default_menu_options=(
  []="powerprofilesctl set performance"
  []="powerprofilesctl set balanced"
  []="powerprofilesctl set power-saver"
)

# The menu that will be displayed
typeset -A menu
menu=()

# Only add power profiles that are available to menu
for key in "${!default_menu_options[@]}"; do
  grep_arg=${default_menu_options[${key}]##* }
  if powerprofilesctl list | grep -q "$grep_arg"; then
    menu[${key}]=${default_menu_options[${key}]}
  fi
done
unset grep_arg
unset default_menu_options

menu_nrows=${#menu[@]}

# Menu entries that may trigger a confirmation message
menu_confirm="Shutdown Reboot Hibernate Suspend Halt Logout"

launcher_exe=""
launcher_options=""

function prepare_launcher() {
  if [[ "$1" == "rofi" ]]; then
    launcher_exe="rofi"
    launcher_options=(-dmenu -i -lines "${menu_nrows}" "${ROFI_OPTIONS[@]}")
  elif [[ "$1" == "zenity" ]]; then
    launcher_exe="zenity"
    launcher_options=(--list --title="${ZENITY_TITLE}" --text="${ZENITY_TEXT}"
      "${ZENITY_OPTIONS[@]}")
  fi
}

for l in "${launcher_list[@]}"; do
  if command_exists "${l}"; then
    prepare_launcher "${l}"
    break
  fi
done

# No launcher available
if [[ -z "${launcher_exe}" ]]; then
  exit 1
fi

launcher=(${launcher_exe} "${launcher_options[@]}")
selection="$(printf '%s\n' "${!menu[@]}" | sort | "${launcher[@]}")"

function ask_confirmation() {
  if [ "${launcher_exe}" == "rofi" ]; then
    confirmed=$(echo -e "Yes\nNo" | rofi -dmenu -i -lines 2 -p "${selection}?" "${ROFI_OPTIONS[@]}")
    [ "${confirmed}" == "Yes" ] && confirmed=0
  elif [ "${launcher_exe}" == "zenity" ]; then
    zenity --question --text "Are you sure you want to ${selection,,}?"
    confirmed=$?
  fi

  if [ "${confirmed}" == 0 ]; then
    i3-msg -q "exec --no-startup-id ${menu[${selection}]}"
  fi
}

if [[ $? -eq 0 && ! -z ${selection} ]]; then
  if [[ "${enable_confirmation}" = true &&
    ${menu_confirm} =~ (^|[[:space:]])"${selection}"($|[[:space:]]) ]]; then
    ask_confirmation
  else
    i3-msg -q "exec --no-startup-id ${menu[${selection}]}"
  fi
fi
