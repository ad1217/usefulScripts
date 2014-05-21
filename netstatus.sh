#!/bin/bash
ip=$(ip -4 a show $1|grep -o -P '(?<=inet )[0-9.]*')
GPing=$(ping -c1 -W1 8.8.8.8|(grep "bytes from"||echo "Down")|sed 's/.*time=\([0-9\.]*\) ms.*/\1ms/')
WPing=$(ping -c1 -W1 192.168.23.1|(grep "bytes from"||echo "Down")|sed 's/.*time=\([0-9\.]*\) ms.*/\1ms/')
echo -n "$ip G:$GPing W:$WPing"

