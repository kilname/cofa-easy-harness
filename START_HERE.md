# Cofa Easy Harness v2 — 한 문장만 기억하면 되는 Codex 작업 절차

이 하네스는 **범용 작업 방법**만 제공한다. 실전 과제·모범답안·개인 계정·API 키·시험 PDF는 포함하지 않는다. 공식 제품·대회 주최기관의 배포물이 아니다.

## 평소 연습: 준비 → 실행

작업 폴더에 `README.md`가 있어야 한다. POSIX sh가 있는 Linux/macOS 또는 Windows의 Git Bash·WSL 같은 셸 환경에서 하네스를 푼 폴더의 설치기를 호출한다. **PowerShell만 있는 Windows에서는 `sh` 명령이 바로 실행되지 않을 수 있다.**

```sh
sh install.sh "/path/to/project"
```

그런 다음 **프로젝트 폴더**에서 Codex를 새로 켜고 한 문장만 입력한다.

> README.md를 읽고 AGENTS.md 절차대로 실제 구현과 검증까지 진행해줘. 중요한 미확정 사항은 먼저 질문해줘.

실무자 답변이 오면: `이것은 실무자 답변이야. 확정된 범위만 관련 계획·코드에 반영하고 이어서 진행해줘: ...`

작업이 끊기면: `현재 PLAN.md, DECISIONS.md, 코드와 실제 테스트를 읽고 다음 미완료 단계부터 이어가줘.`

## 실전: **허용된 공개 GitHub 저장소**에서 Clone

PDF 기준 개인 PC 파일 업로드는 금지되어 있으며, 공개 GitHub의 Clone/다운로드와 공개 Skill 사용은 가능하다. 시험 내 외부 브라우저로 직접 GitHub를 열지 않고 **제공된 Codex 및 터미널**에서 확인한다. 아래 예시의 URL은 실제 공개된 저장소 URL로 바꿔야 한다.

```bash
# 작업공간 안에서 실행 (허용된 terminal/git 사용)
git clone --depth 1 https://github.com/kilname/cofa-easy-harness.git .cofa-harness
sh .cofa-harness/install.sh .
```

- 이미 `.cofa-harness` 폴더가 존재한다면 덮어쓰거나 삭제하지 말고 내용을 먼저 확인한다.
- `install.sh`는 **대상에 README.md가 있을 때** 일반 지침과 Skill만 설치한다. 기존 사용자 작업은 덮어쓰지 않는다.
- `sh`가 없거나 도구/외부 네트워크 사용이 차단되면 **우회하지 말고** Cofa Helper로 확인한다.
- 자동 인식이 불확실하면 Codex에게 현재 프로젝트의 `AGENTS.md`와 `.agents/skills/critical-verification/SKILL.md`를 읽었는지 확인하도록 한다.
- `.cofa-harness`가 작업 폴더 안에 남는다. **제출 파일 경로를 점검하고** 불필요한 준비 자료가 제출 대상이 되지 않는지 확인한다. 삭제는 명시적으로 승인된 범위에서만.

**시작 한 문장:** `README.md를 읽고 AGENTS.md 절차대로 필수 기능을 실제 구현하고 검증해줘. 미확정 핵심 사항은 먼저 질문해줘.`

## 제한과 주의

- 시험의 제공 Codex만 사용한다. 외부 AI 모델 연결을 MCP로 우회하지 않는다. 시험 문제·결과물 Git Push/외부 전송 금지.
- Codex가 구현할 순서는 문제 종류에 따라 달라진다. 하네스가 완성도·합격·호환성을 보증하지 않는다.
- 사용자 고유의 비공개 Skill, 사전 준비한 PDF/개인 PC 파일을 업로드하지 않는다.
- 실제 시험 응시 화면·새 안내·Cofa Helper 답변이 본 파일보다 우선한다.
- 시험 제출 확정 뒤 서술형 답변은 AI와 복사·붙여넣기 없이 직접 작성한다.

## 자체 점검

`sh doctor.sh`는 파일 구성이 있는지만 검사한다. 시험 정책 준수나 실전 문제 해결을 보증하지 않는다. 
`sh tests/test_harness.sh` 는 설치기/문서 구성에 대한 로컬 테스트다.
