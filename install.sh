#!/bin/bash

set -e

#############################################################################
#                                                                           #
# Project 'pterodactyl-installer-Zkillu'                                           #
#                                                                           #
#############################################################################

SCRIPT_VERSION="v0.0.1"
GITHUB_BASE_URL="https://raw.githubusercontent.com/Arnaudtech/pterodactyl-zkillu"

LOG_PATH="/var/log/pterodactyl-zkillu.log"

# sortir avec une erreur si l'utilisateur n'est pas root
if [[ $EUID -ne 0 ]]; then
  echo "* Ce script doit être exécuté avec les privilèges de l'utilisateur root (sudo)." 1>&2
  exit 1
fi

# check for curl
if ! [ -x "$(command -v curl)" ]; then
  echo "* curl est requis pour utiliser ce script"
  echo "* Pour l'installer, il faut utiliser apt (Debian & Ubuntu & derivatives) ou yum/dnf (CentOS)"
  exit 1
fi

output() {
  echo -e "* ${1}"
}

error() {
  COLOR_RED='\033[0;31m'
  COLOR_NC='\033[0m'

  echo ""
  echo -e "* ${COLOR_RED}ERROR${COLOR_NC}: $1"
  echo ""
}

execute() {
  echo -e "\n\n* pterodactyl-installer $(date) \n\n" >> $LOG_PATH

  bash <(curl -s "$1") | tee -a $LOG_PATH
  [[ -n $2 ]] && execute "$2"
}

done=false

output "Pterodactyl installation by Zkillu @ $SCRIPT_VERSION"
output
output "Copyright (C) 2020 - 2022, Arno"
output "https://github.com/Arnaudtech/pterodactyl-zkillu"
output
output "Sponsoring/Donations: https://github.com/vilhelmprytz/pterodactyl-installer?sponsor=1"
output "Ce script est utilisé pour installer Pterodactyl pour les clients Zkillu."

output

PANEL_LATEST="$GITHUB_BASE_URL/$SCRIPT_VERSION/install-panel.sh"

WINGS_LATEST="$GITHUB_BASE_URL/$SCRIPT_VERSION/install-wings.sh"

PANEL_LEGACY="$GITHUB_BASE_URL/$SCRIPT_VERSION/legacy/panel_0.7.sh"

WINGS_LEGACY="$GITHUB_BASE_URL/$SCRIPT_VERSION/legacy/daemon_0.6.sh"

PANEL_CANARY="$GITHUB_BASE_URL/master/install-panel.sh"

WINGS_CANARY="$GITHUB_BASE_URL/master/install-wings.sh"

while [ "$done" == false ]; do
  options=(
    "Installation du Panel"
    "Installation des Wings"
    "Installez [0] et [1] sur la même machine (le script des wings est exécuté après le panel).\n"

    "Installation du panel en version 0.7 (Sur demande du client. Version qui ne bénéficie d'aucun support !)"
    "Install 0.6 version of daemon (Sur demande du client. Version qui ne bénéficie d'aucun support !)"
    "Installez [3] et [4] sur la même machine (le script des wings est exécuté après le panel)\n"

    "Installation du panel en version canary (Sur demande du client. Version possiblement instable !)"
    "Installation du service wings en version canary (Sur demande du client. Version possiblement instable !)"
    "Installez [6] et [7] sur la même machine (le script des wings est exécuté après le panel)"
  )

  actions=(
    "$PANEL_LATEST"
    "$WINGS_LATEST"
    "$PANEL_LATEST;$WINGS_LATEST"

    "$PANEL_LEGACY"
    "$WINGS_LEGACY"
    "$PANEL_LEGACY;$WINGS_LEGACY"

    "$PANEL_CANARY"
    "$WINGS_CANARY"
    "$PANEL_CANARY;$WINGS_CANARY"
  )

  output "Que voulez vous faire ?"

  for i in "${!options[@]}"; do
    output "[$i] ${options[$i]}"
  done

  echo -n "* Input 0-$((${#actions[@]} - 1)): "
  read -r action

  [ -z "$action" ] && error "Input is required" && continue

  valid_input=("$(for ((i = 0; i <= ${#actions[@]} - 1; i += 1)); do echo "${i}"; done)")
  [[ ! " ${valid_input[*]} " =~ ${action} ]] && error "Invalid option"
  [[ " ${valid_input[*]} " =~ ${action} ]] && done=true && IFS=";" read -r i1 i2 <<< "${actions[$action]}" && execute "$i1" "$i2"
done
