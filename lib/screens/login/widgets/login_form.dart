import 'package:flutter/material.dart';

import '../../../themes/buttons/standard_button.dart';

class LoginForm extends StatelessWidget {
  final AnimationController animationController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final FocusNode emailFocusNode;
  final FocusNode passwordFocusNode;
  final GlobalKey<FormState> formKey;
  final bool rememberMe;
  final ValueChanged<bool?> onRememberMeChanged;
  final VoidCallback onSignIn;
  final VoidCallback onCreateAccount;
  final String? errorMessage;
  final VoidCallback? onErrorDismissed;

  const LoginForm({
    super.key,
    required this.animationController,
    required this.emailController,
    required this.passwordController,
    required this.emailFocusNode,
    required this.passwordFocusNode,
    required this.formKey,
    required this.rememberMe,
    required this.onRememberMeChanged,
    required this.onSignIn,
    required this.onCreateAccount,
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
              onVisible: () {},
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
            'Your own personal outfit organizer',
            style: TextStyle(
              fontSize: MediaQuery.of(context).size.width < 600 ? 18 : 25,
              fontWeight: FontWeight.bold,
              color: Colors.black54,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          TextFormField(
            controller: emailController,
            focusNode: emailFocusNode,
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
            onFieldSubmitted: (_) {
              FocusScope.of(context).requestFocus(passwordFocusNode);
            },
          ),
          const SizedBox(height: 20),
          TextFormField(
            controller: passwordController,
            focusNode: passwordFocusNode,
            decoration: const InputDecoration(
              labelText: 'Password',
              filled: true,
              fillColor: Color(0xFFECEFF1),
              border: OutlineInputBorder(),
              labelStyle: TextStyle(color: Colors.black87),
            ),
            style: const TextStyle(color: Colors.black87),
            obscureText: true,
            validator: (value) => value!.isEmpty ? '* Enter password' : null,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => onSignIn(),
          ),
          const SizedBox(height: 5),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Checkbox(value: rememberMe, onChanged: onRememberMeChanged),
              const Text(
                'Remember Me',
                style: TextStyle(color: Colors.black54),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: onSignIn,
            style: StandardButtonStyles.defaultStyle(),
            child: const Text('Sign In'),
          ),
          const SizedBox(height: 20),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Don't have an account? ",
                style: TextStyle(color: Colors.black54),
              ),
              GestureDetector(
                onTap: onCreateAccount,
                child: const Text(
                  'Sign up here',
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
