#!/usr/bin/env bash
########################################################################
## Scipts: IonCube installer                                    ##
## Code By: Arian Omrani                                              ##
## Repository: https://github.com/arianomrani/php-extension-installer ##
########################################################################

clear

echo "Welcome to IonCube Installer"
echo -e "\E[0m\E[01;31m\033[5m###############################################################################\E[0m"

# Show an error and exit
abort() {
  echo -e "\E[0m\E[01;31m\033[5mPlease check log and run scripts with -x.\E[0m"
  echo -e "\E[0m\E[01;31m\033[5m$1\E[0m"
  exit 1
}

EXTENSION_INI=/usr/local/php*/lib/php.conf.d/extensions.ini
PHP_INI=/usr/local/php*/lib/php.ini
DIRECTADMIN_INI=/usr/local/php*/lib/php.conf.d/10-directadmin.ini
WEBAPPS_INI=/usr/local/php*/lib/php.conf.d/50-webapps.ini

IONCUBE_FILE_NAME=ioncube_loaders_lin_x86-64.zip
IONCUBE_FILE_URL=https://downloads.ioncube.com/loader_downloads/$IONCUBE_FILE_NAME

TMPDIR=$(mktemp -d)
IC_PATH=/usr/local/lib/ioncube

mkdir -p $IC_PATH
rm -f $IC_PATH/*
touch $EXTENSION_INI

#download ioncube file and extraxt
echo "Download and extraxt IonCube files to $IC_PATH"
wget --tries=0 --retry-connrefused --show-progress --timeout=180 -x --no-cache --no-check-certificate $IONCUBE_FILE_URL -O $TMPDIR/$IONCUBE_FILE_NAME >/dev/null 2>&1
unzip -o $TMPDIR/$IONCUBE_FILE_NAME -d $IC_PATH >/dev/null 2>&1
rm -rf $TMPDIR

#remove extension from ini files
sed -i -r '/ioncube_loader_lin/d' $EXTENSION_INI $PHP_INI $DIRECTADMIN_INI $WEBAPPS_INI

#check and add extension in ini files
if [[ ! "$(grep -P "ioncube_loader_lin_"  $EXTENSION_INI $PHP_INI $DIRECTADMIN_INI $WEBAPPS_INI)" ]]; then
  INI=$EXTENSION_INI
  echo "add zend_extension=/usr/local/lib/ioncube/ioncube_loader_lin_$PHP_VERTION.so to $INI"
  echo zend_extension=/usr/local/lib/ioncube/ioncube_loader_lin_$PHP_VERTION.so >> $INI
fi

echo "done, restart handler and webserver"
echo -e "\E[0m\E[01;31m\033[5m###############################################################################\E[0m"
