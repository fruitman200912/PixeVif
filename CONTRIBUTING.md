# 커밋 메시지 규칙

PixelVif는 [Conventional Commits](https://www.conventionalcommits.org/) 형식을 따른다.

## 형식

```
<type>(<scope>): <description>

[optional body]

[optional footer]
```

- `description`은 한국어로 작성한다.
- 제목 줄은 50자 내외로 간결하게 작성한다.
- 제목 끝에 마침표를 붙이지 않는다.
- 본문이 필요한 경우 "무엇을"이 아니라 "왜"를 설명한다.

## Type

| Type | 설명 |
|------|------|
| `feat` | 새로운 기능 추가 |
| `fix` | 버그 수정 |
| `refactor` | 동작 변화 없는 코드 구조 개선 |
| `test` | 테스트 추가/수정 |
| `docs` | 문서 변경 |
| `chore` | 빌드, 설정, 의존성 등 잡무성 변경 |
| `style` | 포맷팅 등 코드 의미에 영향 없는 변경 |
| `perf` | 성능 개선 |

## Scope

모노레포 구조에 맞춰 변경이 속한 영역을 명시한다.

| Scope | 대상 |
|------|------|
| `desktop` | `apps/desktop` (Tauri 클라이언트) |
| `server` | `apps/server` (Node 서버) |
| `shared` | `packages/shared` |
| `infra` | `docker-compose.yml`, CI, 루트 설정 등 |

scope를 특정하기 어려운 루트 전역 변경은 생략 가능하다: `chore: 워크스페이스 초기화`.

## 예시

```
feat(desktop): Tauri 플러그인(fs, dialog, store, updater, os) 등록
fix(server): refresh token 만료 시간 계산 오류 수정
chore(infra): docker-compose에 Redis 7 서비스 추가
docs: 커밋 메시지 규칙 문서 추가
test(desktop): App 컴포넌트 렌더링 테스트 추가
```

## Co-Authored-By

Claude Code가 작성/보조한 커밋에는 아래 트레일러를 포함한다.

```
Co-Authored-By: Claude Sonnet 5 <noreply@anthropic.com>
```
