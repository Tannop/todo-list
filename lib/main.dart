import 'dart:convert';
import 'package:flutter/material.dart';
// import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

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

String status = 'IN_PROGRESS';

class Task {
  String id;
  String title;
  String description;
  DateTime createdAt;
  String image;
  String status;

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.createdAt,
    required this.image,
    required this.status,
  });
}

class _TodoListScreenState extends State<TodoListScreen> {
  List<Task> tasks = [];
  TextEditingController searchController = TextEditingController();
  String sortBy = 'Date'; // Default sorting by Date

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
          _buildSearchBar(),
          _buildSortDropdown(),
          Expanded(
            child: _buildTaskList(),
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

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        controller: searchController,
        onChanged: (value) {
          setState(
              () {}); // Trigger a rebuild to update the task list based on the search query
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
            value: sortBy,
            onChanged: (value) {
              setState(() {
                sortBy = value!;
              });
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

  Widget _buildTaskList() {
    List<Task> filteredTasks = _filterAndSortTasks();

    return ListView.builder(
      itemCount: filteredTasks.length,
      itemBuilder: (context, index) {
        Task task = filteredTasks[index];
        // Text complete and inprogress
        // return Card(
        //   child: ListTile(
        //     title: Text(task.title),
        //     subtitle: Text(task.description),
        //     trailing: Row(
        //       mainAxisSize: MainAxisSize.min,
        //       children: [
        //         // Changed status bar update
        //         const Text('Mark as: '),
        //         ElevatedButton(
        //           onPressed: () {
        //             _toggleStatus(task);
        //           },
        //           style: ElevatedButton.styleFrom(
        //             foregroundColor: Colors.white,
        //             backgroundColor: task.status == 'IN_PROGRESS'
        //                 ? Colors.red
        //                 : Colors.green,
        //             padding: EdgeInsets.symmetric(
        //                 horizontal: 10,
        //                 vertical: 5), // Adjust padding as needed
        //           ),
        //           child: Text(
        //             task.status == 'IN_PROGRESS' ? 'Complete' : 'In Progress',
        //             style: TextStyle(fontSize: 12),
        //           ),
        //         ),
        //       ],
        //     ),
        //     onTap: () {
        //       _updateTask(context, task);
        //     },
        //   ),
        // );
        return Card(
          child: ListTile(
            title: Text(task.title),
            subtitle: Text(task.description),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Changed status bar update to Checkbox
                const Text('Mark as Complete: '),
                Checkbox(
                  value: task.status == 'COMPLETED',
                  onChanged: (bool? value) {
                    _toggleStatus(task);
                  },
                ),
              ],
            ),
            onTap: () {
              _updateTask(context, task);
            },
          ),
        );
      },
    );
  }

  List<Task> _filterAndSortTasks() {
    // Filter tasks based on the search query
    String query = searchController.text.toLowerCase();
    List<Task> filteredTasks = tasks
        .where((task) =>
            task.title.toLowerCase().contains(query) ||
            task.description.toLowerCase().contains(query))
        .toList();

    // Sort tasks based on the selected sort option
    switch (sortBy) {
      case 'Title':
        filteredTasks.sort((a, b) => a.title.compareTo(b.title));
        break;
      case 'Date':
        filteredTasks.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        break;
      case 'Status':
        filteredTasks.sort((a, b) => a.status.compareTo(b.status));
        break;
    }

    return filteredTasks;
  }

  void _addTask(BuildContext context) async {
    Task? newTask = await showDialog<Task>(
      context: context,
      builder: (BuildContext context) {
        String id = Uuid().v4(); // Generate UUID
        String title = '';
        String description = '';
        DateTime createdAt = DateTime.now();
        String image = '';
        String status = 'IN_PROGRESS';

        return AlertDialog(
          title: Text('Add Task'),
          content: SingleChildScrollView(
              child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                maxLength: 100,
                decoration: InputDecoration(labelText: 'Title'),
                onChanged: (value) {
                  title = value;
                },
              ),
              TextField(
                decoration: InputDecoration(labelText: 'Description'),
                onChanged: (value) {
                  description = value;
                },
              ),
              ListTile(
                title: Text('Date'),
                subtitle: Text(createdAt.toLocal().toString()),
                onTap: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: createdAt,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2101),
                  );

                  if (pickedDate != null) {
                    setState(() {
                      createdAt = pickedDate;
                    });
                  }
                },
              ),
              ElevatedButton(
                onPressed: () async {
                  XFile? pickedImage = await ImagePicker()
                      .pickImage(source: ImageSource.gallery);

                  if (pickedImage != null) {
                    setState(() {
                      image = pickedImage.path;
                    });
                  }
                },
                child: Text('Select Image'),
              ),
              // Row(
              //   children: [
              //     ElevatedButton(
              //       onPressed: () {
              //         setState(() {
              //           status = 'IN_PROGRESS';
              //         });
              //       },
              //       style: ElevatedButton.styleFrom(
              //         primary: status == 'IN_PROGRESS' ? Colors.red : null,
              //       ),
              //       child: Text(
              //         'In Progress',
              //         style: TextStyle(color: Colors.white),
              //       ),
              //     ),
              //     SizedBox(width: 10),
              //     ElevatedButton(
              //       onPressed: () {
              //         setState(() {
              //           status = 'COMPLETED';
              //         });
              //       },
              //       style: ElevatedButton.styleFrom(
              //         primary: status == 'COMPLETED' ? Colors.green : null,
              //       ),
              //       child: Text(
              //         'Completed',
              //         style: TextStyle(color: Colors.white),
              //       ),
              //     ),
              //   ],
              // )
            ],
          )),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(null); // Return null if canceled
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                try {
                  // Validate fields before creating the task
                  _validateTaskFields(title, createdAt, status, image);
                  Task task = Task(
                    id: id,
                    title: title,
                    description: description,
                    createdAt: createdAt,
                    image: image,
                    status: status,
                  );
                  Navigator.of(context).pop(task);
                } catch (e) {
                  _showErrorSnackBar(e.toString());
                }
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );

    if (newTask != null) {
      setState(() {
        tasks.add(newTask);
        _saveTasks(); // Save tasks after modification
      });
    }
  }

  void _updateTask(BuildContext context, Task task) async {
    Task? updatedTask = await showDialog<Task>(
      context: context,
      builder: (BuildContext context) {
        String title = task.title;
        String description = task.description;
        DateTime createdAt = task.createdAt;
        String image = task.image;
        String status = task.status;

        return AlertDialog(
          title: Text('Update Task'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  maxLength: 100,
                  decoration: InputDecoration(labelText: 'Title'),
                  controller: TextEditingController(text: title),
                  onChanged: (value) {
                    title = value;
                  },
                ),
                TextField(
                  decoration: InputDecoration(labelText: 'Description'),
                  controller: TextEditingController(text: description),
                  onChanged: (value) {
                    description = value;
                  },
                ),
                ListTile(
                  title: Text('Date'),
                  subtitle: Text(_formatDate(createdAt)),
                  onTap: () async {
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: createdAt,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2101),
                    );

                    if (pickedDate != null) {
                      setState(() {
                        createdAt = pickedDate;
                      });
                    }
                  },
                ),
                ElevatedButton(
                  onPressed: () async {
                    XFile? pickedImage = await ImagePicker()
                        .pickImage(source: ImageSource.gallery);

                    if (pickedImage != null) {
                      setState(() {
                        image = pickedImage.path;
                      });
                    }
                  },
                  child: Text('Select Image'),
                ),
              ],
            ),
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
                try {
                  // Validate fields before updating the task
                  _validateTaskFields(title, createdAt, status, image);
                  Task updatedTask = Task(
                    id: task.id,
                    title: title,
                    description: description,
                    createdAt: createdAt,
                    image: image,
                    status: status,
                  );
                  Navigator.of(context).pop(updatedTask);
                } catch (e) {
                  _showErrorSnackBar(e.toString());
                }
              },
              child: Text('Update'),
            ),
          ],
        );
      },
    );

    if (updatedTask != null) {
      setState(() {
        tasks.removeWhere((t) => t.id == task.id);
        tasks.add(updatedTask);
        _saveTasks(); // Save tasks after modification
      });
    }
  }

  String _formatDate(DateTime dateTime) {
    return DateFormat('MMMM d, yyyy hh:mm a').format(dateTime);
  }

  void _validateTaskFields(
      String title, DateTime createdAt, String status, String image) {
    if (title.isEmpty || title.length > 100) {
      throw 'Title must not be empty and should be less than 100 characters.';
    }
    //Here
    // Add additional validations for other fields
    // Ensure that createdAt is in the correct format, image is Base64 encoded, etc.
    // Handle errors by throwing exceptions with appropriate messages.
  }

  void _clearCompletedTasks(BuildContext context) {
    // Check if there are completed tasks
    bool hasCompletedTasks = tasks.any((task) => task.status == 'COMPLETED');

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
                  tasks.removeWhere((task) => task.status == 'COMPLETED');
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
          tasks = taskList.map((taskJson) {
            Map<String, dynamic> taskMap = json.decode(taskJson);
            return Task(
              id: taskMap['id'],
              title: taskMap['title'],
              description: taskMap['description'],
              createdAt: DateTime.parse(taskMap['createdAt']),
              image: taskMap['image'],
              status: taskMap['status'],
            );
          }).toList();
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
      List<String> taskList = tasks
          .map((task) => json.encode({
                'id': task.id,
                'title': task.title,
                'description': task.description,
                'createdAt': task.createdAt.toIso8601String(),
                'image': task.image,
                'status': task.status,
              }))
          .toList();
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

  void _toggleStatus(Task task) {
    setState(() {
      task.status = task.status == 'IN_PROGRESS' ? 'COMPLETED' : 'IN_PROGRESS';
      _saveTasks(); // Save tasks after modifying the status
    });
  }
}
