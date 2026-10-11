# Cuda dev image

A docker container with my entire dev setup for easy setup on VastAI cloud GPU's.

## Nsight Support
To profile gpus you need a vastAI vm (not container)

Once in the VM run:
`scripts/setup-docker-gpu.sh`

Then execute
`make shell-gpu-vm`

Once inside run
`scripts/cuda-smoke.sh`

## Ghostty Issues
For my ghostty I often need to show TERM

To connect to vast-ai instance:
`TERM=xterm-256color ssh -p 20286 root@89.121.253.244`

## How to build new image

1. `make build`
2. `make push`
