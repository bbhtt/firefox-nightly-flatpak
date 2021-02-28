## How to install

````bash
flatpak remote-add --no-gpg-verify firefox-nightly https://proletarius101.gitlab.com/proletarius101/firefox-nightly-flatpak/blob/master/firefox-nightly.flatpakrepo
sudo flatpak install org.mozilla.FirefoxNightly -y
````

> Note: `sudo` is [required](https://docs.flatpak.org/en/latest/flatpak-builder.html#signing) to install/update Firefox Nightly from this repo, since the repo is not GPG signed by me. I haven't found a way to sign the repo unattendedly. But it has to be signed by the CI anyway.