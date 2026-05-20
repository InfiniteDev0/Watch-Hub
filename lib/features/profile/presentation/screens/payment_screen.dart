import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:watch_hub/core/constants/app_assets.dart';

class PaymentScreen extends StatelessWidget {
  const PaymentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Payment',
          style: TextStyle(
            fontFamily: AppAssets.instrumentSerif,
            fontSize: 24,
            fontWeight: FontWeight.w400,
            color: Colors.black,
          ),
        ),
        centerTitle: false,
      ),
      body: const Center(
        child: Text(
          'No payment methods saved',
          style: TextStyle(
            fontFamily: AppAssets.manrope,
            fontSize: 16,
            color: Colors.black54,
          ),
        ),
      ),
    );
  }
}
