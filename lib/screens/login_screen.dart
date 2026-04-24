import 'dart:ui';
import 'package:flutter/material.dart';
import '../widgets/responsive_container.dart';
import '../widgets/animated_wrapper.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:email_otp/email_otp.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isAdminMode = false;

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );

        // Fetch user role
        DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid).get();
        
        if (userDoc.exists) {
          String role = userDoc.get('role') ?? 'user';
          
          if (_isAdminMode && role != 'admin') {
            throw Exception('Unauthorized: Not an admin');
          }

          // --- REAL SMTP EMAIL OTP CONFIGURATION ---
          EmailOTP.config(
            appName: 'Aura Bank Vault',
            otpType: OTPType.numeric,
            emailTheme: EmailTheme.v5,
          );
          
          // >>> TODO: USER MUST REPLACE THESE CREDENTIALS FOR REAL EMAILS TO SEND <<<
          EmailOTP.setSMTP(
            emailPort: EmailPort.port587,
            secureType: SecureType.tls,
            host: "smtp.gmail.com",
            username: "your_email@gmail.com", 
            password: "your_16_digit_app_password", 
          );

          await EmailOTP.sendOTP(email: _emailController.text.trim());

          if (!mounted) return;
          
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('OTP sent to your email.'),
              backgroundColor: Color(0xFF00FFC2),
            ),
          );

          // Pass the role to the OTP screen if needed, but we can fetch it there or use routes.
          // Since the existing route just goes to OTP verification, we can push there.
          // Wait, if it's admin, does it also need OTP? The old code did this:
          // if (_isAdminMode) { Navigator.pushReplacementNamed(context, '/admin-dashboard'); }
          // else { Navigator.pushReplacementNamed(context, '/otp-verification'); }
          
          if (_isAdminMode) {
            Navigator.pushReplacementNamed(context, '/admin-dashboard');
          } else {
            Navigator.pushReplacementNamed(context, '/otp-verification');
          }
        } else {
          throw Exception('User data not found');
        }

      } on FirebaseAuthException catch (e) {
        String message = 'Authentication failed.';
        if (e.code == 'user-not-found' || e.code == 'wrong-password' || e.code == 'invalid-credential') {
          message = 'Invalid credentials.';
        }
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message), backgroundColor: const Color(0xFFFF5E5E)),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.toString().replaceAll('Exception: ', '')), backgroundColor: const Color(0xFFFF5E5E)),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Required';
    }
    final emailRegex = RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
    if (!emailRegex.hasMatch(value)) {
      return 'Invalid email';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Required';
    }
    if (value.length < 6) return 'Minimum 6 chars';
    return null;
  }

  InputDecoration _glassInputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
      prefixIcon: Icon(icon, color: Colors.white70),
      filled: true,
      fillColor: Colors.white.withOpacity(0.08),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.1), width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFF00FFC2), width: 1.5),
      ),
      errorStyle: const TextStyle(color: Color(0xFFFF5E5E)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // Elegant dark space gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF0F172A), Color(0xFF3B0764), Color(0xFF0F172A)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
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
                        child: Form(
                          key: _formKey,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  GestureDetector(
                                    onTap: () => setState(() => _isAdminMode = false),
                                    child: Text('USER', style: TextStyle(color: !_isAdminMode ? const Color(0xFF00FFC2) : Colors.white54, fontWeight: !_isAdminMode ? FontWeight.bold : FontWeight.normal, letterSpacing: 2)),
                                  ),
                                  const SizedBox(width: 24),
                                  Text('|', style: TextStyle(color: Colors.white.withOpacity(0.2))),
                                  const SizedBox(width: 24),
                                  GestureDetector(
                                    onTap: () => setState(() => _isAdminMode = true),
                                    child: Text('ADMIN', style: TextStyle(color: _isAdminMode ? const Color(0xFF8B5CF6) : Colors.white54, fontWeight: _isAdminMode ? FontWeight.bold : FontWeight.normal, letterSpacing: 2)),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 32),
                              Icon(
                                _isAdminMode ? Icons.shield : Icons.fingerprint,
                                size: 70,
                                color: _isAdminMode ? const Color(0xFF8B5CF6) : const Color(0xFF00FFC2),
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'Aura Bank',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                  letterSpacing: 2,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'The Future of Finance',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white.withOpacity(0.6),
                                  letterSpacing: 1.5,
                                ),
                              ),
                              const SizedBox(height: 48),
                              FadeSlideAnimation(
                                delay: 0.2, // Simulated delay concept if applied
                                child: TextFormField(
                                  controller: _emailController,
                                  validator: _validateEmail,
                                  style: const TextStyle(color: Colors.white),
                                  decoration: _glassInputDecoration('Email', Icons.alternate_email),
                                  keyboardType: TextInputType.emailAddress,
                                  textInputAction: TextInputAction.next,
                                ),
                              ),
                              const SizedBox(height: 20),
                              FadeSlideAnimation(
                                delay: 0.4,
                                child: TextFormField(
                                  controller: _passwordController,
                                  validator: _validatePassword,
                                  style: const TextStyle(color: Colors.white),
                                  decoration: _glassInputDecoration('Password', Icons.lock_outline),
                                  obscureText: true,
                                  textInputAction: TextInputAction.done,
                                  onFieldSubmitted: (_) => _login(),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  onPressed: () {},
                                  child: const Text(
                                    'Forgot credentials?',
                                    style: TextStyle(color: Color(0xFF00FFC2)),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 24),
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  gradient: const LinearGradient(
                                    colors: [Color(0xFF00FFC2), Color(0xFF0284C7)],
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF00FFC2).withOpacity(0.3),
                                      blurRadius: 15,
                                      offset: const Offset(0, 5),
                                    ),
                                  ],
                                ),
                                child: ElevatedButton(
                                  onPressed: _isLoading ? null : _login,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    shadowColor: Colors.transparent,
                                    padding: const EdgeInsets.symmetric(vertical: 18),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  ),
                                  child: _isLoading 
                                      ? const SizedBox(
                                          width: 24, 
                                          height: 24, 
                                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5)
                                        )
                                      : Text(
                                          _isAdminMode ? 'ACCESS CONSOLE' : 'ACCESS VAULT',
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w900,
                                            color: Colors.black87,
                                            letterSpacing: 2,
                                          ),
                                        ),
                                ),
                              ),
                              const SizedBox(height: 24),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text('New to Aura?', style: TextStyle(color: Colors.white.withOpacity(0.6))),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pushNamed(context, '/signup');
                                    },
                                    child: const Text('Initialize', style: TextStyle(color: Color(0xFF00FFC2), fontWeight: FontWeight.bold)),
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
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
