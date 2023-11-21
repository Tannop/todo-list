import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:todo_list/main.dart';

void main() {
  testWidgets('Add Task Test', (WidgetTester tester) async {
    await _buildAndVerifyEmptyList(tester);

    await tester.tap(find.text('Add Task'));
    await tester.pumpAndSettle();

    await _enterTaskNameAndTapAdd(tester, 'New Task');

    expect(find.text('New Task'), findsOneWidget);
  });

  testWidgets('Mark Task as Completed Test', (WidgetTester tester) async {
    await _buildAndVerifyEmptyList(tester);

    await _enterTaskNameAndTapAdd(tester, 'New Task');
    await tester.tap(find.byType(Checkbox));
    await tester.pumpAndSettle();

    expect(find.text('New Task'), findsOneWidget);
    expect(find.byIcon(Icons.check), findsOneWidget);
  });

  testWidgets('Delete Task Test', (WidgetTester tester) async {
    await _buildAndVerifyEmptyList(tester);

    await _enterTaskNameAndTapAdd(tester, 'New Task');

    await tester.tap(find.byIcon(Icons.delete));
    await tester.pumpAndSettle();

    expect(find.text('New Task'), findsNothing);
  });
}

Future<void> _buildAndVerifyEmptyList(WidgetTester tester) async {
  // Ensure a clean slate by pumping a MyApp widget
  await tester.pumpWidget(MyApp());
  // Verify that the initial task list is empty
  expect(find.text('No tasks added yet'), findsOneWidget);
}

Future<void> _enterTaskNameAndTapAdd(
    WidgetTester tester, String taskName) async {
  await tester.tap(find.text('Add Task'));
  await tester.pumpAndSettle();

  await tester.enterText(find.byType(TextField), taskName);
  await tester.pumpAndSettle();

  await tester.tap(find.text('Add'));
  await tester.pumpAndSettle();
}
