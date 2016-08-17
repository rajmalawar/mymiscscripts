#!/usr/bin/env bash
# These environment variables need to be setup
#export s3_bucket_name=MY_BUCKET
#export tenant=ORG_NAME
#export app_name=MY_APP
#export environment=MY_ENV
#export version=1
#export s3_file=config_file

echo "Environment variables are: "
env > /tmp/env

if [ -z "$s3_bucket_name" ]; then
    echo "Need to set s3_bucket_name"
    exit 1
fi
if [ -z "$tenant" ]; then
    echo "Need to set tenant"
    exit 1
fi
if [ -z "$app_name" ]; then
    echo "Need to set app_name"
    exit 1
fi
if [ -z "$environment" ]; then
    echo "Need to set environment"
    exit 1
fi
if [ -z "$s3_file" ]; then
    echo "Need to set s3_file"
    exit 1
fi
if [ -z "$version" ]; then
    echo "Need to set version"
    exit 1
fi

s3_value="${s3_file}.${version}"
s3_key="${tenant}/${app_name}/${environment}/${s3_value}"
echo "Getting from, " $s3_bucket_name ", key, " $s3_key ", file " $s3_value
aws s3api get-object --bucket $s3_bucket_name --key $s3_key $s3_value

echo "Setting up environment variables"

if [ ! -f "${s3_value}" ]
then
  echo "File does not exist. Exiting..."
  exit 1
fi

while read p; do
  export $p > /dev/null
done < $s3_value
