#!/bin/sh

export MANIFEST_PATH=$CI_PROJECT_DIR/$APP_ID.yaml

#export MANIFEST_PATH=org.mozilla.FirefoxNightly.yaml

# Extract the filename for the old release
sed '153!d' $MANIFEST_PATH|sed -n '{s|.*/firefox-\(.*\)\.tar.bz2|\1|p;q;}' > oldrelease;

# Extract the filename for the new release
wget -nv --spider -S --max-redirect 0 "https://download.mozilla.org/?product=firefox-nightly-latest-ssl&os=linux64&lang=en-US" 2>&1 | sed -n '/Location: /{s|.*/firefox-\(.*\)\.tar.*|\1|p;q;}' > newrelease;

# Replace the filename to update the url
newrelease=$(cat newrelease) && oldrelease=$(cat oldrelease) && sed -i "153s/$oldrelease/$newrelease/g" $MANIFEST_PATH;

# Extract the filename again in case of an update
sed '153!d' $MANIFEST_PATH|sed -n '{s|.*/firefox-\(.*\)\.tar.bz2|\1|p;q;}' > updrelease;

# Download the latest version
wget -nv https://download-installer.cdn.mozilla.net/pub/firefox/nightly/latest-mozilla-central/firefox-$(cat updrelease).checksums;
# Calculate the new checksum
cat firefox-$(cat updrelease).checksums|grep "$(cat updrelease).tar.bz2"|grep -v asc|grep -v sha512|cut -d " " -f1 > shanew;

# Calculate the old checksum
sed '154!d' $MANIFEST_PATH|cut -d: -f2|sed 's/^[ \t]*//;s/[ \t]*$//' > shaold;

# Replace the checksum
shanew=$(cat shanew) && shaold=$(cat shaold) && sed -i "154s/$shaold/$shanew/g" $MANIFEST_PATH;

# Delete the leftovers
rm *release sha* *.checksums;
