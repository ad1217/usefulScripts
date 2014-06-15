#!/bin/bash

echo -n "WS|"
if [ $# -ne 0 ];then
    i3-msg -t get_workspaces | grep -oP '{.*?"output".*?}' | grep $1 | grep -oP '(name":"\K[^"]*)|("visible":true,"focused":[^,]*)' | tr '\n' '|' | sed 's/|"visible":true,"focused":true/★/g;s/|"visible":true,"focused":false/⚫/g'|tr '\n' '|'
else
    i3-msg -t get_workspaces | grep -oP '{.*?"output".*?}' | grep -oP '(name":"\K[^"]*)|("visible":true,"focused":[^,]*)' | tr '\n' '|' | sed 's/|"visible":true,"focused":true/★/g;s/|"visible":true,"focused":false/⚫/g'|tr '\n' '|'
fi
