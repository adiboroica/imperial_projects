import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:keep_playing_frontend/models/user.dart';
import 'package:keep_playing_frontend/state/auth_cubit.dart';
import 'package:keep_playing_frontend/state/auth_state.dart';
import 'package:keep_playing_frontend/widgets/app_theme.dart';
import 'package:keep_playing_frontend/widgets/loading_indicator.dart';

class SharedLoginPage extends StatefulWidget {
  final String title;
  final bool Function(User user) roleCheck;
  final String roleErrorMessage;
  final Widget Function() buildSignUpPage;
  final Widget Function() buildHomePage;

  const SharedLoginPage({
    super.key,
    required this.title,
    required this.roleCheck,
    required this.roleErrorMessage,
    required this.buildSignUpPage,
    required this.buildHomePage,
  });

  @override
  State<SharedLoginPage> createState() => _SharedLoginPageState();
}

class _SharedLoginPageState extends State<SharedLoginPage> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: BlocListener<AuthCubit, AuthState>(
        listener: (context, state) {
          switch (state) {
            case AuthAuthenticated(user: final user):
              if (widget.roleCheck(user)) {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => widget.buildHomePage()),
                );
              } else {
                _showRoleDeniedDialog();
                context.read<AuthCubit>().logout();
              }
            case AuthError(message: final msg):
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(msg)),
              );
            default:
              break;
          }
        },
        child: BlocBuilder<AuthCubit, AuthState>(
          builder: (context, state) {
            if (state is AuthLoading) {
              return const LoadingScreen();
            }
            return _buildForm(context);
          },
        ),
      ),
    );
  }

  Widget _buildForm(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.paddingLarge),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                'assets/images/logo_transparent.png',
                height: 150,
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
                    return 'Please enter your username';
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
                    return 'Please enter your password';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppTheme.paddingLarge),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: _handleLogin,
                  child: const Text(
                    'Login',
                    style: TextStyle(
                      fontSize: AppTheme.buttonFontSize,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppTheme.paddingMedium),
              TextButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => widget.buildSignUpPage(),
                  ),
                ),
                child: const Text('Don\'t have an account? Sign Up'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleLogin() {
    if (!_formKey.currentState!.validate()) return;

    context.read<AuthCubit>().login(
          userLogin: UserLogin(
            username: _usernameController.text.trim(),
            password: _passwordController.text,
          ),
        );
  }

  void _showRoleDeniedDialog() {
    showDialog(
      context: context,
      builder: (_) => SimpleDialog(
        title: const Center(child: Text('Access Denied')),
        contentPadding: const EdgeInsets.all(AppTheme.paddingMedium),
        children: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: Text(widget.roleErrorMessage),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(AppTheme.paddingMedium),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                ),
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Ok', style: TextStyle(color: Colors.white)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
