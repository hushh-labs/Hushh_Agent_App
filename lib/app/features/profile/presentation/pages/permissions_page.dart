import 'package:flutter/material.dart';
import '../../../settings/presentation/pages/permissions.dart';

/// Legacy permissions page - redirects to comprehensive PermissionsView
class PermissionsPage extends StatelessWidget {
  const PermissionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Redirect to the new comprehensive permissions view
    return const PermissionsView();
  }
}