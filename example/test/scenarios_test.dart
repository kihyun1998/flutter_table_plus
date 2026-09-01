import 'package:example/demo_data/demo_data.dart';
import 'package:example/scenarios/hr_dashboard_scenario.dart';
import 'package:example/scenarios/large_table_scenario.dart';
import 'package:example/shell/shell_page.dart';
import 'package:example/theme/example_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_table_plus/flutter_table_plus.dart';
import 'package:flutter_test/flutter_test.dart';

// A scenario is the package composed rather than demonstrated: several features
// switched on at once, the way a consumer would actually assemble them. What is
// asserted here is the part of that assembly the package deliberately does not
// do for you.
//
// The load-bearing group is the second one. `data` and `mergedGroups` are two
// caller lists and the table validates neither against the other — a group is
// anchored, measured and drawn on the members that are actually there, and
// nothing warns when the row order moves out from under it. Sorting is the
// ordinary way to move it, which is why the dashboard sorts inside each group
// and rebuilds both together.

void _wide(WidgetTester tester) {
  tester.view.physicalSize = const Size(1600, 1200);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
}

Future<void> _pump(WidgetTester tester, Widget child) async {
  await tester.pumpWidget(MaterialApp(
    theme: exampleTheme(Brightness.light),
    home: Scaffold(body: child),
  ));
  await tester.pumpAndSettle();
}

/// The ids in `demo.rows`, split by department in the order they appear.
List<List<String>> _rowIdsByDepartment(HrDashboardDemo demo) => [
      for (final department in HrDashboardDemo.departments)
        demo.rows
            .where((e) => e.department == department)
            .map((e) => e.id)
            .toList(),
    ];

