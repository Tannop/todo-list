import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:todo_list/task_model.dart';
import 'todo_list_controller.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'To-Do List App',
      theme: ThemeData(
        primarySwatch: Colors.deepOrange,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: TodoListScreen(),
    );
  }
}

class TodoListScreen extends StatelessWidget {
  final TodoListController taskController = Get.put(TodoListController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('To-Do List'),
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildSortDropdown(),
          Expanded(
            child:
                Obx(() => _buildTaskList(taskController.filterAndSortTasks())),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    taskController.addTask(context);
                  },
                  child: Text('Add Task'),
                ),
                ElevatedButton(
                  onPressed: () {
                    taskController.clearCompletedTasks();
                  },
                  child: Text('Clear Completed'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        controller:
            TextEditingController(text: taskController.searchController.value),
        onChanged: (value) {
          taskController.updateSearch(value);
        },
        decoration: InputDecoration(
          labelText: 'Search by Title or Description',
          prefixIcon: Icon(Icons.search),
        ),
      ),
    );
  }

  Widget _buildSortDropdown() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text('Sort By: '),
          DropdownButton<String>(
            value: taskController.sortBy.value,
            onChanged: (value) {
              taskController.sortBy.value = value!;
            },
            items: ['Title', 'Date', 'Status']
                .map((sortOption) => DropdownMenuItem<String>(
                      value: sortOption,
                      child: Text(sortOption),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskList(List<Task> filteredTasks) {
    return ListView.builder(
      itemCount: filteredTasks.length,
      itemBuilder: (context, index) {
        Task task = filteredTasks[index];
        return Card(
          child: ListTile(
            title: Text(task.title),
            subtitle: Text(task.description),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Mark as Complete: '),
                Checkbox(
                  value: task.status == 'COMPLETED',
                  onChanged: (bool? value) {
                    taskController.toggleStatus(task);
                  },
                ),
              ],
            ),
            onTap: () {
              taskController.updateTask(context, task);
            },
          ),
        );
      },
    );
  }
}
