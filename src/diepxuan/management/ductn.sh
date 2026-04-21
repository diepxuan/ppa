#!/usr/bin/env bash
#!/bin/bash

SCRIPT_DIR=$(dirname "$(realpath "$0")")
VENV_DIR="$SCRIPT_DIR/venv"
VENV_ACTIVATE="$VENV_DIR/bin/activate"

cd "$SCRIPT_DIR"

# Nếu uv có sẵn thì dùng uv
if command -v uv >/dev/null 2>&1; then
    [[ -f "$SCRIPT_DIR/ductn.py" ]] && uv run "$SCRIPT_DIR/ductn.py" "$@"
    exit 0
fi

# [[ ! -f "$VENV_ACTIVATE" ]] && python3 -m venv venv && pip install -r "$SCRIPT_DIR/requirements.txt"
# Nếu venv chưa tồn tại, tạo venv và cài requirements
if [[ ! -f "$VENV_ACTIVATE" ]]; then
    python3 -m venv "$VENV_DIR"
    source "$VENV_ACTIVATE"
    pip install --upgrade pip
    [[ -f "$SCRIPT_DIR/requirements.txt" ]] && pip install -r "$SCRIPT_DIR/requirements.txt"
    deactivate
fi

# Kích hoạt venv
source "$VENV_ACTIVATE"

# Chạy script nếu tồn tại
[[ -f "$SCRIPT_DIR/ductn.py" ]] && python3 "$SCRIPT_DIR/ductn.py" "$@"

# Hủy kích hoạt venv
deactivate
