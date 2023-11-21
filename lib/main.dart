import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'To-Do List App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: TodoListScreen(),
    );
  }
}

class TodoListScreen extends StatefulWidget {
  @override
  _TodoListScreenState createState() => _TodoListScreenState();
}

class Task {
  String text;
  bool isCompleted;

  Task(this.text, this.isCompleted);
}

class _TodoListScreenState extends State<TodoListScreen> {
  List<Task> tasks = [];

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('To-Do List'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: Checkbox(
                    value: tasks[index].isCompleted,
                    onChanged: (value) {
                      setState(() {
                        tasks[index].isCompleted = value!;
                        _saveTasks(); // Save tasks after modification
                      });
                    },
                  ),
                  title: Text(
                    tasks[index].text,
                    style: TextStyle(
                      decoration: tasks[index].isCompleted
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                    ),
                  ),
                  trailing: IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () {
                      setState(() {
                        tasks.removeAt(index);
                        _saveTasks(); // Save tasks after modification
                      });
                    },
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    _addTask(context);
                  },
                  child: Text('Add Task'),
                ),
                ElevatedButton(
                  onPressed: () {
                    _clearCompletedTasks(context);
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

  void _addTask(BuildContext context) async {
    String? newTask = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        String task = ''; // Initialize with an empty string

        return AlertDialog(
          title: Text('Add Task'),
          content: TextField(
            onChanged: (value) {
              task = value; // Update the task text as the user types
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(null); // Return null if canceled
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(task);
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );

    if (newTask != null && newTask.isNotEmpty) {
      setState(() {
        tasks.add(Task(newTask, false));
        _saveTasks(); // Save tasks after modification
      });
    }
  }

  void _clearCompletedTasks(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Clear Completed Tasks?'),
          content: Text('Are you sure you want to clear all completed tasks?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  tasks.removeWhere((task) => task.isCompleted);
                  _saveTasks(); // Save tasks after modification
                });
                Navigator.of(context).pop();
              },
              child: Text('Clear'),
            ),
          ],
        );
      },
    );
  }

  // Load tasks from shared preferences
  Future<void> _loadTasks() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? taskList = prefs.getStringList('tasks');

    if (taskList != null) {
      setState(() {
        tasks = taskList.map((task) => Task(task, false)).toList();
      });
    }
  }

  // Save tasks to shared preferences
  void _saveTasks() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> taskList = tasks.map((task) => task.text).toList();
    prefs.setStringList('tasks', taskList);
  }
}
