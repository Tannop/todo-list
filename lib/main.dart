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
        primarySwatch: Colors.deepOrange,
        visualDensity: VisualDensity.adaptivePlatformDensity,
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
            child: ReorderableListView.builder(
              itemCount: tasks.length,
              onReorder: (oldIndex, newIndex) {
                setState(() {
                  if (oldIndex < newIndex) {
                    newIndex -= 1;
                  }
                  final Task task = tasks.removeAt(oldIndex);
                  tasks.insert(newIndex, task);
                  _saveTasks(); // Save tasks after modification
                });
              },
              itemBuilder: (context, index) {
                return ReorderableDragStartListener(
                  key: Key(tasks[index].text),
                  index: index,
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.grey, // Set the border color
                        width: 1.0, // Set the border width
                      ),
                      borderRadius:
                          BorderRadius.circular(10.0), // Set the border radius
                    ),
                    margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    child: ListTile(
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
                    ),
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
    } else {
      _showErrorSnackBar('Task cannot be empty');
    }
  }

  void _clearCompletedTasks(BuildContext context) {
    // Check if there are completed tasks
    bool hasCompletedTasks = tasks.any((task) => task.isCompleted);

    if (!hasCompletedTasks) {
      // If no completed tasks, show a dialog indicating that
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('No Completed Tasks'),
            content: Text('There are no completed tasks. 😭'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
      return;
    }

    // If there are completed tasks, show the clear confirmation dialog
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
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      List<String>? taskList = prefs.getStringList('tasks');

      if (taskList != null) {
        setState(() {
          tasks = taskList.map((task) => Task(task, false)).toList();
        });
      }
    } catch (e) {
      _showErrorSnackBar('Error loading tasks');
    }
  }

  // Save tasks to shared preferences
  void _saveTasks() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      List<String> taskList = tasks.map((task) => task.text).toList();
      prefs.setStringList('tasks', taskList);
    } catch (e) {
      _showErrorSnackBar('Error saving tasks');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(seconds: 2),
      ),
    );
  }
}
