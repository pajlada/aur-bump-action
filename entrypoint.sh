#!/bin/bash

set -o errexit -o pipefail -o nounset

PACKAGE_NAME=$INPUT_PACKAGE_NAME
COMMIT_USERNAME=$INPUT_COMMIT_USERNAME
COMMIT_EMAIL=$INPUT_COMMIT_EMAIL
SSH_PRIVATE_KEY=$INPUT_SSH_PRIVATE_KEY
DRY_RUN=$INPUT_DRY_RUN
NEW_PKGVER=$INPUT_NEW_PKGVER

HOME=/home/builder

# config ssh
ssh-keyscan -t ed25519 aur.archlinux.org >> $HOME/.ssh/known_hosts
echo -e "${SSH_PRIVATE_KEY//_/\\n}" > $HOME/.ssh/aur
chmod 600 $HOME/.ssh/aur*

# config git
git config --global user.name "$COMMIT_USERNAME"
git config --global user.email "$COMMIT_EMAIL"
AUR_REPO_URL="ssh://aur@aur.archlinux.org/${PACKAGE_NAME}.git"
if [ -z "$SSH_PRIVATE_KEY" ]; then
    >&2 echo "No SSH private key specified, pushing won't be possible. Using https repo instead. Force enabling DRY_RUN"
    DRY_RUN="true"
    AUR_REPO_URL="https://aur.archlinux.org/${PACKAGE_NAME}.git"
fi

>&2 echo " * Cloning repo"
cd /tmp
git clone "$AUR_REPO_URL"
cd "$PACKAGE_NAME"

>&2 echo " * Get current version"

CURRENT_VER=$(grep pkgver .SRCINFO | awk -F '=' '{print $2}' | tr -d "[:space:]")

if [ "$CURRENT_VER" = "$NEW_PKGVER" ]; then
    # Nothing has changed
    >&2 echo " ! Nothing has changed - the current PKGVER and new PKGVER are the same ($CURRENT_VER = $NEW_PKGVER)"
else
    # Modify PKGBUILD
    sed -i "s/pkgver=$CURRENT_VER/pkgver=$NEW_PKGVER/" PKGBUILD

    makepkg --printsrcinfo > .SRCINFO

    if git diff --exit-code; then
        >&2 echo " ! There should have been a change, but there was none. Something is wrong"
        exit 1
    fi

    git add PKGBUILD .SRCINFO
    git commit -m "Update to $NEW_PKGVER"
    if [ "$DRY_RUN" = "true" ]; then
        git --no-pager log -p origin..HEAD
    else
        >&2 echo " ! Pushing change"
        git push
    fi
fi
