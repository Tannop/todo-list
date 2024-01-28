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
        title: const Text('To-Do List'),
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
                  child: const Text('Add Task'),
                ),
                ElevatedButton(
                  onPressed: () {
                    taskController.clearCompletedTasks();
                  },
                  child: const Text('Clear Completed'),
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
        decoration: const InputDecoration(
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
          const Text('Sort By: '),
          Obx(() => DropdownButton<String>(
                value: taskController.sortBy.value,
                onChanged: (String? value) {
                  if (value != null) {
                    taskController.sortBy.value = value;
                  }
                },
                items: ['Title', 'Date', 'Status']
                    .map((sortOption) => DropdownMenuItem<String>(
                          value: sortOption,
                          child: Text(sortOption),
                        ))
                    .toList(),
              )),
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
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(task.description),
                const SizedBox(height: 8), // Adjust spacing as needed
                Text('Status: ${task.status}'),
              ],
            ),
            onTap: () {
              //print("This is the id: " + task.id);
              taskController.updateTask(context, task);
            },
          ),
        );
      },
    );
  }
}
