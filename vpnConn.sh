#!/bin/bash

echo "Attempting Connection"
if sudo openvpn --config $1 --daemon "HTB" --writepid /tmp/htb_pid.txt; then
    echo "Connecting . . ."
    sleep 5
    OVPNPID=$(cat /tmp/htb_pid.txt)
    echo "OpenVPN PID: "$OVPNPID

    # Get Tun0 IP Address
    if ipaddr=$(ip a s tun0 | awk -F"[ /]+" '/scope global tun0/{print $3}'); then
        echo "Tun0 IP: "$ipaddr
        xsetroot -name " VPN: $ipaddr 箱 " &

    else
        echo "Failed to get Tun0 IP"
    fi
    # Await OVPN closing
    $(tail --pid=$OVPNPID -f /dev/null)
    echo "VPN Disconnected."
    xsetroot -name " 箱 " &
else
    echo "Connection Failed."
fi

