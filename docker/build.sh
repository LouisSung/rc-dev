#!/usr/bin/env bash

# specify manually
VER_ROCKET_CHAT='3.16.1'

# update automatically
VER_BASE='12.22.1-buster-slim'
VER_METEOR='2.1.1'
VER_APPS_ENGINE='1.27.0'

THIS_SCRIPT='build.sh'
DOCKERFILE_BUILD='DockerfileBuild'
DOCKERFILE_RUNTIME='DockerfileRuntime'
DOCKERFILE_DEV='DockerfileDev'
DOCKER_ENTRYPOINT='docker-entrypoint.sh'
TMP_DOCKERFILE='.DockerfileTmp'
TMP_METEOR_RELEASE='.MeteorRelease'
TMP_PACKAGE_JSON='.PackageJson'

# move to script folder
DIR_SCRIPT="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
DIR_RESTORE=$(pwd)
cd "$DIR_SCRIPT" || exit 1

# <<<<<<< Script Start
curl -s "https://raw.githubusercontent.com/RocketChat/Rocket.Chat/$VER_ROCKET_CHAT/.docker/Dockerfile" > $TMP_DOCKERFILE
TMP_VER_BASE="$(cat < $TMP_DOCKERFILE | grep -oP 'FROM node:\K(.+)')"
VER_BASE=${TMP_VER_BASE:-$VER_BASE}
curl -s "https://raw.githubusercontent.com/RocketChat/Rocket.Chat/$VER_ROCKET_CHAT/.meteor/release" > $TMP_METEOR_RELEASE
TMP_VER_METEOR="$(cat < $TMP_METEOR_RELEASE | grep -oP 'METEOR@\K(.+)')"
VER_METEOR=${TMP_VER_METEOR:-$VER_METEOR}
curl -s "https://raw.githubusercontent.com/RocketChat/Rocket.Chat/$VER_ROCKET_CHAT/package.json" > $TMP_PACKAGE_JSON
TMP_VER_APPS_ENGINE="$(cat < $TMP_PACKAGE_JSON | grep -oP '"@rocket.chat/apps-engine": "\K([^"]+)')"
VER_APPS_ENGINE=${TMP_VER_APPS_ENGINE:-$VER_APPS_ENGINE}
rm $TMP_DOCKERFILE $TMP_METEOR_RELEASE $TMP_PACKAGE_JSON

# update versions
echo "node@$VER_BASE, Rocket.Chat@$VER_ROCKET_CHAT, Meteor@$VER_METEOR, Apps Engine@$VER_APPS_ENGINE"
for f in $DOCKERFILE_BUILD $DOCKERFILE_RUNTIME $DOCKERFILE_DEV; do
  sed -i "s/FROM node:.*/FROM node:$VER_BASE/" $f
  sed -i "s/\(install.meteor.com\/?release\)=[^ ]*/\1=$VER_METEOR/" $f
  sed -i "s/RC_VERSION=[^ ]*/RC_VERSION=$VER_ROCKET_CHAT/" $f
  sed -i "s/--branch [^ ]* \(.*\/Rocket.Chat \)/--branch $VER_ROCKET_CHAT \1/" $f
  sed -i "s/--branch v[^ ]* \(.*\/Rocket.Chat.Apps-engine \)/--branch v$VER_APPS_ENGINE \1/" $f
done
sed -i "s/\(FROM node:.*\)-slim/\1/" $DOCKERFILE_DEV  # use normal debian for dev env
sed -i "0,/VER_BASE=.*/s/VER_BASE=.*/VER_BASE='$VER_BASE'/" $THIS_SCRIPT
sed -i "0,/VER_METEOR=.*/s/VER_METEOR=.*/VER_METEOR='$VER_METEOR'/" $THIS_SCRIPT
sed -i "0,/VER_APPS_ENGINE=.*/s/VER_APPS_ENGINE=.*/VER_APPS_ENGINE='$VER_APPS_ENGINE'/" $THIS_SCRIPT
sed -i "s/louissung\/rc:runtime-[^ ]*/louissung\/rc:runtime-$VER_ROCKET_CHAT/" $DOCKER_ENTRYPOINT
sed -i "s/louissung\/rc:dev-[^ ]*/louissung\/rc:dev-$VER_ROCKET_CHAT/" $DOCKER_ENTRYPOINT

# build images
docker build -t "louissung/rc:dev-$VER_ROCKET_CHAT" -f $DOCKERFILE_DEV .
# comment out to copy bundle from the image
# rm -rf ../app/bundle && mkdir -p ../app/bundle && docker run --name rc-bundle -v "$(pwd)/../app/bundle:/appBundle" "louissung/rc:dev-$VER_ROCKET_CHAT" bash -c 'cp -r /root/app/bundle/. /appBundle && chmod -R o+w /appBundle' && docker rm rc-bundle
docker build -t "louissung/rc:build-$VER_ROCKET_CHAT" -f $DOCKERFILE_BUILD .
docker build -t "louissung/rc:runtime-$VER_ROCKET_CHAT" -f $DOCKERFILE_RUNTIME .

# >>>>>>> Script End
cd "$DIR_RESTORE" || exit 1
