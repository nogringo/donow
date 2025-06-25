import 'package:donow/screens/new_todo/new_todo_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NewTodoPage extends StatelessWidget {
  const NewTodoPage({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(NewTodoController());
    return Scaffold(
      appBar: AppBar(
        actions: [
          GetBuilder<NewTodoController>(
            builder: (c) {
              return FilledButton(
                onPressed: c.canCreateTodo ? c.createTodo : null,
                child: Text("Create"),
              );
            },
          ),
          SizedBox(width: 8),
        ],
      ),
      body: TextField(
        controller: NewTodoController.to.descriptionController,
        autofocus: true,
        expands: true,
        minLines: null,
        maxLines: null,
        decoration: InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.all(8),
          hintText: "What do you have to do ?",
        ),
        onChanged: (_) => NewTodoController.to.update(),
      ),
    );
  }
}
