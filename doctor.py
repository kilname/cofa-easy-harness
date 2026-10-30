#!/usr/bin/env python3
"""Small structural lint. Never claims application correctness or security."""
from pathlib import Path
import sys
root = Path(__file__).resolve().parent
paths = [root/'AGENTS.md', root/'.agents/skills/critical-verification/SKILL.md', root/'install.py', root/'START_HERE.md']
errors=[]
for p in paths:
    if not p.is_file(): errors.append('missing '+str(p.relative_to(root)))
if not errors:
    skill=paths[1].read_text(encoding='utf-8')
    if not skill.startswith('---\nname: critical-verification\n') or '\n---\n' not in skill[5:]:
        errors.append('skill frontmatter malformed')
    if '실제 실행' not in (root/'AGENTS.md').read_text(encoding='utf-8'):
        errors.append('missing evidence instruction')
    if 'git push' not in (root/'AGENTS.md').read_text(encoding='utf-8').lower():
        errors.append('missing outbound guidance')
for e in errors:print('FAIL',e)
if errors:sys.exit(1)
print('PASS: basic harness files and Skill frontmatter exist')
print('NOT VERIFIED: real Codex execution, exam acceptance, task correctness, complete security')
