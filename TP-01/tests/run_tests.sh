#!/bin/bash
set -e

CALC="${CALC:-../calc}"
TMPDIR=$(mktemp -d)
trap "rm -rf $TMPDIR" EXIT

NORMALIZE="sed 's/^> //' | sed '/^$/d' | sed 's/[[:space:]]\+/ /g; s/[[:space:]]*$//'"

passed=0
failed=0

for input in *.in; do
    name="${input%.in}"
    expected="${name}.out"

    if [[ ! -f "$expected" ]]; then
        echo "Teste: $name ... FALHOU (arquivo $expected não encontrado)"
        ((failed++)) || true
        continue
    fi

    eval "cat '$input' | '$CALC' | $NORMALIZE" > "$TMPDIR/out.txt" || true

    if diff -q "$expected" "$TMPDIR/out.txt" > /dev/null; then
        echo "Teste: $name ... PASSOU"
        ((passed++)) || true
    else
        echo "Teste: $name ... FALHOU"
        echo "--- Esperado ($expected) ---"
        cat "$expected"
        echo "--- Obtido ---"
        cat "$TMPDIR/out.txt"
        echo "--- Diff ---"
        diff -u "$expected" "$TMPDIR/out.txt" || true
        ((failed++)) || true
    fi
done

echo ""
echo "========================================"
echo "Resultado: $passed passaram, $failed falharam"
echo "========================================"

if [[ $failed -gt 0 ]]; then
    exit 1
fi
