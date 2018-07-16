#!/usr/bin/env bash

set -e

ls -la
echo "Current directory: `pwd`"

# Check if version is new release
SOLC_JS_VERSION=`npm view @shyftnetwork/shyft_solc version`
SOLC_VERSION=`node -e "console.log(require('$TRAVIS_BUILD_DIR/bin/list.json').latestRelease);"`
if [ $SOLC_JS_VERSION == $SOLC_VERSION ]
then
    exit 0
fi
echo 'Found new version of solc'
echo $encrypted_c6ed341a5849_key
echo $encrypted_c6ed341a5849_iv
# Add git ssh key
openssl aes-256-cbc -K $encrypted_c6ed341a5849_key -iv $encrypted_c6ed341a5849_iv -in shyft_deploy_key.enc -out shyft_deploy_key -d
chmod 600 shyft_deploy_key
eval `ssh-agent -s`
ssh-add shyft_deploy_key
echo 'SSH key added'
# Clone solc-js
git clone --depth 2 git@github.com:shyftnetwork/shyft_solc-js.git
cd shyft_solc-js
git config user.name "travis"
git config user.email "david@chainsafe.io"
git clean -f -d -x

# Update package version
npm version patch
NEWVERSION=`node -e "console.log(require('./package.json').version);"`

echo 'New version is $NEWVERSION'

# Call npm publish, prepublish will fetch latest version
npm publish --access=public

echo 'Publish successful'

# Push changes to git
git add package.json
git commit -a -m "Updated to version $NEWVERSION"
git push origin master