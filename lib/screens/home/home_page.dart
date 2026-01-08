import 'package:donow/app_routes.dart';
import 'package:nostr_todo_sdk/nostr_todo_sdk.dart';
import 'package:donow/repository.dart';
import 'package:donow/widgets/update_indicator_view.dart';
import 'package:donow/widgets/user_dialog.dart';
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
        content: Text(
          AppLocalizations.of(context)!.deleteAllCompletedConfirmation,
        ),
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
              foregroundColor: Theme.of(context).colorScheme.onSurfaceVariant,
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
                  showUserDialog(context);
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
                      foregroundColor: Theme.of(
                        context,
                      ).colorScheme.onSurfaceVariant,
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

                    if (_selectedView == TodoView.completed) {
                      final completedTodos = snapshot.data!
                          .where((todo) => todo.status == TodoStatus.done)
                          .toList();

                      if (completedTodos.isEmpty) {
                        return Center(
                          child: Text(
                            AppLocalizations.of(context)!.noCompletedTasks,
                            style: Theme.of(context).textTheme.bodyLarge
                                ?.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                ),
                          ),
                        );
                      }

                      return ListView.builder(
                        padding: EdgeInsets.only(bottom: 100),
                        itemCount: completedTodos.length,
                        itemBuilder: (context, index) {
                          final todo = completedTodos[index];
                          return GestureDetector(
                            onLongPress: () {
                              _showBottomSheet(context, todo);
                            },
                            onSecondaryTapDown: (details) {
                              _showContextMenu(
                                context,
                                details.globalPosition,
                                todo,
                              );
                            },
                            child: ListTile(
                              leading: Checkbox(
                                value: todo.status == TodoStatus.done,
                                onChanged: (_) => Repository.to
                                    .toggleCompleteTodo(todo.eventId),
                              ),
                              title: Text(
                                todo.description,
                                style: TextStyle(
                                  decoration: TextDecoration.lineThrough,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                ),
                              ),
                              trailing: PopupMenuButton<String>(
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
                                    Repository.to.toggleCompleteTodo(
                                      todo.eventId,
                                    );
                                  } else if (value == 'delete') {
                                    Repository.to.deleteTodo(todo.eventId);
                                  } else if (value == 'block') {
                                    Repository.to.blockTodo(todo.eventId);
                                  } else if (value == 'unblock') {
                                    Repository.to.startTodo(todo.eventId);
                                  }
                                },
                                itemBuilder: (BuildContext context) => [
                                  PopupMenuItem<String>(
                                    value: 'uncomplete',
                                    child: Row(
                                      children: [
                                        Icon(Icons.undo),
                                        SizedBox(width: 8),
                                        Text(
                                          AppLocalizations.of(
                                            context,
                                          )!.markAsIncomplete,
                                        ),
                                      ],
                                    ),
                                  ),
                                  PopupMenuItem<String>(
                                    value: 'delete',
                                    child: Row(
                                      children: [
                                        Icon(Icons.delete_outlined),
                                        SizedBox(width: 8),
                                        Text(
                                          AppLocalizations.of(context)!.delete,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    } else {
                      // Active view - show active and blocked todos
                      final activeTodos = snapshot.data!
                          .where(
                            (todo) =>
                                todo.status == TodoStatus.pending ||
                                todo.status == TodoStatus.doing,
                          )
                          .toList();
                      final blockedTodos = snapshot.data!
                          .where((todo) => todo.status == TodoStatus.blocked)
                          .toList();

                      if (activeTodos.isEmpty && blockedTodos.isEmpty) {
                        return Center(
                          child: Text(
                            AppLocalizations.of(context)!.noActiveTasks,
                            style: Theme.of(context).textTheme.bodyLarge
                                ?.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                ),
                          ),
                        );
                      }

                      // Combine todos with a separator
                      final allItems = <dynamic>[];
                      allItems.addAll(activeTodos);
                      if (activeTodos.isNotEmpty && blockedTodos.isNotEmpty) {
                        allItems.add('separator');
                      }
                      allItems.addAll(blockedTodos);

                      return ListView.builder(
                        padding: EdgeInsets.only(bottom: 100),
                        itemCount: allItems.length,
                        itemBuilder: (context, index) {
                          final item = allItems[index];

                          if (item == 'separator') {
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 8.0,
                              ),
                              child: Row(
                                children: [
                                  Expanded(child: Divider()),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16.0,
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.block,
                                          size: 16,
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.onSurfaceVariant,
                                        ),
                                        SizedBox(width: 8),
                                        Text(
                                          AppLocalizations.of(context)!.blocked,
                                          style: TextStyle(
                                            color: Theme.of(
                                              context,
                                            ).colorScheme.onSurfaceVariant,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Expanded(child: Divider()),
                                ],
                              ),
                            );
                          }

                          final todo = item as Todo;
                          final isBlocked = todo.status == TodoStatus.blocked;

                          return GestureDetector(
                            onLongPress: () {
                              _showBottomSheet(context, todo);
                            },
                            onSecondaryTapDown: (details) {
                              _showContextMenu(
                                context,
                                details.globalPosition,
                                todo,
                              );
                            },
                            child: ListTile(
                              leading: isBlocked
                                  ? Checkbox(
                                      value: null,
                                      tristate: true,
                                      onChanged: (_) => Repository.to
                                          .removeTodoStatus(todo.eventId),
                                    )
                                  : Checkbox(
                                      value: todo.status == TodoStatus.done,
                                      onChanged: (_) => Repository.to
                                          .toggleCompleteTodo(todo.eventId),
                                    ),
                              title: Text(
                                todo.description,
                                style: isBlocked
                                    ? TextStyle(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.onSurfaceVariant,
                                      )
                                    : null,
                              ),
                              trailing: PopupMenuButton<String>(
                                icon: Icon(Icons.more_vert),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  side: BorderSide(
                                    color: Theme.of(context).dividerColor,
                                    width: 1,
                                  ),
                                ),
                                onSelected: (value) {
                                  if (value == 'block') {
                                    Repository.to.blockTodo(todo.eventId);
                                  } else if (value == 'unblock') {
                                    Repository.to.startTodo(todo.eventId);
                                  } else if (value == 'delete') {
                                    Repository.to.deleteTodo(todo.eventId);
                                  }
                                },
                                itemBuilder: (BuildContext context) {
                                  final items = <PopupMenuItem<String>>[];

                                  if (isBlocked) {
                                    items.add(
                                      PopupMenuItem<String>(
                                        value: 'unblock',
                                        child: Row(
                                          children: [
                                            Icon(Icons.play_arrow),
                                            SizedBox(width: 8),
                                            Text(
                                              AppLocalizations.of(
                                                context,
                                              )!.unblock,
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  } else {
                                    items.add(
                                      PopupMenuItem<String>(
                                        value: 'block',
                                        child: Row(
                                          children: [
                                            Icon(Icons.block),
                                            SizedBox(width: 8),
                                            Text(
                                              AppLocalizations.of(
                                                context,
                                              )!.markAsBlocked,
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  }

                                  items.add(
                                    PopupMenuItem<String>(
                                      value: 'delete',
                                      child: Row(
                                        children: [
                                          Icon(Icons.delete_outlined),
                                          SizedBox(width: 8),
                                          Text(
                                            AppLocalizations.of(
                                              context,
                                            )!.delete,
                                          ),
                                        ],
                                      ),
                                    ),
                                  );

                                  return items;
                                },
                              ),
                            ),
                          );
                        },
                      );
                    }
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
              if (_selectedView == TodoView.active)
                if (todo.status == TodoStatus.blocked)
                  ListTile(
                    leading: Icon(Icons.play_arrow),
                    title: Text(AppLocalizations.of(context)!.unblock),
                    onTap: () {
                      Repository.to.startTodo(todo.eventId);
                      Get.back();
                    },
                  )
                else
                  ListTile(
                    leading: Icon(Icons.block),
                    title: Text(AppLocalizations.of(context)!.markAsBlocked),
                    onTap: () {
                      Repository.to.blockTodo(todo.eventId);
                      Get.back();
                    },
                  ),
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

    if (_selectedView == TodoView.active) {
      if (todo.status == TodoStatus.blocked) {
        items.add(
          PopupMenuItem<String>(
            value: 'unblock',
            child: ListTile(
              leading: Icon(Icons.play_arrow),
              title: Text(AppLocalizations.of(context)!.unblock),
            ),
          ),
        );
      } else {
        items.add(
          PopupMenuItem<String>(
            value: 'block',
            child: ListTile(
              leading: Icon(Icons.block),
              title: Text(AppLocalizations.of(context)!.markAsBlocked),
            ),
          ),
        );
      }
    } else if (_selectedView == TodoView.completed) {
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
    } else if (value == 'block') {
      Repository.to.blockTodo(todo.eventId);
    } else if (value == 'unblock') {
      Repository.to.startTodo(todo.eventId);
    }
  }
}
