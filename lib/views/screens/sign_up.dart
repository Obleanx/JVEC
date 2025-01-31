import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:jvec/widgets/jvec_button.dart';
import 'package:jvec/widgets/google_signup.dart';
import 'package:jvec/widgets/terms_ofservice.dart';
import 'package:jvec/widgets/custom_textfields.dart';
import 'package:jvec/widgets/registration_form.dart';
import 'package:jvec/widgets/registration_tabs.dart';
import 'package:jvec/controllers/auth_controllers.dart';

class SignUpScreen extends StatelessWidget {
  final AuthController controller = Get.put(AuthController());
  final TextEditingController passwordController = TextEditingController();

  SignUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Obx(() {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),
              Center(child: Image.asset('lib/images/ride.jpeg', height: 100)),
              Text(
                controller.isSignUp.value ? "J V E C" : "Sign in to Jvec",
                style:
                    const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                controller.isSignUp.value
                    ? "Book a ride in minutes and explore your city effortlessly."
                    : "Sign in to book a ride instantly.",
                style: const TextStyle(fontSize: 14, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              RegistrationTabs(),
              const SizedBox(height: 20),
              controller.isSignUp.value
                  ? RegistrationForm()
                  : _buildLoginForm(),
              const SizedBox(height: 40),
              JvecButton(
                isLoading: controller.isLoading.value,
                onPressed: controller.isSignUp.value
                    ? controller.createUserAccount
                    : () => controller
                        .signIn(), // Ensure it calls signIn() with navigation
                child: Text(
                    controller.isSignUp.value ? 'Create Account' : 'Login'),
              ),
              const SizedBox(height: 20),
              const GoogleSignUpButton(),
              const SizedBox(height: 20),
              const TermsOfService(),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildLoginForm() {
    return Form(
      key: controller.formKey,
      child: Column(
        children: [
          CustomTextField(
            label: "Email",
            validator: controller.validateEmail,
            onSaved: (value) => controller.email = value!,
          ),
          const SizedBox(height: 20),
          PasswordField(
            label: "Password",
            onSaved: (value) => controller.password = value!,
            validator: controller.validatePassword,
            primaryPasswordController: passwordController,
          ),
        ],
      ),
    );
  }
}
