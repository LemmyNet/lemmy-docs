#!/bin/bash
set -e

# generate config docs
pushd lemmy
mkdir ../generated
cargo run -- --print-config-docs >> ../generated/config.hjson
# replace // comments with #
sed -i "s/\/\//#/" ../generated/config.hjson
# remove trailing commas
sed -i "s/,\$//" ../generated/config.hjson
# remove quotes around json keys
sed -i "s/\"//" ../generated/config.hjson
sed -i "s/\"//" ../generated/config.hjson
popd

cargo install mdbook --git https://github.com/Nutomic/mdBook.git --branch localization \
    --rev 0982a82
mdbook build .
