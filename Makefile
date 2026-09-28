IMAGE=pookie-cuda-dev:v1
PLATFORM=linux/amd64

build:
	docker build --platform $(PLATFORM) -t $(IMAGE) .

shell:
	docker run --rm -it \
		--platform $(PLATFORM) -t \
		$(IMAGE)
