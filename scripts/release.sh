#!/usr/bin/env bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
TOP=$DIR/..

set -e

version=$( node -e "console.log(require('$TOP/package.json').version)" )
pkg_name=$( node -e "console.log(require('$TOP/package.json').name)" )
name=$pkg_name-$version
repo=$TOP/build/$name

pushd $TOP
composer install --no-dev
composer dump-autoload --optimize
#npm install
npm run build

rm -rf $repo || true
mkdir -p $repo

for item in "$TOP/cache" "$TOP/src" "$TOP/public" "$TOP/vendor" "$TOP/twig"
do
    echo $item
    cp -R $item $repo/
done

for item in "$TOP/INSTALL.md" "$TOP/LICENSE" "$TOP/README.md" "$TOP/boot.php" "$TOP/config.example.ini" "$TOP/package.json"
do
    echo $item
    cp $item $repo/
done

rm -rf $repo/public/less
rm -rf $repo/public/scss
rm -rf $repo/public/js

zipname=$TOP/build/$name.zip
rm -rf $zipname
pushd $repo
zip -r $TOP/build/$name.zip * .*
popd

RELEASE=$TOP/build/release
rm -rf $RELEASE || true
mv $repo $RELEASE
cp $TOP/config.ini $RELEASE || true
cp -R $TOP/git-test $RELEASE/ || true

popd