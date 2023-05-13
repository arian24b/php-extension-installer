#!/usr/bin/env bash
########################################################################
## Scipts: sourcegurdian installer                                    ##
## Code By: Arian Omrani                                              ##
## Repository: https://github.com/arianomrani/php-extension-installer ##
########################################################################

clear

echo "Welcome to SourceGurdian Installer"
echo -e "\E[0m\E[01;31m\033[5m###############################################################################\E[0m"

# Show an error and exit
abort() {
  echo -e "\E[0m\E[01;31m\033[5mPlease check log and run scripts with -x.\E[0m"
  echo -e "\E[0m\E[01;31m\033[5m$1\E[0m"
  exit 1
}

#dot vertion to no dot version (7.4 => 74)
PHP_VERTION=$1
A=${PHP_VERTION//\./}
PHP_VERTION_NO_DOT="${A[@]}"

EXTENSION_INI=/usr/local/php$PHP_VERTION_NO_DOT/lib/php.conf.d/extensions.ini
PHP_INI=/usr/local/php$PHP_VERTION_NO_DOT/lib/php.ini
DIRECTADMIN_INI=/usr/local/php$PHP_VERTION_NO_DOT/lib/php.conf.d/10-directadmin.ini
WEBAPPS_INI=/usr/local/php$PHP_VERTION_NO_DOT/lib/php.conf.d/50-webapps.ini

SOURCE_GUARDIAN_FILE_NAME=SourceGuardian-loaders.linux-x86_64-14.0.2.zip
SOURCE_GUARDIAN_FILE_URL=https://github.com/arianomrani/php-extension-installer/raw/main/files/$SOURCE_GUARDIAN_FILE_NAME

TMPDIR=$(mktemp -d)
SG_PATH=/usr/local/lib/sourcegurdian

mkdir -p $SG_PATH
rm -f $SG_PATH/*
touch $EXTENSION_INI

#download sourcegurdian file and extraxt
echo "Download and extraxt SourceGurdian files to $SG_PATH"
wget --tries=0 --retry-connrefused --show-progress --timeout=180 -x --no-cache --no-check-certificate $SOURCE_GUARDIAN_FILE_URL -O $TMPDIR/$SOURCE_GUARDIAN_FILE_NAME >/dev/null 2>&1
unzip -o $TMPDIR/$SOURCE_GUARDIAN_FILE_NAME -d $SG_PATH >/dev/null 2>&1
rm -rf $TMPDIR

#remove extension from ini files
sed -i -r '/extension=ixed/d' $EXTENSION_INI $PHP_INI $DIRECTADMIN_INI $WEBAPPS_INI

#check and add extension in ini files
if [[ ! "$(grep -P "ixed.\d+\.\d+.lin"  $EXTENSION_INI $PHP_INI $DIRECTADMIN_INI $WEBAPPS_INI)" ]]; then
  INI=$EXTENSION_INI
  echo "add extension=$SG_PATH/ixed.$PHP_VERTION.lin to $INI"
  echo extension=$SG_PATH/ixed.$PHP_VERTION.lin >> $INI
fi

echo "done, restart handler and webserver"
echo -e "\E[0m\E[01;31m\033[5m###############################################################################\E[0m"
