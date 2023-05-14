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

IONCUBE_FILE_NAME=ioncube_loaders_lin_x86-64.zip
IONCUBE_FILE_URL=https://downloads.ioncube.com/loader_downloads/$IONCUBE_FILE_NAME

TMPDIR=$(mktemp -d)
IC_PATH=/usr/local/lib

mkdir -p $IC_PATH
rm -rf $IC_PATH/ioncube

#download ioncube file and extraxt
echo "Download and extraxt IonCube files to $IC_PATH/ioncube"
wget --tries=0 --retry-connrefused --timeout=180 -x --no-cache --no-check-certificate $IONCUBE_FILE_URL -O $TMPDIR/$IONCUBE_FILE_NAME >/dev/null 2>&1
unzip -o $TMPDIR/$IONCUBE_FILE_NAME -d $IC_PATH >/dev/null 2>&1
rm -rf $TMPDIR

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

echo "done, restart handler and webserver"
echo -e "\E[0m\E[01;31m\033[5m###############################################################################\E[0m"
