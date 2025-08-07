import 'package:donow/app_routes.dart';
import 'package:donow/models/todo.dart';
import 'package:donow/repository.dart';
import 'package:donow/widgets/update_indicator_view.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nostr_widgets/nostr_widgets.dart';
import 'package:window_manager/window_manager.dart';
import 'package:donow/l10n/app_localizations.dart';

enum TodoView { active, completed }

enum MenuActions { delete }

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TodoView _selectedView = TodoView.active;

  void _deleteAllCompleted(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.deleteAllCompleted),
        content: Text(AppLocalizations.of(context)!.deleteAllCompletedConfirmation),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          TextButton(
            onPressed: () {
              Repository.to.deleteAllCompletedTodos();
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: Text(AppLocalizations.of(context)!.delete),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: DragToMoveArea(
          child: AppBar(
            title: Text(AppLocalizations.of(context)!.appTitle),
            actions: [
              UpdateIndicatorView(),
              GestureDetector(
                onTap: () {
                  Get.toNamed(AppRoutes.user);
                },
                child: NPicture(ndk: Repository.to.ndk),
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
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (_selectedView == TodoView.completed)
                  TextButton.icon(
                    onPressed: () => _deleteAllCompleted(context),
                    icon: Icon(Icons.delete_sweep),
                    label: Text(AppLocalizations.of(context)!.clearAll),
                    style: TextButton.styleFrom(
                      foregroundColor: Theme.of(context).colorScheme.error,
                    ),
                  )
                else
                  SizedBox.shrink(),
                SegmentedButton<TodoView>(
                  segments: [
                    ButtonSegment<TodoView>(
                      value: TodoView.active,
                      label: Text(AppLocalizations.of(context)!.active),
                      icon: Icon(Icons.circle, color: Colors.transparent),
                    ),
                    ButtonSegment<TodoView>(
                      value: TodoView.completed,
                      label: Text(AppLocalizations.of(context)!.completed),
                      icon: Icon(Icons.circle, color: Colors.transparent),
                    ),
                  ],
                  selected: {_selectedView},
                  onSelectionChanged: (Set<TodoView> newSelection) {
                    setState(() {
                      _selectedView = newSelection.first;
                    });
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: GetBuilder<Repository>(
              builder: (c) {
                return FutureBuilder<List<Todo>>(
                  future: c.todos(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return Container();

                    final todos = _selectedView == TodoView.active
                        ? snapshot.data!.where((todo) => !todo.isCompleted).toList()
                        : snapshot.data!.where((todo) => todo.isCompleted).toList();

                    if (todos.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _selectedView == TodoView.active
                                  ? Icons.task_alt
                                  : Icons.check_circle_outline,
                              size: 64,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant
                                  .withValues(alpha: 0.5),
                            ),
                            SizedBox(height: 16),
                            Text(
                              _selectedView == TodoView.active
                                  ? AppLocalizations.of(context)!.noActiveTasks
                                  : AppLocalizations.of(context)!.noCompletedTasks,
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                                  ),
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: EdgeInsets.only(bottom: 100),
                      itemCount: todos.length,
                      itemBuilder: (context, index) {
                        final todo = todos[index];
                        return GestureDetector(
                          onLongPress: () {
                            _showBottomSheet(context, todo);
                          },
                          onSecondaryTapDown: (details) {
                            _showContextMenu(context, details.globalPosition, todo);
                          },
                          child: ListTile(
                            leading: Checkbox(
                              value: todo.isCompleted,
                              onChanged: (_) =>
                                  Repository.to.toggleCompleteTodo(todo.eventId),
                            ),
                            title: Text(
                              todo.description,
                              style: _selectedView == TodoView.completed
                                  ? TextStyle(
                                      decoration: TextDecoration.lineThrough,
                                      color:
                                          Theme.of(context).colorScheme.onSurfaceVariant,
                                    )
                                  : null,
                            ),
                            trailing: _selectedView == TodoView.completed
                                ? PopupMenuButton<String>(
                                    icon: Icon(Icons.more_vert),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      side: BorderSide(
                                        color: Theme.of(context).dividerColor,
                                        width: 1,
                                      ),
                                    ),
                                    onSelected: (value) {
                                      if (value == 'uncomplete') {
                                        Repository.to.toggleCompleteTodo(todo.eventId);
                                      } else if (value == 'delete') {
                                        Repository.to.deleteTodo(todo.eventId);
                                      }
                                    },
                                    itemBuilder: (BuildContext context) => [
                                      PopupMenuItem<String>(
                                        value: 'uncomplete',
                                        child: Row(
                                          children: [
                                            Icon(Icons.undo),
                                            SizedBox(width: 8),
                                            Text(AppLocalizations.of(context)!.markAsIncomplete),
                                          ],
                                        ),
                                      ),
                                      PopupMenuItem<String>(
                                        value: 'delete',
                                        child: Row(
                                          children: [
                                            Icon(Icons.delete_outlined),
                                            SizedBox(width: 8),
                                            Text(AppLocalizations.of(context)!.delete),
                                          ],
                                        ),
                                      ),
                                    ],
                                  )
                                : null,
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: _selectedView == TodoView.active
          ? FloatingActionButton(
              onPressed: () {
                Get.toNamed(AppRoutes.newTodo);
              },
              child: Icon(Icons.add),
            )
          : null,
    );
  }

  void _showBottomSheet(BuildContext context, Todo todo) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 100),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_selectedView == TodoView.completed)
                ListTile(
                  leading: Icon(Icons.undo),
                  title: Text(AppLocalizations.of(context)!.markAsIncomplete),
                  onTap: () {
                    Repository.to.toggleCompleteTodo(todo.eventId);
                    Get.back();
                  },
                ),
              ListTile(
                leading: Icon(Icons.delete_outlined),
                title: Text(AppLocalizations.of(context)!.delete),
                onTap: () {
                  Repository.to.deleteTodo(todo.eventId);
                  Get.back();
                },
              ),
            ],
          ),
        );
      },
      showDragHandle: true,
    );
  }

  void _showContextMenu(
    BuildContext context,
    Offset globalPosition,
    Todo todo,
  ) async {
    final items = <PopupMenuEntry<String>>[];
    
    if (_selectedView == TodoView.completed) {
      items.add(
        PopupMenuItem<String>(
          value: 'uncomplete',
          child: ListTile(
            leading: Icon(Icons.undo),
            title: Text(AppLocalizations.of(context)!.markAsIncomplete),
          ),
        ),
      );
    }
    
    items.add(
      PopupMenuItem<String>(
        value: 'delete',
        child: ListTile(
          leading: Icon(Icons.delete_outlined),
          title: Text(AppLocalizations.of(context)!.delete),
        ),
      ),
    );

    final value = await showMenu(
      context: context,
      position: RelativeRect.fromLTRB(
        globalPosition.dx,
        globalPosition.dy,
        globalPosition.dx + 1,
        globalPosition.dy + 1,
      ),
      items: items,
      elevation: 8.0,
    );

    if (value == 'uncomplete') {
      Repository.to.toggleCompleteTodo(todo.eventId);
    } else if (value == 'delete') {
      Repository.to.deleteTodo(todo.eventId);
    }
  }
}