#!/bin/bash
function getKey(){
	grep -o -P "\"$2\": ?\"\K[^\"]*" <<< $1|sed 's/"//g'
}

function printComics(){
	IFS=$'\n'
	titleNum=1
	echo "Enter a selection:"
	for i in $(sed 's/},{"viewport/\nviewport/g' index.html)
	do
		echo "$titleNum. $(getKey "$i" "title")"
		((titleNum++))
	done
	echo -n ">"
}

function getComic(){
	IFS=$'\n'
	titleNum=0
	currentIndex=$(sed 's/},{"viewport/\nviewport/g' index.html|sed "$1q;d")
	title=$(getKey "$currentIndex" "title")
	echo "Getting $title"
	mkdir -p comics/$title
	cd comics/$title
	echo "Getting manifest"
	wget -q --timeout 2 -t 5 --load-cookies $cookieFile $(getKey "$currentIndex" "manifest") -O manifest.json||(echo "Manifest forbidden, check cookies file (try accessing the manifest at $(getKey "$currentIndex" "manifest") then updating your cookies.txt file).";exit 1)

	baseURL=$(getKey $(cat manifest.json) "base_url");
	URLs=$(getKey $(cat manifest.json) "src_image");
	echo "Getting $(wc -l < <(echo "$URLs")) images:"
	x=0
	for i in $URLs
	do
			echo -n "$x."
			wget -q --timeout 2 -t 5 --load-cookies $cookieFile $baseURL/$i -O $(printf "%03d" $x).jpg --append-output=imageLog.txt&
			x=$(($x+1))
	done
	echo ""
	wait
	echo "Making cbz"
	zip ../$title.cbz *.jpg>/dev/null
	cd ../..
}

while getopts ":o:c:g:" opt; do
	case $opt in
		o)
			dir=$OPTARG
			;;
		c)
			cookieFile=$(readlink -f $OPTARG)
			;;
		g)
			input=$(eval echo $OPTARG)
			;;
		\?)
			echo -e "Invalid option: -$OPTARG\nUsage: @$ -o outputDir [-c cookies.txt] [-g \"number of comic(s)\"]" >&2
			exit 1
			;;
		:)
			echo "Option -$OPTARG requires an argument" >&2
			exit 1
			;;
	esac
done

if [ -z "$dir" ]; then echo "Please specify a directory with -o";exit 1;fi
if [ -z "$cookieFile" -a -e ~/cookies.txt ]; then
	cookieFile=~/cookies.txt;echo "Note: No cookie.txt specified, using $HOME/cookies.txt"
else
	echo "No cookie file specified, and $HOME/cookies.txt does not exist";exit 1
fi
if [ ! -e "$dir" ]; then mkdir $dir;fi
cd $dir

wget -q --load-cookies "$cookieFile" 'https://digital.darkhorse.com/api/v/books/' -O index.html||(echo "Error downloading, check network and presence of cookies.txt in working directory and try again.";exit 1)
if [ -z "$input" ]; then
	printComics
	input=$(read input;eval echo $input)
fi
IFS=' '
for i in $input; do getComic $i;done
