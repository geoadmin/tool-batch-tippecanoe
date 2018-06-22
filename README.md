# tool-batch-tippecanoe
Tippecanoe docker image for AWS Batch



1. Image creation
-----------------

Base image (tippecanoe only). This is a local image.

    make tippecanoe

Create an image suitable for AWS Batch (node, wrapper script to tileset-process.sh)

    make batch

And push to `swisstopo/batch-tippecanoe`

    make push

2. Prepare data
---------------

Zip the source file

    zip oev_haltestellen_3857.zip oev_haltestellen_3857.json

And upload in a bucket accessible to AWS Batch:
   
    aws s3 cp oev_haltestellen_3857.zip s3://<your bucket>/in/vector/oev_haltestellen_3857.zip

3. Processing
-------------


    S3INPUTZIP="s3://<your bucket>/in/vector/oev_haltestellen_3857.zip" \ 
    S3OUTPUTDIR="s3://<your-bucket>/output/vector" \ 
    TILESETNAME="oev_haltestellen" JOB_NAME=fourth   ./submit_etl.sh


