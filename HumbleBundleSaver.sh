#!/bin/bash
IFS=$'\n'
rows=$(cat $1|tr '\n' '~' | grep -zoP "<div class=\"row.*?/div>(?=<div class=\"row)")
DLType="bt" #bt or web

#shortnames=$(grep -oP "class=\"row \K[^\"]*" <<< "$rows")
#names=$(grep -oP "class=\"row $i\" data-human-name=\"\K[^\"]*" <<< "$rows")
#links=$(grep -oP "data-$DLType=\"\K[^\"]*" <<< "$rows" |sed 's/\&amp;/\&/g')
#filenames=$(grep -oP "[^:]*/\K[^?]*" <<< $links |sed 's/ /\n/g')
 
for i in $rows; do
    echo "Getting $(grep -oP "data-human-name=\"\K[^\"]*" <<< $i)"
    type=$(grep -oP 'js-platform downloads \K[^"]*' <<< $i)
    echo $type
    for x in $(grep -oP '<div class="js-platform.*?</div>.*?(?=<div class="js-platform|$)' <<< $i|grep \<a); do
	for z in $(grep -oP '<div class="download("| ).*? </div>' <<< "$x");do
	    link=$(grep -oP "data-$DLType=\"\K[^\"]*" <<< "$z"|sed 's/\&amp;/\&/g')
	    filename=$(grep -oP "[^:]*/\K[^?]*" <<< $link |sed 's/ /\n/g')
	    md5=$(grep -oP 'data-md5="\K[^"]*' <<< "$z")
	    #echo $filename
	done
    done
done
