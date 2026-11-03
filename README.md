# Cofa Easy Harness v2 — Shell edition (비공식 · Codex용)

**비공식 준비 자료이며 실제 과제의 정답·코드를 포함하지 않습니다.**

과제의 정답을 제공하지 않고 Codex가 **요구사항 이해 → 질문 → 최소 구현 → 실제 테스트 → 비판적 검증 → 제출 준비**를 반복하도록 안내하는 한국어 범용 하네스입니다.

- 외부 AI 모델 호출, 원격 MCP, 자동 제출, 개인 API 키 없음.
- 원본 과제 README·정책을 덮어쓰지 않음.
- 시험에서는 공개 저장소에서 Clone하는 방식만 고려하며, 실제 응시 환경의 규칙이 우선함.

## 작업 모드 선택
- **학습 모드:** **내가 먼저 분석하고 AI는 근거로 검토**한다. 답을 선공개하지 않고, 질문의 범위에 맞춰 정확히 채점하며, 막히면 단계별로 힌트를 준다. 요청 전에는 코딩하지 않는다.
- **실전 모드(기본):** 초기 분석을 짧게 마치고 **확정된 부분부터 구현하면서 필요한 요구사항을 추가 분석**한다. 단계별 실제 실행·테스트와 제출 전 구현 근거 이해를 병행한다.
- 모드 전환은 Codex에 한 문장만 입력하면 된다. 상세 사용법은 [START_HERE.md](START_HERE.md)에 있다.

**처음 보는 사람:** [`START_HERE.md`](START_HERE.md)를 확인하세요. 입력 문장 하나만 알면 시작할 수 있습니다.

**사용법 (과제 README.md가 있는 디렉터리의 POSIX sh 지원 터미널):**

```bash
git clone --depth 1 https://github.com/kilname/cofa-easy-harness.git .cofa-harness
sh .cofa-harness/install.sh .
```

먼저 클론과 설치가 허용되는지 확인하세요. 기존 `.cofa-harness`가 있을 때 덮어쓰지 마세요.

**핵심 프롬프트:**

> README.md를 읽고 AGENTS.md 절차대로 필수 기능을 실제 구현하고 검증해줘. 미확정 핵심 사항은 먼저 질문해줘.

하네스 파일 구조는 `sh doctor.sh`, 설치기 테스트는 `sh tests/test_harness.sh`로 점검합니다. 이는 시험 환경에서의 안전성·정확성 보증이 아닙니다.

- [설치 안내](START_HERE.md)
- [범용 검증 Skill](.agents/skills/critical-verification/SKILL.md)

공식 기관·주최사와 무관한 비공식 준비 자료입니다.
