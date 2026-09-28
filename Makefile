IMAGE=ghcr.io/vossenwout/pookie-cuda-dev:latest
PLATFORM=linux/amd64


.PHONY: build shell shell-gpu login push pull

build:
	docker build --platform $(PLATFORM) -t $(IMAGE) .

shell:
	docker run --rm -it \
		--platform $(PLATFORM) -t \
		$(IMAGE)

shell-gpu:
	docker run --rm -it \
		--platform $(PLATFORM) --gpus all \
		$(IMAGE)

login:
	@set -a; . ./.env; set +a; \
	printf '%s' "$$CR_PAT" | docker login ghcr.io -u vossenwout --password-stdin

pull:
	docker pull $(IMAGE)
push: build
	docker push $(IMAGE)
