import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:todo_list/main.dart'; // Update this import based on your project structure

void main() {
  testWidgets('Add Task Test', (WidgetTester tester) async {
    await tester.pumpWidget(MyApp());

    // Verify that the initial task list is empty
    expect(find.text('No tasks added yet'), findsOneWidget);

    // Tap on the "Add Task" button
    await tester.tap(find.text('Add Task'));
    await tester.pumpAndSettle();

    // Enter a task name in the dialog
    await tester.enterText(find.byType(TextField), 'New Task');
    await tester.pumpAndSettle();

    // Tap on the "Add" button in the dialog
    await tester.tap(find.text('Add'));
    await tester.pumpAndSettle();

    // Verify that the task is added to the list
    expect(find.text('New Task'), findsOneWidget);
  });

  testWidgets('Mark Task as Completed Test', (WidgetTester tester) async {
    await tester.pumpWidget(MyApp());

    // Verify that the initial task list is empty
    expect(find.text('No tasks added yet'), findsOneWidget);

    // Add a task to the list
    await tester.tap(find.text('Add Task'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'New Task');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Add'));
    await tester.pumpAndSettle();

    // Tap on the checkbox to mark the task as completed
    await tester.tap(find.byType(Checkbox));
    await tester.pumpAndSettle();

    // Verify that the task is marked as completed
    expect(find.text('New Task'), findsOneWidget);
    expect(find.byIcon(Icons.check), findsOneWidget);
  });

  testWidgets('Delete Task Test', (WidgetTester tester) async {
    await tester.pumpWidget(MyApp());

    // Verify that the initial task list is empty
    expect(find.text('No tasks added yet'), findsOneWidget);

    // Add a task to the list
    await tester.tap(find.text('Add Task'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'New Task');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Add'));
    await tester.pumpAndSettle();

    // Tap on the delete icon to delete the task
    await tester.tap(find.byIcon(Icons.delete));
    await tester.pumpAndSettle();

    // Verify that the task is deleted from the list
    expect(find.text('New Task'), findsNothing);
  });
}
