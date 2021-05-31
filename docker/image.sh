# run in Docker image build (louissung/rc:build-*)
cd /app/Rocket.Chat.Apps-engine && git checkout .
cp -n /app/locks/rc-ae.yarn.lock yarn.lock && upgradeYarn
yarn install && yarn run compile

cd /app/Rocket.Chat && git checkout .
cp -n /app/locks/rc.yarn.lock yarn.lock && upgradeYarn
yarn add ../Rocket.Chat.Apps-engine

meteor yarn run testunit --exclude app/models/server/models/Sessions.tests.js
meteor yarn add date-fns@^2.15.0
(TEST_MODE=true meteor run & sleep 7m) && meteor yarn run test && pkill node

meteor build --server-only --directory /app
cd /app/bundle/programs/server
cp -n /app/locks/bundle.yarn.lock yarn.lock && upgradeYarn
yarn install
chown -R rocketchat:rocketchat /app/bundle && chmod -R ugo+rwX /app/bundle
