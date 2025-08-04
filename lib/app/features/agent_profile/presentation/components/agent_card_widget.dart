import 'package:flutter/material.dart';

/// A reusable agent card widget that matches the design from the image
class AgentCardWidget extends StatelessWidget {
  final String agentName;
  final String agentRole;
  final String? qrData;
  final VoidCallback? onSharePressed;
  final double? width;
  final double? height;

  const AgentCardWidget({
    super.key,
    required this.agentName,
    required this.agentRole,
    this.qrData,
    this.onSharePressed,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width ?? 320,
      height: height ?? 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.black,
        ),
        child: Stack(
          children: [
            // Decorative pattern background
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: Colors.black,
                ),
                child: CustomPaint(
                  painter: DecorativePatternPainter(),
                ),
              ),
            ),

            // Card content
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header with Share button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const SizedBox(), // Empty space for alignment
                      GestureDetector(
                        onTap: onSharePressed,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                'Share',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Icon(
                                Icons.share,
                                color: Colors.black,
                                size: 14,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  const Spacer(),

                  // Agent details
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        agentName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        agentRole,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),

                  const Spacer(),

                  // Footer with QR Code and Hushh branding
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // QR Code
                      Container(
                        width: 45,
                        height: 45,
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.qr_code,
                          color: Colors.black,
                          size: 20,
                        ),
                      ),
                      // Hushh branding
                      const Text(
                        'hushh',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Custom painter for decorative pattern background
class DecorativePatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    // Create intricate pattern similar to the card in the image
    final path = Path();
    
    // Draw flowing curves and patterns
    for (int i = 0; i < 8; i++) {
      final startX = (size.width / 8) * i;
      final startY = size.height * 0.3;
      
      path.moveTo(startX, startY);
      path.quadraticBezierTo(
        startX + 20, startY - 30,
        startX + 40, startY,
      );
      path.quadraticBezierTo(
        startX + 60, startY + 30,
        startX + 80, startY,
      );
    }
    
    // Draw additional decorative elements
    for (int i = 0; i < 6; i++) {
      final centerX = (size.width / 6) * i + 20;
      final centerY = size.height * 0.7;
      
      // Draw circular patterns
      canvas.drawCircle(
        Offset(centerX, centerY),
        12,
        paint,
      );
      
      // Inner circles
      canvas.drawCircle(
        Offset(centerX, centerY),
        6,
        paint,
      );
    }
    
    // Draw flowing lines
    final flowPath = Path();
    flowPath.moveTo(0, size.height * 0.5);
    
    for (double x = 0; x < size.width; x += 25) {
      flowPath.quadraticBezierTo(
        x + 12, size.height * 0.4,
        x + 25, size.height * 0.5,
      );
    }
    
    canvas.drawPath(path, paint);
    canvas.drawPath(flowPath, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}