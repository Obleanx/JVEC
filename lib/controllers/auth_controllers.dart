import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:jvec/bindings/map_bindings.dart';
import 'package:jvec/views/screens/map_screens.dart';

class AuthController extends GetxController {
  var isSignUp = true.obs;
  var isLoading = false.obs;

  final formKey = GlobalKey<FormState>();
  String firstName = '',
      lastName = '',
      email = '',
      phoneNumber = '',
      password = '';
  String confirmPassword = '';

  void toggleAuthMode() {
    isSignUp.value = !isSignUp.value;
  }

  void createUserAccount() async {
    if (!formKey.currentState!.validate()) return;
    isLoading.value = true;
    await Future.delayed(const Duration(seconds: 2)); // Simulated network call
    isLoading.value = false;
    Get.snackbar("Success", "Account created successfully!");
  }

  void signIn() async {
    if (!formKey.currentState!.validate()) return;

    isLoading.value = true;
    await Future.delayed(const Duration(seconds: 2)); // Simulated network call
    isLoading.value = false;

    // Navigate to MapScreen after login
    Get.off(() => MapScreen(), binding: MapBinding());

    Get.snackbar("Welcome Back!", "You are now logged in.");
  }

  String? validateField(String? value) {
    if (value == null || value.isEmpty) return "This field is required";
    return null;
  }

  /// Email Validation
  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return "Email is required";
    }
    if (!RegExp(
            r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]+")
        .hasMatch(value)) {
      return "Enter a valid email address";
    }
    return null;
  }

  /// Phone Number Validation
  String? validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return "Phone number is required";
    }
    if (!RegExp(r"^\+?[0-9]{7,15}$").hasMatch(value)) {
      return "Enter a valid phone number";
    }
    return null;
  }

  /// Password Validation
  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return "Password is required";
    }
    if (value.length < 4) {
      return "Password must be at least 4 characters long";
    }
    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return "Password must contain at least one uppercase letter";
    }
    if (!RegExp(r'[a-z]').hasMatch(value)) {
      return "Password must contain at least one lowercase letter";
    }
    if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value)) {
      return "Password must contain at least one special character";
    }
    return null;
  }
}
