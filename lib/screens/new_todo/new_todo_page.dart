import 'package:donow/screens/new_todo/new_todo_controller.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:window_manager/window_manager.dart';
import 'package:donow/l10n/app_localizations.dart';

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
                    child: Text(AppLocalizations.of(context)!.create),
                  );
                },
              ),
              SizedBox(width: 8),
              if (!kIsWeb && GetPlatform.isDesktop)
                SizedBox(
                  width: 154,
                  child: WindowCaption(
                    brightness: Theme.of(context).brightness,
                    backgroundColor: Colors.transparent,
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
          hintText: AppLocalizations.of(context)!.whatToDo,
        ),
        onChanged: (_) => NewTodoController.to.update(),
      ),
    );
  }
}
