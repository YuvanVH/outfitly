import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:outfitly/services/auth_service.dart';
import '../../../widgets/animated_wave.dart';
import '../widgets/register_form.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  RegisterScreenState createState() => RegisterScreenState();
}

class RegisterScreenState extends State<RegisterScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  late AnimationController _controller;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      User? user = await AuthService().registerUser(
        _emailController.text.trim(),
        _passwordController.text.trim(),
        _firstNameController.text.trim(), // Pass firstName
      );
      setState(() {
        _isLoading = false;
      });

      if (user != null && mounted) {
        context.go('/');
      } else if (mounted) {
        setState(() {
          _errorMessage = "Registration failed. Please try again.";
        });
      }
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'email-already-in-use':
          message = 'This email is already registered.';
          break;
        case 'invalid-email':
          message = 'Invalid email format.';
          break;
        case 'weak-password':
          message = 'Password is too weak.';
          break;
        default:
          message = 'An error occurred: ${e.message}';
      }
      setState(() {
        _isLoading = false;
        _errorMessage = message;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = "An unexpected error occurred: $e";
      });
    }
  }

  void _clearError() {
    setState(() {
      _errorMessage = null;
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _firstNameController.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(color: Colors.white),
          AnimatedWave(controller: _controller),
          Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth:
                        MediaQuery.of(context).size.width > 600
                            ? 600
                            : MediaQuery.of(context).size.width * 0.75,
                  ),
                  child: RegisterForm(
                    animationController: _controller,
                    emailController: _emailController,
                    passwordController: _passwordController,
                    firstNameController: _firstNameController, // New parameter
                    formKey: _formKey,
                    isLoading: _isLoading,
                    onRegister: _register,
                    onGoToLogin: () => context.go('/'),
                    errorMessage: _errorMessage,
                    onErrorDismissed: _clearError,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
