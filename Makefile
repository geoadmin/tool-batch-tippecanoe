


.PHONY: tippecanoe
tippecanoe:
	docker build -t swisstopo/tippecanoe:ubuntu -f Dockerfile.ubuntu   .

.PHONY: batch
batch: tippecanoe
		docker build -t swisstopo/batch-tippecanoe -f Dockerfile.batch . 

.PHONY: push
push: batch
	docker push swisstopo/batch-tippecanoe:latest

.PHONY: clean
clean:
	rm -f etl-job.json
