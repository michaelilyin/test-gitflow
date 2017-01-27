#!/usr/bin/env bash

# This script is used for update versions in project build files.

# Version must be specified in call arguments.
VERSION_FOR_UPDATE=$1

#
# First update maven versions.
#

# Main parent for maven projects.
MAIN_PARENT=:main-parent

# First of all install parent project for register current version in local maven repository.
# This is required because we will build child project referred on old version.
mvn clean install -pl $MAIN_PARENT

# Set new version for parent project.
mvn versions:set -DnewVersion=$VERSION_FOR_UPDATE -pl $MAIN_PARENT
if [ $? -ne 0 ]; then
    # Check operation result here. If version update fails break current gitflow process.
	echo Can not udpate version for parent. Abort.
	exit 1
fi

# Install parent project again (with new version)
mvn clean install -pl $MAIN_PARENT

# Update child modules and set current parent version on them
mvn versions:update-child-modules
if [ $? -ne 0 ]; then
    # Check operation result here. If version update fails break current gitflow process.
	echo Can not udpate version for parent. Abort.
	exit 1
fi

# At last "commit" version update (all backup files will be removed, no one get commits will be performed)
mvn versions:commit

#
# Next update npm project versions.
#

# We need to check that specified version required to semver specification.
VERSION_REGEX=[0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*

# Get length of satisfied string.
LEN=$(expr match $VERSION_FOR_UPDATE $VERSION_REGEX)
if [ $LEN -gt 0 ]; then
    # if version satisfied for regex completely or partially (0.0.0.0-SNAPSHOT or 0.0.0.0 not 0.0.0)
    # we get substring of satisfied part from specified version string.
	VERSION_FOR_NPM=$(expr substr $VERSION_FOR_UPDATE 1 $LEN)
	# update "verion" property in "package.json" files
	sed -i -- "s/\"version\":\s*\".*\"/\"version\": \"$VERSION_FOR_NPM\"/g" client/package.json
	sed -i -- "s/\"version\":\s*\".*\"/\"version\": \"$VERSION_FOR_NPM\"/g" client-web/package.json
fi

# update "tag" property in "package.json" files wit version string as is.
sed -i -- "s/\"tag\":\s*\".*\"/\"tag\": \"$VERSION_FOR_UPDATE\"/g" client/package.json
sed -i -- "s/\"tag\":\s*\".*\"/\"tag\": \"$VERSION_FOR_UPDATE\"/g" client-web/package.json

#
# Next commit all changes to git.
#

# Add changed files for commit and commit them.
git add */pom.xml
git add */**/pom.xml
git add pom.xml
git add client/package.json
git add client-web/package.json
git commit -m "Update project version to $VERSION_FOR_UPDATE"