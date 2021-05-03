# Rocket.Chat Dev | Dev env set up using Docker
## Docker Image Build
```bash
# build image
docker build -t louissung/rc-dev docker
# docker save -o rc-dev.tar louissung/rc-dev
# zip -s 45m rc-dev.zip rc.tar

# load prebuilt image
# git checkout docker-image
# docker load rc-dev.tar
```

## Dev Env Setup
```bash
# init
git clone --branch 3.14.0 https://github.com/RocketChat/Rocket.Chat
docker volume create rc-db
# set up ssh and sftp configs
# https://www.jetbrains.com/help/webstorm/running-ssh-terminal.html
# https://www.jetbrains.com/help/webstorm/creating-a-remote-server-configuration.html

# run
docker run -dt --name rc-dev -v rc-db:/root/Rocket.Chat/.meteor/local/db -p 2222:22 -p 3000:3000 -p 3001:3001 -p 9229:9229 louissung/rc-dev:3.14.0-apps-engine

# register sample plugin (apps)
# check http://localhost:3000/admin/General > Apps > Enable development mode & Enable the App Framework
docker exec -it rc-dev bash
>>> cd /root/Apps/recipes/
>>> # sed -i 's/export class RocketChatTester/export class AppsRocketChatTesterApp/' AppsRocketChatTesterApp.ts  # fix `There must be an exported class`
>>> rc-apps deploy --url http://localhost:3000 -u <username> -p <password>


# info
docker system df -v | grep -e 'rc-db'
docker inspect -f '{{.Mounts}}' rc-dev
docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' rc-dev
```

## Materials
* Official Docs: [Rock.Chat Docs](https://docs.rocket.chat) ([Offline Docs](rocket-chat-docs.pdf.zip) & [Developer Guides](rocket-chat-dev-docs.pdf))
* Meteor Folder structure: [Meteor Guide](https://guide.meteor.com/structure.html#example-app-structure)
* Sample breakpoint: [`server/methods/canAccessRoom.js#L10`](https://github.com/RocketChat/Rocket.Chat/blob/3.14.0/server/methods/canAccessRoom.js#L10)

## WebStorm Run/Debug Configs
(outdated for louissung/rc-dev:3.14.0-apps-engine, use sftp instead)
1. Run Docker container
    <img src="docs/img/1-docker-set-up.png" width="1080">
2. Attach JS debugger and MongoDB viewer
    <img src="docs/img/2-debugger-and-db-viewer.png" width="1080">

### Excluded Paths
1. `".svn;.cvs;.idea;.DS_Store;.git;.hg;*.hprof;*.pyc;.npm;node_modules"`
2. `["/Rocket.Chat/imports/client", "/Rocket.Chat/public", "/Rocket.Chat/private", "/Rocket.Chat/.meteor"]`
