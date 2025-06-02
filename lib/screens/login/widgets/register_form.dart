import 'package:flutter/material.dart';
import '../../../themes/buttons/standard_button.dart';

class RegisterForm extends StatelessWidget {
  final AnimationController animationController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController firstNameController; // New parameter
  final GlobalKey<FormState> formKey;
  final bool isLoading;
  final VoidCallback onRegister;
  final VoidCallback onGoToLogin;
  final String? errorMessage;
  final VoidCallback? onErrorDismissed;

  const RegisterForm({
    super.key,
    required this.animationController,
    required this.emailController,
    required this.passwordController,
    required this.firstNameController, // New parameter
    required this.formKey,
    required this.isLoading,
    required this.onRegister,
    required this.onGoToLogin,
    this.errorMessage,
    this.onErrorDismissed,
  });

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (errorMessage != null && errorMessage!.isNotEmpty) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text(
                errorMessage!,
                style: const TextStyle(color: Colors.black87),
              ),
              backgroundColor: Colors.white,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 4),
            ),
          ).closed.then((_) {
            if (onErrorDismissed != null) {
              onErrorDismissed!();
            }
          });
      }
    });

    return Form(
      key: formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 50),
          FadeTransition(
            opacity: Tween<double>(begin: 0.9, end: 0.6).animate(
              CurvedAnimation(
                parent: animationController,
                curve: Curves.easeInOutSine,
                reverseCurve: Curves.easeInOutSine,
              ),
            ),
            child: Image.asset(
              'web/assets/icons/hanger-purple.png',
              height: 100,
            ),
          ),
          const Text(
            'Outfitly',
            style: TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.bold,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 25),
          Text(
            'Create your Outfitly account!',
            style: TextStyle(
              fontSize: MediaQuery.of(context).size.width < 600 ? 18 : 25,
              fontWeight: FontWeight.bold,
              color: Colors.black54,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          TextFormField(
            controller: firstNameController, // New field
            decoration: const InputDecoration(
              labelText: 'First Name',
              filled: true,
              fillColor: Color(0xFFECEFF1),
              border: OutlineInputBorder(),
              labelStyle: TextStyle(color: Colors.black87),
            ),
            style: const TextStyle(color: Colors.black87),
            validator:
                (value) =>
                    value!.isEmpty ? '* Enter first name' : null, // Mandatory
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 20),
          TextFormField(
            controller: emailController,
            decoration: const InputDecoration(
              labelText: 'Email',
              filled: true,
              fillColor: Color(0xFFECEFF1),
              border: OutlineInputBorder(),
              labelStyle: TextStyle(color: Colors.black87),
            ),
            style: const TextStyle(color: Colors.black87),
            validator: (value) => value!.isEmpty ? '* Enter email' : null,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 20),
          TextFormField(
            controller: passwordController,
            decoration: const InputDecoration(
              labelText: 'Password',
              filled: true,
              fillColor: Color(0xFFECEFF1),
              border: OutlineInputBorder(),
              labelStyle: TextStyle(color: Colors.black87),
            ),
            style: const TextStyle(color: Colors.black87),
            obscureText: true,
            validator:
                (value) => value!.length < 6 ? '* Min 6 characters' : null,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => onRegister(),
          ),
          const SizedBox(height: 20),
          isLoading
              ? const CircularProgressIndicator()
              : ElevatedButton(
                onPressed: onRegister,
                style: StandardButtonStyles.defaultStyle(),
                child: const Text('Register'),
              ),
          const SizedBox(height: 20),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Already have an account? ",
                style: TextStyle(color: Colors.black54),
              ),
              GestureDetector(
                onTap: onGoToLogin,
                child: const Text(
                  'Sign in here',
                  style: TextStyle(
                    color: Color.fromARGB(255, 125, 13, 217),
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
