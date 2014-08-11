#!/bin/bash
interfaces=$(echo "$@" | sed 's/ /\\|/g')
ip=$(ip -4 a|grep -o -P '((?<=inet )[0-9.]*)|(^\d: \K[^:]*)'|tr '\n' ':'|grep -oP '(:|^)\K[^:]*:\d[^:$]*'|grep -v lo|grep "$interfaces"|tr '\n' ' ')
GPing=$(ping -c1 -W1 8.8.8.8|(grep "bytes from"||echo "Down")|sed 's/.*time=\([0-9\.]*\) ms.*/\1ms/')
echo -n "${ip}G:$GPing"

