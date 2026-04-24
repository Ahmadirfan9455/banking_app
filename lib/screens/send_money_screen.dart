import 'dart:ui';
import 'package:flutter/material.dart';
import '../widgets/responsive_container.dart';
import '../widgets/animated_wrapper.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SendMoneyScreen extends StatefulWidget {
  const SendMoneyScreen({Key? key}) : super(key: key);

  @override
  State<SendMoneyScreen> createState() => _SendMoneyScreenState();
}

class _SendMoneyScreenState extends State<SendMoneyScreen> {
  final _amountController = TextEditingController();
  final _recipientController = TextEditingController();
  bool _isProcessing = false;

  void _processTransfer() async {
    if (_amountController.text.isEmpty || _recipientController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter recipient and amount.'),
          backgroundColor: Color(0xFFFF5E5E),
        ),
      );
      return;
    }

    double? amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid amount.'),
          backgroundColor: Color(0xFFFF5E5E),
        ),
      );
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception("User not authenticated.");

      final db = FirebaseFirestore.instance;
      
      // Find receiver by email
      String receiverEmail = _recipientController.text.trim();
      var receiverQuery = await db.collection('users').where('email', isEqualTo: receiverEmail).limit(1).get();
      
      if (receiverQuery.docs.isEmpty) {
        throw Exception("Recipient not found.");
      }
      
      var receiverDocRef = receiverQuery.docs.first.reference;
      var senderDocRef = db.collection('users').doc(user.uid);

      if (receiverDocRef.id == senderDocRef.id) {
        throw Exception("Cannot send money to yourself.");
      }

      await db.runTransaction((transaction) async {
        DocumentSnapshot senderSnapshot = await transaction.get(senderDocRef);
        DocumentSnapshot receiverSnapshot = await transaction.get(receiverDocRef);

        if (!senderSnapshot.exists || !receiverSnapshot.exists) {
          throw Exception("Sender or recipient data corrupted.");
        }

        double senderBalance = (senderSnapshot.get('balance') ?? 0.0).toDouble();
        double receiverBalance = (receiverSnapshot.get('balance') ?? 0.0).toDouble();

        if (senderBalance < amount) {
          throw Exception("Insufficient funds.");
        }

        // Update balances
        transaction.update(senderDocRef, {'balance': senderBalance - amount});
        transaction.update(receiverDocRef, {'balance': receiverBalance + amount});

        // Log transaction
        DocumentReference txRef = db.collection('transactions').doc();
        transaction.set(txRef, {
          'id': txRef.id,
          'senderId': user.uid,
          'senderEmail': senderSnapshot.get('email'),
          'receiverId': receiverSnapshot.get('uid'),
          'receiverEmail': receiverEmail,
          'amount': amount,
          'participants': [senderSnapshot.get('email'), receiverEmail],
          'timestamp': FieldValue.serverTimestamp(),
        });
      });

      if (!mounted) return;

      setState(() {
        _isProcessing = false;
      });

      _showSuccessDialog();

    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isProcessing = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll("Exception: ", "")),
          backgroundColor: const Color(0xFFFF5E5E),
        ),
      );
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.transparent,
        contentPadding: EdgeInsets.zero,
        content: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A).withOpacity(0.8),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFF00FFC2).withOpacity(0.5), width: 1.5),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.check_circle, color: Color(0xFF00FFC2), size: 80),
                  const SizedBox(height: 24),
                  const Text(
                    'Transfer Complete',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Successfully transmitted \$${_amountController.text} to ${_recipientController.text}',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.7)),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context); // close dialog
                        Navigator.pop(context); // Go back to dashboard
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00FFC2),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: const Text('RETURN TO VAULT', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Transfer Assets', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1)),
      ),
      body: Stack(
        children: [
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
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 16),
                      // Balance info
                      ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.04),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.white.withOpacity(0.1)),
                            ),
                            child: StreamBuilder<DocumentSnapshot>(
                              stream: FirebaseFirestore.instance.collection('users')
                                  .doc(FirebaseAuth.instance.currentUser?.uid).snapshots(),
                              builder: (context, snapshot) {
                                double balance = 0.0;
                                if (snapshot.hasData && snapshot.data!.exists) {
                                  balance = (snapshot.data!.get('balance') ?? 0.0).toDouble();
                                }
                                return Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('Available Liquidity', style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 14)),
                                    Text('\$${balance.toStringAsFixed(2)}', style: const TextStyle(color: Color(0xFF00FFC2), fontSize: 18, fontWeight: FontWeight.bold)),
                                  ],
                                );
                              }
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      const Text('RECIPIENT', style: TextStyle(color: Colors.white54, letterSpacing: 2, fontSize: 12, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _recipientController,
                        style: const TextStyle(color: Colors.white, fontSize: 18),
                        decoration: _glassInputDecoration('Wallet ID or Email', Icons.account_circle_outlined),
                      ),
                      const SizedBox(height: 24),
                      const Text('AMOUNT', style: TextStyle(color: Colors.white54, letterSpacing: 2, fontSize: 12, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _amountController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        style: const TextStyle(color: Color(0xFF00FFC2), fontSize: 32, fontWeight: FontWeight.bold),
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.attach_money, color: Color(0xFF00FFC2), size: 32),
                          hintText: '0.00',
                          hintStyle: TextStyle(color: Colors.white.withOpacity(0.2)),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.05),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide(color: Colors.white.withOpacity(0.1), width: 1),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: const BorderSide(color: Color(0xFF00FFC2), width: 1.5),
                          ),
                          contentPadding: const EdgeInsets.symmetric(vertical: 24),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          'No transfer fees applied',
                          style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 12),
                        ),
                      ),
                      const SizedBox(height: 48),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          gradient: const LinearGradient(
                            colors: [Color(0xFF8B5CF6), Color(0xFF2563EB)],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF8B5CF6).withOpacity(0.4),
                              blurRadius: 15,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: _isProcessing ? null : _processTransfer,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: _isProcessing
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                                )
                              : const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'AUTHORIZE TRANSFER',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w900,
                                        color: Colors.white,
                                        letterSpacing: 2,
                                      ),
                                    ),
                                    SizedBox(width: 12),
                                    Icon(Icons.arrow_forward_rounded, color: Colors.white),
                                  ],
                                ),
                        ),
                      ),
                    ],
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
    _amountController.dispose();
    _recipientController.dispose();
    super.dispose();
  }
}
