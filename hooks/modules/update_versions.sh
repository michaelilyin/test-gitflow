#!/usr/bin/env bash

VERSION_FOR_UPDATE=$1

mvn versions:set -DnewVersion=$VERSION_FOR_UPDATE
if [ $? -ne 0 ]; then
	echo Can not udpate version for aggregator. Abort.
	exit 1
fi
mvn versions:commit

mvn versions:set -DnewVersion=$VERSION_FOR_UPDATE -pl :parent-parent
if [ $? -ne 0 ]; then
	echo Can not udpate version for parent. Abort.
	exit 1
fi
mvn versions:commit

VERSION_REGEX=[0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*

LEN=$(expr match $VERSION_FOR_UPDATE $VERSION_REGEX)
echo UPDATE NPM VERSION $LEN $VERSION_FOR_UPDATE $VERSION_REGEX
if [ $LEN -gt 0 ]; then
	VERSION_FOR_NPM=$(expr substr $VERSION_FOR_UPDATE, 1, $LEN)
	echo NPM VERSION $VERSION_FOR_NPM
	sed -i -- "s/\"version\":\s*\".*\"/\"version\":\"$VERSION_FOR_NPM\"/g" client/package.json
fi

sed -i -- "s/\"tag\":\s*\".*\"/\"tag\":\"$VERSION_FOR_UPDATE\"/g" client/package.json

git add */pom.xml
git add pom.xml
git add client/package.json
git commit -m "Update project version to $VERSION_FOR_UPDATE"

#return zero because if we continue release there is nothing for commit will be and git commit returns 1
exit 0