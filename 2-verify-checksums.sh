#!/bin/bash

# based on https://stackoverflow.com/a/29754866 
# brew install gnu-getopt
# echo 'export PATH="/usr/local/opt/gnu-getopt/bin:$PATH"' >> ~/.bash_profile

# saner programming env: these switches turn some bugs into errors
set -o errexit -o pipefail -o noclobber -o nounset

# -allow a command to fail with !’s side effect on errexit
# -use return value from ${PIPESTATUS[0]}, because ! hosed $?
! getopt --test > /dev/null 
if [[ ${PIPESTATUS[0]} -ne 4 ]]; then
    echo 'I’m sorry, `getopt --test` failed in this environment.'
    exit 1
fi

OPTIONS=s:,d:,p:,v,t
LONGOPTS=source:,destination:,progress:,verbose,test

# -regarding ! and PIPESTATUS see above
# -temporarily store output to be able to check for errors
# -activate quoting/enhanced mode (e.g. by writing out “--options”)
# -pass arguments only via   -- "$@"   to separate them correctly
! PARSED=$(getopt --options=$OPTIONS --longoptions=$LONGOPTS --name "$0" -- "$@")
#echo "PIPESTATUS[0]=${PIPESTATUS[0]}"; 
if [[ ${PIPESTATUS[0]} -ne 0 ]]; then
    # e.g. return value is 1
    echo "then getopt has complained about wrong arguments to stdout";
    exit 2
fi
# read getopt’s output this way to handle the quoting right:
eval set -- "$PARSED"

v=n test=n source_checksums=- destination_checksums=- progress_file=-
# now enjoy the options in order and nicely split until we see --
while true; do
    case "$1" in
        -v|--verbose)
            v=y
            shift
            ;;
        -t|--test)
            test=y
            shift
            ;;
        -s|--source)
            source_checksums="$2"
            shift 2
            ;;
        -d|--destination)
            destination_checksums="$2"
            shift 2
            ;;
        -p|--progress)
            progress_file="$2"
            shift 2
            ;;
        --)
            shift
            break
            ;;
        *)
            echo "Programming error"
            exit 3
            ;;
    esac
done

#  test to see if they gave the -s option
if [ "-" == "$source_checksums" ] || [ "-" == "$destination_checksums" ] || [ "-" == "$progress_file" ]; then
  echo "-s and -d and -p optios are required"
  exit
fi

echo "verbose: $v, test: $test, source_checksums=$source_checksums destination_checksums=$destination_checksums progress_file=$progress_file";
file_number=0;

while read -r line
do

    if [ $(($file_number % 1000)) == 0 ]; then
        date=$(date);
        echo -e "$date \t checked $file_number files";
    fi

    checksum=$(echo "$line" | awk '{print $1}');
    file=$(echo "$line" | awk '{print $2}');
    
    if result=$(grep "$checksum" "$destination_checksums"); then
        echo "$checksum exists" >> "$progress_file"
        if [ "$v" = "y" ]; then
            file_found=$(echo $result | awk '{print $2}');
            echo "$file_number: $checksum of $file exists in $file_found";
        fi
    else
        echo "$checksum MISSING" >> "$progress_file"
        >&2 echo "$file_number: $checksum of $file is MISSING"
    fi

    let file_number=$file_number+1;
done < "$source_checksums"

