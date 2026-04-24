import 'dart:ui';
import 'package:flutter/material.dart';
import '../widgets/responsive_container.dart';
import '../widgets/animated_wrapper.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Admin Console', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
        actions: [
          IconButton(
            icon: const Icon(Icons.shield, color: Color(0xFFFF5E5E)),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
          ),
        ],
      ),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF0F172A), Color(0xFF1E1B4B), Color(0xFF0F172A)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          SafeArea(
            child: ResponsiveContainer(
              maxWidth: 800, // wider for admin panel
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    FadeSlideAnimation(
                      child: Text(
                        'SYSTEM OVERVIEW',
                        style: TextStyle(color: Colors.white.withOpacity(0.5), letterSpacing: 2, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(child: _AdminStatCard(title: 'Active Users', value: '14,204', icon: Icons.people, color: const Color(0xFF00FFC2), delay: 0.1)),
                        const SizedBox(width: 16),
                        Expanded(child: _AdminStatCard(title: 'Pending KYC', value: '43', icon: Icons.pending_actions, color: const Color(0xFFFFB020), delay: 0.2)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(child: _AdminStatCard(title: 'Total Vault Volume', value: '\$8.4B', icon: Icons.account_balance, color: const Color(0xFF8B5CF6), delay: 0.3)),
                        const SizedBox(width: 16),
                        Expanded(child: _AdminStatCard(title: 'System Alerts', value: '0', icon: Icons.gpp_good, color: const Color(0xFF10B981), delay: 0.4)),
                      ],
                    ),
                    const SizedBox(height: 32),
                    FadeSlideAnimation(
                      delay: 0.5,
                      child: Text(
                        'RECENT FLAG OPERATIONS',
                        style: TextStyle(color: Colors.white.withOpacity(0.5), letterSpacing: 2, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildGlassList(delay: 0.6),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlassList({required double delay}) {
    return FadeSlideAnimation(
      delay: delay,
      child: ClipRRect(
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
                _buildListTile('Large Transfer Detected', 'User #4892 sent \$50k', Icons.warning_amber, const Color(0xFFFFB020)),
                Divider(color: Colors.white.withOpacity(0.1)),
                _buildListTile('New Account Blocked', 'High risk IP flagged', Icons.block, const Color(0xFFFF5E5E)),
                Divider(color: Colors.white.withOpacity(0.1)),
                _buildListTile('Server Node #4 Updated', 'Routine maintenance completed', Icons.check_circle, const Color(0xFF10B981)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildListTile(String title, String subtitle, IconData icon, Color iconColor) {
    return ListTile(
      leading: Icon(icon, color: iconColor),
      title: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      subtitle: Text(subtitle, style: TextStyle(color: Colors.white.withOpacity(0.5))),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextButton(onPressed: (){}, child: Text('Review', style: TextStyle(color: iconColor))),
        ],
      ),
    );
  }
}

class _AdminStatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final double delay;

  const _AdminStatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.delay,
  });

  @override
  Widget build(BuildContext context) {
    return FadeSlideAnimation(
      delay: delay,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.04),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: color.withOpacity(0.3), width: 1.5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, color: color, size: 28),
                const SizedBox(height: 16),
                Text(title, style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12)),
                const SizedBox(height: 4),
                Text(value, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
