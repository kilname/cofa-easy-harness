#!/bin/sh
# Structural checks only — does not prove task correctness or exam compatibility.
set -eu
root=$(CDPATH= cd -P "$(dirname "$0")" && pwd -P)
failed=0
for item in AGENTS.md install.sh START_HERE.md .agents/skills/critical-verification/SKILL.md; do
  if [ ! -f "$root/$item" ]; then
    echo "FAIL missing: $item"
    failed=1
  fi
done
if [ "$failed" -ne 0 ]; then exit 1; fi
if ! grep -Fq 'name: critical-verification' "$root/.agents/skills/critical-verification/SKILL.md"; then
  echo 'FAIL Skill metadata missing'
  exit 1
fi
if ! grep -Fq 'git push' "$root/AGENTS.md"; then
  echo 'FAIL outbound protection instruction missing'
  exit 1
fi
echo 'PASS: expected instruction files and basic markers exist'
echo 'NOT VERIFIED: actual task correctness, complete safety, Codex discovery, Cofa exam compatibility'
