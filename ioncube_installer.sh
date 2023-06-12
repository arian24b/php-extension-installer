#!/usr/bin/env bash

########################################################################
## Scipts: IonCube installer on CloudPanel                            ##
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
IONCUBE_FILE_NAME=ioncube_loaders_lin_x86-64.zip
IONCUBE_FILE_URL=https://downloads.ioncube.com/loader_downloads/$IONCUBE_FILE_NAME
TMPDIR=$(mktemp -d)

clear

green_msg "Welcome to IonCube Installer on directadmin."
yellow_msg "###############################################################################"

# Download and extraxt files
green_msg "Download and extraxt IonCube files to $TMPDIR"
wget --tries=0 --retry-connrefused --timeout=180 -x --no-cache --no-check-certificate $IONCUBE_FILE_URL -O $TMPDIR/$IONCUBE_FILE_NAME >/dev/null 2>&1
unzip -o $TMPDIR/$IONCUBE_FILE_NAME -d $TMPDIR >/dev/null 2>&1

for PHP_VERTION in $(grep -e php[1234]_release /usr/local/directadmin/custombuild/options.conf | cut -d "=" -f "2" | grep -v no)
do
  #dot vertion to no dot version (7.4 => 74)
  #PHP_VERTION=$1
  A=${PHP_VERTION//\./}
  PHP_VERTION_NO_DOT="${A[@]}"

  EXTENSION_INI=/usr/local/php$PHP_VERTION_NO_DOT/lib/php.conf.d/extensions.ini
  PHP_INI=/usr/local/php$PHP_VERTION_NO_DOT/lib/php.ini
  DIRECTADMIN_INI=/usr/local/php$PHP_VERTION_NO_DOT/lib/php.conf.d/10-directadmin.ini
  WEBAPPS_INI=/usr/local/php$PHP_VERTION_NO_DOT/lib/php.conf.d/50-webapps.ini

  touch $EXTENSION_INI $PHP_INI $DIRECTADMIN_INI $WEBAPPS_INI

  #remove extension from ini files
  sed -i -r '/ioncube_loader_lin/d' $EXTENSION_INI $PHP_INI $DIRECTADMIN_INI $WEBAPPS_INI >/dev/null 2>&1

  #check and add extension in ini files
  if [[ ! "$(grep -P "ioncube_loader_lin_"  $EXTENSION_INI $PHP_INI $DIRECTADMIN_INI $WEBAPPS_INI >/dev/null 2>&1)" ]]; then
    INI=$EXTENSION_INI
    echo "add zend_extension=/usr/local/lib/ioncube/ioncube_loader_lin_$PHP_VERTION.so to $INI"
    echo zend_extension=/usr/local/lib/ioncube/ioncube_loader_lin_$PHP_VERTION.so >> $INI
  fi
done

yellow_msg "###############################################################################"
green_msg "Installation done, restart PHP Handler and WebServer"
