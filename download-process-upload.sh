#!/bin/bash

set  -x


TMPDIR=tmp
AWS_BATCH_JOB_ID=""
NOW=$(date +%Y%m%d-%H%M%S)
v=n
f=n
d=n



getopt --test > /dev/null
if [[ $? -ne 4 ]]; then
    echo "I’m sorry, `getopt --test` failed in this environment."
    exit 1
fi

OPTIONS=t:dfo:v
LONGOPTIONS=tilset:,debug,force,output:,verbose

# -temporarily store output to be able to check for errors
# -e.g. use “--options” parameter by name to activate quoting/enhanced mode
# -pass arguments only via   -- "$@"   to separate them correctly
PARSED=$(getopt --options=$OPTIONS --longoptions=$LONGOPTIONS --name "$0" -- "$@")
if [[ $? -ne 0 ]]; then
    # e.g. $? == 1
    #  then getopt has complained about wrong arguments to stdout
    exit 2
fi
# read getopt’s output this way to handle the quoting right:
eval set -- "$PARSED"


# now enjoy the options in order and nicely split until we see --
while true; do
    case "$1" in
        -d|--debug)
            d=y
            shift
            ;;
        -f|--force)
            f=y
            shift
            ;;
        -v|--verbose)
            v=y
            shift
            ;;
        -t|--tileset)
            tilesetName="$2"
            shift 2
            ;;
        -o|--output)
            s3Dir="$2"
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
    echo "$0: A single input file is required."
    exit 4
fi

if [ -n "${AWS_BATCH_JOB_ID}"  ]; then
    echo "No AWS_BATCH_JOB_ID"
    exit 2
fi




echo "verbose: $v, force: $f, debug: $d, out: $s3Dir, in: $1, tileset: $tilesetName, AWS_BATCH_JOB_ID: $AWS_BATCH_JOB_ID"

inFile=$1

outDir=${tilesetName}/${AWS_BATCH_JOB_ID}


if [ ! -d "${outDir}" ]; then
    echo "Creating ${outDir}"
    mkdir -p "${outDir}"
fi


basename=$(basename "$inFile")

if [ ! -f "${inFile}" ]; then
    aws s3 cp "${inFile}"  "${TMPDIR}/${basename}"
fi

set +e
zip --test "${TMPDIR}/${basename}"  2>/dev/null
[[ $? -eq 0  ]] &&  unzip -o "${TMPDIR}/${basename}" -d ${TMPDIR} || echo "Not compressed"


set -e


localInput=${TMPDIR}/$(zipinfo -1 "${TMPDIR}/${basename}")



./process-tilesets.sh  --inputs="${localInput}" --outputpath="${outDir}" --tilesetname="${tilesetName}"

aws s3 cp --recursive  "${outDir}"  "${s3Dir}/${tilesetName}/${NOW}"


echo "That's all folk!"




