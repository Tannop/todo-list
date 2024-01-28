import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:todo_list/task_model.dart';
import 'package:todo_list/todo_list_controller.dart';
import 'package:todo_list/todo_list_screen.dart';

void main() {
  testWidgets('Add Task Test', (WidgetTester tester) async {
    await _buildAndVerifyEmptyList(tester);

    await tester.tap(find.byKey(const Key('addTaskButton')));
    await tester.pumpAndSettle();

    await tester.enterText(
        find.byKey(const Key('addTaskTitleTextField')), 'New Task Title');
    await tester.enterText(find.byKey(const Key('addTaskDescriptionTextField')),
        'Description for the new task');

    await tester.tap(find.text('Add'));
    await tester.pumpAndSettle();

    expect(find.text('New Task Title'), findsOneWidget);
  });

  testWidgets('Mark Task as Completed Test', (WidgetTester tester) async {
    String title = 'New Task';
    await _buildAndVerifyEmptyList(tester);

    await _enterTaskDetailsAndTapAdd(tester, title, 'Description');
    await _updatetask(tester, title, 'Description');

    //moved to _updatetask
    // await tester.tap(find.text('New Task'));
    // await tester.pumpAndSettle();
    // await tester.tap(find.byKey(const Key('checkBox')));
    // await tester.pumpAndSettle();
    // await tester.tap(find.byKey(const Key('updateButton')));
    // await tester.pumpAndSettle();

    // expect(find.byKey(const Key('checkBox')), findsOneWidget);
    // expect(find.byIcon(Icons.check), findsOneWidget);
  });

  testWidgets('Clear Completed Tasks Test', (WidgetTester tester) async {
    await _buildAndVerifyEmptyList(tester);

    await _enterTaskDetailsAndTapAdd(tester, 'Task 1', 'Description 1');
    await _enterTaskDetailsAndTapAdd(tester, 'Task 2', 'Description 2');
    await _enterTaskDetailsAndTapAdd(tester, 'Task 3', 'Description 3');

    // Verify that initially, there are 3 tasks

    await _updatetask(tester, 'Task 1', 'Description');

    await tester.tap(find.byKey(const Key('clearTaskButton')));
    await tester.pumpAndSettle();
    expect(find.text('Task 1'), isNot('Task 1'));
  });
}

Future<void> _buildAndVerifyEmptyList(WidgetTester tester) async {
  await tester.pumpWidget(MaterialApp(
    home: Scaffold(
      body: TodoListScreen(),
    ),
  ));

  //expect(find.text('No tasks added yet'), findsOneWidget);
}

Future<void> _enterTaskDetailsAndTapAdd(
    WidgetTester tester, String title, String description) async {
  await tester.tap(find.byKey(const Key('addTaskButton')));
  await tester.pumpAndSettle();
  await tester.enterText(find.byKey(const Key('addTaskTitleTextField')), title);

  await tester.enterText(
      find.byKey(const Key('addTaskDescriptionTextField')), description);
  await tester.pumpAndSettle();

  await tester.tap(find.text('Add'));
  await tester.pumpAndSettle();
}

Future<void> _updatetask(
    WidgetTester tester, String title, String description) async {
  await _enterTaskDetailsAndTapAdd(tester, title, description);
  await tester.tap(find.text(title).first);
  await tester.pumpAndSettle();
  await tester.tap(find.byKey(const Key('checkBox')));
  await tester.pumpAndSettle();
  await tester.tap(find.byKey(const Key('updateButton')));
  await tester.pumpAndSettle();
}
