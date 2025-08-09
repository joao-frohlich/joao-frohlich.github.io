#!/bin/bash

SOURCES_BRANCH="main"
SITE_BRANCH="site"
DEFAULT_COMMIT_MESSAGE="Updated site"
SOURCE_DIR="docs"

if ! [[ -f ./deploy.sh ]]
then
	echo "Check 1 Error: You need to run this script from the directory deploy.sh resides in"
	exit 1
else
	echo "Check 1 OK - running in the right directory"
fi

if ! git status | grep -q -E "(No ramo|On branch) $SOURCES_BRANCH"
then
	echo "Check 2 Error: You need to be in the $SOURCES_BRANCH branch of your repository"
	exit 1
else
	echo "Check 2 OK - running in $SOURCES_BRANCH branch"
fi

read -p "Enter a commit message (defaults to '$DEFAULT_COMMIT_MESSAGE'): " COMMIT_MESSAGE
if [ -z "$COMMIT_MESSAGE" ]
then
	COMMIT_MESSAGE=$DEFAULT_COMMIT_MESSAGE
fi
echo "Using commit message: '$COMMIT_MESSAGE'"

git add -A
git commit -m "$COMMIT_MESSAGE"
git push

cd $SOURCE_DIR
bundle exec jekyll build

cd _site

if ! git status | grep -q -E "(No Ramo|On branch) $SITE_BRANCH"
then
	echo "Check 3 Error: You need to be in the $SITE_BRANCH branch of your repository - exiting - no site checked in"
	exit 1
else
	echo "Check 3 OK - running in $SITE_BRANCH branch"
fi

touch .nojekyll

git add -A
git commit -m "$COMMIT_MESSAGE"
git push

echo "----done----"
