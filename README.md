# AUR bump action

This action can bump the version of an AUR package through GitHub workflows

## Requirements

To be able to perform the push, you need to add an SSH private key with write permission to the given AUR repo.

## Inputs

### `package_name`

**Required** The AUR package name you want to update.

### `commit_username`

**Required** The username to use when creating the new commit.

### `commit_email`

**Required** The email to use when creating the new commit.

### `ssh_private_key`

**Required** Your private key with access to AUR package.

### `new_pkgver`

The new PKGVER to be inserted into the PKGBUILD and .SRCINFO files.

### `dry-run`

A boolean value deciding whether to skip the final push or not

## Example usage

```
name: aur-bump-version

on:
  schedule:
    - cron: '0 0 * * *'

jobs:
  aur-sync:
    runs-on: ubuntu-latest
    steps:
      - name: Sync AUR package with Github release
        uses: pajlada/aur-bump-action@master
        with:
          package_name: chatterino2-nightly-appimage
          commit_username: 'Github Action Bot'
          commit_email: github-action-bot@example.com
          ssh_private_key: ${{ secrets.AUR_SSH_PRIVATE_KEY }}
          extra_dependencies: 'jre-openjdk'
          new_pkgver: 'new-version-2021-05-24'
```
