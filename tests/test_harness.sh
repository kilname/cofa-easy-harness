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
[ -f "$p/AGENTS.md" ] && [ -f "$p/COFA_WORKFLOW.md" ] && [ -f "$p/COFA_DUAL_SESSION.md" ] && [ -f "$p/START_HERE.md" ] && [ -f "$p/.agents/skills/critical-verification/SKILL.md" ] || fail 'fresh files'
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
grep -Fq '## 0-7. 실전 사용자 검토 게이트' "$p/AGENTS.md" || fail 'user review gates missing'
grep -Fq '검토 ① 시작 직후' "$p/COFA_WORKFLOW.md" || fail 'initial user review missing'
grep -Fq '검토 ② 핵심 설계 확정 전' "$p/AGENTS.md" || fail 'material design review missing'
grep -Fq '검토 ③ 최종 제출 직전' "$p/AGENTS.md" || fail 'final user evidence review missing'
grep -Fq '업무 정책이나 파괴적·외부 작업 등 명시적 승인이 필요한 결정' "$p/AGENTS.md" || fail 'user authority boundary missing'
grep -Fq '테스트 PASS를 사용자 승인으로 대체하지 않고' "$p/COFA_WORKFLOW.md" || fail 'verification distinction missing'
pass 'user material review checkpoints and boundaries installed'
grep -Fq '## 0-8. 두 터미널 A/B 공유 폴더 운영' "$p/AGENTS.md" || fail 'dual-session role instructions absent'
grep -Fq 'B는 개발을 수행하지 않는 튜터' "$p/COFA_WORKFLOW.md" || fail 'tutor is not developer instruction missing'
grep -Fq 'COFA_TO_A.md' "$p/COFA_DUAL_SESSION.md" || fail 'handoff file contract missing'
grep -Fq '실제 읽기 전용 sandbox' "$p/COFA_WORKFLOW.md" || fail 'read-only caveat missing'
[ ! -e "$p/COFA_TO_A.md" ] || fail 'installer generated unrequested handoff'
pass 'dual terminal A/B guide and local-only handoff protocol installed'
grep -Fq '## 기본 순서: B 먼저 → 최초 개발 지시서 → A 시작' "$p/COFA_DUAL_SESSION.md" || fail 'B-first execution order not found'
grep -Fq '유형: 최초 개발 요청' "$p/COFA_DUAL_SESSION.md" || fail 'first-handoff contract missing'
grep -Fq 'A가 이전 요청을 모두 읽었는지 확인' "$p/COFA_DUAL_SESSION.md" || fail 'handoff overwrite protection missing'
grep -Fq 'A가 시작한 이후에는 B의 설명을 기다리지 않고' "$p/AGENTS.md" || fail 'nonblocking A after B initial handoff missing'
grep -Fq '**B 먼저 시작:**' "$root/START_HERE.md" || fail 'quickstart B-first command missing'
pass 'B-first understanding, manual initial handoff, then concurrent learning installed'
grep -Fq '## 이것 하나만 기억: START_HERE.md' "$p/START_HERE.md" || fail 'single entrypoint missing'
grep -Fq 'START_HERE.md 읽고 개발 A로 시작해줘' "$p/START_HERE.md" || fail 'A prompt not discoverable'
grep -Fq 'COFA_DUAL_SESSION.md' "$p/START_HERE.md" || fail 'detailed role instructions not linked'
pass 'START_HERE.md single user-memorized entrypoint installed'
cp "$p/AGENTS.md" "$tmp/first-agents"
cp "$p/START_HERE.md" "$tmp/first-start"
sh "$root/install.sh" "$p" >/dev/null || fail 'second install'
cmp -s "$p/AGENTS.md" "$tmp/first-agents" || fail 'reinstall changed AGENTS'
cmp -s "$p/START_HERE.md" "$tmp/first-start" || fail 'reinstall changed START_HERE'
grep -Fq 'COFA_TO_A.md' "$p/COFA_DUAL_SESSION.md" || fail 'reinstall changed dual guide'
pass 'idempotent reinstall'
new_project keep_start
printf 'MY START NOTES\n' > "$p/START_HERE.md"
sh "$root/install.sh" "$p" >/dev/null || fail 'install preserves existing START_HERE'
grep -Fq 'MY START NOTES' "$p/START_HERE.md" || fail 'existing START_HERE overwritten'
pass 'existing START_HERE preserved'
new_project keep_guide
printf 'MY OWN INSTRUCTIONS\n' > "$p/COFA_DUAL_SESSION.md"
sh "$root/install.sh" "$p" >/dev/null || fail 'install preserves existing dual guide'
grep -Fq 'MY OWN INSTRUCTIONS' "$p/COFA_DUAL_SESSION.md" || fail 'existing dual guide overwritten'
pass 'existing dual guide preserved'
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
[ ! -e "$p/AGENTS.md" ] && [ ! -e "$p/.agents" ] && [ ! -e "$p/COFA_DUAL_SESSION.md" ] && [ ! -e "$p/START_HERE.md" ] || fail 'dry run changed files'
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
new_project symlink_guide
ln -s "$tmp/outside" "$p/COFA_DUAL_SESSION.md"
if sh "$root/install.sh" "$p" >/dev/null 2>&1; then fail 'dual guide symlink accepted'; fi
grep -Fq 'protected' "$tmp/outside" || fail 'dual guide symlink outside changed'
pass 'dual guide symlink rejected'
new_project symlink_start
ln -s "$tmp/outside" "$p/START_HERE.md"
if sh "$root/install.sh" "$p" >/dev/null 2>&1; then fail 'START_HERE symlink accepted'; fi
grep -Fq 'protected' "$tmp/outside" || fail 'START_HERE symlink outside changed'
pass 'START_HERE symlink rejected'
sh "$root/doctor.sh" >/dev/null || fail 'doctor'
pass 'doctor structure checks'
echo "PASS: $n shell harness tests"
