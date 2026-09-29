# Cuda dev image

A docker container with my entire dev setup for easy setup on VastAI cloud GPU's.

## Nsight
To profile gpus you need a vastAI vm (not container)

Then also run
`scripts/setup-docker-gpu.sh`

## Ghostty Issues
For my ghostty I often need to show TERM
TERM=xterm-256color ssh -p 20286 root@89.121.253.244
