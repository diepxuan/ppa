#!/usr/bin/env bash
#!/bin/bash

SCRIPT_DIR=$(dirname "$(realpath "$0")")
VENV_ACTIVATE="$SCRIPT_DIR/venv/bin/activate"

cd "$SCRIPT_DIR"
[[ ! -f "$VENV_ACTIVATE" ]] && python3 -m venv venv && pip install -r "$SCRIPT_DIR/requirements.txt"
source "$VENV_ACTIVATE"

[ -f "$SCRIPT_DIR/ductn.py" ] && python3 "$SCRIPT_DIR/ductn.py" "$@"
deactivate
