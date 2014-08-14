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
	currentIndex=$(sed 's/},{"viewport/\nviewport/g' index.html|sed "$1q;d")
	title=$(getKey "$currentIndex" "title")
	echo "Getting $title"
	mkdir -p temp/$title
	cd temp/$title
	uuid=$(getKey $currentIndex "book_uuid");
	echo "Getting book.tar"
	wget -c --load-cookies "$cookieFile" "https://digital.darkhorse.com/api/v5/book/$uuid" -O book.tar --progress=bar:force 2>&1 | tail -f -n +10
	tar xf book.tar||exit
	x=0
	for image in $(grep -oP 'src_image": "\K[^"]*' manifest.json)
	do
	    mv $image $(printf "%03d" $x).jpg
	    x=$(($x+1))
	done
	echo "Making cbz"
	zip comics/$title.cbz *.jpg>/dev/null
	rm book.tar
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
if [ ! -e "$dir/comics" ]; then mkdir -p $dir/comics;fi
cd $dir

wget --load-cookies "$cookieFile" 'https://digital.darkhorse.com/api/v/books/' -O index.html --progress=bar:force 2>&1 | tail -f -n +6||(echo "Error downloading, check network and presence of cookies.txt in working directory and try again.";exit 1)
if [ -z "$input" ]; then
	printComics
	input=$(read input;eval echo $input)
fi
IFS=' '
for i in $input; do getComic $i;done
