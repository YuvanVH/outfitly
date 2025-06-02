import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:outfitly/main.dart';
import 'package:outfitly/services/auth_service.dart';
import '../../widgets/nav_bars/dynamic_desktop_title.dart';
import '../../widgets/nav_bars/dynamic_mobile_appbar_title.dart';
import '../user/widgets/profile_avatar.dart';
import '../user/widgets/editable_field.dart';

class UserScreen extends StatefulWidget {
  const UserScreen({super.key});

  @override
  State<UserScreen> createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  final _authService = AuthService();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  bool _isEditingFirstName = false;
  bool _isEditingLastName = false;
  String? _profileImageUrl;
  String? _errorMessage;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
    _authService.authStateChanges.listen((user) {
      if (user == null && mounted) {
        context.go('/splash?logout=true');
      }
    });
  }

  Future<void> _loadUserProfile() async {
    final user = _authService.currentUser;
    if (user == null) {
      context.go('/splash');
      return;
    }

    try {
      final userProfile = await _authService.getUserProfile(user.uid);
      if (userProfile != null && mounted) {
        setState(() {
          _firstNameController.text = userProfile.firstName;
          _lastNameController.text = userProfile.lastName;
          _profileImageUrl = userProfile.profileImage;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error loading profile: $e';
      });
    }
  }

  Future<void> _pickImage() async {
    final user = _authService.currentUser;
    if (user == null) return;

    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        final bytes = await pickedFile.readAsBytes();
        setState(() {
          _isLoading = true;
        });
        final url = await _authService.uploadProfileImage(bytes, user.uid);
        if (mounted) {
          setState(() {
            _profileImageUrl = url;
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Error uploading image: $e';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _saveProfile() async {
    final user = _authService.currentUser;
    if (user == null) return;

    try {
      setState(() {
        _isLoading = true;
      });
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({
            'firstName': _firstNameController.text.trim(),
            'lastName': _lastNameController.text.trim(),
          });
      if (mounted) {
        setState(() {
          _isEditingFirstName = false;
          _isEditingLastName = false;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Error saving profile: $e';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _showSuccessDialog(String message) async {
    await showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Success'),
            content: Text(message),
            backgroundColor: Colors.white,
            titleTextStyle: const TextStyle(
              color: Color(0xFF7D0DDC),
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            contentTextStyle: const TextStyle(color: Colors.black87),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'OK',
                  style: TextStyle(color: Color(0xFF7D0DDC)),
                ),
              ),
            ],
          ),
    );
  }

  Future<void> _changePassword() async {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    final result = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Change Password'),
            content: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: currentPasswordController,
                    decoration: const InputDecoration(
                      labelText: 'Current Password',
                      border: OutlineInputBorder(),
                    ),
                    obscureText: true,
                    validator:
                        (value) =>
                            value!.isEmpty ? 'Enter current password' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: newPasswordController,
                    decoration: const InputDecoration(
                      labelText: 'New Password',
                      border: OutlineInputBorder(),
                    ),
                    obscureText: true,
                    validator: (value) {
                      if (value!.isEmpty) return 'Enter new password';
                      if (value.length < 6) {
                        return 'Password must be 6+ characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: confirmPasswordController,
                    decoration: const InputDecoration(
                      labelText: 'Confirm New Password',
                      border: OutlineInputBorder(),
                    ),
                    obscureText: true,
                    validator: (value) {
                      if (value != newPasswordController.text) {
                        return 'Passwords do not match';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  if (formKey.currentState!.validate()) {
                    Navigator.pop(context, true);
                  }
                },
                child: const Text('Change'),
              ),
            ],
          ),
    );

    if (result == true) {
      try {
        setState(() {
          _isLoading = true;
        });
        await _authService.changePassword(
          currentPasswordController.text.trim(),
          newPasswordController.text.trim(),
        );
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
          await _showSuccessDialog('Password updated successfully!');
        }
      } on FirebaseAuthException catch (e) {
        if (mounted) {
          setState(() {
            _isLoading = false;
            _errorMessage =
                e.code == 'wrong-password'
                    ? 'Incorrect current password'
                    : 'Error changing password: ${e.message}';
          });
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _isLoading = false;
            _errorMessage = 'Error changing password: $e';
          });
        }
      }
    }

    currentPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
  }

  Future<void> _changeEmail() async {
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    final result = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Change Email'),
            content: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: emailController,
                    decoration: const InputDecoration(
                      labelText: 'New Email',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value!.isEmpty) return 'Enter new email';
                      if (!RegExp(
                        r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                      ).hasMatch(value)) {
                        return 'Invalid email format';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: passwordController,
                    decoration: const InputDecoration(
                      labelText: 'Current Password',
                      border: OutlineInputBorder(),
                    ),
                    obscureText: true,
                    validator:
                        (value) =>
                            value!.isEmpty ? 'Enter current password' : null,
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  if (formKey.currentState!.validate()) {
                    Navigator.pop(context, true);
                  }
                },
                child: const Text('Change'),
              ),
            ],
          ),
    );

    if (result == true) {
      try {
        setState(() {
          _isLoading = true;
        });
        await _authService.changeEmail(
          emailController.text.trim(),
          passwordController.text.trim(),
        );
        await _loadUserProfile();
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
          await _showSuccessDialog(
            'Email updated successfully! Please check your inbox to verify the new email.',
          );
        }
      } on FirebaseAuthException catch (e) {
        if (mounted) {
          setState(() {
            _isLoading = false;
            _errorMessage =
                e.code == 'wrong-password'
                    ? 'Incorrect current password'
                    : e.code == 'email-already-in-use'
                    ? 'Email already in use'
                    : 'Error changing email: ${e.message}';
          });
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _isLoading = false;
            _errorMessage = 'Error changing email: $e';
          });
        }
      }
    }

    emailController.dispose();
    passwordController.dispose();
  }

  Future<void> _deleteAccount() async {
    final user = _authService.currentUser;
    if (user == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Account'),
            content: const Text(
              'Are you sure you want to permanently delete your account? This cannot be undone.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );

    if (confirm == true) {
      try {
        setState(() {
          _isLoading = true;
        });
        await _authService.deleteUser(user.uid);
        if (mounted) {
          context.go('/splash?logout=true');
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _errorMessage = 'Error deleting account: $e';
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 900;
    final theme = Theme.of(context);
    final user = _authService.currentUser;

    if (user == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.go('/splash');
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final createdAt = user.metadata.creationTime;

    return Scaffold(
      appBar:
          isDesktop ? null : AppBar(title: const DynamicMobileAppBarTitle()),
      body: Stack(
        children: [
          SafeArea(
            bottom: true,
            child: SingleChildScrollView(
              padding: EdgeInsets.only(
                left: 32.0,
                right: 32.0,
                top: 32.0,
                bottom: 32.0 + 80.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isDesktop) const DynamicDesktopTitle(),
                  const SizedBox(height: 32),
                  Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth:
                            MediaQuery.of(context).size.width > 600
                                ? 500
                                : double.infinity,
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color:
                              theme.brightness == Brightness.light
                                  ? const Color(0xFFF5F5F5)
                                  : theme.cardColor,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withAlpha(30),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Center(
                              child: ProfileAvatar(
                                imageUrl: _profileImageUrl,
                                onTap: _pickImage,
                                isLoading: _isLoading,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Center(
                              child: Text(
                                user.email ?? 'No email',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                            const SizedBox(height: 32),
                            EditableField(
                              label: 'First Name',
                              controller: _firstNameController,
                              isEditing: _isEditingFirstName,
                              onEditToggle:
                                  () => setState(
                                    () =>
                                        _isEditingFirstName =
                                            !_isEditingFirstName,
                                  ),
                            ),
                            const SizedBox(height: 16),
                            EditableField(
                              label: 'Last Name',
                              controller: _lastNameController,
                              isEditing: _isEditingLastName,
                              onEditToggle:
                                  () => setState(
                                    () =>
                                        _isEditingLastName =
                                            !_isEditingLastName,
                                  ),
                            ),
                            const SizedBox(height: 16),
                            if (_isEditingFirstName || _isEditingLastName)
                              Center(
                                child: ElevatedButton(
                                  onPressed: _saveProfile,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF7D0DDC),
                                    foregroundColor: Colors.white,
                                  ),
                                  child: const Text('Save Changes'),
                                ),
                              ),
                            const SizedBox(height: 32),
                            Text(
                              'Account Created: ${createdAt != null ? "${createdAt.day}/${createdAt.month}/${createdAt.year}" : "Unknown"}',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 32),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Theme: ${Theme.of(context).brightness == Brightness.dark ? "Dark Mode" : "Light Mode"}',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: Colors.black87,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Switch(
                                  value:
                                      Theme.of(context).brightness ==
                                      Brightness.dark,
                                  onChanged:
                                      (value) => ThemeProvider.of(
                                        context,
                                      ).toggleTheme(value),
                                  activeColor: const Color(0xFF7D0DDC),
                                  inactiveThumbColor: Colors.grey,
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            Center(
                              child: ElevatedButton(
                                onPressed: _changePassword,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF7D0DDC),
                                  foregroundColor: Colors.white,
                                ),
                                child: const Text('Change Password'),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Center(
                              child: ElevatedButton(
                                onPressed: _changeEmail,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF7D0DDC),
                                  foregroundColor: Colors.white,
                                ),
                                child: const Text('Change Email'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Center(
                    child: OutlinedButton(
                      onPressed: _deleteAccount,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                      ),
                      child: const Text('Delete Account'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_isLoading)
            Container(
              color: const Color.fromARGB(179, 0, 0, 0),
              child: const Center(child: CircularProgressIndicator()),
            ),
          if (_errorMessage != null)
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: SnackBar(
                content: Text(_errorMessage!),
                action: SnackBarAction(
                  label: 'Dismiss',
                  onPressed: () => setState(() => _errorMessage = null),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
