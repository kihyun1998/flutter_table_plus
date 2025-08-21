# 통합 테이블 데모 개발 계획

## 📋 프로젝트 개요

**목표**: 모든 Flutter Table Plus 기능을 시연하는 하나의 통합 데모 페이지 구축
**문제점**: 현재 여러 예제 파일에 기능이 분산되어 코드 중복이 심함
**해결책**: 모든 기능을 포함한 하나의 종합적인 데모 페이지 구축

## 🎯 포함할 기능들

### 기본 테이블 기능
- [x] **정렬 (Sorting)**: 컬럼별 오름차순/내림차순
- [x] **컬럼 재정렬 (Column Reordering)**: 드래그 앤 드롭
- [x] **셀 편집 (Cell Editing)**: 인라인 편집
- [x] **행 선택 (Row Selection)**: 단일/다중 선택

### 고급 기능
- [x] **Merged Rows**: 그룹화된 행 표시
- [x] **Expandable Rows**: 확장/축소 가능한 그룹
- [x] **Hover Buttons**: 행 호버시 액션 버튼
- [x] **Custom Cell Builders**: 커스텀 셀 렌더링
- [x] **Dynamic Heights**: 동적 행 높이
- [x] **Empty State**: 빈 데이터 상태
- [x] **Tooltip 설정**: 다양한 tooltip 동작

### 테마 및 스타일링
- [x] **다양한 테마**: Light/Dark/Custom 모드
- [x] **보더 설정**: LastRowBorderBehavior
- [x] **커스텀 색상**: 헤더, 바디, 선택 색상

## 📁 파일 구조

```
/example/lib/pages/comprehensive_demo/
├── comprehensive_table_demo.dart          # 메인 페이지
├── models/
│   ├── demo_data_model.dart               # 데이터 모델 정의
│   ├── demo_employee.dart                 # 직원 클래스
│   └── demo_department.dart               # 부서 클래스
├── data/
│   ├── demo_data_source.dart              # 샘플 데이터 생성
│   ├── demo_merged_groups.dart            # 병합 그룹 정의
│   └── demo_column_definitions.dart       # 컬럼 정의
├── widgets/
│   ├── control_panel.dart                 # 상단 제어 패널
│   ├── table_stats.dart                   # 하단 통계 표시
│   └── custom_cells/
│       ├── avatar_cell.dart               # 아바타 셀
│       ├── progress_cell.dart             # 프로그레스 바 셀
│       ├── tag_cell.dart                  # 태그 셀
│       └── chart_cell.dart                # 차트 셀
└── utils/
    ├── demo_theme_provider.dart           # 테마 관리
    └── demo_actions.dart                  # 액션 핸들러들
```

## 🗺️ 단계별 구현 계획

### Phase 1: 기본 구조 및 데이터 모델
**목표**: 컴파일 가능한 기본 구조 완성
- [ ] 파일 구조 생성
- [ ] 데이터 모델 (Employee, Department) 정의
- [ ] 기본 샘플 데이터 생성  
- [ ] 컬럼 정의 (기본 텍스트만)
- [ ] 빈 메인 페이지 생성

**체크포인트**: 에러 없이 컴파일되고 빈 테이블이 표시됨

### Phase 2: 기본 테이블 및 정렬  
**목표**: 기본 테이블이 동작하고 정렬/재정렬 가능
- [ ] 간단한 텍스트 컬럼들 표시
- [ ] 정렬 기능 추가 (onSort)
- [ ] 컬럼 재정렬 기능 (onColumnReorder)
- [ ] 기본 테마 적용

**체크포인트**: 데이터가 표시되고 컬럼을 클릭하여 정렬할 수 있음

### Phase 3: 선택 및 편집 기능
**목표**: 사용자가 행을 선택하고 편집할 수 있음
- [ ] 행 선택 (단일/다중) 구현
- [ ] 셀 편집 기능 추가
- [ ] 선택된 행 표시 UI
- [ ] 편집 콜백 처리

**체크포인트**: 체크박스로 행 선택하고 셀을 더블클릭하여 편집 가능

### Phase 4: Merged Rows
**목표**: 부서별로 그룹화된 행들이 표시됨
- [ ] 부서별 그룹 데이터 생성
- [ ] MergedRowGroup 정의
- [ ] 병합된 행 표시
- [ ] 병합 행에서 편집 가능

**체크포인트**: 같은 부서 직원들이 하나의 그룹으로 병합되어 표시됨

