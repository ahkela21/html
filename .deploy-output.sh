#!/bin/bash
set -ev
STATUS=`git log -1 --pretty=oneline`

# Partially based on https://gist.github.com/domenic/ec8b0fc8ab45f39403dd

SOURCE_BRANCH="master"
TARGET_BRANCH="gh-pages"

# Pull requests and commits to other branches shouldn't try to deploy, just build to verify
if [ "$TRAVIS_PULL_REQUEST" != "false" -o "$TRAVIS_BRANCH" != "$SOURCE_BRANCH" ]; then
    echo "Skipping deploy; just doing a build."
    exit 0
fi

# Save some useful information
REPO=`git config remote.origin.url`
SSH_REPO=${REPO/https:\/\/github.com\//git@github.com:}
SHA=`git rev-parse --verify HEAD`

echo $SSH_REPO

# Clone the existing gh-pages for this repo into publish/
# Create a new empty branch if gh-pages doesn't exist yet (should only happen on first deploy)
git clone $REPO publish
cd publish
git checkout $TARGET_BRANCH || git checkout --orphan $TARGET_BRANCH
cd ..

# Clean out existing contents
rm -rf publish/**/* || exit 0

cp single-page.html ./publish/
cp out/* ./publish/
mkdir -p ./publish/fonts
mkdir -p ./publish/images
mkdir -p ./publish/styles
cp fonts/* ./publish/fonts
cp images/* ./publish/images
cp styles/* ./publish/styles
cp entities.dtd ./publish/
cp entities.json ./publish/


# Now let's go have some fun with the cloned repo
cd publish
git init

# Commit the "changes", i.e. the new version.
# The delta will show diffs between new and old versions.
git add -A .
git commit -m "Built by Travis-CI: $STATUS"
git status

# Now that we're all set up, we can push.
git config user.email "$COMMIT_AUTHOR_EMAIL"
git push https://ahkela21:tct1121@github.com/ahkela21/html.git $TARGET_BRANCH
