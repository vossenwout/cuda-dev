#!/usr/bin/env bash
set -u

PASS=0
WARN=0
FAIL=0

green() { printf "\033[32m[PASS]\033[0m %s\n" "$1"; PASS=$((PASS+1)); }
yellow() { printf "\033[33m[WARN]\033[0m %s\n" "$1"; WARN=$((WARN+1)); }
red() { printf "\033[31m[FAIL]\033[0m %s\n" "$1"; FAIL=$((FAIL+1)); }

section() {
    echo
    echo "========================================"
    echo "$1"
    echo "========================================"
}

check_cmd() {
    if command -v "$1" >/dev/null 2>&1; then
        green "$1 found: $(command -v "$1")"
        return 0
    else
        red "$1 not found"
        return 1
    fi
}

section "SYSTEM"

echo "User:         $(whoami)"
echo "Home:         $HOME"
echo "Architecture: $(uname -m)"
echo "Kernel:       $(uname -r)"

if [ "$(uname -m)" = "x86_64" ]; then
    green "Running on x86_64"
else
    yellow "Not running on x86_64"
fi

section "DEV TOOLS"

check_cmd git
check_cmd cmake
check_cmd nvim
check_cmd tmux
check_cmd fzf
check_cmd fd
check_cmd rg
check_cmd lazygit

echo
nvim --version 2>/dev/null | head -1 || true
tmux -V 2>/dev/null || true
cmake --version 2>/dev/null | head -1 || true

section "CUDA TOOLKIT"

if check_cmd nvcc; then
    nvcc --version
fi

section "GPU ACCESS"

if command -v nvidia-smi >/dev/null 2>&1; then
    green "nvidia-smi available"

    if nvidia-smi; then
        green "GPU visible inside container"
    else
        red "nvidia-smi exists but failed"
    fi
else
    red "nvidia-smi not available — GPU/driver is probably not exposed to container"
fi

section "CUDA COMPILE + EXECUTION"

TMPDIR="$(mktemp -d)"
trap 'rm -rf "$TMPDIR"' EXIT

cat >"$TMPDIR/smoke.cu" <<'EOF'
#include <cstdio>
#include <cuda_runtime.h>

__global__ void smoke_kernel(int* result) {
    result[0] = 42;
}

int main() {
    int* d_result = nullptr;
    int result = 0;

    cudaError_t err = cudaMalloc(&d_result, sizeof(int));
    if (err != cudaSuccess) {
        fprintf(stderr, "cudaMalloc failed: %s\n", cudaGetErrorString(err));
        return 1;
    }

    smoke_kernel<<<1, 1>>>(d_result);

    err = cudaGetLastError();
    if (err != cudaSuccess) {
        fprintf(stderr, "Kernel launch failed: %s\n", cudaGetErrorString(err));
        cudaFree(d_result);
        return 1;
    }

    err = cudaMemcpy(&result, d_result, sizeof(int), cudaMemcpyDeviceToHost);
    if (err != cudaSuccess) {
        fprintf(stderr, "cudaMemcpy failed: %s\n", cudaGetErrorString(err));
        cudaFree(d_result);
        return 1;
    }

    cudaFree(d_result);

    if (result != 42) {
        fprintf(stderr, "Wrong result: %d\n", result);
        return 1;
    }

    printf("CUDA kernel executed successfully. result=%d\n", result);
    return 0;
}
EOF

if command -v nvcc >/dev/null 2>&1; then
    if nvcc -O2 "$TMPDIR/smoke.cu" -o "$TMPDIR/smoke"; then
        green "CUDA source compiled successfully"

        if "$TMPDIR/smoke"; then
            green "CUDA kernel executed successfully"
        else
            red "CUDA program compiled but failed at runtime"
        fi
    else
        red "CUDA compilation failed"
    fi
else
    red "Skipping CUDA compile test because nvcc is missing"
fi

section "NSIGHT COMPUTE"

if command -v ncu >/dev/null 2>&1; then
    green "ncu installed"
    ncu --version || true

    if [ -x "$TMPDIR/smoke" ]; then
        echo
        echo "Testing GPU performance-counter access..."

        NCU_OUTPUT="$TMPDIR/ncu-output.txt"

        if ncu \
            --target-processes all \
            --set basic \
            "$TMPDIR/smoke" \
            >"$NCU_OUTPUT" 2>&1; then

            green "ncu profiling works"
            cat "$NCU_OUTPUT"
        else
            cat "$NCU_OUTPUT"

            if grep -qi "ERR_NVGPUCTRPERM" "$NCU_OUTPUT"; then
                red "ncu is installed but GPU performance counters are blocked"
            else
                red "ncu profiling failed"
            fi
        fi
    fi
else
    red "ncu not installed"
fi

section "NSIGHT SYSTEMS"

if command -v nsys >/dev/null 2>&1; then
    green "nsys installed"
    nsys --version || true

    echo
    if nsys status --environment; then
        green "nsys environment check completed"
    else
        yellow "nsys exists but some profiling capabilities may be unavailable"
    fi
else
    yellow "nsys not installed"
fi

section "SUMMARY"

echo "PASS: $PASS"
echo "WARN: $WARN"
echo "FAIL: $FAIL"

echo

if [ "$FAIL" -eq 0 ]; then
    echo "Environment looks ready for CUDA development."
    exit 0
else
    echo "Some functionality is missing or blocked."
    exit 1
fi
