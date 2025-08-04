import 'package:donow/app_routes.dart';
import 'package:donow/repository.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class UpdateIndicatorView extends StatelessWidget {
  const UpdateIndicatorView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (!Repository.to.hasUpdate.value) return Container();

      return Padding(
        padding: const EdgeInsets.only(right: 8.0),
        child: IconButton(
          onPressed: () {
            Get.toNamed(AppRoutes.user);
          },
          icon: Icon(
            Icons.vertical_align_bottom,
            color: Theme.of(context).colorScheme.primary,
          ),
          tooltip: "Update available",
        ),
      );
    });
  }
}
