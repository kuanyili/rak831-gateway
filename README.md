# The Things Network: RAK831-based gateway

Reference setup for [The Things Network](https://www.thethingsnetwork.org/) gateways based on

- Hardware: Raspberry Pi with [RAK831](http://www.rakwireless.com/en/WisKeyOSH/RAK831) concentrator connected through [adapter board](http://docs.rakwireless.com/en/LoRa/RAK831-Lora-Gateway/Application-Notes/Interface-Panel-Installation-Instructions.pdf).
- Software: Semtech [gateway driver](https://github.com/Lora-net/lora_gateway) and [packet forwarder](https://github.com/Lora-net/packet_forwarder)
- Configuration: [The Things Network Master Gateway Configurations](https://github.com/TheThingsNetwork/gateway-conf)

## Setup based on Raspbian image

- Download [Raspbian Stretch Lite](https://www.raspberrypi.org/downloads/raspbian/)
- Follow the [installation instruction](https://www.raspberrypi.org/documentation/installation/installing-images/README.md) to create the SD card
- [Enable one-time SSH](https://www.raspberrypi.org/blog/a-security-update-for-raspbian-pixel/)
- Use `raspi-config` utility to

        $ sudo raspi-config

    - **Enable SPI** (`5 Interfacing Options -> P4 SPI`)
    - **Enable SSH** (`5 Interfacing Options -> P2 SSH`)
    - Set hostname (`2 Network Options -> N1 Hostname`)
    - Change locale (`4 Localisation Options -> I1 Change Locale`)
    - Change timezone (`4 Localisation Options -> I2 Change Timezone`)

- Make sure you have an updated installation and install `git`:

        $ sudo apt update
        $ sudo apt dist-upgrade
        $ sudo apt install git

- Clone the installer and start the installation

        $ git clone https://github.com/kuanyili/rak831-gateway.git ~/rak831-gateway
        $ cd ~/rak831-gateway
        $ sudo ./install.sh

- Register gateway [via Semtech UDP packet forwarder](https://www.thethingsnetwork.org/docs/gateways/registration.html#via-semtech-udp-packet-forwarder)

    - Gateway's EUI can be found in `/opt/ttn-gateway/conf/local_conf.json`

## Update

If you have a running gateway and want to update, simply run the installer again:

    $ cd ~/rak831-gateway
    $ git pull
    $ sudo ./install.sh
