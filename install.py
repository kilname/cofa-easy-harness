#!/usr/bin/env python3
"""Install text-only Codex working instructions into a task folder without overwriting sources.
No network activity, no subprocesses, no automatic deletion, no external API calls.
"""
from __future__ import annotations
import argparse
import os
from pathlib import Path
import shutil
import sys
import tempfile
from datetime import datetime

ROOT = Path(__file__).resolve().parent
SKILL = Path('.agents/skills/critical-verification/SKILL.md')
GUIDE = Path('COFA_WORKFLOW.md')
MARK_START = '<!-- COFA_EASY_HARNESS_V2_START -->'
MARK_END = '<!-- COFA_EASY_HARNESS_V2_END -->'
APPEND = f'''\n\n{MARK_START}
## Cofa Easy Harness v2 통합 지침
- 기존 규칙, 시험 안내, 과제 README, 담당자 답변을 우선한다.
- 매 작업 시작에는 `COFA_WORKFLOW.md`를 읽고 과제 README와 대조한다.
- 중요 Phase 종료 시 `.agents/skills/critical-verification/SKILL.md`를 읽고 실제 테스트·반례·미실행을 구분한다.
- 개인 API·외부 AI·원격 업로드·git push·감독 우회·자동 제출은 하지 않는다.
{MARK_END}
'''


def atomic_write(path: Path, text: str):
    # The caller already verified that the destination is an allowed path.
    fd, temp = tempfile.mkstemp(prefix='.cofa-tmp-', suffix='.txt', dir=str(path.parent))
    try:
        with os.fdopen(fd, 'w', encoding='utf-8', newline='\n') as f:
            f.write(text)
        os.replace(temp, path)
    finally:
        if os.path.exists(temp):
            os.unlink(temp)


def backup_name(path: Path):
    stamp = datetime.now().strftime('%Y%m%d-%H%M%S')
    candidate = path.with_name(path.name + '.backup-' + stamp)
    suffix = 1
    while candidate.exists() or candidate.is_symlink():
        candidate = path.with_name(path.name + '.backup-' + stamp + '-' + str(suffix))
        suffix += 1
    return candidate


def main(argv=None):
    parser = argparse.ArgumentParser(description='Install safe, local-only Codex instructions')
    parser.add_argument('project', nargs='?', default='.', help='Existing task project containing README.md')
    parser.add_argument('--dry-run', action='store_true', help='Print intended changes; write nothing')
    args = parser.parse_args(argv)
    project = Path(args.project).expanduser().resolve()
    if project == ROOT or not project.is_dir() or not (project/'README.md').is_file():
        print('ERROR: choose an existing task project with README.md (not this harness folder)', file=sys.stderr)
        return 2

    agents = project/'AGENTS.md'
    dst_skill = project/SKILL
    workflow = project/GUIDE
    # Reject destination symlinks; the installer should never follow links to overwrite other files.
    targets = (agents, dst_skill, workflow)
    for target in targets:
        # Reject links anywhere between the task root and the intended file.
        parts_to_check = [target]
        cursor = target.parent
        while cursor != project and cursor != cursor.parent:
            parts_to_check.append(cursor)
            cursor = cursor.parent
        if any(item.is_symlink() for item in parts_to_check):
            print('ERROR: destination contains symbolic link: ' + str(target), file=sys.stderr)
            return 3
        if target.exists() and not target.is_file():
            print('ERROR: destination not a regular file: ' + str(target), file=sys.stderr)
            return 3

    actions = []
    if not dst_skill.exists():
        actions.append(('new', dst_skill, (ROOT/SKILL).read_text(encoding='utf-8')))
    else:
        print('KEEP existing Skill:', dst_skill)
    if not workflow.exists():
        actions.append(('new', workflow, (ROOT/'AGENTS.md').read_text(encoding='utf-8')))
    else:
        print('KEEP existing workflow:', workflow)
    if not agents.exists():
        actions.append(('new', agents, (ROOT/'AGENTS.md').read_text(encoding='utf-8')))
    else:
        existing = agents.read_text(encoding='utf-8-sig')
        if MARK_START in existing or existing.lstrip().startswith('# Codex 실무과제 하네스 — 실행 지침'):
            print('KEEP existing integration in AGENTS.md')
        else:
            actions.append(('append', agents, existing.rstrip() + APPEND))

    for operation, dest, contents in actions:
        print(('WOULD ' if args.dry_run else '') + operation.upper() + ': ' + str(dest))
        if args.dry_run:
            continue
        if operation == 'append':
            saved = backup_name(dest)
            shutil.copy2(dest, saved)
            print('BACKUP existing AGENTS.md:', saved.name)
        dest.parent.mkdir(parents=True, exist_ok=True)
        atomic_write(dest, contents)

    print('DRY RUN ONLY' if args.dry_run else 'INSTALL FINISHED')
    print('Note: this does not prove Codex skill discovery or exam permissions.')
    return 0

if __name__ == '__main__':
    raise SystemExit(main())
