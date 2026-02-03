#!/bin/bash
#set -e
#tput setaf 0 = black 
#tput setaf 1 = red 
#tput setaf 2 = green
#tput setaf 3 = yellow 
#tput setaf 4 = dark blue 
#tput setaf 5 = purple
#tput setaf 6 = cyan 
#tput setaf 7 = gray 
#tput setaf 8 = light blue
##################################################################################################################
##################################################################################################################
#
#   DO NOT JUST RUN THIS. EXAMINE AND JUDGE. RUN AT YOUR OWN RISK.
#
##################################################################################################################
# Funtions

echo "##################################################################"
tput setaf 2
echo "First run the version script"
tput sgr0
echo "##################################################################"

sleep 2

clean_cache() {
  if [[ "$1" == "yes" ]]; then
    echo "##################################################################"
    tput setaf 2
    echo "Cleaning the cache from /var/cache/pacman/pkg/"
    tput sgr0
    echo "##################################################################"
    yes | sudo pacman -Scc
  elif [[ "$1" == "no" ]]; then
    echo "Skipping cache cleaning."
  else
    echo "Invalid option. Use: clean_cache yes | clean_cache no"
  fi
}

remove_buildfolder() {
  if [[ -z "$buildFolder" ]]; then
    echo "Error: \$buildFolder is not set. Please define it before using this function."
    return 1
  fi

  if [[ "$1" == "yes" ]]; then
    if [[ -d "$buildFolder" ]]; then
      echo "##################################################################"
      tput setaf 3
      echo "Deleting the build folder ($buildFolder) - this may take some time..."
      tput sgr0
      sudo rm -rf "$buildFolder"
      echo "##################################################################"
    else
      echo "##################################################################"
      echo "No build folder found. Nothing to delete."
      echo "##################################################################"
    fi
  elif [[ "$1" ]]; then
    echo "Skipping build folder removal."
  else
    echo "Invalid option. Use: remove_buildfolder yes | remove_buildfolder no"
  fi
}

installed_dir=$(dirname $(readlink -f $(basename `pwd`)))

echo
echo "##################################################################"
tput setaf 3
echo "Message"
echo
echo "Do not run this file as root or add sudo in front"
echo "Run this script as a user"
echo
echo "You can add a personal local repo to the iso build if you want"
tput sgr0
echo "##################################################################"
echo

sleep 3

# message for BTRFS
if lsblk -f | grep btrfs > /dev/null 2>&1 ; then
  echo
  echo "##################################################################"
  tput setaf 3
  echo "Message"
  echo
  echo "This script may cause issues on a Btrfs filesystem"
  echo "Make backups before continuing"
  echo "Continue at your own risk"
  echo
  echo "Press CTRL + C to stop the script now"
  tput sgr0
  echo
  for i in $(seq 10 -1 0); do
    echo -ne "Continuing in $i seconds... \r"
    sleep 1
  done
  echo
fi

echo
echo "##################################################################"
tput setaf 2
echo "Phase 1: "
echo "- Setting General parameters"
tput sgr0
echo "##################################################################"
echo

  arcaneVersion='v26.02.03.01'

  isoLabel='arcane-'$kiroVersion'-x86_64.iso'

  # setting the general parameters
  archisoRequiredVersion="archiso 84-1"
  buildFolder=$HOME"/arcane-build"
  outFolder=$HOME"/arcane-out"

echo
echo "##################################################################"
tput setaf 2
echo "Phase 2: "
echo "- Deleting the build folder if one exists"
echo "- Copying the Archiso folder to build folder"
tput sgr0
echo "##################################################################"
echo

  remove_buildfolder yes
  echo
  echo "Copying the Archiso folder to build work"
  echo
  mkdir $buildFolder
  cp -r ../archiso $buildFolder/archiso

echo
echo "##################################################################"
tput setaf 2
echo "Phase 3: "
echo "- Building the iso - this can take a while - be patient"
tput sgr0
echo "##################################################################"
echo

  [ -d $outFolder ] || mkdir $outFolder
	cd $buildFolder/archiso/
	sudo mkarchiso -v -w $buildFolder -o $outFolder $buildFolder/archiso/