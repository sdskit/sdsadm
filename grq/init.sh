#!/bin/bash
BASE_PATH=$(dirname "${BASH_SOURCE}")
BASE_PATH=$(cd "${BASE_PATH}/.."; pwd)
source ${BASE_PATH}/funcs


# prompt if overwriting
prompt="-i"


# parse options
PARAMS=""
while (( "$#" )); do
  case "$1" in
    -f|--force)
      prompt=""
      shift 1
      ;;
    --) # end argument parsing
      shift
      break
      ;;
    -*|--*=) # unsupported flags
      echo "Error: Unsupported flag $1" >&2
      exit 1
      ;;
    *) # preserve positional arguments
      PARAMS=$@
      break
      ;;
  esac
done


# set positional arguments in their proper place
eval set -- "$PARAMS"


# globals
comp_dir=$(get_comp_dir grq)


# create log directories
mkdir -p $comp_dir/log/elasticsearch \
         $comp_dir/log/httpd \
         $comp_dir/log/redis


# create lib directories
mkdir -p $comp_dir/var/lib/elasticsearch/data \
         $comp_dir/var/lib/redis


# setup etc directory
if [ -e "$comp_dir/etc" ]; then
  rsync -rptvzL $comp_dir/etc/ $comp_dir/etc.bak > /dev/null
else
  mkdir -p $comp_dir/etc
fi


# copy global configs
cp -rp $prompt $BASE_PATH/config/datasets.json $comp_dir/etc/
cp -rp $prompt $BASE_PATH/config/logging.yml $comp_dir/etc/
cp -rp $prompt $BASE_PATH/config/redis-config $comp_dir/etc/


# copy component-specific configs
cp -rp $prompt grq/config/* $comp_dir/etc/