#!/usr/bin/env bash

########################################################################
## Scipts: sourcegurdian installer on CloudPanel                      ##
## Code By: Arian Omrani                                              ##
## Repository: https://github.com/arian24b/php-extension-installer    ##
########################################################################

# Red, Green & Yellow Messages.
red_msg() {
  tput setaf 1
  echo "[*] ----- $1"
  tput sgr0
}

green_msg() {
  tput setaf 2
  echo "[*] ----- $1"
  tput sgr0
}

yellow_msg() {
  tput setaf 3
  echo "[*] ----- $1"
  tput sgr0
}

# Show an error and exit
abort() {
  red_msg "Please check log and run scripts with -x for Debug."
  red_msg "$1"
  exit 2
}

# Check if running as root or not!
if [[ $EUID -ne 0 ]]; then
  clear
  abort "This script needs to be run with superuser privileges.";
fi

# Remove dot in number (7.4 => 74)
remove_dot() {
  # Get 7.4 and echo 74
  # Use this:
  #   PHP_VERTION_NO_DOT=$(remove_dot $PHP_VERTION)
  A=$1
  B=${A//\./}
  echo "${b[@]}"
}

find_extension_dir() {
  echo $(php$1 -i | grep "extension_dir => /" | cut -d " " -f 5)
}

# Declare Paths & Settings.
SOURCE_GUARDIAN_FILE_NAME=SourceGuardian-loaders.linux-x86_64-14.0.2.zip
SOURCE_GUARDIAN_FILE_URL=https://github.com/arian24b/php-extension-installer/raw/main/files/$SOURCE_GUARDIAN_FILE_NAME
TMPDIR=$(mktemp -d)

clear

green_msg "Welcome to SourceGurdian Installer on CloudPanel."
yellow_msg "###############################################################################"

# Download and extraxt files
green_msg "Download and extraxt SourceGurdian files to $TMPDIR"
wget --tries=0 --retry-connrefused --timeout=180 -x --no-cache --no-check-certificate -O $TMPDIR/$SOURCE_GUARDIAN_FILE_NAME $SOURCE_GUARDIAN_FILE_URL >/dev/null 2>&1
unzip -o $TMPDIR/$SOURCE_GUARDIAN_FILE_NAME -d $TMPDIR >/dev/null 2>&1

for PHP_VERTION in $(ls -1 /etc/php/)
do
  EXTENSION_DIR=$(find_extension_dir $PHP_VERTION)
  EXTENSION_NAME=ixed.$PHP_VERTION.lin
  PHP_CLI_INI=/etc/php/$PHP_VERTION/cli/php.ini
  PHP_FPM_INI=/etc/php/$PHP_VERTION/fpm/php.ini

  rm -f $EXTENSION_DIR/$EXTENSION_NAME

  mv $TMPDIR/$EXTENSION_NAME $EXTENSION_DIR

  #remove extension from ini files
  sed -i -r '/ixed\.[0-9]+\.[0-9]+\.lin/d' $PHP_CLI_INI $PHP_FPM_INI >/dev/null 2>&1

  #check and add extension in ini files
  if [[ -f $EXTENSION_DIR/$EXTENSION_NAME ]]; then
    for PHP_INI in $PHP_CLI_INI $PHP_FPM_INI
    do
    green_msg "extension=$EXTENSION_NAME adding to $PHP_INI"
    echo "extension=$EXTENSION_NAME" >> $PHP_INI
    done
  fi
done

rm -rf $TMPDIR

yellow_msg "###############################################################################"
green_msg "Installation done, restart PHP Handler and WebServer"
