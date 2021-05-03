FROM node:12.22.1-buster

WORKDIR /root
RUN curl https://install.meteor.com/?release=2.2 | sh \
    && npm install -g @rocket.chat/apps-cli@1.9.0
RUN git clone --branch v1.25.0 https://github.com/RocketChat/Rocket.Chat.Apps-engine /root/Rocket.Chat.Apps-engine \
    && cd /root/Rocket.Chat.Apps-engine && npm install && npm run compile \
    && git clone --branch 3.14.0 https://github.com/RocketChat/Rocket.Chat /root/Rocket.Chat \
    && cd /root/Rocket.Chat && meteor npm install ../Rocket.Chat.Apps-engine

WORKDIR /root/Rocket.Chat
RUN (timeout 9m meteor --allow-superuser npm run debug; exit 0)
ENV METEOR_MONGO_BIND_IP=0.0.0.0
# VOLUME ["/root/Rocket.Chat/.meteor/local/db"]  # mount as needed when docker run

RUN apt-get update && apt-get install -y --no-install-recommends \
            openssh-server vim \
        && rm -rf /var/lib/apt/lists/* \
    && sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config \
    && echo 'root:rocketchatdev' | chpasswd && mkdir -p /var/run/sshd

# sample plugins: https://developer.rocket.chat/apps-development/recipes
RUN git clone --branch recipes/registering-api-endpoints https://github.com/RocketChat/Apps.RocketChat.Tester /root/Apps/recipes \
    && cd /root/Apps/recipes && npm install \
    && sed -i 's/export class RocketChatTester/export class AppsRocketChatTesterApp/' AppsRocketChatTesterApp.ts

EXPOSE 22 3000 3001 9229
CMD bash -c "/usr/sbin/sshd & meteor --allow-superuser run --inspect=0.0.0.0"
