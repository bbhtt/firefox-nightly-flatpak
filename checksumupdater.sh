#!/bin/sh

export MANIFEST_PATH=$CI_PROJECT_DIR/$APP_ID.yaml

sed '154!d' $MANIFEST_PATH|grep -Po '\w\K/\w+[^?]+' > url;
wget -nv https://download-installer.cdn.mozilla.net$(cat url);
sha256sum firefox-*.tar.bz2|cut -d " " -f 1 > shanew;
sed '155!d' $MANIFEST_PATH|cut -d: -f2|sed 's/^[ \t]*//;s/[ \t]*$//' > shaold;
shanew=$(cat shanew) && shaold=$(cat shaold) && sed -i "155s/$shaold/$shanew/g" $MANIFEST_PATH;
rm url sha* *.tar.bz2;
