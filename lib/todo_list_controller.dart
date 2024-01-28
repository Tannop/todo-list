import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:todo_list/task_model.dart';

class TodoListController extends GetxController {
  var tasks = <Task>[].obs;
  //var searchController = TextEditingController().obs;
  var searchController = RxString('');
  var sortBy = RxString('Date');

  @override
  void onInit() {
    super.onInit();
    _loadTasks();
  }

  void addTask(BuildContext context) {
    _addTaskLogic(context);
  }

  void updateTask(BuildContext context, Task task) {
    _updateTaskLogic(context, task);
  }

  void clearCompletedTasks() {
    tasks.removeWhere((task) => task.status == 'COMPLETED');
    _saveTasks();
  }

  List<Task> filterAndSortTasks() {
    String query = searchController.value.toLowerCase();
    List<Task> filteredTasks = tasks
        .where((task) =>
            task.title.toLowerCase().contains(query) ||
            task.description.toLowerCase().contains(query))
        .toList();

    switch (sortBy.value) {
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

  Future<void> _loadTasks() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      List<String>? taskList = prefs.getStringList('tasks');

      if (taskList != null) {
        tasks.assignAll(taskList.map((taskJson) {
          Map<String, dynamic> taskMap = json.decode(taskJson);
          return Task(
            id: taskMap['id'],
            title: taskMap['title'],
            description: taskMap['description'],
            createdAt: DateTime.parse(taskMap['createdAt']),
            image: taskMap['image'],
            status: taskMap['status'],
          );
        }).toList());
      }
    } catch (e) {
      _showErrorSnackBar('Error loading tasks');
    }
  }

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
    Get.snackbar('Error', message, duration: Duration(seconds: 2));
  }

  void toggleStatus(Task task) {
    task.status = task.status == 'IN_PROGRESS' ? 'COMPLETED' : 'IN_PROGRESS';
    _saveTasks();
  }

  String _formatDate(DateTime dateTime) {
    String formattedDate =
        DateFormat('yyyy-MM-ddTHH:mm:ssZ').format(dateTime.toUtc());
    return formattedDate;
  }

  void _validateTaskFields(
      String title, DateTime createdAt, String status, String image) {
    if (title.isEmpty || title.length > 100) {
      throw 'Title must not be empty and should be less than 100 characters.';
    }
  }

  void _addTaskLogic(BuildContext context) async {
    Task? newTask = await showDialog<Task>(
      context: context,
      builder: (BuildContext context) {
        String id = Uuid().v4(); // Generate UUID
        String title = '';
        String description = '';
        DateTime createdAt = DateTime.now().toUtc();
        String image = '';
        String status = 'IN_PROGRESS';

        return AlertDialog(
          title: Text('Add Task'),
          content: SingleChildScrollView(
              child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                key: Key('addTaskTitleTextField'),
                maxLength: 100,
                decoration: InputDecoration(labelText: 'Title'),
                onChanged: (value) {
                  title = value;
                },
              ),
              TextField(
                key: Key('addTaskDescriptionTextField'),
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
                    createdAt = pickedDate;
                  }
                },
              ),
              ElevatedButton(
                onPressed: () async {
                  XFile? pickedImage = await ImagePicker()
                      .pickImage(source: ImageSource.gallery);

                  if (pickedImage != null) {
                    // Read the contents of the image file
                    List<int> imageBytes =
                        await File(pickedImage.path).readAsBytes();

                    // Encode the image bytes to Base64
                    String base64Image = base64Encode(imageBytes);

                    image = base64Image;
                  }
                },
                child: Text('Select Image'),
              ),
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
      tasks.add(newTask);
      _saveTasks();
    }
  }

  void _updateTaskLogic(BuildContext context, Task task) async {
    Task? updatedTask = await showDialog<Task>(
      context: context,
      builder: (BuildContext context) {
        String title = task.title;
        String description = task.description;
        DateTime createdAt = task.createdAt;
        String image = task.image;
        String status = task.status;
        RxString statusupdate = RxString(task.status);
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
                      createdAt = pickedDate;
                    }
                  },
                ),
                ListTile(
                  key: Key('checkBox'),
                  title: const Text('Mark as Complete'),
                  trailing: Obx(
                    () => Checkbox(
                      value: statusupdate.value == 'COMPLETED',
                      onChanged: (bool? value) {
                        statusupdate.value =
                            value! ? 'COMPLETED' : 'IN_PROGRESS';
                        status = statusupdate.value;
                      },
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    XFile? pickedImage = await ImagePicker()
                        .pickImage(source: ImageSource.gallery);

                    if (pickedImage != null) {
                      // Read the contents of the image file
                      List<int> imageBytes =
                          await File(pickedImage.path).readAsBytes();

                      // Encode the image bytes to Base64
                      String base64Image = base64Encode(imageBytes);

                      image = base64Image;
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
              key: Key('updateButton'),
              onPressed: () {
                try {
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
      tasks.removeWhere((t) => t.id == task.id);
      tasks.add(updatedTask);
      _saveTasks();
    }
  }

  void updateSearch(String value) {
    searchController.value = value;
  }

  void updatesort(String value) {
    sortBy.value = value;
  }
}
