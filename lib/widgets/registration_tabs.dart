import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:jvec/controllers/auth_controllers.dart';

class RegistrationTabs extends StatelessWidget {
  final AuthController controller = Get.find<AuthController>();

  RegistrationTabs({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildTab("Sign Up", controller.isSignUp.value,
              () => controller.isSignUp.value = true),
          const SizedBox(width: 20),
          _buildTab("Login", !controller.isSignUp.value,
              () => controller.isSignUp.value = false),
        ],
      );
    });
  }

  Widget _buildTab(String text, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Text(
        text,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? Colors.blue : Colors.black,
          fontSize: 18,
        ),
      ),
    );
  }
}
