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

echo Update client versioins
VERSION_REGEX=[0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*

LEN=$(expr match $VERSION_FOR_UPDATE $VERSION_REGEX)
echo Update version directly, LEN, $VERSION_FOR_UPDATE, $VERSION_REGEX
if [ $LEN -gt 0 ]; then
	echo TRUE
	VERSIONS_FOR_NPM=$(expr substr $VERSION_FOR_UPDATE, 1, $LEN)	
	sed -i -- "s/\"version\":\s*\".*\"/\"version\":\"$VERSION_FOR_UPDATE\"/g" client/package.json
fi

echo Update tag

sed -i -- "s/\"tag\":\s*\".*\"/\"tag\":\"$VERSION_FOR_UPDATE\"/g" client/package.json

git add */pom.xml
git add pom.xml
git add client/package.json
git commit -m "Update project version to $VERSION_FOR_UPDATE"

#return zero because if we continue release there is nothing for commit will be and git commit returns 1
exit 0