# Rocket.Chat Dev | Dev env set up using Docker
## Docker image build
```bash
# build image
docker build -t 'louissung/rc:dev' .
# docker save -o rc.tar louissung/rc:dev
# zip -s 45m rc.zip rc.tar

# load prebuilt image
# git checkout docker-image
# docker load rc.tar
```

## Dev env setup
```bash
# init
mkdir Rocket.Chat  # mount empty folder and copy code (Rocket.Chat@3.13.3) from the Docker image
docker run -v "$(pwd)/Rocket.Chat:/tmpRC" louissung/rc:dev bash -c 'cp -r . ../tmpRC && chown -R 1001 ../tmpRC'

# run
docker run -dt -v "$(pwd)/Rocket.Chat:/Rocket.Chat" -p 3000:3000 -p 3001:3001 -p 9229:9229 -e METEOR_MONGO_BIND_IP=0.0.0.0 --name rc-dev louissung/rc:dev bash
docker exec -it rc-dev bash  # or simply use `docker run meteor xxxxx`
>>> meteor --allow-superuser run --inspect-brk=0.0.0.0
```

## Materials
* Official Docs: [Rock.Chat Docs](https://docs.rocket.chat) ([offline PDF](rocket-chat-official-docs.pdf.zip))
* Meteor Folder structure: [Meteor Guide](https://guide.meteor.com/structure.html#example-app-structure)
* Sample breakpoint: [`server/methods/canAccessRoom.js#L10`](https://github.com/RocketChat/Rocket.Chat/blob/3.13.3/server/methods/canAccessRoom.js#L10)

## WebStorm Run/Debug Configs
1. Run Docker container
    <img src="docs/img/1-docker-set-up.png" width="1080">
2. Attach JS debugger and MongoDB viewer
    <img src="docs/img/2-debugger-and-db-viewer.png" width="1080">
