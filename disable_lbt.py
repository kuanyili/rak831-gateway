#! /usr/bin/env python
import argparse
import json

parser = argparse.ArgumentParser(
    description="disable LBT (Listen Before Talk) in JSON configuration file"
)
parser.add_argument(
    "input",
    action="store",
    type=argparse.FileType("r"),
    help="input JSON configuration file"
)
parser.add_argument(
    "output",
    action="store",
    type=argparse.FileType("w"),
    help="output JSON configuration file"
)


def main():
    args = parser.parse_args()
    conf = json.load(args.input)
    args.input.close()
    try:
        conf["SX1301_conf"]["lbt_cfg"]["enable"] = False
    except KeyError:
        print("LBT is not enabled, do nothing.")
    json.dump(conf, args.output, indent=4)
    args.output.close()

if __name__ == "__main__":
    main()
