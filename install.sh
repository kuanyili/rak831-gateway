#!/bin/bash

# Exit immediately if a pipeline returns a non-zero status
set -e

if [ $UID != 0 ]; then
    echo "Error: you cannot perform this operation unless you are root."
    exit 1
fi

# Pick frequency plan
# See [Frequency plan and regulations by country](https://www.thethingsnetwork.org/docs/lorawan/frequencies-by-country.html)
# and [The Things Network Master Gateway Configurations](https://github.com/TheThingsNetwork/gateway-conf)
PS3="Please enter your frequency plan (number): "
FREQUENCY_PLANS=("EU" "US" "AU" "AS1" "AS2" "KR" "IN" "CN" "RU")
select FREQUENCY_PLAN in "${FREQUENCY_PLANS[@]}";
do
    if [ ! -z "$FREQUENCY_PLAN" ]; then
        echo "You picked $FREQUENCY_PLAN."
        break;
    else
        echo "Error: invalid frequency plan."
        exit 1
    fi
done

# Create ttn group if it isn't already there
if ! getent group ttn >/dev/null; then
    # Add system group: ttn
    addgroup --system ttn >/dev/null
fi

# Create ttn user if it isn't already there
if ! getent passwd ttn >/dev/null; then
    # Add system user: ttn
    adduser \
        --system \
        --disabled-login \
        --ingroup ttn \
        --no-create-home \
        --home /nonexistent \
        --gecos "The Things Network Gateway" \
        --shell /bin/false \
        ttn >/dev/null
    # Add ttn user to supplementary groups so it can
    # reset and communicate with concentrator board
    usermod --groups gpio,spi ttn
fi

# Create install target directory
DESTDIR="/opt/ttn-gateway"
if [ ! -d "$DESTDIR" ]; then
    mkdir $DESTDIR
fi

# Dive into target directory
pushd $DESTDIR

# Build Semtech LoRa gateway driver
if [ ! -d lora_gateway ]; then
    git clone -b master https://github.com/Lora-net/lora_gateway.git
    pushd lora_gateway
else
    pushd lora_gateway
    git pull
fi
make
popd

# Build Semtech LoRa packet forwarder
if [ ! -d packet_forwarder ]; then
    git clone -b master https://github.com/Lora-net/packet_forwarder.git
    pushd packet_forwarder
else
    pushd packet_forwarder
    git pull
fi
make
popd

# Download The Things Network frequency plans
if [ ! -d gateway-conf ]; then
    git clone -b master https://github.com/TheThingsNetwork/gateway-conf.git
    pushd gateway-conf
else
    pushd gateway-conf
    git pull
fi
popd

# Create binary directory
if [ ! -d bin ]; then
    mkdir bin
fi

# Symlink concentrator board reset script
if [ -f ./bin/reset_lgw.sh ]; then
    rm ./bin/reset_lgw.sh
fi
ln -s \
    $DESTDIR/lora_gateway/reset_lgw.sh \
    ./bin/reset_lgw.sh

# Symlink gateway ID updater
if [ -f ./bin/update_gwid.sh ]; then
    rm ./bin/update_gwid.sh
fi
ln -s \
    $DESTDIR/packet_forwarder/lora_pkt_fwd/update_gwid.sh \
    ./bin/update_gwid.sh

# Symlink LoRa packet forwarder
if [ -f ./bin/lora_pkt_fwd ]; then
    rm ./bin/lora_pkt_fwd
fi
ln -s \
    $DESTDIR/packet_forwarder/lora_pkt_fwd/lora_pkt_fwd \
    ./bin/lora_pkt_fwd

# Create configuration directory
if [ ! -d conf ]; then
    mkdir conf
fi

# Back to installer directory
popd

# Generate LBT (Listen Before Talk) disabled global_conf.json
# as we cannot do LBT without FPGA
./disable_lbt.py \
    $DESTDIR/gateway-conf/$FREQUENCY_PLAN-global_conf.json \
    $DESTDIR/conf/global_conf.json

# Generate local_conf.json
cp \
    $DESTDIR/packet_forwarder/lora_pkt_fwd/local_conf.json \
    $DESTDIR/conf/local_conf.json
$DESTDIR/bin/update_gwid.sh $DESTDIR/conf/local_conf.json

# Make configurations self updatable
chown --recursive ttn:ttn $DESTDIR/conf

# Start packet forwarder as a service
cp ./start.sh $DESTDIR/bin/
cp ./ttn-gateway.service /lib/systemd/system/
systemctl enable ttn-gateway.service
systemctl restart ttn-gateway.service
