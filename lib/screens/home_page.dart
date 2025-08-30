// , we import all the necessary packages.

import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:provider/provider.dart';

import 'package:table_calendar/table_calendar.dart';
import 'package:myapp/models/tasks.dart';
import 'package:myapp/services/task_service.dart';
import 'package:myapp/providers/task_provider.dart';

// Here we define our main widget for this screen, Home_Page.

class Home_Page extends StatefulWidget {
  const Home_Page({super.key});

  @override
  // This creates the state object that will manage the state for this widget.
  State<Home_Page> createState() => _Home_PageState();
}

// This is the State class for our Home_Page widget.
// the logic and UI for this screen goes in here.
class _Home_PageState extends State<Home_Page> {
  // We create a TextEditingController
  // to get the text from the "Add Task" text field.
  final TextEditingController nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // initState is called once when the widget is first created.
    Provider.of<TaskProvider>(context, listen: false).loadTasks();
  }

  @override
  // The build method is where we describe the UI for the widget.
  Widget build(BuildContext context) {
    // Scaffold is a basic Material Design layout structure.
    //It gives us things like an app bar, body, and drawer.
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        // The title of our app bar
        //is a Row containing an image and text.
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // We use Image.asset to display our logo from the assets folder.
            Expanded(child: Image.asset('assets/rdplogo.png', height: 80)),
            // A Text widget for our app's title, with a custom font and style.
            const Text(
              'Daily Planner',
              style: TextStyle(
                fontFamily: 'Caveat',
                fontSize: 32,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
      // The body of our Scaffold colunm
      body: Column(
        children: [
          // Expanded makes its child fill the available space.
          Expanded(
            // SingleChildScrollView allows the content to be
            //scrolled if it's too long for the screen.
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // This is the calendar widget from the table_calendar package.
                  TableCalendar(
                    calendarFormat: CalendarFormat.week,
                    focusedDay: DateTime.now(),
                    firstDay: DateTime.utc(2020, 1, 1),
                    lastDay: DateTime.utc(2030, 12, 31),
                  ),
                  // Consumer is a widget from the provider package.
                  // It listens for changes in our TaskProvider and rebuilds the UI below it when the data changes.
                  Consumer<TaskProvider>(
                    builder: (context, taskProvider, child) {
                      // We pass the list of tasks and the functions to
                      //remove/update them to our buildTaskItem widget.
                      return buildTaskItem(
                        taskProvider.tasks,
                        taskProvider.removeTask,
                        taskProvider.updateTask,
                      );
                    },
                  ),
                  Consumer<TaskProvider>(
                    builder: (context, taskProvider, child) {
                      return buildAddTaskSection(nameController, () async {
                        // When the button is pressed, we call the addTask method in our provider.
                        await taskProvider.addTask(nameController.text);

                        nameController.clear();
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      // A Drawer provides a slide menu for the drawer
      drawer: Drawer(),
    );
  }
}

// This function builds the section for adding new tasks.
Widget buildAddTaskSection(nameController, addTask) {
  return Container(
    decoration: BoxDecoration(color: Colors.white),
    child: Row(
      children: [
        Expanded(
          child: Container(
            // A TextField for user input.
            child: TextField(
              maxLength: 32,
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Add Task',
                border: OutlineInputBorder(),
              ),
            ),
          ),
        ),
        // An ElevatedButton that calls the addTask function when pressed.
        ElevatedButton(onPressed: addTask, child: Text('Add Task')),
      ],
    ),
  );
}

// This function builds the list of task items.
Widget buildTaskItem(
  List<Task> tasks,
  Function(int) removeTasks,
  Function(int, bool) updateTask,
) {
  // ListView.builder is very efficient for long lists because it only builds the items that are visible on the screen.
  return ListView.builder(
    shrinkWrap:
        true, // This is needed when a ListView is inside another scrollable widget like SingleChildScrollView.
    physics:
        const NeverScrollableScrollPhysics(), // This also helps prevent scrolling conflicts.
    itemCount: tasks.length, // The number of items in our list.
    itemBuilder: (context, index) {
      // itemBuilder is called for each item in the list.
      final task = tasks[index];
      final isEven = index % 2 == 0; // Just for some alternating row colors.

      return Padding(
        padding: EdgeInsets.all(1.0),
        // ListTile is a standard way to display a row in a list.
        child: ListTile(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          tileColor: isEven ? Colors.blue : Colors.green, // Alternating colors.
          leading: Icon(
            // Show a different icon depending on whether the task is completed.
            task.completed ? Icons.check_circle : Icons.circle_outlined,
          ),
          title: Text(
            task.name,
            style: TextStyle(
              // Add a line-through decoration for completed tasks.
              decoration: task.completed ? TextDecoration.lineThrough : null,
              fontSize: 22,
            ),
          ),
          // The trailing part of the ListTile holds our Checkbox and delete button.
          trailing: Row(
            mainAxisSize: MainAxisSize
                .min, // This keeps the Row from taking up too much space.
            children: [
              // A Checkbox to mark the task as complete.
              Checkbox(
                value: task.completed,
                onChanged: (value) => {updateTask(index, value!)},
              ),
              // An IconButton to delete the task.
              IconButton(
                icon: Icon(Icons.delete),
                onPressed: () => removeTasks(index),
              ),
            ],
          ),
        ),
      );
    },
  );
}
