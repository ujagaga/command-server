#!/bin/bash

INSTALL_DIR="/opt/cmdserver"
PROJECT_NAME=command-server
GIT_URL=https://github.com/ujagaga/$PROJECT_NAME.git
GIT_BRANCH=main
TEMP_DIR="/tmp"
UPDATES_FILE="update.info"
APP_NAME=bnfs
SRC_DIR=.
USB_MOUNT_PACKET=usbmount_0.0.24_all.deb
LOGFILE="install.log"

# Make sure we are in the script dir and not working in the caller dir.
SCRIPT="$(realpath -s $0)"
SCRIPT_DIR="$(dirname $SCRIPT)"
rm -rf $INSTALL_DIR

redecho(){
  echo "$(tput setaf 1)${1}$(tput sgr0)"
}

# Make sure we are running as root so we can install dependencies.
if (( $EUID != 0 )); then
  redecho "Please run as root!"
  exit 1
fi

echo
echo "------------------------------------------------------------------"
echo '*************** "Command Server" installer ***************'
echo "------------------------------------------------------------------"

OK=n
while [ $OK != "y" ]
do
  echo
  echo "Please setup parameters"
  read -r -p "Port for HTTP server (ENTER for default: 80): " PORT
  PORT=${PORT:-80}

  read -r -p "Folder to serve (default: $INSTALL_DIR): " SERVE_DIR
  SERVE_DIR=${SERVE_DIR:-$INSTALL_DIR}

  echo
  read -r -p "Is this setup acceptable (N/y)? " OK
  OK=${OK:-n}
done

mkdir $INSTALL_DIR
echo
echo "*************** Installing dependencies ***************"
apt install -y git build-essential cmake
echo
echo "*************** Downloading app files ***************"
# Fetch the repository.
cd $TEMP_DIR || { redecho "ERROR: Could not find temp dir: $TEMP_DIR"; exit 1; }
echo "cleaning up if necessary"
rm -rf $PROJECT_NAME
git clone $GIT_URL
cd $PROJECT_NAME || { redecho "ERROR: Could not find repository folder: $PROJECT_NAME. Are you sure the configured repository exists"; exit 1; }
git checkout $GIT_BRANCH

echo "Building app"
$PWD/$SRC_DIR/build.sh

while read p; do
    if [[ -d $p ]]; then
        cp -rf $p $INSTALL_DIR
    elif [[ -f $p ]]; then
        mv -f $p $INSTALL_DIR
    else
        if [[ "$p" =~ ^#.*  ]]; then
	    continue
	else
            if [ -z "$p" ]; then
                continue
            else
                echo "Warning: Not found $p"
            fi           
        fi
    fi
done < $UPDATES_FILE

# Remove cloned repository
rm -rf $TEMP_DIR/$PROJECT_NAME

echo

UNINST_FILE=$INSTALL_DIR/uninstall.sh
echo "Creating uninstaller"
{
  echo '#!/bin/bash'
  echo 'if (( $EUID != 0 )); then'
  echo '  echo "Please run as root!"'
  echo "  exit 1"
  echo "fi"
} > $UNINST_FILE

read -r -p "Enable command server at startup (N/y)? " OK
OK=${OK:-n}
if [ "$OK" == "y" ]; then
  cd /etc/systemd/system/ || { redecho "ERROR: Could not find /etc/systemd/system/. Are you sure this is a compatible platform?"; exit 1; }

  # Create startup service  
  SERVICE_FILE=cmdserver.service
  {
    echo "[Unit]"
    echo Description=Command server startup service
    echo After=network-online.target
    echo Wants=network-online.target
    echo
    echo "[Service]"
    echo Type=simple
    echo RemainAfterExit=yes
    echo Restart=on-failure
    echo RestartSec=10s
    echo ExecStart=$INSTALL_DIR/cmd-server -p $PORT -d $SERVE_DIR
    echo
    echo "[Install]"
    echo WantedBy=multi-user.target
  } > $SERVICE_FILE
  systemctl enable $SERVICE_FILE

  {
    echo 'echo "disabling service"'
    echo "systemctl disable $SERVICE_FILE"
    echo "rm /etc/systemd/system/$SERVICE_FILE"
  } >> $UNINST_FILE

fi

{
  echo 'echo "Removing install dir"'
  echo "rm -rf $INSTALL_DIR"
} >> $UNINST_FILE
chmod +x $UNINST_FILE


