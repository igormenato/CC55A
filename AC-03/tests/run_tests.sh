#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

FLEX_BIN="${FLEX:-flex}"

if ! command -v "$FLEX_BIN" >/dev/null 2>&1; then
    echo "Error: flex not found in PATH."
    exit 1
fi

make all >/dev/null

pass_count=0
fail_count=0

run_suite() {
    local suite_dir="$1"
    local binary_name="$2"
    local input_file

    for input_file in "$ROOT_DIR/tests/$suite_dir"/*.in; do
        local case_name
        local expected_file
        local actual_file
        local exit_code

        case_name="$(basename "$input_file" .in)"
        expected_file="$ROOT_DIR/tests/$suite_dir/$case_name.out"
        actual_file="$(mktemp)"
        exit_code=0

        if "$ROOT_DIR/bin/$binary_name" < "$input_file" > "$actual_file"; then
            exit_code=0
        else
            exit_code=$?
        fi

        if [[ "$exit_code" -ne 0 ]]; then
            echo "[FAIL] $suite_dir/$case_name"
            echo "Process exited with code $exit_code"
            fail_count=$((fail_count + 1))
            rm -f "$actual_file"
            continue
        fi

        if diff -u "$expected_file" "$actual_file" >/dev/null; then
            echo "[OK] $suite_dir/$case_name"
            pass_count=$((pass_count + 1))
        else
            echo "[FAIL] $suite_dir/$case_name"
            diff -u "$expected_file" "$actual_file" || true
            fail_count=$((fail_count + 1))
        fi

        rm -f "$actual_file"
    done
}

run_suite "exemplo0" "exemplo0"
run_suite "exemplo1" "exemplo1"
run_suite "exemplo2" "exemplo2"
run_suite "exemplo3" "exemplo3"
run_suite "exemplo4" "exemplo4"
run_suite "ids" "c_identifiers"

echo "Passed: $pass_count"
echo "Failed: $fail_count"

if [[ "$fail_count" -ne 0 ]]; then
    exit 1
fi
