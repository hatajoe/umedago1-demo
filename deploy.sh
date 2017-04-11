#!/bin/sh

HARBOR_DOMAIN=localhost:9999
PROJECT_NAME=umedago

BRANCH=$(git rev-parse --abbrev-ref HEAD)

# get deploy workspace
RES=`curl -XGET http://$HARBOR_DOMAIN/br?name=$PROJECT_NAME\&branch=$BRANCH`
WORK=`echo ${RES} | jq -r '.work'`

# deploy
mkdir -p ${WORK}
rsync -rv --exclude=.git /Users/hatajoe/src/github.com/hatajoe/umedago/* ${WORK}

# harbor /up
FLG=1
curl -XPOST -d "payload={\"name\":\"$PROJECT_NAME\", \"branch\":\"$BRANCH\"}" http://$HARBOR_DOMAIN/up

while [ $FLG == 1 ]
do
	sleep 1
    exit;
	RES=`curl -XGET http://$HARBOR_DOMAIN/br?name=$PROJECT_NAME\&branch=$BRANCH`
	if [ $? == 0 ]; then
		STATE=`echo $RES | jq -r '.state'`
		if [ "$STATE" == "2" ]; then
			FLG=2
		fi
	fi
done
