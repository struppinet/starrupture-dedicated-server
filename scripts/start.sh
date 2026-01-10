#!/bin/bash

echo " "
echo "Startup"
echo " "

server_files="/home/container/server_files"
echo "server path: $server_files"
savegame_files="/home/container/server_files/StarRupture/Saved/SaveGames"
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
echo "Installing/Updating StarRupture Dedicated Server files..."
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

USE_DSSETTINGS=${USE_DSSETTINGS:-"false"}
SERVER_PORT=${SERVER_PORT:-7777}
echo "Using port: $SERVER_PORT"

if [[ "${USE_DSSETTINGS}" == "true" ]] || [[ "${USE_DSSETTINGS}" == "1" ]]; then
  echo "DSSettings handling enabled."
  first_save_dir=$(find "$savegame_files" -mindepth 1 -maxdepth 1 -type d | head -n 1)

  if [ -d "$first_save_dir" ]; then
    echo "Found savegame folder: $first_save_dir"
    cp "/home/container/scripts/DSSettings.txt" "$server_files/DSSettings.txt"
    session_name=$(basename "$first_save_dir")
    sed -i "s/\"SessionName\": \".*\"/\"SessionName\": \"$session_name\"/" "$server_files/DSSettings.txt"
  else
    echo "No savegame subfolder found yet."
  fi
fi

echo " "
echo "Launching StarRupture Dedicated Server"
echo " "

# RUN
cd "$server_files"
xvfb-run --auto-servernum wine $server_files/StarRupture/Binaries/Win64/StarRuptureServerEOS-Win64-Shipping.exe -Log -port=$SERVER_PORT 2>&1
