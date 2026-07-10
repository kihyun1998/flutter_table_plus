# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Flutter Table Plus is a highly customizable and efficient table widget for Flutter that provides synchronized scrolling, theming, sorting, selection, column reordering, column resizing, and cell editing capabilities. The package is structured as a Flutter library with comprehensive documentation and examples.

## Package Philosophy

Flutter Table Plus follows a **"UI-only, data-agnostic"** philosophy. The package does not manage your data or state, but actively provides convenience utilities and sensible defaults to minimize boilerplate.

### Core Principles

1. **No Data Management**: The package does not store or mutate your table data internally. Data operations (sorting, filtering, pagination, etc.) remain under your control.

2. **Callback-Driven**: User interactions (sort clicks, selections, edits) are communicated back through callbacks. You decide how to handle them.

3. **Convenience First**: Where common patterns exist (gesture detection, delta normalization, etc.), the package provides ready-to-use utility widgets and helpers with sensible defaults. Users can always opt out and implement their own logic.

4. **State Management Agnostic**: Works equally well with setState, Provider, Riverpod, Bloc, or any other state management solution.

## Environment Notes

Claude Code and the user share the same Windows machine. The Flutter SDK is on `PATH`, so run `flutter test`, `flutter analyze`, and `dart format` directly — do not ask the user to run them.

The one exception is anything that opens a window or waits for input: `flutter run` needs a human to drive the app and read what is on screen. Ask for those, and say which settings to use and what to look for.

There is **no CI**. The gates in Step 8 are the only gates, and they run here.

`just_tooltip` and `flutter_checkbox` resolve from pub, but their sources sit beside this repo — `../just_tooltip` and `../flutter_checkbox`, same author, each with its own GitHub issue tracker. Read them instead of guessing from pub docs, and fix there what belongs there (Step 2).

Minimum Flutter is **3.13.0** (Dart 3.1.0), forced by `just_tooltip ^0.4.2`. The floor is not decoration: a caret range admits future patches, and a patch that raises its own SDK floor retroactively breaks the promise this package's `environment` makes.

## Common Development Commands

### Testing
```bash
flutter test                    # Package suite
flutter test test/row_tooltip_test.dart         # One file
cd example && flutter test      # Example suite — a gate, not an afterthought
```

### Code Quality
```bash
flutter analyze                 # analysis_options.yaml: flutter_lints + custom_lint
dart format lib test            # Format; the example has its own tree
```

### Example App
```bash
cd example && flutter run -d windows   # Ask the user; it needs a human to look
```

The example opens on a **home menu**, not on the playground. `lib/pages/home_page.dart` lists the demos; `playground/` turns every feature on at once, `tooltip_anchor/` shows one feature in isolation. A focused demo is the right place to verify one behaviour — that is why it exists.

### Package Development
```bash
flutter pub publish --dry-run   # Must report 0 warnings, on a clean tree
dart doc .                      # Generate API documentation
```

## 작업 flow

*Substantive 변경*(버그 수정·기능 추가·동작 변경)이면 이 8단계로 짠다. 단계를 *생략*하려면 (건너뛰는 게 아니라) *왜 이 변경엔 해당 없는지를 명시*한다 — 조용한 스킵 금지.

괄호 안 실증은 그 단계를 건너뛰었다면 놓쳤을 것이다. 전부 이 repo 에서 실제로 일어났다.

### 1. 이슈 먼저 — 관찰은 적고, 진단은 확정하지 마라

이슈 본문은 *관찰을 적는 곳*이지 원인을 단정하는 곳이 아니다. 확정한 진단이 틀리면 다음 사람이 그걸 믿고 엉뚱한 데를 판다.

