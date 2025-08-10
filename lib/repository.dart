import 'package:donow/app_routes.dart';
import 'package:donow/get_database.dart';
import 'package:donow/services/update_checker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:ndk/ndk.dart';
import 'package:nostr_todo_sdk/nostr_todo_sdk.dart';
import 'package:sembast/sembast.dart' as sembast;

class Repository extends GetxController {
  static Repository get to => Get.find();

  TodoService? _todoService;
  late sembast.Database _database;

  RxBool hasUpdate = false.obs;

  Ndk get ndk => Get.find<Ndk>();
  String? get pubkey => ndk.accounts.getPublicKey();

  Future<void> loadApp() async {
    // Initialize database
    await initDatabase();

    // Initialize TodoService
    _todoService = TodoService(ndk: ndk, db: _database);

    checkForUpdate();
  }

  Future<void> initDatabase() async {
    final dbName = kDebugMode ? 'donow_dev_db' : 'donow_db';
    _database = await getDatabase(dbName);
  }

  Future<void> checkForUpdate() async {
    final updateInfo = await UpdateChecker.checkForUpdate();
    if (updateInfo != null) {
      hasUpdate.value = updateInfo.hasUpdate;
    }
  }

  // Todo management methods delegating to TodoService
  Future<List<Todo>> todos() async {
    if (_todoService == null) return [];
    final todos = await _todoService!.getTodos();
    return todos;
  }

  Future<void> createTodo(String description) async {
    if (_todoService == null) return;
    await _todoService!.createTodo(
      description: description,
      encrypted: true, // Using encryption for privacy
    );
    update(); // Trigger UI update
  }

  Future<void> completeTodo(String eventId) async {
    if (_todoService == null) return;
    await _todoService!.completeTodo(id: eventId);
    update(); // Trigger UI update
  }

  Future<void> toggleCompleteTodo(String eventId) async {
    if (_todoService == null) return;
    
    final allTodos = await todos();
    final todo = allTodos.firstWhereOrNull((t) => t.eventId == eventId);
    
    if (todo == null) return;
    
    if (todo.isCompleted) {
      await _todoService!.removeTodoStatus(id: eventId);
    } else {
      await _todoService!.completeTodo(id: eventId);
    }
    update(); // Trigger UI update
  }

  Future<void> deleteTodo(String eventId) async {
    if (_todoService == null) return;
    await _todoService!.deleteTodo(id: eventId);
    update(); // Trigger UI update
  }

  Future<void> deleteAllCompletedTodos() async {
    if (_todoService == null) return;
    
    final allTodos = await todos();
    final completedTodoIds = allTodos
        .where((todo) => todo.isCompleted)
        .map((todo) => todo.eventId)
        .toList();
    
    if (completedTodoIds.isNotEmpty) {
      await _todoService!.deleteTodos(ids: completedTodoIds);
      update(); // Trigger UI update
    }
  }

  void logOut() async {
    // Stop listening to events
    _todoService?.dispose();
    _todoService = null;

    // Clear stored credentials
    await FlutterSecureStorage().delete(key: "privkey");
    await FlutterSecureStorage().delete(key: "loginWith");
    ndk.accounts.logout();

    Get.offAllNamed(AppRoutes.signIn);
  }

  @override
  void onClose() {
    _todoService?.dispose();
    super.onClose();
  }
}