#!/usr/bin/env bash

set -euo pipefail

proof_name="$1"
proof_hash="$2"
proof_hash_upper="$(echo $proof_hash | tr '[:lower:]' '[:upper:]')"

echo "Proof name: $proof_name"
echo "Proof hash: $proof_hash"

count_trusted_rules="$(grep -c 'trusted' out/specs/$proof_hash.k)" || count_trusted_rules='0'
echo "Number of trusted rules:"
echo "$count_trusted_rules"

[[ "$count_trusted_rules" != 0 ]] || exit 0

found_rules=()
for rule in $(grep 'SRULE' out/data/$proof_hash.log | cut --delimiter=' ' --field=3 | cut --delimiter='_' --field=1); do
    rule_name=$(cat "out/data/${proof_hash}_blobs/$rule.json"                       \
                    | jq .term.att                                                  \
                    | grep --only-matching "label($proof_hash_upper.[A-Za-z.]*)"    \
                    | cut --delimiter='(' --field=2 | cut --delimiter=')' --field=1 \
                    | grep --only-matching '\..*'
               )
    found=false
    for r in "${found_rules[@]}"; do [[ "$r" != "$rule_name" ]] || found=true; done
    $found || found_rules+=("${rule_name:1}")
done

count_found_rules="${#found_rules[@]}"

echo "Proof SRULE names:"
echo "${found_rules[@]}"

[[ "$count_trusted_rules" == "$count_found_rules" ]]
