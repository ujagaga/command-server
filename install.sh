#!/bin/bash

INSTALL_DIR="/opt/cmdserver"
PROJECT_NAME=command-server
GIT_URL=https://github.com/ujagaga/$PROJECT_NAME.git
GIT_BRANCH=main
TEMP_DIR="/tmp"
UPDATES_FILE="update.info"
SRC_DIR=.

redecho(){
    echo "$(tput setaf 1)${1}$(tput sgr0)"
}

# Make sure we are running as root so we can install dependencies.
if (( $EUID != 0 )); then
    redecho "Please run as root!"
    exit 1
fi

if [ "$1" = "noclone" ]; then
    echo 
else
    echo
    echo "------------------------------------------------------------------"
    echo '*************** "Command Server" installer ***************'
    echo "------------------------------------------------------------------"
    echo
    cd $TEMP_DIR || { redecho "ERROR: Could not find temp dir: $TEMP_DIR"; exit 1; }
    echo "cleaning up if necessary"
    rm -rf $PROJECT_NAME
    echo
    echo "*************** Installing git ***************"
    apt install -y git
    echo
    echo "*************** Downloading app files ***************"
    # Fetch the repository.    
    git clone $GIT_URL
    cd $PROJECT_NAME || { redecho "ERROR: Could not find repository folder: $PROJECT_NAME. Are you sure the configured repository exists"; exit 1; }
    git checkout $GIT_BRANCH
    echo
    echo "Running downloaded installer"
    chmod +x install.sh || { redecho "ERROR: Could not find installer.sh"; exit 1; }
    ./install.sh noclone
    exit
fi

OK=n
while [ $OK != "y" ]
do
    echo
    echo "*************** Setting up parameters ***************"
    read -r -p "Port for HTTP server (ENTER for default: 80): " PORT
    PORT=${PORT:-80}

    read -r -p "Folder to serve (default install dir: $INSTALL_DIR): " SERVE_DIR
    SERVE_DIR=${SERVE_DIR:-$INSTALL_DIR}

    echo
    read -r -p "Is this setup acceptable (N/y)? " OK
    OK=${OK:-n}
done

# Create install dir
mkdir -p $INSTALL_DIR
echo

echo "*************** Installing dependencies ***************"
apt install -y build-essential cmake
echo

echo "Building app"
$PWD/$SRC_DIR/build.sh

# Backup old web files
echo "Backing up old web folder in case you already have altered content"
rm -rf $INSTALL_DIR/web_old
mv $INSTALL_DIR/web $INSTALL_DIR/web_old
# Copying files and folders
cp -rf cmd $INSTALL_DIR
cp -rf web $INSTALL_DIR
mv -f README.md $INSTALL_DIR
mv -f cmd-server $INSTALL_DIR
mv -f uart_server.py $INSTALL_DIR

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
echo

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
    systemctl start $SERVICE_FILE

    {
        echo 'echo "disabling server service"'
	echo "systemctl stop $SERVICE_FILE"
        echo "systemctl disable $SERVICE_FILE"
        echo "rm /etc/systemd/system/$SERVICE_FILE"
    } >> $UNINST_FILE
fi

read -r -p "Enable 3D printer UART server at startup (N/y)? " OK
OK=${OK:-n}
if [ "$OK" == "y" ]; then
    cd /etc/systemd/system/ || { redecho "ERROR: Could not find /etc/systemd/system/. Are you sure this is a compatible platform?"; exit 1; }

    # Create startup service  
    SERVICE_FILE=printeruartserver.service
    {
        echo "[Unit]"
        echo Description=3D printer UART server startup service
        echo After=network-online.target
        echo Wants=network-online.target
        echo
        echo "[Service]"
        echo Type=simple
        echo RemainAfterExit=yes
        echo ExecStart=$INSTALL_DIR/uart_server.py
        echo
        echo "[Install]"
        echo WantedBy=multi-user.target
    } > $SERVICE_FILE
    systemctl enable $SERVICE_FILE
    systemctl start $SERVICE_FILE

    {
        echo 'echo "disabling uart service"'
	echo "systemctl stop $SERVICE_FILE"
        echo "systemctl disable $SERVICE_FILE"
        echo "rm /etc/systemd/system/$SERVICE_FILE"
    } >> $UNINST_FILE
fi

{
    echo 'echo "Removing install dir"'
    echo "rm -rf $INSTALL_DIR"
} >> $UNINST_FILE

chmod +x $UNINST_FILE

echo
echo "Removing downloaded files"
rm -rf $TEMP_DIR/$PROJECT_NAME

exit 0
