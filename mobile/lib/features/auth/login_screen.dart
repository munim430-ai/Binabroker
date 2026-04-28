import 'package:binabroker/app/theme.dart';
import 'package:binabroker/shared/supabase_client.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final phoneController = TextEditingController(text: '+880');
  bool loading = false;

  @override
  void dispose() {
    phoneController.dispose();
    super.dispose();
  }

  Future<void> sendOtp() async {
    final phone = phoneController.text.trim();

    if (!RegExp(r'^\+8801[3-9]\d{8}$').hasMatch(phone)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid Bangladesh number, for example +8801XXXXXXXXX')),
      );
      return;
    }

    setState(() => loading = true);

    try {
      await supabase.auth.signInWithOtp(phone: phone);
      if (!mounted) return;
      context.go('/otp/$phone');
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.toString())));
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'BinaBroker',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 36, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Broker-free rentals in Bangladesh',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.muted),
                ),
                const SizedBox(height: 32),
                TextField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'Phone number',
                    hintText: '+8801XXXXXXXXX',
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: loading ? null : sendOtp,
                  child: Text(loading ? 'Sending OTP...' : 'Continue'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
