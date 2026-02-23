#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
GODOT_BIN="${GODOT_BIN:-/ssd2/godot/4.6.1/Godot_v4.6.1-stable_linux.x86_64}"

export HOME=/tmp
export XDG_DATA_HOME=/tmp
export XDG_CONFIG_HOME=/tmp

echo "[check] boot smoke test"
"${GODOT_BIN}" --headless --path "${PROJECT_ROOT}" --quit-after 5

echo "[check] movement math unit tests"
"${GODOT_BIN}" --headless --path "${PROJECT_ROOT}" --script res://tests/movement_math_test.gd

echo "[check] slope integration test"
"${GODOT_BIN}" --headless --path "${PROJECT_ROOT}" --script res://tests/slope_movement_test.gd

echo "[check] PASS"
