#!/usr/bin/env bash

VERSION_FOR_UPDATE=$1

MAIN_PARENT=:main-parent

mvn clean install -pl $MAIN_PARENT
mvn versions:set -DnewVersion=$VERSION_FOR_UPDATE -pl $MAIN_PARENT
if [ $? -ne 0 ]; then
	echo Can not udpate version for parent. Abort.
	exit 1
fi
mvn clean install -pl $MAIN_PARENT

mvn versions:update-child-modules
if [ $? -ne 0 ]; then
	echo Can not udpate version for parent. Abort.
	exit 1
fi
mvn versions:commit

VERSION_REGEX=[0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*

LEN=$(expr match $VERSION_FOR_UPDATE $VERSION_REGEX)
if [ $LEN -gt 0 ]; then
	VERSION_FOR_NPM=$(expr substr $VERSION_FOR_UPDATE 1 $LEN)
	sed -i -- "s/\"version\":\s*\".*\"/\"version\": \"$VERSION_FOR_NPM\"/g" client/package.json
	sed -i -- "s/\"version\":\s*\".*\"/\"version\": \"$VERSION_FOR_NPM\"/g" client-web/package.json
fi

sed -i -- "s/\"tag\":\s*\".*\"/\"tag\": \"$VERSION_FOR_UPDATE\"/g" client/package.json
sed -i -- "s/\"tag\":\s*\".*\"/\"tag\": \"$VERSION_FOR_UPDATE\"/g" client-web/package.json

git add */pom.xml
git add */**/pom.xml
git add pom.xml
git add client/package.json
git add client-web/package.json
git commit -m "Update project version to $VERSION_FOR_UPDATE"