### Phase 5: Expandable Rows
**목표**: 팀 행을 클릭하면 멤버들이 나타남  
- [ ] 프로젝트 팀 데이터 추가
- [ ] 확장/축소 기능 구현
- [ ] 요약 행 표시
- [ ] 확장시 멤버 목록 표시

**체크포인트**: 팀 행의 화살표를 클릭하면 팀 멤버들이 확장됨

### Phase 6: Hover Buttons
**목표**: 행에 마우스 올리면 액션 버튼들이 나타남
- [ ] hoverButtonBuilder 구현
- [ ] 편집/삭제/상세보기 버튼
- [ ] 일반 행 vs 병합 행 구분
- [ ] 버튼 위치 및 테마 설정

**체크포인트**: 행 호버시 우측에 액션 버튼들이 나타나고 클릭 가능

### Phase 7: Custom Cells 및 테마
**목표**: 다양한 형태의 셀과 예쁜 테마
- [ ] 아바타 이미지 셀
- [ ] 프로그레스 바 셀 (급여)
- [ ] 태그 셀 (스킬)
- [ ] Light/Dark 테마 전환
- [ ] 커스텀 색상 설정

**체크포인트**: 텍스트가 아닌 다양한 위젯들이 셀에 표시됨

### Phase 8: Control Panel 및 최종 통합
**목표**: 완전한 기능을 가진 데모 완성
- [ ] 상단 기능 토글 패널
- [ ] 하단 통계 표시  
- [ ] 데이터 추가/삭제 버튼
- [ ] 성능 최적화
- [ ] 최종 테스트 및 정리

**체크포인트**: 모든 기능이 토글 가능하고 사용자 친화적인 UI 완성

## 📊 데이터 구조 설계

### DemoEmployee 모델
```dart
class DemoEmployee {
  final String id;
  final String name;
  final String position;
  final String department;
  final double salary;
  final String avatar;
  final double performance;
  final List<String> skills;
  final DateTime joinDate;
  final bool isActive;
}
```

### DemoDepartment 모델
```dart
class DemoDepartment {
  final String id;
  final String name;
  final String manager;
  final int memberCount;
  final double budget;
  final List<String> projects;
  final Color color;
}
```

### DemoProject 모델
```dart
class DemoProject {
  final String id;
  final String name;
  final String description;
  final List<String> memberIds;
  final DateTime startDate;
  final DateTime? endDate;
  final double progress;
}
```

## 🎨 UI 디자인 구상

```
┌─────────────────────────────────────────────────────┐
│  🎛️ Control Panel                                   │
│  [Sort] [Edit] [Select] [Theme] [Data]              │
├─────────────────────────────────────────────────────┤
│  📊 Main Table Area                                 │
│  ┌─────────────────────────────────────────────┐  │
│  │  👤 [Employee Rows]                         │  │  
│  │  🏢 [Department Groups] (Merged)            │  │
│  │  📂 [Project Teams] (Expandable)            │  │
│  └─────────────────────────────────────────────┘  │
├─────────────────────────────────────────────────────┤
│  📈 Stats: 45 rows | 3 selected | Sort: Name ↑     │
└─────────────────────────────────────────────────────┘
```

## 🔧 개발 규칙

### 에러 방지 전략
- 각 단계마다 작은 커밋으로 백업
- 점진적 추가: 기존 코드를 깨뜨리지 않고 추가
- 독립적 테스트: 각 기능을 개별적으로 테스트

### 코드 품질
- 파일별 관심사 분리
- 재사용 가능한 위젯 작성
- 명확한 네이밍 컨벤션
- 충분한 주석 및 문서화

### 각 단계별 체크포인트
1. ✅ **컴파일 성공**: 에러 없이 빌드됨
2. ✅ **기본 동작**: 해당 기능이 정상 작동됨  
3. ✅ **사용자 테스트**: 실제로 사용해보고 문제없음
4. ✅ **다음 단계 준비**: 다음 기능 추가할 준비 완료

## 📝 진행 상황 추적

- [ ] **Phase 1**: 기본 구조 및 데이터 모델
- [ ] **Phase 2**: 기본 테이블 및 정렬
- [ ] **Phase 3**: 선택 및 편집 기능
- [ ] **Phase 4**: Merged Rows
- [ ] **Phase 5**: Expandable Rows  
- [ ] **Phase 6**: Hover Buttons
- [ ] **Phase 7**: Custom Cells 및 테마
- [ ] **Phase 8**: Control Panel 및 최종 통합

---

**시작일**: 2024년
**예상 완료일**: TBD
**담당자**: Claude Code Assistant