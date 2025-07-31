import 'package:flutter/material.dart';

class LuxuryIdentityCard extends StatelessWidget {
  final String name;
  final String designation;

  const LuxuryIdentityCard({
    Key? key,
    required this.name,
    required this.designation,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 360,
      height: 126, // Fixed height for non-responsive version
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF000000),
            Color(0xFF1a1a1a),
            Color(0xFF000000),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 40,
            offset: const Offset(0, 16),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Stack(
        children: [
          // Embossed texture background
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
            ),
            child: CustomPaint(
              painter: EmbossedTexturePainter(),
              size: const Size(360, 126), // Fixed size for painter
            ),
          ),

          // Main content
          Padding(
            padding: const EdgeInsets.all(12), // Adjusted padding
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top section with name/designation and share button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Left side - Name and designation
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: const TextStyle(
                              fontSize: 22, // Adjusted font size
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontFamily: 'Inter',
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 4), // Adjusted spacing
                          Text(
                            designation,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: Colors.grey[400],
                              fontFamily: 'Inter',
                              letterSpacing: 0.2,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Right side - Share button
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withOpacity(0.2),
                          width: 1,
                        ),
                        color: Colors.white.withOpacity(0.05),
                      ),
                      child: Icon(
                        Icons.share,
                        color: Colors.white.withOpacity(0.8),
                        size: 20,
                      ),
                    ),
                  ],
                ),

                // Spacer to push branding to bottom
                const Spacer(),

                // Bottom right - hushh branding
                Align(
                  alignment: Alignment.bottomRight,
                  child: Text(
                    'hushh',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.white.withOpacity(0.9),
                      fontFamily: 'Inter',
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class EmbossedTexturePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.05) // Increased opacity
      ..style = PaintingStyle.fill;

    // Create subtle embossed pattern
    for (double x = 0; x < size.width; x += 30) {
      // Denser pattern
      for (double y = 0; y < size.height; y += 30) {
        // Draw subtle damask-like pattern
        canvas.drawCircle(
          Offset(x + 15, y + 15), // Adjusted position
          6, // Adjusted size
          paint,
        );

        // Additional texture elements - diagonal pattern
        if ((x / 30 + y / 30) % 2 == 0) {
          canvas.drawRRect(
            RRect.fromRectAndRadius(
              Rect.fromLTWH(x + 8, y + 8, 14, 14), // Adjusted size
              const Radius.circular(3), // Adjusted radius
            ),
            Paint()
              ..color = Colors.white.withOpacity(0.03) // Adjusted opacity
              ..style = PaintingStyle.fill,
          );
        }
      }
    }

    // Add subtle grain texture
    for (double x = 0; x < size.width; x += 4) {
      for (double y = 0; y < size.height; y += 4) {
        if ((x + y) % 8 == 0) {
          canvas.drawCircle(
            Offset(x, y),
            0.5,
            Paint()
              ..color = Colors.white.withOpacity(0.02)
              ..style = PaintingStyle.fill,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

// Responsive wrapper for different screen sizes
class ResponsiveLuxuryCard extends StatelessWidget {
  final String name;
  final String designation;

  const ResponsiveLuxuryCard({
    Key? key,
    required this.name,
    required this.designation,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Credit card dimensions - 85-90% of screen width
        double cardWidth = constraints.maxWidth * 0.88; // 88% of screen width
        double cardHeight = cardWidth * 0.625; // Credit card ratio (1.6:1)

        return Container(
          width: cardWidth,
          height: cardHeight,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF000000),
                Color(0xFF1a1a1a),
                Color(0xFF000000),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
                spreadRadius: 0,
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 40,
                offset: const Offset(0, 16),
                spreadRadius: 0,
              ),
            ],
          ),
          child: Stack(
            children: [
              // Embossed texture background
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: CustomPaint(
                  painter: EmbossedTexturePainter(),
                  size: Size(cardWidth, cardHeight),
                ),
              ),

              // Main content
              Padding(
                padding: EdgeInsets.all(cardWidth * 0.04), // Responsive padding
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Name and designation
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                name,
                                style: TextStyle(
                                  fontSize:
                                      cardWidth * 0.065, // Responsive font size
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  fontFamily: 'Inter',
                                  letterSpacing: -0.5,
                                ),
                              ),
                              SizedBox(
                                  height:
                                      cardHeight * 0.02), // Adjusted spacing
                              Text(
                                designation,
                                style: TextStyle(
                                  fontSize: cardWidth * 0.04,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.grey[400],
                                  fontFamily: 'Inter',
                                  letterSpacing: 0.2,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Share button
                        Container(
                          width: cardWidth * 0.12,
                          height: cardWidth * 0.12,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withOpacity(0.2),
                              width: 1,
                            ),
                            color: Colors.white.withOpacity(0.05),
                          ),
                          child: Icon(
                            Icons.share,
                            color: Colors.white.withOpacity(0.8),
                            size: cardWidth * 0.055,
                          ),
                        ),
                      ],
                    ),

                    // Spacer
                    const Spacer(),

                    // Bottom branding
                    Align(
                      alignment: Alignment.bottomRight,
                      child: Text(
                        'hushh',
                        style: TextStyle(
                          fontSize: cardWidth * 0.045,
                          fontWeight: FontWeight.w500,
                          color: Colors.white.withOpacity(0.9),
                          fontFamily: 'Inter',
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
