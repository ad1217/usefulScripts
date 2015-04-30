#!/bin/bash
interfaces=$(echo "$@" | sed 's/ /\\|/g')
ip=$(ip -4 -o a | grep "$interfaces" | sed 's/^[0-9]*: \([^ ]*\)    inet \([0-9.]*\).*/\1:\2/g' | grep -v lo | tr '\n' ' ')
GPing=$(ping -c1 -W1 8.8.8.8 | (grep "bytes from" || echo "<span fgcolor=\"red\">G:Down</span>") | sed 's/.*time=\([0-9\.]*\).*/G:\1ms/')
echo -n "<txt>${ip}$GPing</txt>"
