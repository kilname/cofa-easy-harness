# Cofa Easy Harness v2 (비공식 · Codex용)

**비공식 준비 자료이며 실제 과제의 정답·코드를 포함하지 않습니다.**

과제의 정답을 제공하지 않고 Codex가 **요구사항 이해 → 질문 → 최소 구현 → 실제 테스트 → 비판적 검증 → 제출 준비**를 반복하도록 안내하는 한국어 범용 하네스입니다.

- 외부 AI 모델 호출, 원격 MCP, 자동 제출, 개인 API 키 없음.
- 원본 과제 README·정책을 덮어쓰지 않음.
- 시험에서는 공개 저장소에서 Clone하는 방식만 고려하며, 실제 응시 환경의 규칙이 우선함.

**처음 보는 사람:** [`START_HERE.md`](START_HERE.md)를 확인하세요. 입력 문장 하나만 알면 시작할 수 있습니다.

**사용법 (이미 작업 폴더에 README.md가 있을 때):**

```bash
git clone --depth 1 https://github.com/kilname/cofa-easy-harness.git .cofa-harness
python3 .cofa-harness/install.py .
```

먼저 클론과 설치가 허용되는지 확인하세요. 기존 `.cofa-harness`가 있을 때 덮어쓰지 마세요.

**핵심 프롬프트:**

> README.md를 읽고 AGENTS.md 절차대로 필수 기능을 실제 구현하고 검증해줘. 미확정 핵심 사항은 먼저 질문해줘.

하네스 파일 구조, 설치·테스트는 `doctor.py`와 `tests/`로 확인할 수 있습니다. 이는 시험 환경에서의 안전성·정확성 보증이 아닙니다.

- [설치 안내](START_HERE.md)
- [범용 검증 Skill](.agents/skills/critical-verification/SKILL.md)

공식 기관·주최사와 무관한 비공식 준비 자료입니다.
