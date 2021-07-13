#!/usr/bin/env bash

# specify manually
VER_ROCKET_CHAT='3.16.2'

# update automatically
VER_BASE_IMAGE='12.22.1-buster-slim'
VER_METEOR='2.1.1'

THIS_SCRIPT='build.sh'
DOCKERFILE_BUILD='DockerfileBuild'
DOCKERFILE_RUNTIME='DockerfileRuntime'
DOCKERFILE_DEV='DockerfileDev'
DOCKER_ENTRYPOINT='docker-entrypoint.sh'

# move to script folder
DIR_SCRIPT="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
DIR_RESTORE=$(pwd)
cd "$DIR_SCRIPT" || exit 1

# <<<<<<< Script Start
TMP_VER_BASE_VER_BASE_IMAGE="$(curl -s "https://raw.githubusercontent.com/RocketChat/Rocket.Chat/$VER_ROCKET_CHAT/.docker/Dockerfile" | grep -oP 'FROM node:\K(.+)')"
VER_BASE_IMAGE=${TMP_VER_BASE_VER_BASE_IMAGE:-$VER_BASE_IMAGE}
TMP_VER_METEOR="$(curl -s "https://raw.githubusercontent.com/RocketChat/Rocket.Chat/$VER_ROCKET_CHAT/.meteor/release" | grep -oP 'METEOR@\K(.+)')"
VER_METEOR=${TMP_VER_METEOR:-$VER_METEOR}

# update versions
echo "node@$VER_BASE_IMAGE, Rocket.Chat@$VER_ROCKET_CHAT, Meteor@$VER_METEOR"
for f in $DOCKERFILE_BUILD $DOCKERFILE_RUNTIME $DOCKERFILE_DEV; do
  sed -i "s/FROM node:.*/FROM node:$VER_BASE_IMAGE/" $f
  sed -i "s/\(install.meteor.com\/?release\)=[^ ]*/\1=$VER_METEOR/" $f
  sed -i "s/RC_VERSION=[^ ]*/RC_VERSION=$VER_ROCKET_CHAT/" $f
  sed -i "s/--branch [^ ]* \(.*\/Rocket.Chat \)/--branch $VER_ROCKET_CHAT \1/" $f
done
sed -i "s/\(FROM node:.*\)-slim/\1/" $DOCKERFILE_DEV  # use normal debian for dev env
sed -i "0,/VER_BASE_IMAGE=.*/s/VER_BASE_IMAGE=.*/VER_BASE_IMAGE='$VER_BASE_IMAGE'/" $THIS_SCRIPT
sed -i "0,/VER_METEOR=.*/s/VER_METEOR=.*/VER_METEOR='$VER_METEOR'/" $THIS_SCRIPT
sed -i "s/louissung\/rc:runtime-[^ ]*/louissung\/rc:runtime-$VER_ROCKET_CHAT/" $DOCKER_ENTRYPOINT
sed -i "s/louissung\/rc:dev-[^ ]*/louissung\/rc:dev-$VER_ROCKET_CHAT/" $DOCKER_ENTRYPOINT

# build images
# comment out to copy bundle from the image
docker build -t "louissung/rc:build-$VER_ROCKET_CHAT" -f $DOCKERFILE_BUILD .
docker build -t "louissung/rc:dev-$VER_ROCKET_CHAT" -f $DOCKERFILE_DEV .
# rm -rf app/bundle && mkdir -p app/bundle && docker run --name rc-bundle -v "$(pwd)/../app/bundle:/appBundle" "louissung/rc:dev-$VER_ROCKET_CHAT" bash -c 'cp -r /app/bundle/. /appBundle && chmod -R o+w /appBundle' && docker rm rc-bundle
#docker build -t "louissung/rc:runtime-$VER_ROCKET_CHAT" -f $DOCKERFILE_RUNTIME .

# >>>>>>> Script End
cd "$DIR_RESTORE" || exit 1