- **실증(#55)**: "playground 가 800×600 테스트 표면에 안 맞으니 뷰를 키워라" 라고 못박았다. 2000×1200 으로 키워도 실패했다 — 설정 패널이 `width: 380` 고정이라 실패 로그의 제약은 `0.0<=w<=305.0` 그대로였다. 진짜 원인은 테스트 폰트였다(Step 2).
- **실증(#62)**: "섹션이 접히지 않는다, 그래서 #59 로 먼저 위젯을 갈라야 한다" 라고 썼다. `buildSection` 은 **이미 `ExpansionTile`** 이었다. 파일의 *줄 수*만 보고 *내용*을 안 읽은 결과. 본문을 정정하고 blocker 를 뗐다.
- **실증(#65)**: "오버플로가 12 곳" 이라고 추정했다. 실패 스택을 소스 줄로 집계하니 **34 건이 정확히 두 줄**에서 났다 — 공용 헬퍼 둘. 결함 수는 인스턴스 수가 아니다.
- **실증(#63)**: 아무것도 단정하지 않고 *"#61 이 끝난 뒤 읽고, 결정을 이유와 함께 기록하라"* 로 썼다. 넷 중 유일하게 맞았고, 근거와 함께 닫혔다. **판단을 유예하는 이슈**는 정당한 형태다.
- 닫는 이슈에는 **재개 조건**을 남긴다. 닫힌 이슈는 검색되지만 읽히지 않는다.

### 2. 추측 금지 — 실측한다

**코드를 *읽어서* 얻은 확신은 확신이 아니다.**

- **위젯 테스트 폰트는 글자마다 `fontSize` 크기의 정사각형**이다. 텍스트가 실제보다 훨씬 넓게 측정된다. 실증(#55): `'Performance Metrics'` 19 자 × 16px = 304px, 아이콘 20 + 간격 8 = 332px 인데 상자는 305px → 오버플로 32px. 실제 폰트로는 ~190px 이라 화면에선 멀쩡하다. **이건 성가신 게 아니라 텍스트 폭의 최악 경우 시뮬레이터**다 — 접근성 텍스트 확대가 도달할 자리를 미리 밟는다.
- **`find.text(...)` 는 화면 어디든 잡는다.** 실증(#58): 홈이 존재하지도 않는데 `find.text('Playground')` 가 통과했다 — `settings_panel.dart` 의 헤더가 같은 문자열을 그린다. 흔한 단어를 단언에 쓰면 그 테스트는 아무것도 말하지 않는다.
- **의존성 스캔은 컴파일러가 한다.** 실증(#60): `_settings`/`_columns`/`context` 만 훑고 "순수하다" 고 판단했으나, 옮기자 `_formatNumber`·`_getPerformanceColor` 가 없다고 했다. 둘 다 인자만 받는 순수 함수였다. **위치가 의존성을 만들지 않는다 — 다만 위치가 의존성을 숨긴다.**
- **캐럿 범위는 미래를 미리 허용한다.** 실증(#69): `just_tooltip: ^0.4.0` 은 0.4.2 를 **이미 해석한다**. 0.4.2 는 Flutter 3.13 을 요구하는데 `environment` 는 `>=3.10.0` 이었다. 로컬 SDK 가 3.41 이라 `pub get` 이 성공했고, 3.10~3.12 사용자에게만 깨졌다. `pub get` 성공은 제약이 정직하다는 증거가 아니다.

**경계에서 멈추지 마라 — 원인은 `pubspec` 바깥에 있을 수 있다.**

`just_tooltip` 과 `flutter_checkbox` 는 남의 코드가 아니다. 소스는 `../just_tooltip` · `../flutter_checkbox` 에 있고 각자 이슈 트래커가 있다. dep 의 동작이 궁금하면 pub 문서로 추측하지 말고 **그 리포의 소스와 CHANGELOG 를 읽는다.**

- **우회는 결함을 고치지 않고 *숨긴다*.** 실증(#33): 행 툴팁이 `child` 앵커를 피해 `pointer` 로 우회했고, 잘 작동했다. 그래서 upstream 결함은 살아남았다 — just_tooltip 0.4.2 의 CHANGELOG 가 그 결과를 적는다: *"both known downstreams had independently adopted it as a workaround."* **우회가 잘 들을수록 결함은 오래 산다.** 0.4.2 가 진짜로 고치자 이 리포 여섯 곳의 근거가 한꺼번에 거짓이 됐다(Step 7 의 낡은 근거 회수).
- **"upstream 으로 간다" 는 "upstream 탓을 한다" 가 아니다.** 물을 것은 **누구의 불변식이 깨졌는가**다. 실증(#88): `MouseRegion.onEnter` 에서 조상 툴팁을 억제하는 건 결함이 아니라 0.4.0(#22)이 *의도한 계약*이다. 깨진 건 이쪽 불변식이었다 — 그릴 게 없는 툴팁을 지었다. 고칠 자리는 여기였고, 여기서 고쳤다.
- **의존성은 벽이 아니라 양방향으로 새는 막이다.** 실증(#69/#38): upstream 이 Flutter 3.13 을 요구하자 이쪽 `environment` 가 따라 올라가야 했다. 변경은 아래로만 흐르지 않는다.
- 판정 뒤에도 우회를 택했다면 — 릴리스 사이클이 급하거나 upstream 수정이 클 때 — **우회라고 적고 upstream 이슈 번호를 남긴다.** 이유 없는 우회는 다음 사람에게 그냥 코드로 보인다. upstream 수정의 비용은 발행 한 번(+ `^` 범프)이고, 우회의 비용은 **downstream 전부가** 낸다.

**"확인 못 했다" ≠ "없다".** 미확인 사실은 갭이다. 이슈로 surfacing 하거나 사용자에게 묻는다.

### 3. 설계 판단은 코드 전에 사용자와 확정

**TDD 는 "무엇이 옳은가" 를 답해주지 않는다.** `/tdd` 는 테스트를 쓰기 전에 **seam 합의**를 요구한다.

- **순수 메커니즘**(좌표계·자료구조 — 소스로 도출 가능) → 직접 결정하고 검증 결과만 제시.
- **계약·정책**(테스트 seam, 폴백 동작, 공개 API 표면) → **묻는다.**
- **무엇을 테스트하지 *않을지*도 결정이다.** 실증(#61): 데모 페이지에서 hover 위치를 행동으로 검증하지 않기로 했다. 패키지의 `test/tooltip_anchor_test.dart` 가 이미 다섯 테스트로 못박고 있고, 데모가 다시 하면 폰트·클램프 함정을 데모 픽스처에서 또 상대해야 한다. **데모의 책임은 테마를 조립하는 것이지 just_tooltip 이 위치를 잘 잡는 것이 아니다.**
- **구조가 걸리면 먼저 말한다.** 실증(#62): "라벨로 컨트롤을 필터링" 은 `children` 이 이미 만들어진 `Widget` 이라 불가능했다 — **`Widget` 은 자기가 무엇인지 말해주지 않는다.** 세 안(자기 은닉 / 컨트롤을 데이터로 / 수용 기준 축소)을 제시하고 사용자가 고른 뒤에 코드를 시작했다.

### 4. `/tdd` — RED→GREEN 수직 슬라이스

한 번에 하나. **RED 가 났다는 사실보다 *왜* 났는지가 늘 더 많은 정보를 담는다.**

- **우연한 초록을 의심한다.** 실증(#51): 헤더 앵커 테스트가 red 였지만 원인은 배선이 아니라 픽스처였다(헤더 라벨과 셀 값이 같은 문자열이라 hover 전부터 `Text` 가 둘). 고치고 나니 이번엔 툴팁이 `screenMargin` 에 클램프돼 앵커와 무관하게 화면 중앙에 떴다(`Actual: 344`). 뷰포트를 2000px 로 넓히고 컬럼을 오른쪽으로 밀어서야 red 가 올바른 이유로 났다.
- **앞질러 구현하지 마라.** 실증(#58): Slice 1 최소 구현에 `onTap` 을 미리 넣었더니 Slice 2 가 처음부터 green 이었다. `onTap: null` 로 되돌려 물리는지 확인해야 했다 — 처음부터 비워두는 것보다 비쌌다.
- **green 이면 되돌려 red 를 본다.** 프로덕션 한 줄을 빼고 실패를 눈으로 확인한다. 실증(#52): `scaledBy` 가드를 먼저 쓰자 `Expected: same instance, Actual: <null>` — #50 의 실패 모드가 글자 그대로 재현됐다.
- **되돌릴 때 `git checkout -- <file>` 을 쓰지 마라.** 그 파일의 **미커밋 변경을 전부** 날린다. 실증: 임시 패치를 되돌리며 아직 커밋 안 한 헤더 배선까지 날렸다. `git stash push -- <file>` / `git stash pop` 을 쓴다.
- **순수 이동(pure move)에는 red 가 없다.** 대신 **특성화 테스트를 먼저** 쓴다(Step 5).

### 5. 테스트 신뢰 게이트 — 두 질문은 다르다

- **구분력이 있는가.**
  - **이름이 아니라 개수를 세라.** 실증(#59): 특성화 테스트가 컨트롤 68 개를 *이름 없이* `Switch` 25 / `DropdownButton` 12 / `Slider` 20 개수로 덮었다. 이름으로 못박았다면 섹션을 옮길 때마다 테스트를 고쳐야 했고, "테스트가 안 바뀌었다" 는 순수성의 증거가 사라졌다. 개수는 컨트롤이 늘 때 정직하게 깨진다(20 → 21).
  - **관찰 지점을 구현이 아니라 화면에 둔다.** 실증(#62): `find.byType(ExpansionTile)` 은 위젯을 갈아끼우자 즉시 깨졌다. `find.byIcon(Icons.expand_more)` 로 바꾸니 살아남았다. **리팩터에서 살아남는가는 관찰 지점을 어디에 두었느냐로 결정된다.**
- **옳은 이유로 통과하는가.**
  - **의미 가드와 회귀 가드는 다르다.** 실증(#50/#52): `scaledBy leaves an unset X tooltip theme unset` 은 수정 없이도 통과한다 — 필드를 떨어뜨려도 `null` 이니까. 회귀를 잡는 건 `carries ... through untouched` 쪽이다. 전자는 *`null` 이 폴백을 선택한다는 의미*를 지킨다. 커밋 메시지에 어느 쪽인지 적는다.
  - **행동을 관찰하되, 관찰 가능하게 만들어라.** 실증(#51): 텍스트 툴팁의 hover 대상은 `Text` 자신이라, 짧은 값이면 `child` 와 `pointer` 가 몇 px 차이라 구별되지 않는다. 잘린 긴 텍스트라야 두 앵커가 갈린다.
- **순수 이동 전엔 특성화 테스트를 쓴다.** 그물이자 **발견 도구**다. 실증(#59): 그걸 쓰다가 `ExpansionTile` 의 존재와 오버플로 34 건을 찾았다. 리팩터 전에 찍은 사진 한 장이 #59(그물) · #65(red 장치) · #62(계약) 로 세 번 값을 했다.

### 6. `/code-review`

구현·테스트가 끝나고 릴리스 전에 돌린다. 지적은 고치거나, 안 고치면 *왜 안 고치는지*를 남긴다.

- **"테스트로 그물 치지 말고 절벽을 없애라."** 실증: `scaledBy()` 가 `TablePlusTheme` 의 필드를 손으로 나열해 재구성했고, 그래서 `rowTooltipTheme` 를 잃었다(#50). 리뷰가 지적해 `copyWith` 위에 다시 썼다 — **스케일하는 여섯 필드만 이름을 부르니, 나머지는 열거되지 않아 떨어뜨릴 수 없다.** 기존 가드가 한 글자도 안 바뀌고 통과했고, 그게 그 테스트들이 계약을 테스트했다는 증거다.
- 두 축(Standards / Spec)을 병합하지 마라. **문서화되지 않은 규약은 Standards 축에 안 걸린다** — CHANGELOG·버전 범프 누락은 Spec 축이 잡았다.

### 7. 정합성 스윕 — 동작을 기술하는 모든 표면

코드만 고치고 끝나는 변경은 없다. 아무도 안 보므로 **명시적으로 훑는다**.

- **`CHANGELOG.md`** — pub.dev 는 *발행 시점의* CHANGELOG 를 스냅샷으로 박는다. 발행된 버전의 항목은 고치지 말고 새 버전을 연다. 실증(2.15.0): 미발행이었기에 잘못된 근거를 **제자리에서** 고칠 수 있었다. 발행 뒤였다면 2.16.0 을 열어 "지난 설명이 틀렸습니다" 를 덧붙였어야 했다.
- **낡은 근거 회수** — **틀린 것이 결론이 아니라 근거일 때가 더 위험하다.** 결론이 틀리면 테스트가 잡지만, 근거가 틀리면 아무 테스트도 안 깨지고 다음 사람이 정반대 결론에 도달한다. 실증(#69): `just_tooltip` 0.4.2 가 `TooltipAnchor.child` 를 **잘린 child 의 *보이는* 부분**에 앵커하도록 고치자, 여섯 곳에 적힌 *"행 중앙이 화면 밖으로 스크롤된다"* 가 거짓이 됐다. 결론(`pointer` 필요)은 그대로다 — `child` 앵커는 이제 **보이는 조각의 중앙**, 즉 커서와 무관한 지점을 겨냥한다. 근거를 안 고치면 다음 사람이 *"upstream 버그가 고쳐졌으니 `pointer` 를 빼도 되겠네"* 로 간다.
- **`README.md` · `docs/THEMING.md` · `docs/FEATURES.md`** — 공개 API 가 늘면 여기도 는다. 제약을 적었다면 그 제약이 사라질 때 **지우는 것까지** 그 이슈의 일이다. 실증: #51 이 "헤더와 셀이 anchor 를 공유한다" 를 적었고, #52 가 그걸 지웠다.
- **`example/`** — 데모는 정책이 아니라 **예시**다. 행 카드의 투명 배경·zero padding 은 카드가 성립하기 위한 조건이라 하드코딩이고, `waitDuration` 은 취향이라 컨트롤로 열었다. 라이브러리는 전부 열어두고 함정만 문서화한다.
- **lockfile** — 실증: `example/pubspec.lock` 이 어디에도 없는 `2.16.0` 을 기록하고 있었다. 스스로 모순된 트리는 태그할 물건이 아니다.
- **`.pubignore`** — 존재하면 pub 은 **git 기반 파일 목록을 끈다**(`.gitignore` 는 더 이상 적용되지 않는다). 여기선 `docs/`·`.github/`·`CLAUDE.md`·`coverage/`·`benchmark/`·`build/` 를 뺀다. **pub.dev 아카이브는 한 번 올라가면 내릴 수 없다.**

### 8. 게이트 & PR & 릴리스

CI 는 없다. 이 순서로 **직접** 돌린다:

```bash
flutter analyze                                    # 0 issues
dart format --output=none --set-exit-if-changed lib test
flutter test
cd example && flutter analyze && flutter test
flutter pub publish --dry-run                      # 0 warnings, clean tree
```

- **`cd example && flutter test` 도 게이트다.** 실증(#55): `flutter create` 가 만든 카운터 템플릿이 그대로 남아 이 리포 역사상 계속 빨간불이었다. 영구히 빨간 테스트는 없는 것보다 나쁘다 — 그 명령을 무시하도록 모두를 훈련시키고, 진짜로 뭔가 깨진 날 그걸 가린다.
- **오버플로는 테스트가 잡는다.** `pumpWidget`/`pumpAndSettle` 은 프레임워크가 잡은 예외를 되던진다. 위젯 테스트에서 오버플로가 나면 **뷰포트를 키우기 전에 왜 넘치는지 본다**(Step 2 의 폰트 항목).
- 브랜치 → `feat|fix|refactor|test(<scope>): …` → PR(`Closes #issue`) → **rebase 머지**. `main` 에 머지 커밋은 0 개다; 선형 이력을 유지한다.
- **태그는 문서·example 까지 다 들어간 뒤에 단다.** *미발행* 태그를 옮기는 비용만 0 이다. 실증(2.15.0): 머지되지 않은 PR #69 의 존재를 모른 채 `main` 끝에 태그했고, 그 트리는 `^0.4.0` + `flutter >=3.10.0` 조합이라 3.10~3.12 사용자에게 깨지는 상태였다. 아직 미발행이라 태그를 지우고 다시 달 수 있었다. **릴리스 전에 열린 PR 과 로컬 브랜치를 확인한다.**
- **`flutter pub publish` 는 되돌릴 수 없고 pub.dev 는 버전 삭제가 없다(retract 만). 에이전트가 실행하지 않는다 — 사용자가 직접.**
- **발행 여부는 물어보지 말고 조회한다.** `curl -s https://pub.dev/api/packages/flutter_table_plus`. 에이전트가 실행하지 *않는* 단계일수록 그 결과를 확인해야 한다 — 안 하면 "안 올라갔겠지" 가 조용히 설계 가정으로 승격한다. 실증(2.15.0): 사용자가 릴리스 직후 배포했는데 확인하지 않았고, 그 뒤 **발행된 버전의 CHANGELOG 항목을 제자리 수정하고 `v2.15.0` 태그를 두 번 옮겼다**. pub.dev 는 발행 시점 CHANGELOG 를 스냅샷으로 박으므로 repo 와 pub.dev 가 갈라졌다. 복구: 2.15.0 절을 발행본으로 되돌리고, 태그를 발행 트리로 되돌리고, 범프는 새 `2.15.1` 절로 옮겼다.
- **어느 커밋이 발행됐는지는 아카이브로 특정한다.** 커밋 시각 추정 금지. `archive_url` 을 받아 풀고 파일마다 `git show <commit>:<path>` 와 비교한다. **아카이브는 CRLF, git blob 은 LF 이므로 `tr -d '\r'` 로 정규화**해야 한다 — 안 하면 모든 후보가 0/N 으로 나온다. 실증(2.15.0): `4d2409c` 와 `5546aae` 는 아카이브에 실리는 142 개 파일이 완전히 동일하다(차이는 `example/pubspec.lock` 뿐인데 그건 안 실린다). 시각으로 찍었다면 맞는지 알 방법이 없었다.
- **모든 후보가 실패하면 후보가 아니라 검사기를 의심한다.** 반대로 전부 성공해도 같다. `curl .../versions/9.9.9` 가 404 를 주는지 먼저 보고 나서 `2.15.1` 의 200 을 믿는다. pub.dev 의 패키지 목록 엔드포인트는 캐시되므로, 방금 올린 버전은 목록에 없고 버전 엔드포인트에는 있다.
- **태그와 GitHub Release 는 발행을 *확인한 뒤* 단다.** 순서를 뒤집으면 태그가 가리키는 트리와 발행된 아카이브가 갈라진다.

## Architecture Overview

### Core Components

- **`lib/flutter_table_plus.dart`**: Main library export file
- **`lib/src/widgets/flutter_table_plus.dart`**: Main FlutterTablePlus widget implementation
- **`lib/src/widgets/table_header.dart`**: Header row implementation with sorting, reordering, and column resizing
- **`lib/src/widgets/table_body.dart`**: Body rows `ListView` — a pure row renderer. Implements the `RowLocator` port (`indexAt` / `idsBetween`) via a public `TablePlusBodyState`, accessed by the parent through `GlobalKey`, so drag-selection logic can resolve coordinates to row IDs without owning the body's caches
- **`lib/src/widgets/row_locator.dart`**: `RowLocator` — the narrow port (`indexAt(localY)`, `idsBetween(start, end)`) that decouples drag selection from the body's internal caching strategy
- **`lib/src/widgets/drag_selection_controller.dart`**: `DragSelectionController` — the drag-to-select gesture state machine (threshold, lazy anchor, sticky range, emit), rubber-band geometry, and the auto-scroll loop (owns its own `Timer`; scroll application + repaint are injected as callbacks). Extracted from the table widget and driven by primitive coordinates so it is unit-testable without pumping a widget — including the timer loop via `fakeAsync` (see `test/drag_selection_controller_test.dart`)
- **`lib/src/widgets/synced_scroll_controllers.dart`**: Synchronized scrolling logic
- **`lib/src/widgets/custom_ink_well.dart`**: Custom tap handling widget
- **`lib/src/widgets/table_plus_merged_row.dart`**: Merged row rendering widget for grouped data display

### Data Models

- **`lib/src/models/table_column.dart`**: TablePlusColumn model defining column properties
- **`lib/src/models/table_columns_builder.dart`**: Builder pattern for creating ordered columns safely
- **`lib/src/models/merged_row_group.dart`**: MergedRowGroup and MergeCellConfig models for grouped row functionality
- **`lib/src/models/theme/theme.dart`**: Comprehensive theming system with nested theme classes
- **`lib/src/models/tooltip_behavior.dart`**: Tooltip display behavior configuration

### Utility Classes

- **`lib/src/utils/table_row_height_calculator.dart`**: External row height calculation utility for dynamic heights with TextOverflow.visible support
- **`lib/src/utils/text_overflow_detector.dart`**: Text overflow detection utility for tooltip and layout decisions

### Key Architectural Patterns

1. **Generic, Data-Agnostic Rows**: `FlutterTablePlus<T>` takes `List<T>`; the row's identity comes from the required `rowId: String Function(T)`. Columns read values through `valueAccessor`, so rows can be maps, models, or anything else
2. **Builder Pattern**: TableColumnsBuilder prevents order conflicts and manages column ordering automatically
3. **Synchronized Scrolling**: Header and body each have their own horizontal `SingleChildScrollView`; `SyncedScrollControllers` synchronizes them through a shared-controller pattern (the body is the user-input master, the header uses `NeverScrollableScrollPhysics` and is driven by the body's position). The horizontal scrollbar is a third sync target. Vertical scroll lives inside the body's `ListView`
4. **Merged Row Groups**: MergedRowGroup system for visually combining multiple data rows with configurable merge behavior per column
5. **Theme Composition**: Nested theme classes (TablePlusTheme, TablePlusHeaderTheme, etc.) for granular styling control
6. **Row Widget Polymorphism**: TablePlusRowWidget abstract class enables different row types (_TablePlusRow for normal rows, TablePlusMergedRow for grouped rows) with consistent ListView.builder interface
7. **Drag Selection (single coordinate frame)**: A `Listener` wraps the body's horizontal `Scrollable` from the *outside*, so its `RenderBox` is stationary in screen — `event.localPosition` is therefore viewport-local on both axes. The widget's pointer handlers are thin translators that forward `down`/`move`/`up`/`cancel` to a `DragSelectionController`, which owns the gesture state machine, the auto-scroll loop (its own `Timer`, with scroll application injected as callbacks), and the content-anchored rubber-band origin (`downLocal − hDelta/vDelta` on both axes). Row lookups go through the `RowLocator` port the body implements

### Widget Lifecycle

FlutterTablePlus follows a composition pattern where:
- Header and body are separate widgets, each with its own horizontal `SingleChildScrollView`; `SyncedScrollControllers` keeps their positions aligned
- Drag selection is owned by a `DragSelectionController` (constructed in `_FlutterTablePlusState.initState`); a viewport-level `Listener` forwards pointer events to it, and the body is queried for row-index lookups through the `RowLocator` port it implements (reached via `GlobalKey<TablePlusBodyState<T>>`)
- Column reordering updates the column map and triggers rebuilds
- Column resizing is managed internally via `_resizedWidths` state map; `onColumnResized` callback notifies externally for persistence
- Selection state is managed externally and passed down as props
- Editing state can coexist with selection state
- Merged row groups are treated as single units for selection and editing operations

## Important Implementation Details

- **Column Order Management**: Column order is managed by the `order` field in TablePlusColumn. Use TableColumnsBuilder to prevent order conflicts
- **Selection Requirements**: `rowId` must return a unique, stable id per row - duplicate ids cause unexpected behavior. `MergedRowGroup.rowKeys` are matched against those same ids
- **Null Safety for Features**: Setting `onSort: null` completely hides sort icons and disables sorting. Setting `onColumnReorder: null` disables drag-and-drop. Setting `resizable: false` (default) hides resize handles entirely
- **Column Resizing**: `resizable: true` enables drag-to-resize on header cell right edges. Resize widths are internal layout state (`_resizedWidths`); `onColumnResized` callback fires once on drag end for persistence. Resized columns keep fixed width while unresized columns redistribute proportionally. `minWidth`/`maxWidth` per column are enforced via `clamp()` in all layout calculation paths. Selection column (`__selection__`) is excluded from resizing. Resize handle theming via `TablePlusHeaderTheme.resizeHandleWidth` and `resizeHandleColor`
- **Coexisting Features**: Selection and editing modes can coexist in the same table simultaneously
- **Theme Architecture**: Uses nested theme classes (TablePlusTheme > TablePlusHeaderTheme/TablePlusBodyTheme/etc.) for granular control. Three fields are `TablePlusTooltipTheme`-typed: `tooltipTheme` (cells, non-null), `rowTooltipTheme` and `headerTooltipTheme` (both nullable, both falling back to `tooltipTheme` at the call site in `flutter_table_plus.dart`). `scaledBy()` is built on `copyWith` and **names only the six sub-themes it scales** — the scrollbar and the three tooltip themes are never enumerated, so a field added later cannot be dropped by forgetting to list it. That is not a style choice: hand-listing the fields is exactly how `rowTooltipTheme` went missing (#50), and the bug was invisible because `scaledBy(1.0)` returns the receiver untouched
- **Custom Cell Rendering**: `statefulCellBuilder` (the only custom-cell hook; there is no `cellBuilder`) renders any Flutter widget in a cell, but can impact performance with large datasets
- **Sort Cycle Configuration**: Sort cycle order is configurable between ascending-first and descending-first patterns
- **Tooltip Control**: Fine-grained tooltip behavior control for both cells and headers via `tooltipBehavior` and `headerTooltipBehavior` properties. Two kinds of body tooltip, gated differently: a **text** tooltip exists to reveal truncated glyphs, so it is gated on ellipsis / non-empty text and its hover target is the `Text` itself. A **widget** tooltip (`tooltipBuilder`) draws unrelated content, so only `TooltipBehavior.never` suppresses it and its hover target is the whole cell. `TooltipResolver.shouldShow` takes `hasWidgetTooltip` to keep the two apart. A **row** tooltip (`rowTooltipBuilder`) wraps the whole row in `table_body.dart`'s `itemBuilder` with `TooltipAnchor.pointer` — hover region and anchor must differ, since a row is `contentWidth` wide. Nesting is arbitrated by just_tooltip (innermost wins), so this package holds no priority logic — but "wins" is decided at `MouseRegion.onEnter`, *before* the inner tooltip knows whether it has anything to draw. So **a tooltip that cannot show must never be built**: `wrapWithTooltip` returns the child unwrapped when the resolved message is empty and `hideOnEmptyMessage` holds, because otherwise the cell suppresses the row card and then declines to draw, and hovering it shows nothing at all. `table_header_cell.dart` has always guarded this way (`label.isEmpty`); the cell could not, because its message is only known after `tooltipFormatter` runs. Beware: `TooltipBehavior.always` gives every ellipsized column a tooltip whether or not its text is cut, which leaves a row card nowhere to appear. A row's hover region does cover empty cells — `RenderMouseRegion` is opaque and `hitTestSelf`s, so a zero-width `Text` under the pointer is irrelevant; do not "fix" that by making rows hit-test opaque
- **Tooltip Anchoring**: `TablePlusTooltipTheme.anchor` decides what a tooltip is positioned against. Cells read `tooltipTheme.anchor`, headers read `headerTooltipTheme.anchor` (falling back to the cells'), both defaulting to `TooltipAnchor.child`. `FlutterTooltipPlus.anchor` is a **nullable override** resolved against the theme — pass nothing and the theme decides. The row tooltip passes `TooltipAnchor.pointer` explicitly and never reads the theme: `pointer` is a correctness requirement there, and keeping it off the theme is also what stops `rowTooltipTheme`'s fallback from dragging a cell-oriented anchor onto the row card. **Why `child` is wrong for a row** (corrected in #69, and the old reason is now false): since just_tooltip 0.4.2 a `child` anchor targets the *visible* part of a clipped child, so it lands on the centre of whatever slice of the row is on screen — visible, but unrelated to where along the row the cursor is. It does **not** aim off screen any more. Under `pointer`, `alignment` changes meaning: a point has no target edges, so alignment picks which of the tooltip's *own* edges lands on the cursor
- **Merged Rows**: MergedRowGroup functionality allows grouping consecutive rows with configurable merge behavior per column. Supports custom content, selection, and editing within merged cells
- **Row Ink and Hover**: `TablePlusRowWidget` is a `StatefulWidget`; `TablePlusRowStateBase` owns the hover flag and wires `RowInteractionShell` once for every row type. Hover-button overlays are supported via `hoverButtonBuilder`, and the hover-tracking `MouseRegion` is installed only when one is set. Which ink appears is gated by **which callbacks are wired**, not by the colors: `InkWell` paints a splash/highlight only with a primary-button callback, a hover highlight with any callback. Passing a `null` color does not disable ink - it selects the framework default (`Colors.transparent` disables it, per `TablePlusBodyTheme` docs)
- **Column Width Constraints**: `minWidth`/`maxWidth` on `TablePlusColumn` are enforced in all `_calculateColumnWidths` paths via `clamp()` — both for resize drag and normal proportional layout distribution
- **Drag Selection Coordinate Model**: All drag-selection coordinates live in a single viewport-local reference frame. The `Listener` is placed at the body's viewport (outside the body's horizontal `SingleChildScrollView`), so `event.localPosition` is viewport-local on both axes — eliminating the asymmetry that previously existed when the body slid horizontally under a stale captured screen origin. Auto-scroll edge zones, the rubber band rectangle, and content-anchored origin (`downLocal − hDelta/vDelta`) all use this single frame. This gesture state machine + geometry is encapsulated in `DragSelectionController` (unit-tested in isolation via a fake `RowLocator`); the widget's pointer handlers are thin translators, and row-index lookups are routed to the body through the `RowLocator` port (reached via `GlobalKey<TablePlusBodyState<T>>`)

## Documentation Structure

User-facing documentation lives in the `docs/` directory:
- FEATURES.md: Sorting, selection, editing, merged rows, dynamic heights, empty state, advanced columns
- THEMING.md: Complete theming guide
- MIGRATION.md: Breaking-change migration notes

`docs/agents/` holds the agent-facing conventions referenced under "Agent skills" below.

`docs/` and `CLAUDE.md` are excluded from the published archive by `.pubignore` — they are read on GitHub, where their relative links resolve.

There is no `CONTEXT.md` and no `docs/adr/` yet. Per `docs/agents/domain.md`, proceed silently; the domain-modelling skills create them lazily when a term or decision actually gets resolved.

## Example App Structure

`example/` is a package of its own, with its own analyzer run and its own suite. Both are gates.

- `lib/pages/home_page.dart` — lists the demos. `_DemoTile` was extracted only once a second entry existed; an abstraction pulled from a one-item list rarely fits the second item
- `lib/pages/playground/` — every feature on at once, at a scale that stresses the table. This is where feature *combinations* are exercised, which is where tables actually break. Its settings live in `models/playground_settings.dart`, its columns in `playground_columns.dart`, its theme in `buildPlaygroundTheme`; all three are pure functions of `PlaygroundSettings`, free of `BuildContext`
- `lib/pages/playground/widgets/settings_controls.dart` — `SettingsControl` carries a control's **label beside the widget**, because a `Widget` will not tell you what it is and the panel's search has to ask. `SettingsSection` replaced `ExpansionTile` for the same reason, plus one more: `ExpansionTile` owns its expanded state, so a search could not open a section without stealing the state it must give back
- `lib/pages/tooltip_anchor/` — one feature, isolated. The value it truncates and the heading it truncates are not decoration: a text tooltip's hover target is the `Text` itself, so with a short value both anchors land in the same place and the demo demonstrates nothing

## Agent skills

### Issue tracker

Issues are tracked in this repo's GitHub Issues via the `gh` CLI; external PRs are not a triage surface. See `docs/agents/issue-tracker.md`.

### Triage labels

Default vocabulary (`needs-triage` / `needs-info` / `ready-for-agent` / `ready-for-human` / `wontfix`). See `docs/agents/triage-labels.md`.

### Domain docs

Single-context: `CONTEXT.md` + `docs/adr/` at the repo root. See `docs/agents/domain.md`.

# important-instruction-reminders
Do what has been asked; nothing more, nothing less.
NEVER create files unless they're absolutely necessary for achieving your goal.
ALWAYS prefer editing an existing file to creating a new one.
NEVER proactively create documentation files (*.md) or README files. Only create documentation files if explicitly requested by the User.