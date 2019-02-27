#!/bin/bash

#Get docker env timezone and set system timezone
echo "setting the correct local time"
echo $TZ > /etc/timezone
export DEBCONF_NONINTERACTIVE_SEEN=true DEBIAN_FRONTEND=noninteractive
dpkg-reconfigure tzdata


cd /config
if [ ! -z $VERSION ]; then
  echo "Manual version override:" $VERSION
else
  VERSION=4.5.2.1
  echo "Using Config Exporter version '$VERSION'"
fi

if [ ! -f /config/config-exporter-"$VERSION"-BETA.war ]; then
  echo "Installing version '$VERSION'"
  DOWNLOAD_PATH=https://tools.appdynamics.com/api/download/config-exporter/"$VERSION"/latest
  TOKEN=$(curl -X POST -d '{"username": "'$AppdUser'","password": "'$AppdPass'","scopes": ["download"]}' https://identity.msrv.saas.appdynamics.com/v2.0/oauth/token | grep -oP '(\"access_token\"\:\s\")\K(.*?)(?=\"\,\s\")')
  curl -L -O -H "Authorization: Bearer ${TOKEN}" ${DOWNLOAD_PATH}
  echo "file downloaded"
  echo "DOWNLOAD BROKEN --- place 4.5.2.1 in /config directory"
else
  echo "Using existing install version '$VERSION'"
fi
echo "Setting correct permissions"
chown -R nobody:users /config

echo "Starting AppDynamics Config Exporter"
java -jar config-exporter-"$VERSION"-BETA.war 2>&1 | tee /config/config-exporter-"$VERSION".log
