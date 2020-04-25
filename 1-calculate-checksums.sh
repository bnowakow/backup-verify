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

OPTIONS=o:v,t
LONGOPTS=output:,verbose,test

# -regarding ! and PIPESTATUS see above
# -temporarily store output to be able to check for errors
# -activate quoting/enhanced mode (e.g. by writing out “--options”)
# -pass arguments only via   -- "$@"   to separate them correctly
! PARSED=$(getopt --options=$OPTIONS --longoptions=$LONGOPTS --name "$0" -- "$@")
if [[ ${PIPESTATUS[0]} -ne 0 ]]; then
    # e.g. return value is 1
    #  then getopt has complained about wrong arguments to stdout
    exit 2
fi
# read getopt’s output this way to handle the quoting right:
eval set -- "$PARSED"

v=n outFile=- test=n
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
        -o|--output)
            outFile="$2"
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

# handle non-option arguments
if [[ $# -ne 1 ]]; then
    # TODO add support for multiple directories
    echo "$0: A single input directory is required."
    exit 4
fi

input_directory=$1;

echo "verbose: $v, test: $test, directory: $input_directory, out: $outFile"

file_number=0;
# based on https://stackoverflow.com/a/9612560
find "$input_directory" -name "*" -print0 | while read -d $'\0' file
do
    echo "$file_number: $file"
    if [ $file_number -eq 5 ]; then
        exit;
    fi
 
    let file_number=$file_number+1;
done
