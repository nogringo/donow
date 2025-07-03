import 'package:donow/screens/new_todo/new_todo_controller.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:window_manager/window_manager.dart';

class NewTodoPage extends StatelessWidget {
  const NewTodoPage({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(NewTodoController());
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: DragToMoveArea(
          child: AppBar(
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
              if (!kIsWeb && GetPlatform.isDesktop)
                SizedBox(
                  width: 154,
                  child: WindowCaption(
                    brightness: Theme.of(context).brightness,
                    backgroundColor: Theme.of(context).colorScheme.surface,
                  ),
                ),
            ],
          ),
        ),
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
