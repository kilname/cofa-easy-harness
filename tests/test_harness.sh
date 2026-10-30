#!/bin/sh
set -eu
root=$(CDPATH= cd -P "$(dirname "$0")/.." && pwd -P)
tmp=$(mktemp -d) || exit 1
trap 'rm -rf "$tmp"' 0
n=0
pass() { n=$((n + 1)); echo "PASS $n: $1"; }
fail() { echo "FAIL: $1" >&2; exit 1; }
new_project() {
  p="$tmp/$1"
  mkdir -p "$p"
  printf '# sample project\n' > "$p/README.md"
  printf 'important original code\n' > "$p/app.js"
}
new_project clean
sh "$root/install.sh" "$p" >/dev/null || fail 'fresh install'
[ -f "$p/AGENTS.md" ] && [ -f "$p/COFA_WORKFLOW.md" ] && [ -f "$p/.agents/skills/critical-verification/SKILL.md" ] || fail 'fresh files'
grep -Fq 'important original code' "$p/app.js" || fail 'source preservation'
grep -Fq '# sample project' "$p/README.md" || fail 'README preservation'
pass 'fresh install preserves project source'
cp "$p/AGENTS.md" "$tmp/first-agents"
sh "$root/install.sh" "$p" >/dev/null || fail 'second install'
cmp -s "$p/AGENTS.md" "$tmp/first-agents" || fail 'reinstall changed AGENTS'
pass 'idempotent reinstall'
new_project existing
printf 'USER_POLICY: keep this\n' > "$p/AGENTS.md"
sh "$root/install.sh" "$p" >/dev/null || fail 'existing AGENTS install'
grep -Fq 'USER_POLICY: keep this' "$p/AGENTS.md" || fail 'lost user instructions'
grep -Fq 'COFA_EASY_HARNESS_V2_START' "$p/AGENTS.md" || fail 'missing append marker'
set -- "$p"/AGENTS.md.backup-*
[ "$#" -eq 1 ] && [ -f "$1" ] || fail 'backup missing'
grep -Fq 'USER_POLICY: keep this' "$1" || fail 'backup differs'
sh "$root/install.sh" "$p" >/dev/null || fail 'existing AGENTS reinstall'
count=$(grep -Fc 'COFA_EASY_HARNESS_V2_START' "$p/AGENTS.md")
[ "$count" -eq 1 ] || fail 'duplicate append'
pass 'existing AGENTS backed up and integrated once'
new_project keep_skill
mkdir -p "$p/.agents/skills/critical-verification"
printf 'ORIGINAL SKILL\n' > "$p/.agents/skills/critical-verification/SKILL.md"
sh "$root/install.sh" "$p" >/dev/null || fail 'existing skill install'
grep -Fq 'ORIGINAL SKILL' "$p/.agents/skills/critical-verification/SKILL.md" || fail 'existing skill overwritten'
pass 'existing skill preserved'
new_project dry
sh "$root/install.sh" --dry-run "$p" >/dev/null || fail 'dry run'
[ ! -e "$p/AGENTS.md" ] && [ ! -e "$p/.agents" ] || fail 'dry run changed files'
pass 'dry run no writes'
mkdir -p "$tmp/no_readme"
if sh "$root/install.sh" "$tmp/no_readme" >/dev/null 2>&1; then fail 'missing README accepted'; fi
pass 'no README rejected'
new_project symlink
printf 'protected\n' > "$tmp/outside"
ln -s "$tmp/outside" "$p/AGENTS.md"
if sh "$root/install.sh" "$p" >/dev/null 2>&1; then fail 'symlink accepted'; fi
grep -Fq 'protected' "$tmp/outside" || fail 'outside file was damaged'
pass 'symlink rejected'
sh "$root/doctor.sh" >/dev/null || fail 'doctor'
pass 'doctor structure checks'
echo "PASS: $n shell harness tests"
