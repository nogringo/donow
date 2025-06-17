import 'package:donow/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ndk/ndk.dart';

class RouterIsLoggedInMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    if (Get.find<Ndk>().accounts.isNotLoggedIn) {
      return const RouteSettings(name: AppRoutes.signIn);
    }
    
    return null;
  }
}