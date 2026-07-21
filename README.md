# PixelVif

실시간 협업 픽셀 아트 데스크톱 앱. Tauri v2 + React 클라이언트, Node.js + Express 서버로 구성된 npm workspaces 모노레포.

## 사전 요구사항

| 항목 | 버전 |
|------|------|
| Rust | 1.77+ (rustup stable) |
| Node.js | 22 LTS 권장 (20+ 필수) |
| Docker | Docker Desktop (PostgreSQL, Redis 실행용) |
| Windows | WebView2 런타임 + VS 2022 Build Tools (C++ 워크로드) |
| macOS | Xcode Command Line Tools |
| Linux | libwebkit2gtk-4.1-dev, libgtk-3-dev, libayatana-appindicator3-dev, librsvg2-dev, libssl-dev, build-essential, pkg-config, curl |

버전 확인:

```bash
rustc --version
node --version
docker --version
```

## 설치

```bash
npm install
```

루트에서 한 번만 실행하면 npm workspaces가 `apps/desktop`, `apps/server`, `packages/shared`의 의존성을 모두 설치하고 훅업한다.

`apps/server/.env.example`을 복사해 `apps/server/.env`를 만든다 (이미 있다면 값만 확인):

```bash
cp apps/server/.env.example apps/server/.env
```

## 개발 환경 실행

### 1. DB/캐시 기동 (PostgreSQL 16 + Redis 7)

```bash
npm run db:up      # 기동
npm run db:down    # 중지 및 컨테이너 제거 (데이터는 volume에 유지)
```

### 2. 서버 실행

```bash
npm run dev:server
```

`http://localhost:3000/health` 가 `{ "status": "ok" }` 를 반환하면 정상.

### 3. 데스크톱 앱 실행

```bash
npm run dev:desktop
```

Tauri 창이 뜨면 정상. (최초 실행 시 Rust 빌드로 1~2분 소요될 수 있음)

## 테스트

```bash
npm test          # 전체 워크스페이스 (Vitest)
npm run lint       # ESLint (전체 워크스페이스, flat config)
```

## 모노레포 구조

```
pixelvif/
  apps/
    desktop/     Tauri v2 + React + TS 클라이언트
    server/      Node.js + Express + Prisma 서버
  packages/
    shared/      클라이언트-서버 공유 TS 타입
  docker-compose.yml
```

## 다음 단계

- [ ] `apps/server/prisma/schema.prisma` 검토 (완료됨 — 10개 모델 확정)
- [ ] 첫 마이그레이션 실행: `cd apps/server && npx prisma migrate dev --name init`
  - 마이그레이션 SQL 생성 후 `width`/`height`/`opacity` CHECK 제약을 수동으로 추가해야 함 (스키마 파일 상단 주석 참고)
- [ ] `FR-AUTH-01`(회원가입)부터 TDD 시작 (서버)
- [ ] 인증 UI를 데스크톱 앱에 연결
- [ ] 이후 기능 명세 우선순위(P0 → P1 → P2) 순서로 진행

## 커밋 규칙

[`CONTRIBUTING.md`](./CONTRIBUTING.md) 참고 (Conventional Commits).
