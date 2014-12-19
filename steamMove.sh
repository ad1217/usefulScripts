#!/bin/bash

IFS=$'\n'
basedir="$HOME/.local/share/Steam"


case "$1" in
	"-d"|"--directory") basedir="$2"; shift 2;;
	"-h"|"--help") echo 'Usage: steamMove.sh [OPTIONS] [src num] [dest num]
  -d --directory	Set the base directory
  -h --help	This help text'|column -ts '	'; exit;;
esac

dirs="$basedir
$(grep -oP "[	 ]\"[0-9]+\"[^\"]*\"\K[^\"]*" "$basedir/steamapps/libraryfolders.vdf" | sed 's/\\\\/\//g;s/Z://')"

echo "Detected Libraries:
$(nl -nln <<< "$dirs")"

case $1 in
	'')
		read -p "Select a source library:
> " srcLibraryNum
		
		srcLibrary=$( sed "${srcLibraryNum}q;d" <<< "$dirs")
		;;
	*[!0-9]*)
		srcLibrary="$1"
		;;
	*)
		srcLibraryNum=$1
		srcLibrary=$( sed "${srcLibraryNum}q;d" <<< "$dirs")
		;;
esac

case $2 in
	'')
		read -p "Select a destination library:
> " destLibraryNum
		destLibrary=$( sed "${destLibraryNum}q;d" <<< "$dirs")
		;;
	*[!0-9]*)
		destLibrary="$2"
		;;
	*)
		destLibraryNum=$2
		destLibrary=$( sed "${destLibraryNum}q;d" <<< "$dirs")
		;;
esac
echo "
Source Library: $srcLibrary
  Dest Library: $destLibrary
"

if [ "$srcLibraryNum" = "$destLibraryNum" ];then echo "Source and destination are the same!";exit;fi
if [ -z "$srcLibrary" -o ! -d "$srcLibrary" ];then echo "Source library $srcLibrary is not availible or is null";exit;fi
if [ -z "$destLibrary" -o ! -d "$destLibrary" ];then echo "Destination library $destLibrary is not availible or is null";exit;fi

gameNum=1
echo "Games in $srcLibrary:"
games="$(for jj in "$srcLibrary"/steamapps/appmanifest_*
		do
			echo -n "$gameNum	"
			grep -m1 -oP 'name"[	]*"\K[^"]*' "$jj" |tr -d '\n'
			echo -n "	"
			grep -oP 'installdir"[	]*"\K[^"]*' "$jj" |tr -d '\n'
			echo  "	$jj"
			gameNum=$(($gameNum+1))
		done)"
echo

echo "$(tput bold)Num		Game	   Directory
$(tput sgr0)$(awk -F "	" '{print $1,"\t",$2,"\t",$3}' <<< "$games")" |column -ts '	'
read -p "Enter the number(s) or part of the name of a game to move:
> " input

case $input in  #Still rather ugly
	*[!0-9\ ]*) input="$(awk "/$input/ {print FNR}" <<< "$games")" && echo "Interpreting as search, $( [ -n "$input" ] && wc -l <<<"$input" || echo -n 0) matches";;&
	*[\ ]*) input="$(tr ' ' '\n' <<< "$input")" ;;
	*)  ;;
esac

for ii in $input
do
	echo "Moving \"$(awk -F "	" "NR==$ii {print \$2}" <<< "$games")\""
	read -p "Move, copy or skip? [m/c/*]: " option
	case $option in
		M|m)
			echo "  Directory \"$(awk -F "	" "NR==$ii {print \$3}" <<< "$games")\""
			rsync -rP "$srcLibrary"/steamapps/common/"$(awk -F "	" "NR==$ii {print \$3}" <<< "$games")" "$destLibrary"/steamapps/common
			rm -rf "$srcLibrary"/steamapps/common/"$(awk -F "	" "NR==$ii {print \$3}" <<< "$games")"
			echo "  Manifest \"$(awk -F "	" "NR==$ii {print \$4}" <<< "$games")\""
			mv "$(awk -F "	" "NR==$ii {print \$4}" <<< "$games")" "$destLibrary"/steamapps
			;;
		C|c)
			echo "  Directory \"$(awk -F "	" "NR==$ii {print \$3}" <<< "$games")\""
			rsync -rP "$srcLibrary"/steamapps/common/"$(awk -F "	" "NR==$ii {print \$3}" <<< "$games")" "$destLibrary"/steamapps/common
			echo "  Manifest \"$(awk -F "	" "NR==$ii {print \$4}" <<< "$games")\""
			cp "$(awk -F "	" "NR==$ii {print \$4}" <<< "$games")" "$destLibrary"/steamapps
			;;
	esac
done
