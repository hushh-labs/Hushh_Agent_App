import 'package:flutter/material.dart';
import '../bloc/dashboard_bloc.dart';
import 'quick_insight_card.dart';

class QuickInsightsGrid extends StatelessWidget {
  final List<QuickInsightItem> insights;

  const QuickInsightsGrid({
    super.key,
    required this.insights,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Quick Insights',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
        
        const SizedBox(height: 16),
        
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.2,
            ),
            itemCount: insights.length,
            itemBuilder: (context, index) {
              final insight = insights[index];
              return QuickInsightCard(insight: insight);
            },
          ),
        ),
      ],
    );
  }
} 