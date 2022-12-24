### Unofficial Firefox Nightly flatpak

## Install

1. Install [flatpak](https://flatpak.org/setup/) (>=0.11.1), [xdg-desktop-portal](https://github.com/flatpak/xdg-desktop-portal) and its [backends](https://github.com/flatpak/xdg-desktop-portal#using-portals). Latest versions are preferred.

2. Add the Flathub repository if absent

```bash
flatpak remote-add --user --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
```

3. Install `ffmpeg-full` (necessary for full codec support)

```bash
flatpak install --user flathub org.freedesktop.Platform.ffmpeg-full//22.08
```

4. Install this package

```bash
flatpak install --user https://gitlab.com/projects261/firefox-nightly-flatpak/-/raw/main/firefox-nightly.flatpakref
```

This sets up a new [flatpak remote](https://man7.org/linux/man-pages/man5/flatpak-remote.5.html) called `firefoxnightly-origin` userwide.

## Update

Updates will be fetched if available

```bash
flatpak update
```

## Notes

Gitlab.com free tier gives 400 minutes per month of [pipeline quota](https://about.gitlab.com/blog/2020/09/01/ci-minutes-update-free-users/#changes-to-the-gitlabcom-free-tier) for entire the user/project namespace. A single build usually takes about ~15 minutes to complete and deploy and there is one nightly build published each day. If updates are not available for a while then usually it means the pipeline quota expired for the month and it'll reset in the next month.

Please set up your own repository if possible, following the [instructions](https://gitlab.com/projects261/firefox-nightly-flatpak#set-up-personal-repo) below or build and install the flatpak locally following the [instructions](https://gitlab.com/projects261/firefox-nightly-flatpak#build-locally) below.

## Uninstall

```bash
flatpak remove [--delete-data] org.mozilla.FirefoxNightly
# Clear dependencies
flatpak uninstall --unused
```

## Notes

This package tries to stay close to Mozilla's official packaging and no modifications/preferences are applied beyond what is necessary for having a working flatpak.

The profile location is `~/.var/app/org.mozilla.FirefoxNightly/.mozilla/firefox`

The flatpak is built from the official Nightly tarball published by Mozilla. The search provider, desktop file, run script, manifest, preferences, polices and appstream metadata are taken from [Mozilla](https://hg.mozilla.org/mozilla-central/file/tip/taskcluster/docker/firefox-flatpak).

There are no plans for aarch64 builds. Mozilla does not publish tarballs for aarch64 and building from source is not possible.

## Bugs

Check if it is already a known issue first https://bugzilla.mozilla.org/show_bug.cgi?id=flatpak

Check if it is reproducible in the official tarball (preferably in a new profile or safe mode). If it is, open a bug with Mozilla, optionally use [mozregression](https://mozilla.github.io/mozregression/quickstart.html) to bisect it.

Common troubleshooting help https://fedoraproject.org/wiki/How_to_debug_Firefox_problems

Otherwise feel free to open an issue here.

## Credits

Mozilla for mainlining the stable flatpak recipes.

Original Nightly flatpak project https://gitlab.com/proletarius101/firefox-nightly-flatpak and CI templates https://gitlab.com/accessable-net/gitlab-ci-templates

Logo: [Source](https://www.creativetail.com/40-free-flat-animal-icons/), [License](https://www.creativetail.com/licensing/)

## Set up personal repo

1. Fork https://gitlab.com/projects261/firefox-nightly-flatpak and https://gitlab.com/projects261/gitlab-ci-templates

2. Clone the repostories and update the URLs in `.gitlab-ci.yml` to point to the forks. Update other files if needed.

3. Create a new GPG key locally, to sign the repository.

4. Go to https://gitlab.com/-/profile/personal_access_tokens, create a token for `$CI_GIT_TOKEN`.

5. Go to `https://gitlab.com/<user>/<project>/-/settings/ci_cd`, expand `General` and disable public pipeline. Hit save. Expand variables. Add the following [variables](https://docs.gitlab.com/ee/ci/variables/#add-a-cicd-variable-to-a-project) necessary for the pipeline to run:

   | Type     | Key            | Value                 | Protected | Masked   |
   |----------|----------------|-----------------------|-----------|----------|
   | Variable | GPG_KEY_GREP   | Keygrip of GPG key    | Yes       | Optional |
   | Variable | GPG_KEY_ID     | Keyid of GPG key      | Yes       | Optional |
   | File     | GPG_PASSPHRASE | Passphrase of GPG Key | Yes       | Optional |
   | File     | GPG_PRIVATE_KEY| ASCII armoured private key | Yes  | Optional |
   | Variable | CI_GIT_TOKEN   | Token                 | Yes       | Optional |

6. Make a push or trigger the pipeline. If successful, a page wall be deployed at `https://name.gitlab.io/firefox-nightly-flatpak`

7. Edit the flatpakref file: `Url` should be URL of the above Gitlab page and `GPGKey` is base64 encoded version of the gpg key:

```bash
gpg --export <keyid> > example.gpg
base64 example.gpg | tr -d '\n'
```

8. Set up a [schedule](https://docs.gitlab.com/ee/ci/pipelines/schedules.html) `https://gitlab.com/<name>/<project>/-/pipeline_schedules`

9. Install the flatpakref file as in step #4. Done!

## Notes

My fork uses a script `updater.sh` to update the Firefox versions and checksums and my CI template pushes the changes directly to the `main` branch to save on CI minutes and as the variables above are exposed to the `main` branch only. You can also use `flatpak-external-data-checker` like upstream. For that uncomment [these lines](https://gitlab.com/projects261/firefox-nightly-flatpak/-/blob/main/org.mozilla.FirefoxNightly.yaml#L156-L159) and use the CI templates from [upstream](https://gitlab.com/accessable-net/gitlab-ci-templates). The langpacks are updated manually due to frequent checksum mismatches in the Gitlab shared runners, possible due to a CDN or a cache issue. To automate them uncomment [this](https://gitlab.com/projects261/firefox-nightly-flatpak/-/blob/main/.gitlab-ci.yml#L4)


This can also be done with your own server using Flat-manager, see https://docs.flatpak.org/en/latest/hosting-a-repository.html for instructions.

## Build locally

1. Clone this repository


```bash
git clone https://gitlab.com/projects261/firefox-nightly-flatpak.git
cd firefox-nightly-flatpak
```

2. Install flatpak, [flatpak-builder](https://docs.flatpak.org/en/latest/flatpak-builder.html) and set up the Flathub repository

3. Install the dependencies

```bash
flatpak install --user flathub org.freedesktop.Sdk//22.08
flatpak install --user flathub org.freedesktop.Platform//22.08
flatpak install --user flathub org.mozilla.firefox.BaseApp//22.08
```
3. Run this command to build

```bash
flatpak-builder build --force-clean org.mozilla.FirefoxNightly.yaml
```

4. To install

```bash
flatpak-builder build --force-clean --user --install org.mozilla.FirefoxNightly.yaml
```

5. To update, change this [URL](https://gitlab.com/projects261/firefox-nightly-flatpak/-/blob/main/org.mozilla.FirefoxNightly.yaml#L154) and the [sha256](https://gitlab.com/projects261/firefox-nightly-flatpak/-/blob/main/org.mozilla.FirefoxNightly.yaml#L155) below and redo step #3 and #4

6. (Optional) To build a bundle follow https://docs.flatpak.org/en/latest/single-file-bundles.html

GPG key fingerprint used to sign repo: D53F C6E7 5E0A 45F5 386A  6588 F8A5 F798 CA25 7770
