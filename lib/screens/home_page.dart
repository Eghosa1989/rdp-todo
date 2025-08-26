import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Task {
  final String id;
  final String name;
  final bool completed;

  Task({required this.id, required this.name, required this.completed});
  factory Task.fromMap(String id, Map<String, dynamic> data) {
    return Task(
      id: id,
      name: data['name'] ?? '',
      completed: data['completed'] ?? false,
    );
  }
}

//Define a Task Service to handle Firestone operations
class TaskService {
  //Firestone instance in an alais
  final FirebaseFirestore db = FirebaseFirestore.instance;

  //Future that returns a list of tasks of a task using factory method defined in a task class
  Future<List<Task>> loadTasks() async {
    //class get to retrieve all of the documents inside the collections
    final snapshot = await db.collection('tasks').orderBy('timestamp').get();

    //snapshots od all documents is being mapped to factory object method
    return snapshot.docs
        .map((doc) => Task.fromMap(doc.id, doc.data()))
        .toList();
  }

  //another asynchronous future to add task to the firstore
  Future<String> addTask(String name) async {
    final newTask = {
      'name': name,
      'completed': false,
      'timestamp': FieldValue.serverTimestamp(),
    };

    final docRef = await db.collection('tasks').add(newTask);
    return docRef.id;
  }

  //update task
  Future<void> updateTask(Task task, bool completed) async {
    await db.collection('tasks').doc(task.id).update({
      'name': task.name,
      'completed': task.completed,
    });
  }

  //Future is going to delete task
  Future<void> deleteTask(Task task) async {
    await db.collection('tasks').doc(task.id).delete();
  }
}

//create a task provider to manage state
class TaskProvider extends ChangeNotifier {
  final TaskService taskService = TaskService();
  List<Task> tasks = [];

  //populate task list/arrays with documents from database
  //notifies the root provider of staful changes
  Future<void> loadTasks() async {
    tasks = await taskService.loadTasks();
    notifyListeners();
  }

  Future<void> addTask(String name) async {
    //check to see if name is not empty or null
    if (name.trim().isNotEmpty) {
      //add the trimmed task name to the database
      final id = await taskService.addTask(name.trim());

      //adding the task name to the ;acal list of task held in momory
      tasks.add(Task(id: id, name: name, completed: false));
      notifyListeners();
    }
  }

  Future<void> updateTask(int index, bool completed) async {
    //uses array index to find tasks
    final task = tasks[index];

    //update the task collection in the database by id, using bool for completed
    await taskService.updateTask(task.id as Task, completed);

    //update the local list of tasks
    tasks[index] = Task(id: task.id, name: task.name, completed: completed);
    notifyListeners();
  }

  Future<void> deleteTask(int index) async {
    //use array index to find tasks
    final task = tasks[index];

    //delete the task from the collection
    await taskService.deleteTask(task);

    //remove the task from the local list
    tasks.removeAt(index);
    notifyListeners();
  }
}

class Home_Page extends StatefulWidget {
  const Home_Page({super.key});

  @override
  State<Home_Page> createState() => _Home_PageState();
}

class _Home_PageState extends State<Home_Page> {
  final TextEditingController name = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TaskProvider>(context, listen: false).loadTasks();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Expanded(child: Image.asset('assets/rdplogo.png')),
            const Text('Daily Planner'),
          ],
        ),
      ),
    );
  }
}
