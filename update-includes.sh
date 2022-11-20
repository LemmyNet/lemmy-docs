#!/bin/bash
set -e

LEMMY_VERSION=$(curl "https://raw.githubusercontent.com/LemmyNet/lemmy-ansible/main/VERSION")
if [ ! -d "include/.git" ]
then
  git clone https://github.com/LemmyNet/lemmy.git include
  cd include
else
  cd include
  git checkout main
  git pull
fi
git fetch --tags
git checkout "$LEMMY_VERSION"