#!/bin/bash

echo -n "WS|"
i3-msg -t get_workspaces|tr ',' '\n'|grep 'name\|"visible":true'|sed 's/\".*\"://g'|tr '\n' "|"|sed 's/\"//g;s/|true/★/g'


#i3-msg -t get_workspaces|sed 's/visible":true/★/g'|grep -o -P '(name":"\K[0-9])|★'|tr '\n' '|'