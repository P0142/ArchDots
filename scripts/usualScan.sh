#!/bin/bash

# Ensure target IP is provided as an argument
if [ "$#" -ne 1 ]; then
  echo "Syntax: $0 {Target}";
  exit 1;
fi

target="$1";

# Scan All Ports
echo "Scanning: $target";
sudo /usr/bin/nmap -p- -v --min-rate=1000 -oN nmap.$target-ports $target;

# Detailed Scan
echo "Detailed scan on $target";
ports=$(cat nmap.$target-ports | awk -F/ '/open/ {b=b","$1} END {print substr(b,2)}')
if [ -z "$ports" ]; then
  echo "No Open Ports on $target";
  exit 1;
else
  sudo /usr/bin/nmap -p $ports -v -A -min-rate=1000 -oN nmap.$target $target;
fi
echo "Scan Completed: $target";
