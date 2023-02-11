#!/usr/bin/env sh

clear
echo "###############################################################################"

# Show an error and exit
abort() {
  echo -e "\E[0m\E[01;31m\033[5m$1\E[0m"
  exit 1
}

PHP_VERTION=$1

#dot vertion to no dot version (7.4 => 74) 
A=${PHP_VERTION//\./}
PHP_VERTION_NO_DOT="${A[@]}"

PHP_INI=/usr/local/php$PHP_VERTION_NO_DOT/lib/php.ini
DIRECTADMIN_INI=/usr/local/php$PHP_VERTION_NO_DOT/lib/php.conf.d/10-directadmin.ini

SOURCE_GUARDIAN_FILE_NAME=SourceGuardian-loaders.linux-x86_64-13.0.3.zip

#remove extension from ini files
sed -i -r '/extension=ixed/d' $PHP_INI 
sed -i -r '/extension=ixed/d' $DIRECTADMIN_INI

#check extension in ini file
if [[ ! "$(grep -P "ixed.\d+\.\d+.lin"  $PHP_INI)" ]] || [[ ! "$(grep -P "ixed.\d+\.\d+.lin"  $DIRECTADMIN_INI)" ]]; then
  #echo "add extension=ixed.$PHP_VERTION_NO_DOT.lin to php.ini"
  echo extension=ixed.$PHP_VERTION.lin >> $DIRECTADMIN_INI
fi

cd /usr/local/php$PHP_VERTION_NO_DOT/lib/php/extensions/no-debug-non-zts-*/

#download sourcegurdian file and extraxt it
#echo "download and extraxt sourcegurdian files"
wget https://bash-files.s3.ir-thr-at1.arvanstorage.ir/$SOURCE_GUARDIAN_FILE_NAME >/dev/null 2>&1
unzip -o $SOURCE_GUARDIAN_FILE_NAME >/dev/null 2>&1

/usr/local/directadmin/custombuild/build set ioncube yes
/usr/local/directadmin/custombuild/build ioncube

echo "done, restart handler and webserver"
