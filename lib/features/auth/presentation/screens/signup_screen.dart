// Signup screen UI
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:watch_hub/core/constants/app_colors.dart';
import 'package:watch_hub/core/constants/app_strings.dart';
import 'package:watch_hub/core/router/app_router.dart';
import 'package:watch_hub/core/utils/toast_helper.dart';
import 'package:watch_hub/core/utils/validators.dart';
import 'package:watch_hub/features/auth/logic/providers/auth_provider.dart';
import 'package:watch_hub/shared/widgets/custom_button.dart';
import 'package:watch_hub/shared/widgets/custom_text_field.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignup() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      final success = await authProvider.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        fullName: _fullNameController.text.trim(),
      );

      if (success && mounted) {
        ToastHelper.showSuccess(
          context,
          'Account created! You can now log in.',
        );
        context.go(AppRouter.login);
      } else if (mounted) {
        final err = authProvider.error ?? 'Signup failed. Please try again.';
        ToastHelper.showError(context, err);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: isDarkMode
          ? AppColors.backgroundDark
          : AppColors.backgroundLight,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),

                // Title
                Text(
                  AppStrings.signupTitle,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimaryLight,
                  ),
                ),

                const SizedBox(height: 8),

                // Subtitle
                Text(
                  AppStrings.signupSubtitle,
                  style: TextStyle(
                    fontSize: 14,
                    color: isDarkMode
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                  ),
                ),

                const SizedBox(height: 40),

                // Full Name Field
                CustomTextField(
                  label: 'Full Name',
                  controller: _fullNameController,
                  keyboardType: TextInputType.name,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Full name is required';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 20),

                // Email Field
                CustomTextField(
                  label: AppStrings.emailLabel,
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  validator: Validators.validateEmail,
                ),

                const SizedBox(height: 20),

                // Password Field
                CustomTextField(
                  label: AppStrings.passwordLabel,
                  controller: _passwordController,
                  isPassword: true,
                  validator: Validators.validatePassword,
                ),

                const SizedBox(height: 20),

                // Confirm Password Field
                CustomTextField(
                  label: AppStrings.confirmPasswordLabel,
                  controller: _confirmPasswordController,
                  isPassword: true,
                  validator: (value) => Validators.validateConfirmPassword(
                    value,
                    _passwordController.text,
                  ),
                ),

                const SizedBox(height: 40),

                // Signup Button
                CustomButton(
                  text: AppStrings.signupButton,
                  onPressed: _handleSignup,
                  isLoading: authProvider.isLoading,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
