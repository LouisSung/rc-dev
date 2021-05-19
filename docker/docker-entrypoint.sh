#!/usr/bin/env bash

/usr/sbin/sshd
# mount this entrypoint script to run in production mode
# for ENV set up, see: https://github.com/RocketChat/Docker.Official.Image/blob/master/3.14/Dockerfile
export DEPLOY_METHOD=docker-official MONGO_URL=mongodb://db:27017/meteor HOME=/tmp PORT=3000 ROOT_URL=http://localhost:3000 Accounts_AvatarStorePath=/app/uploads
export MONGO_URL=mongodb://rc-mongo:27017/rocketchat  # change with container hostname (rc-mongo) and database name (rocketchat)
node /root/app/bundle/main.js

# ===== dev mode =====
# docker volume create rc-db
# docker run -idt --name rc-dev -v rc-db:/root/Rocket.Chat/.meteor/local/db -p 2222:22 -p 3000:3000 -p 3001:3001 -p 9229:9229 louissung/rc:dev-3.14.0

# ===== prod mode =====
# docker network create rc-network
# docker volume create rc-uploads
# docker volume create rc-db-prod
# docker run -idt --name rc-mongo --network=rc-network -v rc-db-prod:/data/db -p 3001:27017 mongo:4.4.6-bionic mongod --oplogSize 128 --replSet rs0
# docker exec rc-mongo mongo rc-mongo/rocketchat --eval "rs.initiate({_id: 'rs0', members: [{_id: 0, host: 'localhost:27017'}]})"

# docker run -idt --name rc-prod --network=rc-network -v rc-uploads:/root/app/uploads -v "$(pwd)/docker/docker-entrypoint.sh":/usr/local/bin/docker-entrypoint.sh -p 3000:3000 louissung/rc:dev-3.14.0

# ===== deploy mode =====
# same setup as prod mode (network, volume, and mongodb)
# docker run -idt --name rc-deploy --network=rc-network -v rc-uploads:/app/uploads  -v "$(pwd)/app/bundle:/app/bundle" -p 3000:3000 -e MONGO_URL=mongodb://rc-mongo:27017/rocketchat louissung/rc:base-3.14.0

# ===== useful docker commands =====
# docker rm rc-dev && docker volume rm rc-db
# docker rm rc-mongo rc-prod && docker volume rm rc-uploads rc-db-prod && docker network rm rc-network

# docker logs -f rc-dev
# docker system df -v | grep -e 'rc-'
# docker inspect -f '{{.Mounts}}' rc-dev
# docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' rc-dev
