#!/bin/bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Reset RAK831 concentrator board
# Physical pin 11 = BCM pin 17
# See [Raspberry Pi GPIO pinout](https://pinout.xyz/)
# and [wiring instructions](http://docs.rakwireless.com/en/RAK831%20LoRa%20Gateway/Application%20Notes/interface%20panel%20wiring%20instructions.pdf)
SX1301_RESET_BCM_PIN=17
$SCRIPT_DIR/reset_lgw.sh start $SX1301_RESET_BCM_PIN
$SCRIPT_DIR/reset_lgw.sh stop $SX1301_RESET_BCM_PIN

# Update Gateway ID
$SCRIPT_DIR/update_gwid.sh local_conf.json

# Start up LoRa packet forwarder
$SCRIPT_DIR/lora_pkt_fwd
