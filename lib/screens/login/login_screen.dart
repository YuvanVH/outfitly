import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'widgets/login_form.dart';
import '../../widgets/animated_wave.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _rememberMe = true;
  late AnimationController _controller;

  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();

  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _setPersistence();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();
  }

  Future<void> _setPersistence() async {
    try {
      await FirebaseAuth.instance.setPersistence(
        _rememberMe ? Persistence.LOCAL : Persistence.SESSION,
      );
    } catch (e) {
      debugPrint('Error setting persistence: $e');
    }
  }

  Future<void> _signIn() async {
    if (_formKey.currentState!.validate()) {
      try {
        await _setPersistence();
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailController.text,
          password: _passwordController.text,
        );
        if (mounted) {
          context.go('/home');
        }
      } on FirebaseAuthException catch (e) {
        String errorMessage;
        if (e.code == 'user-not-found') {
          errorMessage = 'No user found for that email.';
        } else if (e.code == 'wrong-password') {
          errorMessage = 'Incorrect password.';
        } else if (e.code == 'invalid-email') {
          errorMessage = 'Invalid email address.';
        } else {
          errorMessage = 'Error: ${e.message}';
        }
        _showError(errorMessage);
      } catch (e) {
        _showError('Error: $e');
      }
    }
  }

  void _showError(String message) {
    setState(() {
      _errorMessage = message;
    });
  }

  void _clearError() {
    setState(() {
      _errorMessage = null;
    });
  }

  Future<void> _createAccount() async {
    context.push('/register');
  }

  void _navigateToHome() {
    if (mounted) {
      context.go('/home');
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _controller.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('LoginScreen rendering');
    return Theme(
      data: ThemeData(
        scaffoldBackgroundColor: Colors.white,
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      child: Scaffold(
        backgroundColor: Colors.white, // Pure white
        body: Stack(
          children: [
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
                      minHeight: 200,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        LoginForm(
                          animationController: _controller,
                          emailController: _emailController,
                          passwordController: _passwordController,
                          emailFocusNode: _emailFocusNode,
                          passwordFocusNode: _passwordFocusNode,
                          formKey: _formKey,
                          rememberMe: _rememberMe,
                          onRememberMeChanged: (value) {
                            setState(() {
                              _rememberMe = value ?? false;
                            });
                          },
                          onSignIn: () {
                            _clearError();
                            _signIn();
                          },
                          onCreateAccount: _createAccount,
                          errorMessage: _errorMessage,
                          onErrorDismissed: _clearError,
                        ),

                        // Debug button
                        if (kDebugMode)
                          Column(
                            children: [
                              const SizedBox(height: 16),
                              ElevatedButton.icon(
                                icon: const Icon(Icons.bug_report),
                                label: const Text('Debug Login'),
                                onPressed: () async {
                                  try {
                                    await FirebaseAuth.instance
                                        .signInWithEmailAndPassword(
                                          email: 'test@example.com',
                                          password: 'password123',
                                        );
                                    _navigateToHome();
                                  } on FirebaseAuthException catch (e) {
                                    if (e.code == 'user-not-found') {
                                      try {
                                        await FirebaseAuth.instance
                                            .createUserWithEmailAndPassword(
                                              email: 'test@example.com',
                                              password: 'password123',
                                            );
                                        _navigateToHome();
                                      } catch (e) {
                                        _showError(
                                          'Kunde inte skapa testanvändare: $e',
                                        );
                                      }
                                    } else {
                                      _showError(
                                        'Fel vid inloggning (${e.code}): ${e.message}',
                                      );
                                    }
                                  } catch (e) {
                                    _showError('Oväntat fel: $e');
                                  }
                                },
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
