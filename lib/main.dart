import 'package:flutter/material.dart';

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
                      _deleteTask(index);
                    },
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: () {
                _addTask(context);
              },
              child: Text('Add Task'),
            ),
          ),
        ],
      ),
    );
  }

  void _addTask(BuildContext context) async {
    Task? newTask = await showDialog<Task>(
      context: context,
      builder: (BuildContext context) {
        Task task = Task('', false); // Initialize with an empty task

        return AlertDialog(
          title: Text('Add Task'),
          content: TextField(
            onChanged: (value) {
              task.text = value; // Update the task text as the user types
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

    if (newTask != null && newTask.text.isNotEmpty) {
      setState(() {
        tasks.add(newTask);
      });
    }
  }

  void _deleteTask(int index) {
    setState(() {
      tasks.removeAt(index);
    });
  }
}
