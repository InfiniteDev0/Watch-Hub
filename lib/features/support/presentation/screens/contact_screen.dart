import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:watch_hub/core/constants/app_assets.dart';
import 'package:watch_hub/core/network/api_client.dart';
import 'package:watch_hub/core/network/api_constants.dart';
import 'package:watch_hub/features/auth/logic/providers/auth_provider.dart';

const _subjects = [
  'Order Issue',
  'Product Question',
  'Return Request',
  'Shipping Inquiry',
  'Account Help',
  'General Inquiry',
];

class ContactScreen extends StatefulWidget {
  const ContactScreen({super.key});

  @override
  State<ContactScreen> createState() => _ContactScreenState();
}

class _ContactScreenState extends State<ContactScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _messageCtrl;
  String _selectedSubject = _subjects.first;

  bool _submitting = false;
  bool _submitted = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().currentUser;
    _nameCtrl = TextEditingController(text: user?.fullName ?? '');
    _emailCtrl = TextEditingController(text: user?.email ?? '');
    _messageCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _messageCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _submitting = true;
      _error = null;
    });

    try {
      final Dio dio = ApiClient.dio;
      await dio.post(
        ApiConstants.contact,
        data: {
          'full_name': _nameCtrl.text.trim(),
          'email': _emailCtrl.text.trim(),
          'subject': _selectedSubject,
          'message': _messageCtrl.text.trim(),
        },
      );
      if (mounted) setState(() => _submitted = true);
    } catch (e) {
      final msg = e.toString().replaceAll('Exception: ', '');
      if (mounted) setState(() => _error = msg);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Contact Us',
          style: TextStyle(
            fontFamily: AppAssets.instrumentSerif,
            fontSize: 24,
            fontWeight: FontWeight.w400,
            color: Colors.black,
          ),
        ),
        centerTitle: false,
      ),
      body: _submitted ? _buildSuccessView() : _buildFormView(),
    );
  }

  // ── Success view ───────────────────────────────────────────────────────────

  Widget _buildSuccessView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(36),
              ),
              child: const Icon(
                Icons.check,
                color: Colors.white,
                size: 36,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Message Sent',
              style: TextStyle(
                fontFamily: AppAssets.instrumentSerif,
                fontSize: 26,
                fontWeight: FontWeight.w400,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Thank you for reaching out. Our support team will get back to you within 24 hours.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: AppAssets.manrope,
                fontSize: 14,
                color: Colors.black54,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 36),
            SizedBox(
              width: 200,
              height: 48,
              child: ElevatedButton(
                onPressed: () => context.pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Back to Home',
                  style: TextStyle(
                    fontFamily: AppAssets.manrope,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Form view ──────────────────────────────────────────────────────────────

  Widget _buildFormView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'We\'d love to hear from you. Fill in the form and our team will respond within 24 hours.',
              style: TextStyle(
                fontFamily: AppAssets.manrope,
                fontSize: 14,
                color: Colors.black54,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 28),

            // ── Full Name ────────────────────────────────────────────
            _ContactField(
              label: 'Full Name',
              controller: _nameCtrl,
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 20),

            // ── Email ────────────────────────────────────────────────
            _ContactField(
              label: 'Email',
              controller: _emailCtrl,
              keyboardType: TextInputType.emailAddress,
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Required';
                if (!v.contains('@')) return 'Enter a valid email';
                return null;
              },
            ),
            const SizedBox(height: 20),

            // ── Subject dropdown ─────────────────────────────────────
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'SUBJECT',
                  style: TextStyle(
                    fontFamily: AppAssets.manrope,
                    fontSize: 11,
                    color: Colors.black54,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  value: _selectedSubject,
                  isExpanded: true,
                  style: const TextStyle(
                    fontFamily: AppAssets.manrope,
                    fontSize: 15,
                    color: Colors.black,
                  ),
                  decoration: const InputDecoration(
                    contentPadding: EdgeInsets.symmetric(vertical: 10),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFFD0D0D0)),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.black),
                    ),
                  ),
                  items: _subjects
                      .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                      .toList(),
                  onChanged: (v) {
                    if (v != null) setState(() => _selectedSubject = v);
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),

            // ── Message ──────────────────────────────────────────────
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'MESSAGE',
                  style: TextStyle(
                    fontFamily: AppAssets.manrope,
                    fontSize: 11,
                    color: Colors.black54,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _messageCtrl,
                  minLines: 4,
                  maxLines: 7,
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? 'Required' : null,
                  style: const TextStyle(
                    fontFamily: AppAssets.manrope,
                    fontSize: 15,
                  ),
                  decoration: const InputDecoration(
                    hintText: 'Describe your issue or question...',
                    hintStyle:
                        TextStyle(color: Colors.black26, fontSize: 14),
                    contentPadding: EdgeInsets.only(top: 10, bottom: 10),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFFD0D0D0)),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.black),
                    ),
                    errorBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.red),
                    ),
                    focusedErrorBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.red),
                    ),
                  ),
                ),
              ],
            ),

            // ── Error banner ─────────────────────────────────────────
            if (_error != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline,
                        size: 16, color: Colors.red),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _error!,
                        style: const TextStyle(
                          fontFamily: AppAssets.manrope,
                          fontSize: 13,
                          color: Colors.red,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 36),

            // ── Submit ───────────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _submitting ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _submitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'Send Message',
                        style: TextStyle(
                          fontFamily: AppAssets.manrope,
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

// ── Reusable field widget ──────────────────────────────────────────────────

class _ContactField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  const _ContactField({
    required this.label,
    required this.controller,
    this.keyboardType,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            fontFamily: AppAssets.manrope,
            fontSize: 11,
            color: Colors.black54,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
          style: const TextStyle(
            fontFamily: AppAssets.manrope,
            fontSize: 15,
          ),
          decoration: const InputDecoration(
            contentPadding: EdgeInsets.symmetric(vertical: 10),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Color(0xFFD0D0D0)),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.black),
            ),
            errorBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.red),
            ),
            focusedErrorBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.red),
            ),
          ),
        ),
      ],
    );
  }
}
