import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'add_manual_entry_bottom_sheet.dart';
import 'add_google_sheets_bottom_sheet.dart';
import '../bloc/lookbook_bloc.dart';

class CreateInventoryBottomSheet extends StatelessWidget {
  const CreateInventoryBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          const SizedBox(height: 24),

          // Title
          const Text(
            'Choose your Inventory Solution',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),

          const SizedBox(height: 8),

          // Subtitle
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              'Choose any of these Inventory Solution that works for you!',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          const SizedBox(height: 32),

          // Options Grid
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.2,
              children: [
                _buildOptionCard(
                  context,
                  title: 'SAP S/4HANA',
                  icon: Icons.business,
                  color: Colors.blue,
                  isEnabled: false,
                  onTap: () => _showComingSoon(context, 'SAP S/4HANA'),
                ),
                _buildOptionCard(
                  context,
                  title: 'Google Sheets',
                  icon: Icons.table_chart,
                  color: Colors.green,
                  isEnabled: true,
                  onTap: () => _openGoogleSheetsModal(context),
                ),
                _buildOptionCard(
                  context,
                  title: 'Manual Entry',
                  icon: Icons.edit,
                  color: Colors.orange,
                  isEnabled: true,
                  onTap: () => _openManualEntryModal(context),
                ),
                _buildOptionCard(
                  context,
                  title: 'Zoho',
                  icon: Icons.inventory,
                  color: Colors.purple,
                  isEnabled: false,
                  onTap: () => _showComingSoon(context, 'Zoho'),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildOptionCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required bool isEnabled,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: isEnabled ? onTap : null,
      child: Container(
        decoration: BoxDecoration(
          color: isEnabled ? Colors.white : Colors.grey[100],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isEnabled ? color.withOpacity(0.3) : Colors.grey[300]!,
            width: 1.5,
          ),
          boxShadow: isEnabled
              ? [
                  BoxShadow(
                    color: color.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isEnabled ? color.withOpacity(0.1) : Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                size: 32,
                color: isEnabled ? color : Colors.grey[500],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isEnabled ? Colors.black87 : Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
            if (!isEnabled) ...[
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Coming Soon',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _openGoogleSheetsModal(BuildContext context) {
    final lookbookBloc = context.read<LookbookBloc>();
    Navigator.pop(context); // Close current modal

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => BlocProvider.value(
        value: lookbookBloc,
        child: const AddGoogleSheetsBottomSheet(),
      ),
    );
  }

  void _openManualEntryModal(BuildContext context) {
    final lookbookBloc = context.read<LookbookBloc>();
    Navigator.pop(context); // Close current modal

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => BlocProvider.value(
        value: lookbookBloc,
        child: const AddManualEntryBottomSheet(),
      ),
    );
  }

  void _showComingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature integration is coming soon!'),
        backgroundColor: Colors.blue,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}
