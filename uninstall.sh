#!/bin/bash

# Exit immediately if a pipeline returns a non-zero status
set -e

if [ $UID != 0 ]; then
    echo "Error: you cannot perform this operation unless you are root."
    exit 1
fi

# Remove systemd service
echo "Removing systemd service."
if [ -f /lib/systemd/system/ttn-gateway.service ]; then
    if [ "$(systemctl is-active ttn-gateway.service)" = "active" ]; then
        systemctl stop ttn-gateway.service
    fi
    if [ "$(systemctl is-enabled ttn-gateway.service)" = "enabled" ]; then
        systemctl disable ttn-gateway.service
    fi
    rm /lib/systemd/system/ttn-gateway.service
fi

# Remove install target directory
echo "Removing install target directory."
DESTDIR="/opt/ttn-gateway"
if [ -d "$DESTDIR" ]; then
    rm --recursive $DESTDIR
fi

echo "Done!"
