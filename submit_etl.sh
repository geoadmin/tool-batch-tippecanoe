#!/bin/bash


#JOB_NAME=$(date +%Y%m%d-%H%M%S) 
JOB_QUEUE=aws_demo_batch_job-queue
JOB_DFN_ARN=arn:aws:batch:eu-west-1:050475232797:job-definition/aws_batch_tippecanoe:5
BUCKET_NAME=ltmom-aws-batch-test
MEMORY=1024
CPU=1
hours=1
TIMEOUT=$((3600*hours))





export JOB_NAME=${JOB_NAME}JSON

envsubst < etl-job.json.in > etl-job.json

aws batch --profile mom_aws-admin-test1  submit-job --job-definition ${JOB_DFN_ARN}  --cli-input-json file://etl-job.json
