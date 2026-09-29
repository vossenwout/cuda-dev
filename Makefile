REGISTRY ?= ghcr.io/vossenwout/pookie-cuda-dev
VARIANT ?= vast-container
PLATFORM ?= linux/amd64
IMAGE = $(REGISTRY):$(VARIANT)


.PHONY: build shell shell-gpu login push pull

build:
	docker build --platform $(PLATFORM) \
		-f docker/Dockerfile.$(VARIANT) -t $(IMAGE) .

shell:
	docker run --rm -it \
		--platform $(PLATFORM) -t \
		--entrypoint zsh \
		$(IMAGE)

shell-gpu:
	docker run --rm -it \
		--platform $(PLATFORM) --gpus all \
		--user root \
		--cap-add=SYS_ADMIN \
		--entrypoint /bin/zsh \
		$(IMAGE) -i

login:
	@set -a; . ./.env; set +a; \
	printf '%s' "$$CR_PAT" | docker login ghcr.io -u vossenwout --password-stdin

pull:
	docker pull $(IMAGE)
push: build
	docker push $(IMAGE)
