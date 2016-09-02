#! /bin/env bash
my_dir="$(dirname "$0")"

set -o errexit
set -o errtrace

source ${my_dir}/beanstalk_functions.sh

if [ $# -ne 1 ]; then
    echo "$0 <env name>"
    exit 1
fi
env_name=$1

n=$(cname_for_env ${env_name})
echo $n