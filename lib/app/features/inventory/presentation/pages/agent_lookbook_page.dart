import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import '../../../../../shared/constants/app_routes.dart';
import '../bloc/lookbook_bloc.dart';
import '../components/lookbooks_grid_view.dart';
import '../components/create_inventory_bottom_sheet.dart';

class AgentLookBookPage extends StatefulWidget {
  const AgentLookBookPage({super.key});

  @override
  State<AgentLookBookPage> createState() => _AgentLookBookPageState();
}

class _AgentLookBookPageState extends State<AgentLookBookPage>
    with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late LookbookBloc _lookbookBloc;

  @override
  void initState() {
    super.initState();

    // Initialize the BLoC instance
    _lookbookBloc = GetIt.instance<LookbookBloc>();

    // Initialize animations
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _animationController.forward();

    // Fetch lookbooks on init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      print('🚀 Initial fetch of lookbooks');
      _lookbookBloc.add(FetchLookbooksEvent());
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _lookbookBloc,
      child: Scaffold(
        backgroundColor: Colors.white,
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        floatingActionButton: _buildFloatingActionButton(),
        appBar: _buildAppBar(),
        body: FadeTransition(
          opacity: _fadeAnimation,
          child: RefreshIndicator(
            onRefresh: () async {
              print('🔄 Manual refresh triggered');
              _lookbookBloc.add(FetchLookbooksEvent());
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: BlocConsumer<LookbookBloc, LookbookState>(
                  listener: (context, state) {
                    print('📱 BLoC State Changed: ${state.runtimeType}');
                    if (state is LookbookError &&
                        state.message.contains('delete')) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(state.message),
                          backgroundColor: Colors.red,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  },
                  builder: (context, state) {
                    print('🏗️ Building UI with state: ${state.runtimeType}');
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 16),
                        _buildSearchField(),
                        const SizedBox(height: 16),
                        _buildActionButtons(),
                        const SizedBox(height: 16),
                        _buildContent(state),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            Color(0xFFF6223C),
            Color(0xFFA342FF),
          ],
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: FloatingActionButton(
        onPressed: _showInventoryOptions,
        foregroundColor: Colors.white,
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: const Icon(Icons.inventory_2_outlined, size: 28),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      automaticallyImplyLeading: false,
      elevation: 0,
      backgroundColor: Colors.white,
      leading: Padding(
        padding: const EdgeInsets.only(left: 8.0),
        child: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.arrow_back_ios_new,
              color: Colors.black87,
            ),
          ),
        ),
      ),
      centerTitle: false,
      title: const Text(
        'Lookbook & Products',
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: Colors.black87,
          fontSize: 20,
        ),
      ),
    );
  }

  Widget _buildSearchField() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (value) {
          _lookbookBloc.add(SearchLookbooksEvent(value));
        },
        decoration: InputDecoration(
          hintText: 'Search lookbooks...',
          prefixIcon: const Icon(Icons.search, color: Colors.grey),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: _customButton(
            icon: Icons.add,
            name: "Create Lookbook",
            onTap: _navigateToCreateLookbook,
            gradient: const LinearGradient(
              colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _customButton(
            icon: Icons.dashboard,
            name: "View All Products",
            onTap: _navigateToAllProducts,
            gradient: const LinearGradient(
              colors: [Color(0xFF10B981), Color(0xFF059669)],
            ),
          ),
        ),
      ],
    );
  }

  Widget _customButton({
    required IconData icon,
    required String name,
    required VoidCallback onTap,
    Gradient? gradient,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text(
              name,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.white,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(LookbookState state) {
    if (state is LookbookLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (state is LookbookError) {
      return Center(
        child: Column(
          children: [
            const SizedBox(height: 32),
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red[300],
            ),
            const SizedBox(height: 16),
            Text(
              'Error loading lookbooks',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              state.message,
              style: TextStyle(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _lookbookBloc.add(FetchLookbooksEvent()),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (state is LookbookLoaded) {
      if (state.lookbooks.isEmpty) {
        return _buildEmptyState();
      }

      return LookbooksGridView(
        lookbooks: state.lookbooks,
        onLookbookTap: _onLookbookTap,
        onLookbookDelete: _onLookbookDelete,
      );
    }

    return _buildEmptyState();
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 32),
          Icon(
            Icons.collections_bookmark_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 24),
          Text(
            'Create Your First Lookbook',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              'Lookbooks are collections of your products that you can create and share with potential customers',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: _navigateToCreateLookbook,
            icon: const Icon(Icons.add),
            label: const Text('Create Lookbook'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  void _showInventoryOptions() {
    showModalBottomSheet(
      isDismissible: true,
      enableDrag: true,
      backgroundColor: Colors.transparent,
      context: context,
      builder: (BuildContext context) => BlocProvider.value(
        value: _lookbookBloc,
        child: const CreateInventoryBottomSheet(),
      ),
    );
  }

  void _navigateToCreateLookbook() async {
    print('🧭 Navigating to create lookbook page...');

    // Navigate to create lookbook page and wait for result
    final result = await Navigator.pushNamed(context, AppRoutes.createLookbook);

    print('🔙 Returned from create lookbook page. Result: $result');

    // When user returns, refresh the lookbooks list
    if (mounted) {
      print(
          '🔄 Page still mounted, refreshing lookbooks after returning from create page');
      print(
          '🎯 Current BLoC state before refresh: ${_lookbookBloc.state.runtimeType}');

      // Add a small delay to ensure any Firebase operations are complete
      await Future.delayed(const Duration(milliseconds: 500));

      _lookbookBloc.add(FetchLookbooksEvent());
      print('✅ Refresh event dispatched to BLoC');
    } else {
      print('⚠️ Page no longer mounted, skipping refresh');
    }
  }

  void _navigateToAllProducts() {
    Navigator.pushNamed(context, AppRoutes.agentProducts);
  }

  void _onLookbookTap(String lookbookId) {
    Navigator.pushNamed(
      context,
      AppRoutes.agentProducts,
      arguments: {'lookbookId': lookbookId},
    );
  }

  void _onLookbookDelete(String lookbookId) {
    _lookbookBloc.add(DeleteLookbookEvent(lookbookId));

    // Show immediate feedback
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Deleting lookbook...'),
        backgroundColor: Colors.orange,
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 2),
      ),
    );
  }
}
