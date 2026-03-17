# Scale/Zoom 구현 팁

flutter_table_plus에서 scale 기능을 구현하면서 얻은 교훈을 정리합니다.
folderview/treeview 등 동일한 스크롤 구조를 가진 패키지에서도 참고할 수 있습니다.

## 1. Ctrl+Wheel 시 스크롤과 줌 동시 발생 문제

### 문제
`Listener(onPointerSignal:)`로 Ctrl+wheel을 감지해 줌을 처리해도,
`PointerSignalEvent`는 전파를 막을 수 없어서 내부 `Scrollable`이 동시에 스크롤됩니다.

### 해결: 커스텀 ScrollPhysics

`Scrollable._receivedPointerSignal()`은 스크롤 처리 전에 `physics.shouldAcceptUserOffset()`을 호출합니다.
이 메서드가 `false`를 반환하면 `pointerSignalResolver`에 아예 등록하지 않아서 스크롤 자체가 발생하지 않습니다.

```dart
class _ScaleBlockingScrollPhysics extends ClampingScrollPhysics {
  const _ScaleBlockingScrollPhysics({super.parent});

  @override
  _ScaleBlockingScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return _ScaleBlockingScrollPhysics(parent: buildParent(ancestor));
  }

  @override
  bool shouldAcceptUserOffset(ScrollMetrics position) {
    if (HardwareKeyboard.instance.isControlPressed) return false;
    return super.shouldAcceptUserOffset(position);
  }
}
```

- `onScaleChanged`가 non-null일 때만 이 physics를 적용
- null이면 기존 `ClampingScrollPhysics` 유지
- `HardwareKeyboard.instance.isControlPressed`는 동기적으로 확인 가능

### 백업: pre-scale offset 저장

ScrollPhysics가 1차 방어선이지만, 만약을 대비해 `Listener.onPointerSignal`에서
스크롤 발생 전 offset을 저장하고 `didUpdateWidget`에서 보정합니다.

```dart
// Listener에서 (스크롤 오염 전)
_preScaleVerticalOffset = controller.offset;

// didUpdateWidget에서 (scale 변경 후)
final baseOffset = _preScaleVerticalOffset ?? controller.offset;
controller.jumpTo((baseOffset * ratio).clamp(0, maxExtent));
```

## 2. 스크롤 위치 보정

scale이 바뀌면 콘텐츠 크기가 변하므로 스크롤 위치 보정이 필요합니다.

```
offset=500, scale 1.0→2.0 일 때:
보정 없음: offset=500 그대로 → 콘텐츠 중간으로 점프
보정 있음: offset=500*2=1000 → 같은 콘텐츠 위치 유지
```

`didUpdateWidget`에서 `addPostFrameCallback`으로 보정해야 합니다.
(새 레이아웃의 `maxScrollExtent`가 계산된 후에 `jumpTo` 가능)

## 3. 스케일링 대상 구분

| 스케일 O | 스케일 X |
|---|---|
| 행 높이, 컬럼 너비 | 스크롤바 (UI chrome) |
| 폰트 크기, 패딩 | 색상, 불리언 |
| 아이콘 (FittedBox) | Border/Divider 두께 |
| 리사이즈 핸들 | Duration |

## 4. 컬럼 너비 스케일링 공식

비례 분배 로직을 변경하지 않고 스케일 적용하는 방법:

```dart
// 논리 공간에서 계산 → 결과에 scale 곱하기
final logicalWidths = _calculateColumnWidths(availableWidth / scale, columns);
final columnWidths = logicalWidths.map((w) => w * scale).toList();
```

`_resizedWidths`는 논리 단위(unscaled)로 저장해야 scale 변경에도 값이 유지됩니다.

## 5. 커스텀 아이콘 스케일링

사용자가 제공하는 Widget(예: sort icon)은 내부 size가 고정이라 SizedBox만 키워도 안 커집니다.
`FittedBox`로 감싸면 SizedBox에 맞게 자동 스케일되고, scale=1.0에서는 no-op입니다.

```dart
SizedBox(
  width: scaledIconWidth,
  child: FittedBox(child: userProvidedIcon),
)
```

## 6. Material Checkbox 주의

Material `Checkbox`의 렌더링 크기는 `materialTapTargetSize`와 `visualDensity`에 의해 결정되므로,
SizedBox wrapper를 키워도 체크박스 자체는 안 커집니다. 커스텀 체크박스가 필요합니다.
