# Feature Guide: Handling Empty State

`FlutterTablePlus` allows you to display a custom widget when the table has no data to show. This is useful for providing clear feedback to the user instead of showing an empty table.

## 1. Using the `noDataWidget` Property

The `FlutterTablePlus` widget includes a `noDataWidget` property. If you provide a widget to this property, it will be displayed automatically whenever the `data` list you provide is empty.

If `data` is empty and `noDataWidget` is `null`, the table will simply display the header with an empty body.

### How It Works

- **If `data` is NOT empty**: The table renders the rows as usual.
- **If `data` is empty AND `noDataWidget` is provided**: The `noDataWidget` is displayed in the body of the table.
- **If `data` is empty AND `noDataWidget` is `null`**: The table body remains empty.

## 2. Example

Here is how you can provide a custom widget to be displayed when there are no employees to show.

```dart
import 'package:flutter/material.dart';
import 'package:flutter_table_plus/flutter_table_plus.dart';

class MyTableScreen extends StatelessWidget {
  final List<Map<String, dynamic>> employeeData;
  final List<TablePlusColumn> columns;

  const MyTableScreen({
    super.key,
    required this.employeeData,
    required this.columns,
  });

  @override
  Widget build(BuildContext context) {
    return FlutterTablePlus(
      columns: columns,
      data: employeeData,
      
      // Provide a custom widget for the empty state
      noDataWidget: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'No Employees Found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'There are no employees to display at this time.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

## 3. Behavior Notes

- **Header**: The table header will always be visible, even when the `noDataWidget` is shown.
- **Sorting**: When the `noDataWidget` is active (because the data list is empty), sorting on column headers is automatically disabled to prevent pointless user interactions.
