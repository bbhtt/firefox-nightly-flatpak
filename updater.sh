#!/usr/bin/env sh

set -e

update () {

	relnum1=$(awk '/x86_64.tar.*/{print NR; exit}' "$MANIFEST_PATH")
	relnum2=$(awk '/aarch64.tar.*/{print NR; exit}' "$MANIFEST_PATH")
	vernum=$(awk '/VERSION:/{print NR; exit}' "$MANIFEST_PATH")
	shanum1=$(awk '/sha256/{print NR}' "$MANIFEST_PATH"|tail -n2|head -1)
	shanum2=$(awk '/sha256/{print NR}' "$MANIFEST_PATH"|tail -n1)
	oldrelease1=$(sed "${relnum1}!d" "$MANIFEST_PATH"|sed -n '{s|.*/firefox-\(.*\)\.tar.*|\1|p;q;}')
	oldrelease2=$(sed "${relnum2}!d" "$MANIFEST_PATH"|sed -n '{s|.*/firefox-\(.*\)\.tar.*|\1|p;q;}')
	newrelease1=$(curl -I -s -L "https://download.mozilla.org/?product=firefox-nightly-latest-ssl&os=linux64&lang=en-US"| sed -n '/Location: /{s|.*/firefox-\(.*\)\.tar.*|\1|p;q;}')
	newrelease2=$(curl -I -s -L "https://download.mozilla.org/?product=firefox-nightly-latest-ssl&os=linux64-aarch64&lang=en-US"| sed -n '/Location: /{s|.*/firefox-\(.*\)\.tar.*|\1|p;q;}')
	sed -i "${relnum1}s/$oldrelease1/$newrelease1/g" "$MANIFEST_PATH"
	sed -i "${relnum2}s/$oldrelease2/$newrelease2/g" "$MANIFEST_PATH"
	updrelease1=$(sed "${relnum1}!d" "$MANIFEST_PATH"|sed -n '{s|.*/firefox-\(.*\)\.tar.*|\1|p;q;}')
	updrelease2=$(sed "${relnum2}!d" "$MANIFEST_PATH"|sed -n '{s|.*/firefox-\(.*\)\.tar.*|\1|p;q;}')
	versionold=$(echo "$oldrelease1"|head -c 7)
	versionnew=$(echo "$updrelease1"|head -c 7)
	sed -i "${vernum}s/VERSION: $versionold/VERSION: $versionnew/g" "$MANIFEST_PATH"
	curl -s -O https://download-installer.cdn.mozilla.net/pub/firefox/nightly/latest-mozilla-central/firefox-"$updrelease1".checksums
	curl -s -O https://download-installer.cdn.mozilla.net/pub/firefox/nightly/latest-mozilla-central/firefox-"$updrelease2".checksums
	shanew1=$(grep "$updrelease1".tar.xz < firefox-"$updrelease1".checksums|grep -v asc|grep -v sha512|cut -d " " -f1)
	shaold1=$(sed "${shanum1}!d" "$MANIFEST_PATH"|cut -d: -f2|sed 's/^[ \t]*//;s/[ \t]*$//')
	sed -i "${shanum1}s/$shaold1/$shanew1/g" "$MANIFEST_PATH"
	shanew2=$(grep "$updrelease2".tar.xz < firefox-"$updrelease2".checksums|grep -v asc|grep -v sha512|cut -d " " -f1)
	shaold2=$(sed "${shanum2}!d" "$MANIFEST_PATH"|cut -d: -f2|sed 's/^[ \t]*//;s/[ \t]*$//')
	sed -i "${shanum2}s/$shaold2/$shanew2/g" "$MANIFEST_PATH"
	rm -- *.checksums

}

if [ -z "$CI_PROJECT_DIR" ]; then
	export APP_ID=org.mozilla.FirefoxNightly
	export MANIFEST_PATH="$PWD"/"$APP_ID".yaml
else
	export MANIFEST_PATH="$CI_PROJECT_DIR"/"$APP_ID".yaml
fi

if [ ! -f "$MANIFEST_PATH" ]; then
	echo "Manifest not found in current working directory"
	exit 1
else
	update
fi
