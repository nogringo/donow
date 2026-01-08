import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:donow/repository.dart';

class NewTodoController extends GetxController {
  static NewTodoController get to => Get.find();

  final descriptionController = TextEditingController();

  String get todoDescription => descriptionController.text.trim();
  bool get canCreateTodo => todoDescription.isNotEmpty;

  void createTodo() async {
    if (!canCreateTodo) return;

    await Repository.to.createTodo(todoDescription);
    Get.back();
  }
}
