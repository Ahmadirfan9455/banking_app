import 'dart:ui';
import 'package:flutter/material.dart';
import '../widgets/responsive_container.dart';
import '../widgets/animated_wrapper.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('My Vault', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Colors.white),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
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
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const FadeSlideAnimation(delay: 0.1, child: _GreetingWidget()),
                    const SizedBox(height: 32),
                    const FadeSlideAnimation(delay: 0.2, child: _BalanceCard()),
                    const SizedBox(height: 32),
                    FadeSlideAnimation(
                      delay: 0.3,
                      child: Text(
                        'QUICK ACTIONS',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white.withOpacity(0.5),
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    FadeSlideAnimation(
                      delay: 0.4,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _QuickActionButton(icon: Icons.send_rounded, label: 'Send', iconColor: const Color(0xFF00FFC2), onTap: () => Navigator.pushNamed(context, '/send-money')),
                          _QuickActionButton(icon: Icons.account_balance_wallet, label: 'Receive', iconColor: const Color(0xFF8B5CF6), onTap: () {}),
                          _QuickActionButton(icon: Icons.receipt_long, label: 'Pay Bills', iconColor: const Color(0xFFFFB020), onTap: () {}),
                          _QuickActionButton(icon: Icons.grid_view_rounded, label: 'More', iconColor: const Color(0xFF0284C7), onTap: () {}),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    FadeSlideAnimation(
                      delay: 0.5,
                      child: Text(
                        'RECENT TRANSACTIONS',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white.withOpacity(0.5),
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const FadeSlideAnimation(delay: 0.6, child: _TransactionList()),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GreetingWidget extends StatelessWidget {
  const _GreetingWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(colors: [Color(0xFF00FFC2), Color(0xFF8B5CF6)]),
          ),
          child: const CircleAvatar(
            radius: 24,
            backgroundColor: Color(0xFF0F172A),
            child: Icon(Icons.person, color: Colors.white),
          ),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Welcome back,', style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.6))),
            const Text('Aura Citizen', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1)),
          ],
        ),
      ],
    );
  }
}

class _BalanceCard extends StatelessWidget {
  const _BalanceCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withOpacity(0.2), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF8B5CF6).withOpacity(0.2),
                blurRadius: 30,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Total Liquid Assets', style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 14, letterSpacing: 1)),
                  const Icon(Icons.remove_red_eye_outlined, color: Colors.white54, size: 20),
                ],
              ),
              const SizedBox(height: 12),
              const Text(
                '\$14,204.50',
                style: TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.w900, letterSpacing: 1),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('**** **** **** 8824', style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 16, letterSpacing: 3)),
                  const Icon(Icons.contactless_outlined, color: Color(0xFF00FFC2)),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color iconColor;
  final VoidCallback onTap;

  const _QuickActionButton({required this.icon, required this.label, required this.iconColor, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withOpacity(0.1)),
                ),
                child: Icon(icon, color: iconColor, size: 28),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white.withOpacity(0.8), letterSpacing: 1)),
        ],
      ),
    );
  }
}

class _TransactionList extends StatelessWidget {
  const _TransactionList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: Column(
            children: [
              _TransactionTile(icon: Icons.bolt, title: 'Server Hosting', date: 'Today, 2:30 PM', amount: '-\$120.00', isNegative: true, iconColor: const Color(0xFFFFB020)),
              Divider(color: Colors.white.withOpacity(0.1)),
              _TransactionTile(icon: Icons.work, title: 'Inbound Transfer', date: 'Yesterday, 9:00 AM', amount: '+\$4,500.00', isNegative: false, iconColor: const Color(0xFF00FFC2)),
              Divider(color: Colors.white.withOpacity(0.1)),
              _TransactionTile(icon: Icons.shopping_bag, title: 'Tech Procure', date: 'Oct 18, 10:00 AM', amount: '-\$1,299.00', isNegative: true, iconColor: const Color(0xFFFF5E5E)),
            ],
          ),
        ),
      ),
    );
  }
}

class _TransactionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String date;
  final String amount;
  final bool isNegative;
  final Color iconColor;

  const _TransactionTile({
    required this.icon, required this.title, required this.date, required this.amount, required this.isNegative, required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: iconColor.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: iconColor),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
                const SizedBox(height: 4),
                Text(date, style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12)),
              ],
            ),
          ),
          Text(amount, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: isNegative ? const Color(0xFFFF5E5E) : const Color(0xFF00FFC2))),
        ],
      ),
    );
  }
}
