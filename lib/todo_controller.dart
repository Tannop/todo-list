import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'dart:convert';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:todo_list/task_model.dart';

class TodoController extends GetxController {
  var tasks = <Task>[].obs;
  var searchController = TextEditingController().obs;
  var sortBy = 'Date'.obs;

  void addTask(BuildContext context) {
    _addTaskLogic(context);
  }

  void updateTask(BuildContext context, Task task) {
    _updateTaskLogic(context, task);
  }

  void toggleTaskStatus(Task task) {
    task.status = task.status == 'IN_PROGRESS' ? 'COMPLETED' : 'IN_PROGRESS';
    _saveTasks();
  }

  void clearCompletedTasks() {
    List<Task> completedTasks =
        tasks.where((task) => task.status == 'COMPLETED').toList();

    if (completedTasks.isEmpty) {
      // Show a snackbar or a dialog indicating that there are no completed tasks
      Get.snackbar('No Completed Tasks', 'There are no completed tasks. 😭',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    // Show the clear confirmation dialog
    Get.defaultDialog(
      title: 'Clear Completed Tasks?',
      middleText: 'Are you sure you want to clear all completed tasks?',
      textConfirm: 'Clear',
      confirm: ElevatedButton(
        onPressed: () {
          tasks.removeWhere((task) => task.status == 'COMPLETED');
          _saveTasks(); // Save tasks after modification
          Get.back(); // Close the dialog
        },
        child: Text('Clear'),
      ),
      textCancel: 'Cancel',
    );
  }

  void updateSearch(String value) {
    searchController.value.text = value;
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

  void _validateTaskFields(
      String title, DateTime createdAt, String status, String image) {
    if (title.isEmpty || title.length > 100) {
      throw 'Title must not be empty and should be less than 100 characters.';
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

  void toggleStatus(Task task) {
    task.status = task.status == 'IN_PROGRESS' ? 'COMPLETED' : 'IN_PROGRESS';
    _saveTasks();
  }

  void _showErrorSnackBar(String message) {
    Get.snackbar('Error', message, duration: Duration(seconds: 2));
  }

  String _formatDate(DateTime dateTime) {
    String formattedDate =
        DateFormat('yyyy-MM-dd HH:mm').format(dateTime.toUtc());
    return formattedDate;
  }
}
