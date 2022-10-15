### Unofficial Firefox Nightly flatpak

## Install

1. Install [flatpak]([https://flatpak.org/setup/) (>=0.11.1), [xdg-desktop-portal](https://github.com/flatpak/xdg-desktop-portal) and its [backends](https://github.com/flatpak/xdg-desktop-portal#using-portals). Latest versions are preferred.

2. Add the Flathub repository

```bash
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
```

3. Install `ffmpeg-full` (necessary for codec support)

```bash
flatpak install org.freedesktop.Platform.ffmpeg-full//22.08
```

4. Install this package

```bash
flatpak install --user https://gitlab.com/bbhtt/firefox-nightly-flatpak/-/raw/main/firefox-nightly.flatpakref
```

This sets up a new [flatpak remote](https://man7.org/linux/man-pages/man5/flatpak-remote.5.html) called `firefoxnightly-origin`

## Update

Updates will be fetched if available

```bash
flatpak update
```

## Uninstall

```bash
flatpak remove --delete-data org.mozilla.FirefoxNightly
flatpak remote-delete firefoxnightly-origin
```

## Notes

This package tries to stay close to Mozilla's official packaging and no modifications/preferences are applied beyond what is necessary for having a working flatpak.

The profile location is `~/.var/app/org.mozilla.FirefoxNightly/.mozilla/firefox`

The flatpak is built from the official Nightly tarball published by Mozilla. The search provider, desktop file and run script is taken from [Fedora](https://src.fedoraproject.org/rpms/firefox.git); manifest, preferences, polices and appstream metadata, wrapper are taken from [Mozilla](https://hg.mozilla.org/mozilla-central/file/tip/taskcluster/docker/firefox-flatpak). The only difference in permissions is `--socket=x11` is not exposed rather `--socket=fallback-x11` is exposed.

Native Wayland with `MOZ_ENABLE_WAYLAND=1` is enabled if the desktop environment is GNOME/KDE/Sway and if the `WAYLAND_DISPLAY` variable is set.

There are no plans for aarch64 builds. Mozilla does not publish tarballs for aarch64 and building from source is not possible.

## Bugs

Check if it is already a known issue first https://bugzilla.mozilla.org/show_bug.cgi?id=flatpak

Check if it is reproducible in the official tarball (preferably in a new profile or safe mode). If it is, open a bug with Mozilla, optionally use [mozregression](https://mozilla.github.io/mozregression/quickstart.html) to bisect it.

Common troubleshooting help https://fedoraproject.org/wiki/How_to_debug_Firefox_problems

Otherwise feel free to open an issue here.

## Credits

Original project: https://gitlab.com/proletarius101/firefox-nightly-flatpak

## Set up personal repo

1. Fork https://gitlab.com/proletarius101/firefox-nightly-flatpak and https://gitlab.com/accessable-net/gitlab-ci-templates/

2. Clone https://gitlab.com/proletarius101/firefox-nightly-flatpak and update the URLs in `.gitlab-ci.yml` to point to the fork. Update other files if needed.

3. Create a new GPG key locally, to sign the repository.

4. Go to https://gitlab.com/-/profile/personal_access_tokens, create a token for `$CI_GIT_TOKEN`.

5. Go to `https://gitlab.com/<user>/<project>/-/settings/ci_cd`, expand `General` and disable public pipeline. Hit save.

Expand variables. Add the following [variables](https://docs.gitlab.com/ee/ci/variables/#add-a-cicd-variable-to-a-project) necessary for the pipeline to run:

| Type     | Key            | Value                 | Protected | Masked   |
|----------|----------------|-----------------------|-----------|----------|
| Variable | GPG_KEY_GREP   | Keygrip of GPG key    | Yes       | Optional |
| Variable | GPG_KEY_ID     | Keyid of GPG key      | Yes       | Optional |
| File     | GPG_PASSPHRASE | Passphrase of GPG Key | Yes       | Optional |
| File     | GPG_PRIVATE_KEY| ASCII armoured private key | Yes  | Optional |
| Variable | CI_GIT_TOKEN   | Token                 | Yes       | Optional |

6. Make a push or trigger the pipeline. If successful, a page wall be deployed at `https://username.gitlab.io/firefox-nightly-flatpak`

7. Edit the flatpakref file: `Url` should be URL of the above Gitlab page and `GPGKey` is base64 encoded version of the gpg key:

```bash
gpg --export <keyid> > example.gpg
base64 example.gpg | tr -d '\n'
```

8. Set up a [schedule](https://docs.gitlab.com/ee/ci/pipelines/schedules.html) `https://gitlab.com/<username>/<project>/-/pipeline_schedules`

9. Install the flatpakref file as in step #4. Done!
