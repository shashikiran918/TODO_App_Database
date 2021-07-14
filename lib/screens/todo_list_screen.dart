import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:task/screens/add_task_screen.dart';

import 'package:task/database.dart';
import 'package:task/task_model.dart';

class TodoListScreen extends StatefulWidget {
  @override
  _TodoListScreenState createState() => _TodoListScreenState();
}

class _TodoListScreenState extends State<TodoListScreen> {
  Future<List<Task>>? _taskList;
  final DateFormat _dateFormatter = DateFormat('MMM dd, yyyy');

  @override
  void initState() {
    super.initState();
    _updateTaskList();
  }

  _updateTaskList() {
    setState(() {
      _taskList = DatabaseHelper.instance.getTaskList();
    });
  }

  Widget _buildTask(Task task) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 0.5),
      child: Column(
        children: [
          Card(margin: EdgeInsets.all(15.0),
            color: Colors.white10,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
            ),
            child: ListTile(visualDensity: VisualDensity(vertical: 4.0,horizontal: 4.0),
              title: Text(
                task.title!,
                style: TextStyle(
                    fontSize: 23,
                    fontWeight: FontWeight.w700,
                    decoration: task.status == 0 ? TextDecoration.none : TextDecoration.lineThrough),
              ),
              subtitle: Text(
                '${_dateFormatter.format(task.date!)} * ${task.priority}',
                style: TextStyle(height: 2.0,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    decoration: task.status == 0 ? TextDecoration.none : TextDecoration.lineThrough),
              ),
              trailing: Checkbox(
                onChanged: (value) {
                  task.status = value! ? 1 : 0;
                  DatabaseHelper.instance.updateTask(task);
                  _updateTaskList();
                },
                activeColor: Theme.of(context).primaryColor,
                value: task.status == 1 ? true : false,
              ),
              onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => AddTaskScreen(
                          updateTaskList: _updateTaskList, task: task))),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('TODO ',
          style: TextStyle(
            color: Colors.brown,
            fontSize: 30.0,
            fontStyle: FontStyle.italic,
            fontWeight: FontWeight.w500,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.menu),
          tooltip: "MENU BAR",
          onPressed: () {  },
        ),
        brightness: Brightness.dark,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).primaryColor,
        onPressed: () => {
          Navigator.push(context,
            MaterialPageRoute(
              builder: (_) => AddTaskScreen(
                  updateTaskList : _updateTaskList
              ),
            ),
          )
        },
        child: Icon(Icons.add),
      ),
      body: FutureBuilder(
        future: _taskList,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          final int? completedTaskCount = (snapshot.data as List<Task>).where((Task task) => task.status == 1).toList().length;

          return ListView.builder(
            padding: EdgeInsets.symmetric(vertical: 10.0),
            itemCount: 1 + (snapshot.data as List<Task>).length ,
            itemBuilder: (BuildContext context, int index) {
              if (index == 0) {
                return Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 20.0, horizontal: 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'My Tasks',
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 30,
                            fontWeight: FontWeight.bold),
                      ),
                      SizedBox(
                        height: 10.0,
                      ),
                      Text(
                        '$completedTaskCount of ${(snapshot.data as List<Task>).length}',
                        style: TextStyle(
                            color: Colors.grey,
                            fontSize: 15.0,
                            fontWeight: FontWeight.w600),
                      )
                    ],
                  ),
                );
              }
              return _buildTask((snapshot.data as List<Task>)[index - 1]);
            },
          );
        },
      ),
    );
  }
}
