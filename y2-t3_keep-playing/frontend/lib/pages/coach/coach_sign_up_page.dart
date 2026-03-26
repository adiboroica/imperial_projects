import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import 'package:keep_playing_frontend/models/user.dart';
import 'package:keep_playing_frontend/state/auth_cubit.dart';
import 'package:keep_playing_frontend/widgets/app_theme.dart';
import 'package:keep_playing_frontend/widgets/confirmation_dialog.dart';
import 'package:keep_playing_frontend/widgets/exit_guard.dart';
import 'package:keep_playing_frontend/widgets/loading_indicator.dart';

class CoachSignUpPage extends StatefulWidget {
  const CoachSignUpPage({super.key});

  @override
  State<CoachSignUpPage> createState() => _CoachSignUpPageState();
}

class _CoachSignUpPageState extends State<CoachSignUpPage> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _imagePicker = ImagePicker();

  XFile? _qualificationFile;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ExitGuard(
      title: 'Discard Sign Up?',
      content: 'Any information entered will be lost.',
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Coach Sign Up'),
          backgroundColor: AppTheme.primaryColor,
          foregroundColor: Colors.white,
        ),
        body: _isSubmitting
            ? const LoadingScreen()
            : Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(AppTheme.paddingLarge),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Icon(
                          Icons.sports,
                          size: 80,
                          color: AppTheme.primaryColor,
                        ),
                        const SizedBox(height: AppTheme.paddingLarge),
                        TextFormField(
                          controller: _usernameController,
                          decoration: const InputDecoration(
                            labelText: 'Username',
                            prefixIcon: Icon(Icons.person),
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a username';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: AppTheme.paddingMedium),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: true,
                          decoration: const InputDecoration(
                            labelText: 'Password',
                            prefixIcon: Icon(Icons.lock),
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a password';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: AppTheme.paddingLarge),
                        OutlinedButton.icon(
                          icon: const Icon(Icons.upload_file),
                          label: Text(
                            _qualificationFile != null
                                ? _qualificationFile!.name
                                : 'Upload Qualification',
                          ),
                          onPressed: _pickQualificationFile,
                        ),
                        const SizedBox(height: AppTheme.paddingLarge),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryColor,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          onPressed: _handleSignUp,
                          child: const Text(
                            'Sign Up',
                            style: TextStyle(
                              fontSize: AppTheme.buttonFontSize,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
      ),
    );
  }

  Future<void> _pickQualificationFile() async {
    final file = await _imagePicker.pickImage(source: ImageSource.gallery);
    if (file != null) {
      setState(() => _qualificationFile = file);
    }
  }

  Future<void> _handleSignUp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    final signUp = CoachSignUp(
      username: _usernameController.text.trim(),
      password: _passwordController.text,
      qualificationFile: _qualificationFile,
    );

    try {
      final apiUsers = context.read<AuthCubit>().apiUsers;
      final response = await apiUsers.signUpAsCoach(signUp: signUp);

      if (!mounted) return;
      setState(() => _isSubmitting = false);

      if (response.statusCode == 201 || response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Account created successfully')),
        );
        Navigator.of(context).pop();
      } else {
        await showDialog(
          context: context,
          builder: (_) => const RequestFailedDialog(),
        );
      }
    } catch (_) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      await showDialog(
        context: context,
        builder: (_) => const RequestFailedDialog(),
      );
    }
  }
}
