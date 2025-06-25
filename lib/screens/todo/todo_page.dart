import 'package:donow/app_routes.dart';
import 'package:donow/models/todo.dart';
import 'package:donow/repository.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

enum MenuActions { delete }

class TodoPage extends StatelessWidget {
  const TodoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Donow"),
        actions: [
          IconButton(
            onPressed: () {
              Repository.to.logOut();
            },
            icon: Icon(Icons.logout),
          ),
          SizedBox(width: 24),
        ],
      ),
      body: GetBuilder<Repository>(
        builder: (c) {
          return FutureBuilder(
            future: c.todos(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return Container();

              return ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  final todo = snapshot.data![index];
                  return GestureDetector(
                    onLongPress: () {
                      showModalBottomSheet(
                        context: context,
                        builder: (context) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 100),
                            child: ListTile(
                              leading: Icon(Icons.delete_outlined),
                              title: Text("Delete"),
                              onTap: () {
                                Repository.to.deleteTodo(todo.eventId);
                                Get.back();
                              },
                            ),
                          );
                        },
                        showDragHandle: true,
                      );
                    },
                    onSecondaryTapDown: (details) {
                      _showContextMenu(context, details.globalPosition, todo);
                    },
                    child: CheckboxListTile(
                      value: todo.isCompleted,
                      onChanged: (_) =>
                          Repository.to.toggleCompleteTodo(todo.eventId),
                      title: Text(todo.description),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Get.toNamed(AppRoutes.newTodo);
        },
        child: Icon(Icons.add),
      ),
    );
  }

  void _showContextMenu(
    BuildContext context,
    Offset globalPosition,
    Todo todo,
  ) async {
    final value = await showMenu(
      context: context,
      position: RelativeRect.fromLTRB(
        globalPosition.dx,
        globalPosition.dy,
        globalPosition.dx + 1,
        globalPosition.dy + 1,
      ),
      items: <PopupMenuEntry<MenuActions>>[
        const PopupMenuItem<MenuActions>(
          value: MenuActions.delete,
          child: ListTile(
            leading: Icon(Icons.delete_outlined),
            title: Text("Delete"),
          ),
        ),
      ],
      elevation: 8.0,
    );

    if (value == MenuActions.delete) {
      Repository.to.deleteTodo(todo.eventId);
    }
  }
}