void main() {
  group('the HR dashboard is the package assembled, not demonstrated', () {
    testWidgets('four departments, each merged into one labelled cell',
        (tester) async {
      _wide(tester);
      final demo = HrDashboardDemo();
      addTearDown(demo.dispose);

      await _pump(tester, HrDashboardStage(demo: demo));

      for (final department in HrDashboardDemo.departments) {
        expect(find.text(department), findsOneWidget,
            reason: '$department is not drawn once as a merged cell');
      }
      // Five people each, and the department's payroll beside it — the number
      // that earns a cell five rows tall. It was folded per group and dropped
      // on the floor for one commit; `unused_field` cannot see that, because it
      // only covers `_`-prefixed names.
      expect(find.textContaining('5 people · \$'),
          findsNWidgets(HrDashboardDemo.departments.length));
    });

    testWidgets('a performance bar is drawn against the range the generator '
        'actually produces', (tester) async {
      // `RandomDataGenerator` makes `0.5 + nextDouble() * 0.5`, so every score
      // is between 0.5 and 1.0. The bar divided by 5.0 under a comment claiming
      // the range was 0..5, so all twenty drew between 10% and 20% full while
      // reading `0.7`. No test could catch it — the fact lived in another file
      // and nothing asserted the fill. This is that assertion.
      _wide(tester);
      final demo = HrDashboardDemo();
      addTearDown(demo.dispose);

      await _pump(tester, HrDashboardStage(demo: demo));

      for (final employee in demo.rows) {
        expect(employee.performance, greaterThanOrEqualTo(0.5),
            reason: 'the generator changed range; the bar has to follow it');
        expect(employee.performance, lessThanOrEqualTo(1.0));
      }

      final bars = tester.widgetList<LinearProgressIndicator>(
          find.byType(LinearProgressIndicator));
      expect(bars, isNotEmpty, reason: 'no bar was drawn at all');
      for (final bar in bars) {
        expect(bar.value, greaterThanOrEqualTo(0.5),
            reason: 'a bar is drawn near-empty for a score of at least 0.5 — '
                'the fill is being computed against the wrong range');
      }
    });

    testWidgets('the header strip counts people, never group ids',
        (tester) async {
      // A group id lands in the same `Set<String>` the row ids do, so a strip
      // that counted the set would report six for five selected people the
      // moment a department row was clicked.
      _wide(tester);
      final demo = HrDashboardDemo();
      addTearDown(demo.dispose);

      await _pump(tester, HrDashboardStage(demo: demo));
      expect(find.text('20 across 4 departments'), findsOneWidget);

      demo.toggle(demo.rows.first.id, true);
      demo.toggle('dept_Engineering', true);
      await tester.pumpAndSettle();

      expect(demo.selected, hasLength(2));
      expect(find.text('1 selected · 1 department'), findsOneWidget,
          reason: 'the group id was counted as a person');
    });

    testWidgets('and says so when only a department is selected',
        (tester) async {
      // Clicking a merged row reports the group id and none of its five member
      // ids. A strip counting only people fell through to the headcount line —
      // which reads as *nothing selected* while a row sits highlighted and the
      // knob pane lists the group.
      _wide(tester);
      final demo = HrDashboardDemo();
      addTearDown(demo.dispose);

      await _pump(tester, HrDashboardStage(demo: demo));

      demo.toggle('dept_Engineering', true);
      await tester.pumpAndSettle();

      expect(find.text('20 across 4 departments'), findsNothing,
          reason: 'the strip reports nothing selected while one row is');
      expect(find.text('1 department'), findsOneWidget);
    });

    testWidgets('turning grouping off hands the table an empty group list',
        (tester) async {
      // There is no `enabled` flag — the list *is* the feature.
      _wide(tester);
      final demo = HrDashboardDemo();
      addTearDown(demo.dispose);

      await _pump(tester, HrDashboardStage(demo: demo));
      expect(demo.groups, hasLength(4));

      demo.grouped = false;
      await tester.pumpAndSettle();

      expect(demo.groups, isEmpty);
      expect(demo.rows, hasLength(20),
          reason: 'ungrouping dropped rows — it should only drop the merging');
      expect(find.textContaining('5 people'), findsNothing);
    });

    testWidgets('and takes the group ids out of the selection with them',
        (tester) async {
      // The state two siblings already clear: `EmployeeDemo.selectable` empties
      // the selection when selection goes off, for exactly this reason. A group
      // id can only have arrived by clicking a merged row, so with the merged
      // rows gone it is visible state with no control able to change it.
      _wide(tester);
      final demo = HrDashboardDemo();
      addTearDown(demo.dispose);

      await _pump(tester, HrDashboardStage(demo: demo));
      demo.toggle(demo.rows.first.id, true);
      demo.toggle('dept_Engineering', true);
      await tester.pumpAndSettle();
      expect(demo.selected, hasLength(2));

      demo.grouped = false;
      await tester.pumpAndSettle();

      expect(demo.selected, [demo.rows.first.id],
          reason: 'a group id survived the groups being turned off');
    });

    test('and the sort follows the grouping across the whole table', () {
      // Per department is only honest while there is a merged cell to explain
      // it. Ungrouped, salary ascending and resetting four times is a table
      // that looks broken.
      final demo = HrDashboardDemo();
      addTearDown(demo.dispose);

      demo.grouped = false;
      demo.sort('salary', SortDirection.ascending);

      final salaries = demo.rows.map((e) => e.salary).toList();
      expect(salaries, orderedEquals([...salaries]..sort()),
          reason: 'the sort is still per department with no groups drawn');
    });
  });

  group('sorting and merged groups are rebuilt together', () {
    test('the group list follows the sorted row order, member for member', () {
      // The mutation this exists for: sort `members` and build the group from
      // the unsorted list. Every id is still in the right group, so nothing
      // errors and no count changes — the group is simply anchored somewhere
      // other than where its members now are.
      final demo = HrDashboardDemo();
      addTearDown(demo.dispose);

      demo.sort('salary', SortDirection.ascending);

      final byDepartment = _rowIdsByDepartment(demo);
      expect(demo.groups, hasLength(HrDashboardDemo.departments.length));

      for (var i = 0; i < demo.groups.length; i++) {
        expect(demo.groups[i].rowKeys, byDepartment[i],
            reason: '${HrDashboardDemo.departments[i]} — the group list and '
                'the row order disagree after a sort');
      }
    });

    test('sorting is inside each department, not across the table', () {
      // A global sort would interleave the departments, and each group would
      // then be drawn stacked at wherever its earliest surviving member landed.
      final demo = HrDashboardDemo();
      addTearDown(demo.dispose);

      demo.sort('salary', SortDirection.ascending);

      // The departments keep their declared order...
      expect(
        demo.rows.map((e) => e.department).toSet().toList(),
        HrDashboardDemo.departments,
        reason: 'the sort escaped its group and interleaved the departments',
      );

      // ...and inside each one, salaries ascend.
      for (final department in HrDashboardDemo.departments) {
        final salaries = demo.rows
            .where((e) => e.department == department)
            .map((e) => e.salary)
            .toList();
        expect(salaries, orderedEquals([...salaries]..sort()),
            reason: '$department is not sorted');
      }
    });

    test('descending reverses it, and none returns the declared order', () {
      final demo = HrDashboardDemo();
      addTearDown(demo.dispose);

      final unsorted = demo.rows.map((e) => e.id).toList();

      demo.sort('salary', SortDirection.descending);
      final descending = demo.rows
          .where((e) => e.department == HrDashboardDemo.departments.first)
          .map((e) => e.salary)
          .toList();
      expect(descending, orderedEquals([...descending]..sort((a, b) => b - a)));

      demo.sort('salary', SortDirection.none);
      expect(demo.rows.map((e) => e.id).toList(), unsorted,
          reason: 'SortDirection.none is a real third state and did not '
              'return the rows to the order they arrived in');
    });
  });

  group('the very large table', () {
    test('the monitor is given the count these rows were generated at', () {
      // **A semantic guard, not a regression guard, and it is labelled because
      // this repo has paid for the confusion (#50/#52).** It states the
      // invariant — the count reported and the rows generated come from one
      // pass — and measured under the lazy mutation it stays **green**: reading
      // `demo.rows` here forces generation before the assertion looks, so
      // driving the notifier directly can never see the ordering that broke.
      // The regression guard for that is the last test in this group, which has
      // to go through `ShellPage` to see it at all.
      final demo = LargeTableDemo();
      addTearDown(demo.dispose);

      expect(demo.metrics.rowCount, demo.rows.length);
      expect(demo.metrics.dataGenerationTimeMs, isNotNull,
          reason: 'the panel opens with no Data Generation row at all');

      demo.rowCount = LargeTableDemo.counts[1];

      expect(demo.rows, hasLength(LargeTableDemo.counts[1]));
      expect(demo.metrics.rowCount, demo.rows.length,
          reason: 'the monitor is reporting a row count the table does not '
              'have');
    });

    test('sorting is timed, and does not regenerate', () {
      final demo = LargeTableDemo();
      addTearDown(demo.dispose);

      // Identity, not a duration. Comparing `dataGenerationTimeMs` before and
      // after would decide "did it regenerate" by whether two measurements of
      // the same work happened to produce the same millisecond — a race whose
      // verdict is worse than either answer. The rows are seeded, so the
      // *values* cannot tell a regeneration apart either; the list object can.
      final unsorted = demo.rows;

      expect(demo.metrics.lastSortTimeMs, isNull);
      demo.sort('salary', SortDirection.ascending);
      expect(demo.metrics.lastSortTimeMs, isNotNull);

      demo.sort('salary', SortDirection.none);
      expect(identical(demo.rows, unsorted), isTrue,
          reason: 'the sort rebuilt the rows it was meant to be reordering, so '
              'what was timed as a sort contains a generation');
    });

    test('changing the count drops the sort with the rows', () {
      final demo = LargeTableDemo();
      addTearDown(demo.dispose);

      demo.sort('salary', SortDirection.ascending);
      expect(demo.sortColumn, 'salary');

      demo.rowCount = LargeTableDemo.counts[1];

      expect(demo.direction, SortDirection.none,
          reason: 'the header still claims a sort the new rows are not in');
      expect(demo.sortColumn, isNull);
    });

    test('SortDirection.none clears the column, as the dashboard does', () {
      // Two scenarios answering the same question two ways is a defect waiting
      // for the first theme that distinguishes "this column, unsorted" from
      // "no column". Inert on screen today; aligned anyway.
      final demo = LargeTableDemo();
      addTearDown(demo.dispose);

      demo.sort('salary', SortDirection.ascending);
      demo.sort('salary', SortDirection.none);
      expect(demo.sortColumn, isNull);

      final dashboard = HrDashboardDemo();
      addTearDown(dashboard.dispose);
      dashboard.sort('salary', SortDirection.ascending);
      dashboard.sort('salary', SortDirection.none);
      expect(dashboard.sortColumn, isNull);
    });

    testWidgets('the stage draws the rows it was given', (tester) async {
      _wide(tester);
      final demo = LargeTableDemo();
      addTearDown(demo.dispose);

      await _pump(tester, LargeTableStage(demo: demo));

      // Observed at the screen and by count, not by naming the body's widgets.
      expect(find.byType(FlutterTablePlus<Employee>), findsOneWidget);
      expect(find.text(demo.rows.first.name), findsWidgets);
    });

    testWidgets('and the panel beside it agrees, through the real shell',
        (tester) async {
      // **The decisive test, and it has to go through `ShellPage`.** The knob
      // pane and the stage are two regions of the shell, and the stage sits
      // inside `PreviewFrame`, whose body is a `LayoutBuilder` — an element
      // that owns its own `BuildScope`, flushed from `performLayout`
      // (`packages/flutter/lib/src/widgets/layout_builder.dart:119`). So the
      // panel is built before the stage, in every frame and on every path.
      // Driving the notifier directly, as every test above does, cannot see
      // that ordering at all.
      tester.view.physicalSize = const Size(1800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(MaterialApp(
        theme: exampleTheme(Brightness.light),
        home: const ShellPage(),
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text('A hundred thousand rows'));
      await tester.pumpAndSettle();

      expect(find.text('1.0K'), findsOneWidget,
          reason: 'the monitor does not report the count it opened at');
      expect(find.text('Data Generation'), findsOneWidget,
          reason: 'the panel has no generation row, so nothing was measured '
              'before it was drawn');

      await tester.tap(find.widgetWithText(ChoiceChip, '10k'));
      await tester.pumpAndSettle();

      expect(find.text('10.0K'), findsOneWidget,
          reason: 'the panel is one selection behind the table beside it');
      expect(find.text('1.0K'), findsNothing);
    });
  });
}
