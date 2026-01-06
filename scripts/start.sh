#!/bin/bash

echo " "
echo "Startup"
echo " "

server_files="/home/container/server_files"
echo "server path: $server_files"
savegame_files="/home/container/.wine/drive_c/users/container/AppData/LocalLow/data"
echo "savegame path: $savegame_files"

echo " "
echo "Installing Steam"
echo " "

steam_path=/home/container/steamcmd
mkdir -p $steam_path
curl -sSL -o $steam_path/steamcmd.tar.gz https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz
tar -xzf $steam_path/steamcmd.tar.gz -C $steam_path
steamcmd=$steam_path/steamcmd.sh
echo "Steam ... OK"

echo " "
echo "Installing/Updating Aska Dedicated Server files..."
echo " "

$steamcmd +@sSteamCmdForcePlatformType windows +force_install_dir "$server_files" +login anonymous +app_update 3809400 validate +quit
exit_code=$?

if [ $exit_code -ne 0 ]; then
  echo " "
  echo "SteamCmd failed with exit code: $exit_code"
  echo "Try deleting the appmanifest file or clear the whole server_files (installation only)"
  echo " "
  exit
else
  echo " "
  echo "SteamCmd finished successfully (Exit Code: $exit_code)"
  echo " "
fi

echo " "
echo "Configuring StarRupture Dedicated Server ..."
echo " "

# update env cfg data
#source /home/container/scripts/env2cfg.sh

echo " "
echo "Launching StarRupture Dedicated Server"
echo " "

# RUN
cd "$server_files"
xvfb-run --auto-servernum wine $server_files/StarRuptureServerEOS.exe -Log -port=$SERVER_PORT 2>&1
