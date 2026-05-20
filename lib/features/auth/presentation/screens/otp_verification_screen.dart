import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:watch_hub/core/constants/app_colors.dart';
import 'package:watch_hub/core/constants/app_constants.dart';
import 'package:watch_hub/core/constants/app_strings.dart';
import 'package:watch_hub/core/router/app_router.dart';
import 'package:watch_hub/core/utils/toast_helper.dart';
import 'package:watch_hub/features/auth/logic/providers/auth_provider.dart';
import 'package:watch_hub/shared/widgets/custom_button.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String email;

  /// 'signup' or 'recovery'
  final String otpType;

  const OtpVerificationScreen({
    super.key,
    required this.email,
    this.otpType = 'signup',
  });

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final List<TextEditingController> _otpControllers = List.generate(
    AppConstants.otpLength,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(
    AppConstants.otpLength,
    (_) => FocusNode(),
  );

  int _secondsRemaining = AppConstants.otpExpirySeconds;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() {
          _secondsRemaining--;
        });
      } else {
        timer.cancel();
      }
    });
  }

  void _resendOTP() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final type = widget.otpType == 'recovery'
        ? OtpType.recovery
        : OtpType.signup;

    final success = await authProvider.resendOtp(
      email: widget.email,
      type: type,
    );

    if (success && mounted) {
      ToastHelper.showSuccess(context, 'OTP resent!');
      setState(() {
        _secondsRemaining = AppConstants.otpExpirySeconds;
      });
      _startTimer();
    } else if (mounted) {
      final err = authProvider.error ?? 'Failed to resend OTP.';
      ToastHelper.showError(context, err);
    }
  }

  Future<void> _handleVerifyOTP() async {
    final otp = _otpControllers.map((c) => c.text).join();

    if (otp.length != AppConstants.otpLength) {
      ToastHelper.showError(
        context,
        'Please enter all ${AppConstants.otpLength} digits',
      );
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final type = widget.otpType == 'recovery'
        ? OtpType.recovery
        : OtpType.signup;

    final success = await authProvider.verifyOtp(
      email: widget.email,
      token: otp,
      type: type,
    );

    if (success && mounted) {
      ToastHelper.showSuccess(context, 'OTP verified!');
      if (widget.otpType == 'recovery') {
        // Go to reset password screen
        context.push(AppRouter.resetPassword, extra: widget.email);
      } else {
        // Signup confirmed — go home
        context.go(AppRouter.home);
      }
    } else if (mounted) {
      final err = authProvider.error ?? 'Invalid OTP. Please try again.';
      ToastHelper.showError(context, err);
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 40),

              // Title
              Text(
                AppStrings.otpTitle,
                textAlign: TextAlign.center,
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
                AppStrings.otpSubtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: isDarkMode
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight,
                ),
              ),

              const SizedBox(height: 40),

              // OTP Input Boxes
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(
                  AppConstants.otpLength,
                  (index) => SizedBox(
                    width: 50,
                    height: 60,
                    child: TextField(
                      controller: _otpControllers[index],
                      focusNode: _focusNodes[index],
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      maxLength: 1,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: isDarkMode
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimaryLight,
                      ),
                      decoration: InputDecoration(
                        counterText: '',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: isDarkMode
                                ? AppColors.borderDark
                                : AppColors.borderLight,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: isDarkMode
                                ? AppColors.primaryDark
                                : AppColors.primaryLight,
                            width: 2,
                          ),
                        ),
                      ),
                      onChanged: (value) {
                        if (value.isNotEmpty &&
                            index < AppConstants.otpLength - 1) {
                          _focusNodes[index + 1].requestFocus();
                        } else if (value.isEmpty && index > 0) {
                          _focusNodes[index - 1].requestFocus();
                        }
                      },
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Resend & Timer
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: _secondsRemaining == 0 ? _resendOTP : null,
                    child: Text(
                      AppStrings.resendCode,
                      style: TextStyle(
                        color: _secondsRemaining == 0
                            ? (isDarkMode
                                  ? AppColors.primaryDark
                                  : AppColors.primaryLight)
                            : AppColors.textSecondaryLight,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                  Text(
                    'Expires in 00:${_secondsRemaining.toString().padLeft(2, '0')}',
                    style: TextStyle(
                      fontSize: 14,
                      color: isDarkMode
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 40),

              // Continue Button
              CustomButton(
                text: AppStrings.continueButton,
                onPressed: _handleVerifyOTP,
                isLoading: authProvider.isLoading,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
