import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

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
  Future<List<Task>> fetchTask() async {
    //class get to retrieve all of the documents inside the collections
    final snapshot = await db.collection('tasks').orderBy('timestamp').get();

    //snapshots od all documents is being mapped to factory object method
    return snapshot.docs
        .map((doc) => Task.fromMap(doc.id, doc.data()))
        .toList();
  }
}

//create a task provider to manage state
class Taskprovider extends ChangeNotifier {}

class Home_Page extends StatefulWidget {
  const Home_Page({super.key});

  @override
  State<Home_Page> createState() => _Home_PageState();
}

class _Home_PageState extends State<Home_Page> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text("Hello World")));
  }
}
