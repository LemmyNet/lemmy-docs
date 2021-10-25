#!/bin/bash
set -e

mkdir -p include/config
mkdir -p include/activitypub
cd include/config
curl https://raw.githubusercontent.com/LemmyNet/lemmy/main/config/defaults.hjson -o defaults.hjson

cd ../activitypub
curl https://raw.githubusercontent.com/LemmyNet/lemmy/main/crates/apub/assets/lemmy-person.json -o lemmy-person.json
curl https://raw.githubusercontent.com/LemmyNet/lemmy/main/crates/apub/assets/lemmy-community.json -o lemmy-community.json
curl https://raw.githubusercontent.com/LemmyNet/lemmy/main/crates/apub/assets/lemmy-post.json -o lemmy-post.json
curl https://raw.githubusercontent.com/LemmyNet/lemmy/main/crates/apub/assets/lemmy-comment.json -o lemmy-comment.json
curl https://raw.githubusercontent.com/LemmyNet/lemmy/main/crates/apub/assets/lemmy-private-message.json -o lemmy-private-message.json
