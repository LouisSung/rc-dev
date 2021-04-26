FROM node:12.22.1-buster

RUN curl https://install.meteor.com/ | sh \
    && cp '/root/.meteor/packages/meteor-tool/2.2.0/mt-os.linux.x86_64/scripts/admin/launch-meteor' /usr/local/bin/meteor

RUN git clone https://github.com/RocketChat/Rocket.Chat.git \
    && cd Rocket.Chat \
    && git checkout 3.13.3 \
    && meteor npm install

WORKDIR /Rocket.Chat
RUN (timeout 10m meteor --allow-superuser npm start; exit 0)
EXPOSE 3000
