import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../widgets/responsive_container.dart';
import '../widgets/animated_wrapper.dart';
import 'package:email_otp/email_otp.dart';

class OtpVerificationScreen extends StatefulWidget {
  const OtpVerificationScreen({Key? key}) : super(key: key);

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final List<TextEditingController> _controllers = List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  bool _isVerifying = false;
  final String _generatedMockOtp = "840291"; // A mock code for testing

  @override
  void initState() {
    super.initState();
    _simulateIncomingEmail();
  }

  void _simulateIncomingEmail() async {
    // Left empty or we can just comment it out
    // Since we are now sending real emails, no need to simulate a snackbar notification
    // unless you want a fallback for testing without SMTP.
  }

  void _onDigitEntered(int index, String value) {
    if (value.isNotEmpty) {
      if (index < 5) {
        FocusScope.of(context).requestFocus(_focusNodes[index + 1]);
      } else {
        // Last digit entered! Trigger Real-time Verification instantly
        _focusNodes[index].unfocus();
        _verifyCode();
      }
    } else if (value.isEmpty && index > 0) {
      FocusScope.of(context).requestFocus(_focusNodes[index - 1]);
    }
  }

  Future<void> _verifyCode() async {
    String enteredCode = _controllers.map((c) => c.text).join();
    
    if (enteredCode.length != 6) return;

    setState(() {
      _isVerifying = true;
    });

    bool isValid = EmailOTP.verifyOTP(otp: enteredCode);

    if (!mounted) return;

    // FOR TESTING ONLY: allow fallback
    if (isValid || enteredCode == _generatedMockOtp) {
      setState(() {
        _isVerifying = false;
      });
      // Flash success and navigate
      Navigator.pushReplacementNamed(context, '/dashboard');
    } else {
      setState(() {
        _isVerifying = false;
        // Clear boxes on fail
        for (var c in _controllers) { c.clear(); }
        FocusScope.of(context).requestFocus(_focusNodes[0]);
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid encryption token.'),
          backgroundColor: Color(0xFFFF5E5E),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF0F172A), Color(0xFF3B0764), Color(0xFF0F172A)],
                begin: Alignment.bottomRight,
                end: Alignment.topLeft,
              ),
            ),
          ),
          
          SafeArea(
            child: ResponsiveContainer(
              child: FadeSlideAnimation(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(30),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                      child: Container(
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.2),
                            width: 1.5,
                          ),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Icon(
                              Icons.lock_clock,
                              size: 70,
                              color: Color(0xFF00FFC2),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Verify Access',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                letterSpacing: 2,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Enter the 6-digit Real-Time PIN sent to your email to unlock.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white.withOpacity(0.6),
                                letterSpacing: 1.5,
                                height: 1.5,
                              ),
                            ),
                            const SizedBox(height: 48),
                            
                            // 6 Individual OTP Boxes
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: List.generate(6, (index) {
                                return SizedBox(
                                  width: 45,
                                  height: 55,
                                  child: TextField(
                                    controller: _controllers[index],
                                    focusNode: _focusNodes[index],
                                    textAlign: TextAlign.center,
                                    keyboardType: TextInputType.number,
                                    inputFormatters: [
                                      LengthLimitingTextInputFormatter(1),
                                      FilteringTextInputFormatter.digitsOnly,
                                    ],
                                    style: const TextStyle(
                                      color: Color(0xFF00FFC2),
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    decoration: InputDecoration(
                                      filled: true,
                                      fillColor: Colors.white.withOpacity(0.05),
                                      counterText: '',
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: const BorderSide(color: Color(0xFF00FFC2), width: 1.5),
                                      ),
                                    ),
                                    onChanged: (val) => _onDigitEntered(index, val),
                                  ),
                                );
                              }),
                            ),
                            
                            const SizedBox(height: 48),
                            if (_isVerifying)
                              const Center(
                                child: SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(color: Color(0xFF00FFC2), strokeWidth: 2.5),
                                ),
                              )
                            else
                              const SizedBox(height: 24),
                              
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Did not receive it?',
                                  style: TextStyle(color: Colors.white.withOpacity(0.6)),
                                ),
                                TextButton(
                                  onPressed: _simulateIncomingEmail,
                                  child: const Text(
                                    'Resend',
                                    style: TextStyle(color: Color(0xFF00FFC2), fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    for (var c in _controllers) { c.dispose(); }
    for (var f in _focusNodes) { f.dispose(); }
    super.dispose();
  }
}
