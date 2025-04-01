import 'dart:async';
import 'package:flutter/material.dart';
import 'package:urban_treasure/main.dart';
import 'package:urban_treasure/views/screens/home_screen.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String factorId;

  const OtpVerificationScreen({super.key, required this.factorId});

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final _otpController = TextEditingController();
  bool _isLoading = false;
  bool _isResending = false;
  int _resendCooldown = 0;
  Timer? _cooldownTimer;
  String? _challengeId;

  @override
  void initState() {
    super.initState();
    _sendInitialChallenge();
  }

  @override
  void dispose() {
    _otpController.dispose();
    _cooldownTimer?.cancel();
    super.dispose();
  }

  Future<void> _sendInitialChallenge() async {
    try {
      final challenge =
          await supabase.auth.mfa.challenge(factorId: widget.factorId);
      _challengeId = challenge.id;
      _startCooldown();
    } catch (e) {
      debugPrint("Error sending initial challenge: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error sending OTP: $e")),
        );
      }
    }
  }

  void _startCooldown() {
    setState(() {
      _resendCooldown = 30;
    });

    _cooldownTimer?.cancel();
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendCooldown <= 1) {
        timer.cancel();
        setState(() => _resendCooldown = 0);
      } else {
        setState(() => _resendCooldown--);
      }
    });
  }

  Future<void> _verifyOtp() async {
    final otp = _otpController.text.trim();
    if (otp.isEmpty || _challengeId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter the OTP code")),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Step 1: Verify OTP
      await supabase.auth.mfa.verify(
        factorId: widget.factorId,
        challengeId: _challengeId!,
        code: otp,
      );

      // Step 2: Refresh session to get the updated session with MFA
      final refreshed = await supabase.auth.refreshSession();
      final newSession = refreshed.session;

      if (newSession == null) {
        throw Exception("Session refresh failed after MFA.");
      }

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Verification failed: $e")),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _resendOtp() async {
    setState(() => _isResending = true);

    try {
      final challenge =
          await supabase.auth.mfa.challenge(factorId: widget.factorId);
      _challengeId = challenge.id;

      _startCooldown();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("OTP has been resent to your email")),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to resend OTP: $e")),
      );
    } finally {
      if (mounted) setState(() => _isResending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool canResend = _resendCooldown == 0 && !_isResending;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Verify OTP"),
        backgroundColor: const Color.fromARGB(255, 221, 178, 49),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Enter the OTP sent to your email',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _otpController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'OTP Code',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isLoading ? null : _verifyOtp,
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Verify'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 221, 178, 49),
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: canResend ? _resendOtp : null,
              child: _isResending
                  ? const Text("Resending...")
                  : Text(
                      canResend
                          ? "Resend OTP"
                          : "Resend OTP (${_resendCooldown}s)",
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
