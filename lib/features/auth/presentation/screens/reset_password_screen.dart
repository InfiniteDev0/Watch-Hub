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

class ResetPasswordScreen extends StatefulWidget {
  final String email;

  const ResetPasswordScreen({super.key, required this.email});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleResetPassword() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      final success = await authProvider.updatePassword(
        _newPasswordController.text,
      );

      if (success && mounted) {
        ToastHelper.showSuccess(context, 'Password reset successful!');
        context.go(AppRouter.login);
      } else if (mounted) {
        final err = authProvider.error ?? 'Failed to reset password.';
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
                  AppStrings.resetPasswordTitle,
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
                  AppStrings.resetPasswordSubtitle,
                  style: TextStyle(
                    fontSize: 14,
                    color: isDarkMode
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                  ),
                ),

                const SizedBox(height: 40),

                // New Password Field
                CustomTextField(
                  label: AppStrings.newPasswordLabel,
                  controller: _newPasswordController,
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
                    _newPasswordController.text,
                  ),
                ),

                const SizedBox(height: 40),

                // Reset Password Button
                CustomButton(
                  text: AppStrings.resetPasswordButton,
                  onPressed: _handleResetPassword,
                  isLoading: authProvider.isLoading,
                ),

                const SizedBox(height: 16),

                // Go Back to Login
                Center(
                  child: TextButton(
                    onPressed: () => context.go(AppRouter.login),
                    child: Text(
                      AppStrings.goBackToLogin,
                      style: TextStyle(
                        color: isDarkMode
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimaryLight,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
