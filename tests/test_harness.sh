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
grep -Fq '## 0-1. 작업 모드' "$p/AGENTS.md" || fail 'mode instructions missing in AGENTS'
grep -Fq '학습 모드에서는 명시적으로 요청받지 않은' "$p/COFA_WORKFLOW.md" || fail 'learning guard missing in workflow'
grep -Fq '**실전 모드:**' "$p/AGENTS.md" || fail 'practical mode missing'
pass 'learning and practical mode instructions installed'
grep -Fq '## 0-2. 학습 모드 강화' "$p/AGENTS.md" || fail 'learner-first protocol missing'
grep -Fq '원래 질문에서 요구한 범위' "$p/COFA_WORKFLOW.md" || fail 'scope-aware grading missing'
grep -Fq '배정의 불변 제약(hard constraint)' "$p/AGENTS.md" || fail 'requirements taxonomy missing'
grep -Fq '## 0-3. 실전 모드 강화' "$p/AGENTS.md" || fail 'practical learning guard missing'
grep -Fq '후속 서술형 단계의 AI 사용 및 답안 생성은 금지' "$p/AGENTS.md" || fail 'post-submission no-AI missing'
pass 'v3 learning quality and exam boundaries installed'
grep -Fq '## 0-4. 시간제한 과제: 분석과 개발을 교차 진행' "$p/AGENTS.md" || fail 'iterative analysis/build protocol missing'
grep -Fq '확정된 기반 작업은 즉시 구현한다' "$p/COFA_WORKFLOW.md" || fail 'early implementation guard missing'
grep -Fq '미확정 정책은 차단 여부를 구분한다' "$p/AGENTS.md" || fail 'policy blocking distinction missing'
pass 'timeboxed iterative build and policy boundaries installed'
grep -Fq '## 0-5. 실전 기본 동작: 개발을 멈추지 않는' "$p/AGENTS.md" || fail 'integrated practical learning missing'
grep -Fq '설명 후 별도 승인·이해 확인을 기다리지 않고' "$p/COFA_WORKFLOW.md" || fail 'non-blocking explanation missing'
grep -Fq '실제로 사용한 개념만' "$p/AGENTS.md" || fail 'concept grounding missing'
grep -Fq '## 0-6. 실전 품질 게이트' "$p/AGENTS.md" || fail 'quality gate missing'
grep -Fq '미착수 / 구현 중 / 실제 검증 통과 / 실패 / 미검증' "$p/COFA_WORKFLOW.md" || fail 'requirements evidence statuses missing'
grep -Fq '금지된 서술형 단계에는 AI 호출·답안 작성·검토를 중단한다' "$p/AGENTS.md" || fail 'exam boundary missing'
pass 'just-in-time learning, quality gates, exam boundaries installed'
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
