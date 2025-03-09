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

# CMDs
lastlogin="$(last $USER | head -n1 | tr -s ' ' | cut -d' ' -f5,6,7)"
uptime="$(uptime -p | sed -e 's/up //g')"
host=$(hostname)

# Options
hibernate=󰤄 # nf-md-power_sleep
shutdown=󰐥  # nf-md-power
reboot=󰜉    # nf-md-restart
lock=      # nf-fa-lock
suspend=󰒲   # nf-md-sleep
logout=󰍃    # nf-md-logout
yes=󰄬       # nf-fa-check
no=󰜺        # nf-md-close

# Rofi CMD
rofi_cmd() {
  rofi -dmenu \
    -p "󰣇  $USER@$host" \
    -mesg "󰄉  Uptime: $uptime" \
    -theme ${dir}/${style}.rasi \
    -selected-row 4
}

# Confirmation CMD
confirm_cmd() {
  rofi -theme-str 'window {location: center; anchor: center; fullscreen: false; width: 350px;}' \
    -theme-str 'mainbox {orientation: vertical; children: [ "message", "listview" ];}' \
    -theme-str 'listview {columns: 2; lines: 1;}' \
    -theme-str 'element-text {horizontal-align: 0.5;}' \
    -theme-str 'textbox {horizontal-align: 0.5;}' \
    -dmenu \
    -p 'Confirmation' \
    -mesg 'Are you Sure?' \
    -theme ${dir}/${style}.rasi
}

# Ask for confirmation
confirm_exit() {
  echo -e "$yes\n$no" | confirm_cmd
}

# Pass variables to rofi dmenu
run_rofi() {
  #echo -e "$lock\n$suspend\n$logout\n$hibernate\n$reboot\n$shutdown" | rofi_cmd
  echo -e "$lock\n$suspend\n$logout\n$reboot\n$shutdown" | rofi_cmd
}

# Execute Command
run_cmd() {
  selected="$(confirm_exit)"
  if [[ "$selected" == "$yes" ]]; then
    if [[ $1 == '--shutdown' ]]; then
      systemctl poweroff
    elif [[ $1 == '--reboot' ]]; then
      systemctl reboot
    elif [[ $1 == '--hibernate' ]]; then
      systemctl hibernate
    elif [[ $1 == '--suspend' ]]; then
      mpc -q pause
      amixer set Master mute
      systemctl suspend
    elif [[ $1 == '--logout' ]]; then
      if [[ "$DESKTOP_SESSION" == 'openbox' ]]; then
        openbox --exit
      elif [[ "$DESKTOP_SESSION" == 'bspwm' ]]; then
        bspc quit
      elif [[ "$DESKTOP_SESSION" == 'i3' ]]; then
        i3-msg exit
      elif [[ "$DESKTOP_SESSION" == 'plasma' ]]; then
        qdbus org.kde.ksmserver /KSMServer logout 0 0 0
      fi
    fi
  else
    exit 0
  fi
}

# Actions
chosen="$(run_rofi)"
case ${chosen} in
$shutdown)
  run_cmd --shutdown
  ;;
$reboot)
  run_cmd --reboot
  ;;
$hibernate)
  run_cmd --hibernate
  ;;
$lock)
  if [[ -x '/usr/bin/betterlockscreen' ]]; then
    betterlockscreen -l
  elif [[ -x '/usr/bin/i3lock' ]]; then
    i3lock
  fi
  ;;
$suspend)
  run_cmd --suspend
  ;;
$logout)
  run_cmd --logout
  ;;
esac
