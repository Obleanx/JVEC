import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:jvec/widgets/custom_textfields.dart';
import 'package:jvec/controllers/auth_controllers.dart';

class RegistrationForm extends StatelessWidget {
  final AuthController controller = Get.find<AuthController>();
  final TextEditingController passwordController = TextEditingController();

  RegistrationForm({super.key});

  @override
  Widget build(BuildContext context) {
    return Form(
      key: controller.formKey,
      child: Column(
        children: [
          CustomTextField(
            label: "First Name",
            validator: controller.validateField,
            onSaved: (value) => controller.firstName = value!,
          ),
          const SizedBox(height: 20),
          CustomTextField(
            label: "Last Name",
            validator: controller.validateField,
            onSaved: (value) => controller.lastName = value!,
          ),
          const SizedBox(height: 20),
          CustomTextField(
            label: "Email",
            validator: controller.validateEmail,
            onSaved: (value) => controller.email = value!,
          ),
          const SizedBox(height: 20),
          CustomTextField(
            label: "Phone Number",
            isPhoneNumber: true,
            validator: controller.validatePhoneNumber,
            onSaved: (value) => controller.phoneNumber = value!,
          ),
          const SizedBox(height: 20),
          PasswordField(
            label: "Password",
            onSaved: (value) => controller.password = value!,
            validator: controller.validatePassword,
            primaryPasswordController: passwordController,
          ),
          const SizedBox(height: 20),
          PasswordField(
            label: "Confirm Password",
            isConfirmPassword: true,
            primaryPasswordController: passwordController,
            onSaved: (value) => controller.confirmPassword = value!,
          ),
        ],
      ),
    );
  }
}
