import 'package:flutter/material.dart';
import '../components/agent_card_widget.dart';
import '../../../../../shared/core/components/standard_dialog.dart';

/// Demo page to showcase the agent card widget
class AgentCardDemoPage extends StatelessWidget {
  const AgentCardDemoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          'Agent Card Demo',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Agent Card Examples',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Cards matching the provided design',
              style: TextStyle(
                fontSize: 16,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 32),

            // Example 1: Adarsh - American Express
            Center(
              child: AgentCardWidget(
                agentName: 'Adarsh',
                agentRole: "American Express's Agent",
                onSharePressed: () {
                  _showShareDialog(context, 'Adarsh');
                },
              ),
            ),
            const SizedBox(height: 32),

            // Example 2: Different agent
            Center(
              child: AgentCardWidget(
                agentName: 'Sarah Johnson',
                agentRole: "Chase Bank's Agent",
                onSharePressed: () {
                  _showShareDialog(context, 'Sarah Johnson');
                },
              ),
            ),
            const SizedBox(height: 32),

            // Example 3: Another agent
            Center(
              child: AgentCardWidget(
                agentName: 'Michael Chen',
                agentRole: "Wells Fargo's Agent",
                onSharePressed: () {
                  _showShareDialog(context, 'Michael Chen');
                },
              ),
            ),
            const SizedBox(height: 32),

            // Features section
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Card Features',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildFeatureItem(
                    icon: Icons.palette,
                    title: 'Black Premium Design',
                    description: 'Elegant black background with subtle patterns',
                  ),
                  _buildFeatureItem(
                    icon: Icons.qr_code,
                    title: 'QR Code Integration',
                    description: 'Quick access QR code for easy sharing',
                  ),
                  _buildFeatureItem(
                    icon: Icons.share,
                    title: 'Share Functionality',
                    description: 'One-tap sharing with elegant button',
                  ),
                  _buildFeatureItem(
                    icon: Icons.branding_watermark,
                    title: 'Hushh Branding',
                    description: 'Consistent brand identity',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: Colors.black87,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showShareDialog(BuildContext context, String agentName) {
    StandardDialog.showInfoDialog(
      context: context,
      title: 'Share $agentName\'s Card',
      message: 'Share functionality would be implemented here. Options could include:\n\n'
          '• Social media sharing\n'
          '• QR code display\n'
          '• Email/SMS sharing\n'
          '• Download as image',
      primaryButtonText: 'Share',
      secondaryButtonText: 'Close',
      icon: Icons.share,
      iconColor: const Color(0xFFA342FF),
      onPrimaryPressed: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$agentName\'s card would be shared'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
    );
  }
}