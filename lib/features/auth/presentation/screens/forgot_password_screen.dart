// Forgot password screen UI
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:watch_hub/core/constants/app_colors.dart';
import 'package:watch_hub/core/router/app_router.dart';
import 'package:watch_hub/core/utils/toast_helper.dart';
import 'package:watch_hub/core/utils/validators.dart';
import 'package:watch_hub/features/auth/logic/providers/auth_provider.dart';
import 'package:watch_hub/shared/widgets/custom_button.dart';
import 'package:watch_hub/shared/widgets/custom_text_field.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleSendOTP() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      final success = await authProvider.sendPasswordReset(
        _emailController.text.trim(),
      );

      if (success && mounted) {
        ToastHelper.showSuccess(context, 'OTP sent to your email!');
        context.push(
          AppRouter.otpVerification,
          extra: {'email': _emailController.text.trim(), 'type': 'recovery'},
        );
      } else if (mounted) {
        final err =
            authProvider.error ?? 'Failed to send OTP. Please try again.';
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
                  'Forgot Password?',
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
                  'Enter your email to receive an OTP',
                  style: TextStyle(
                    fontSize: 14,
                    color: isDarkMode
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                  ),
                ),

                const SizedBox(height: 40),

                // Email Field
                CustomTextField(
                  label: 'Email',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  validator: Validators.validateEmail,
                ),

                const SizedBox(height: 40),

                // Send OTP Button
                CustomButton(
                  text: 'Send OTP',
                  onPressed: _handleSendOTP,
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
