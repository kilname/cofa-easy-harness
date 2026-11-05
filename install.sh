#!/bin/sh
# Local-only POSIX-sh installer. No network, pip, Python, git push or external AI calls.
set -eu

usage() {
  echo 'Usage: sh install.sh [--dry-run] [PROJECT_DIR]' >&2
  exit 2
}

dry_run=0
project_arg=.
seen_project=0
for arg in "$@"; do
  case "$arg" in
    --dry-run) dry_run=1 ;;
    -*) usage ;;
    *) if [ "$seen_project" -eq 1 ]; then usage; fi
       project_arg=$arg
       seen_project=1 ;;
  esac
done

source_dir=$(CDPATH= cd -P "$(dirname "$0")" && pwd -P) || exit 2
project_dir=$(CDPATH= cd -P "$project_arg" && pwd -P) || {
  echo 'ERROR: project directory not found' >&2
  exit 2
}
if [ "$project_dir" = "$source_dir" ] || [ ! -f "$project_dir/README.md" ]; then
  echo 'ERROR: project must have README.md and differ from the harness directory' >&2
  exit 2
fi

source_skill="$source_dir/.agents/skills/critical-verification/SKILL.md"
if [ ! -f "$source_skill" ] || [ ! -f "$source_dir/AGENTS.md" ] || [ ! -f "$source_dir/COFA_DUAL_SESSION.md" ] || [ ! -f "$source_dir/START_HERE.md" ]; then
  echo 'ERROR: incomplete harness; required instruction files not found' >&2
  exit 2
fi

agents="$project_dir/AGENTS.md"
workflow="$project_dir/COFA_WORKFLOW.md"
dual_guide="$project_dir/COFA_DUAL_SESSION.md"
start_here="$project_dir/START_HERE.md"
skill_root="$project_dir/.agents"
skill_parent="$skill_root/skills"
skill_dir="$skill_parent/critical-verification"
skill="$skill_dir/SKILL.md"
for path in "$agents" "$workflow" "$dual_guide" "$start_here" "$skill_root" "$skill_parent" "$skill_dir" "$skill"; do
  if [ -L "$path" ]; then
    echo "ERROR: refusing symbolic-link destination: $path" >&2
    exit 3
  fi
done
for path in "$agents" "$workflow" "$dual_guide" "$start_here" "$skill"; do
  if [ -e "$path" ] && [ ! -f "$path" ]; then
    echo "ERROR: destination is not a regular file: $path" >&2
    exit 3
  fi
done
for path in "$skill_root" "$skill_parent" "$skill_dir"; do
  if [ -e "$path" ] && [ ! -d "$path" ]; then
    echo "ERROR: expected directory: $path" >&2
    exit 3
  fi
done

if [ ! -f "$skill" ]; then
  echo 'ADD .agents/skills/critical-verification/SKILL.md'
  if [ "$dry_run" -eq 0 ]; then
    mkdir -p "$skill_dir"
    cp "$source_skill" "$skill"
  fi
else
  echo 'KEEP existing critical-verification Skill'
fi

if [ ! -f "$start_here" ]; then
  echo 'ADD START_HERE.md (single entrypoint)'
  if [ "$dry_run" -eq 0 ]; then cp "$source_dir/START_HERE.md" "$start_here"; fi
else
  echo 'KEEP existing START_HERE.md'
fi

if [ ! -f "$dual_guide" ]; then
  echo 'ADD COFA_DUAL_SESSION.md'
  if [ "$dry_run" -eq 0 ]; then cp "$source_dir/COFA_DUAL_SESSION.md" "$dual_guide"; fi
else
  echo 'KEEP existing COFA_DUAL_SESSION.md'
fi

if [ ! -f "$workflow" ]; then
  echo 'ADD COFA_WORKFLOW.md'
  if [ "$dry_run" -eq 0 ]; then cp "$source_dir/AGENTS.md" "$workflow"; fi
else
  echo 'KEEP existing COFA_WORKFLOW.md'
fi

if [ ! -f "$agents" ]; then
  echo 'ADD AGENTS.md'
  if [ "$dry_run" -eq 0 ]; then cp "$source_dir/AGENTS.md" "$agents"; fi
elif grep -Fq '<!-- COFA_EASY_HARNESS_V2_START -->' "$agents"; then
  echo 'KEEP existing AGENTS.md integration (already present)'
elif grep -Fq '# Codex 실무과제 하네스 — 실행 지침' "$agents"; then
  echo 'KEEP existing AGENTS.md (harness already installed)'
else
  echo 'APPEND integration to AGENTS.md (preserve existing content and make backup)'
  if [ "$dry_run" -eq 0 ]; then
    backup="$agents.backup-$(date +%Y%m%d-%H%M%S)"
    index=1
    while [ -e "$backup" ] || [ -L "$backup" ]; do
      backup="$agents.backup-$(date +%Y%m%d-%H%M%S)-$index"
      index=$((index + 1))
    done
    cp -p "$agents" "$backup"
    temp_file=$(mktemp "$project_dir/.cofa-agents.XXXXXXXX") || exit 4
    trap 'if [ -n "$temp_file" ]; then rm -f "$temp_file"; fi' 0
    cp -p "$agents" "$temp_file"
    cat >> "$temp_file" <<'APPEND'

<!-- COFA_EASY_HARNESS_V2_START -->
## Cofa Easy Harness v2 통합 지침
- 기존 프로젝트 규칙, 공식 시험 안내, 과제 README와 담당자 답변을 우선한다.
- 작업 시 COFA_WORKFLOW.md를 읽고 현재 과제에 맞게 적용한다.
- 중요 단계 후 .agents/skills/critical-verification/SKILL.md를 읽고 테스트를 실제 실행한다.
- 개인 API·외부 AI·원격 업로드·git push·감독 우회·자동 제출을 하지 않는다.
<!-- COFA_EASY_HARNESS_V2_END -->
APPEND
    mv "$temp_file" "$agents"
    temp_file=
    echo "BACKUP: $(basename "$backup")"
  fi
fi

if [ "$dry_run" -eq 1 ]; then
  echo 'DRY RUN COMPLETE: no files changed'
else
  echo 'INSTALL COMPLETE: open/restart provided Codex in the task project'
fi
