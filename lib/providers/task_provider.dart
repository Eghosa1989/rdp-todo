import 'package:myapp/services/task_service.dart';
import 'package:myapp/models/task.dart';
import 'package:flutter/material.dart';

//create a task provider to manage state
class TaskProvider extends ChangeNotifier {
  final TaskService taskService = TaskService();
  List<Task> tasks = [];

  //populates task list /array with documents from database
  //notifies the root provider of stateful change
  Future<void> loadTasks() async {
    tasks = await taskService.fetchTasks();
    notifyListeners();
  }

  Future<void> addTask(String name) async {
    // check to see if name is not empty or null
    if (name.trim().isNotEmpty) {
      // add the trimmed task name to the database
      final id = await taskService.addTask(name.trim());
      //adding the task name to the local list of tasks held in memory
      tasks.add(Task(id: id, name: name, completed: false));
      notifyListeners();
    }
  }

  Future<void> updateTask(String id, bool completed) async {
    //update the task collection in the database by id, using bool for completed
    await taskService.updateTask(id, completed);
    //updating the local task list
    final index = tasks.indexWhere((task) => task.id == id);
    if (index != -1) {
      tasks[index] = Task(
        id: tasks[index].id,
        name: tasks[index].name,
        completed: completed,
      );
      notifyListeners();
    }
  }

  Future<void> removeTask(String id) async {
    //delete the task from the collection
    await taskService.deleteTask(id);
    //remote the task from the list in memory
    tasks.removeWhere((task) => task.id == id);
    notifyListeners();
  }
}
