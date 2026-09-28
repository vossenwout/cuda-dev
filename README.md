# Cuda dev image

A docker container with my entire dev setup for easy setup on cloud GPU's.

## Variants

- `vast-container`: `docker/Dockerfile.vast-container` (default)
- `vast-vm`: `docker/Dockerfile.vast-vm`

Both Dockerfiles initially contain the same setup and build with the repository root as context.

```sh
make build VARIANT=vast-container
make push VARIANT=vast-container
make build VARIANT=vast-vm
make push VARIANT=vast-vm
```

Images are tagged `ghcr.io/vossenwout/pookie-cuda-dev:vast-container` and
`ghcr.io/vossenwout/pookie-cuda-dev:vast-vm` respectively.

The `pull`, `shell`, and `shell-gpu` targets also accept `VARIANT`:

```sh
make pull VARIANT=vast-vm
make shell-gpu VARIANT=vast-vm
```

Use `make shell` without GPU access (for example, on macOS).
