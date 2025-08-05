import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import '../../constants/app_routes.dart';
import '../../../app/features/splash/presentation/bloc/splash_bloc.dart';
import '../../../app/features/splash/presentation/pages/splash_page_with_bloc.dart';
import '../../../app/features/auth/presentation/bloc/auth_bloc.dart';
import '../../../app/features/auth/presentation/pages/main_auth_selection.dart';
import '../../../app/features/auth/presentation/pages/otp_verification.dart';
import '../../../app/features/auth/domain/enum.dart';
import '../../../app/Home/presentation/bloc/home_bloc.dart';
import '../../../app/Home/presentation/pages/home_page.dart';

import '../../../app/features/inventory/presentation/bloc/lookbook_bloc.dart';
import '../../../app/features/inventory/presentation/pages/agent_lookbook_page.dart';
import '../../../app/features/inventory/domain/entities/product.dart';
import '../../../app/features/inventory/presentation/components/product_tile.dart';
import '../../../app/features/inventory/data/datasources/lookbook_firestore_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../app/features/agent_profile/presentation/pages/agent_profile_email_page.dart';
import '../../../app/features/agent_profile/presentation/pages/agent_profile_name_page.dart';
import '../../../app/features/agent_profile/presentation/pages/agent_profile_categories_page.dart';
import '../../../app/features/agent_profile/presentation/pages/agent_profile_brands_page.dart';
import '../../../app/features/agent_profile/presentation/pages/agent_card_created_page.dart';
import '../../../app/features/agent_profile/presentation/pages/agent_card_demo_page.dart';

// New auth flow pages
import '../../../app/features/auth/presentation/pages/auth_email_page.dart';
import '../../../app/features/auth/presentation/pages/auth_name_page.dart';
import '../../../app/features/auth/presentation/pages/auth_categories_page.dart';
import '../../../app/features/auth/presentation/pages/auth_brands_page.dart';
import '../../../app/features/auth/presentation/pages/auth_card_created_page.dart';
import '../../../app/features/profile/presentation/pages/permissions_page.dart';
import '../../../app/features/notification_bidding/presentation/bloc/notification_bidding_bloc.dart';
import '../../../app/features/notification_bidding/presentation/pages/notification_bidding_page.dart';

final sl = GetIt.instance;

class Routes {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.splash:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (context) => sl<SplashBloc>(),
            child: const SplashPageWithBloc(),
          ),
        );

      case AppRoutes.mainAuth:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (context) => sl<AuthBloc>(),
            child: const MainAuthSelectionPage(),
          ),
        );

      case AppRoutes.emailVerification:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (context) => sl<AuthBloc>(),
            child: OtpVerificationPage(
              args: OtpVerificationPageArgs(
                emailOrPhone: args?['emailOrPhone'] ?? '',
                type: args?['type'] ?? OtpVerificationType.phone,
              ),
            ),
          ),
        );

      case AppRoutes.home:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (context) => sl<HomeBloc>(),
            child: const HomePage(),
          ),
        );

      // New auth flow routes
      case AppRoutes.authEmail:
        return MaterialPageRoute(
          builder: (_) => const AuthEmailPage(),
        );

      case AppRoutes.authName:
        final email = settings.arguments as String? ?? '';
        return MaterialPageRoute(
          builder: (_) => AuthNamePage(email: email),
        );

      case AppRoutes.authCategories:
        final profileData = settings.arguments as Map<String, dynamic>? ?? {};
        return MaterialPageRoute(
          builder: (_) => AuthCategoriesPage(profileData: profileData),
        );

      case AppRoutes.authBrands:
        final profileData = settings.arguments as Map<String, dynamic>? ?? {};
        return MaterialPageRoute(
          builder: (_) => AuthBrandsPage(profileData: profileData),
        );

      case AppRoutes.authCardCreated:
        final profileData = settings.arguments as Map<String, dynamic>? ?? {};
        return MaterialPageRoute(
          builder: (_) => AuthCardCreatedPage(profileData: profileData),
        );

      // Legacy agent profile routes (keeping for backward compatibility)
      case AppRoutes.agentProfileEmail:
        return MaterialPageRoute(
          builder: (_) => const AgentProfileEmailPage(),
        );

      case AppRoutes.agentProfileName:
        final email = settings.arguments as String? ?? '';
        return MaterialPageRoute(
          builder: (_) => AgentProfileNamePage(email: email),
        );

      case AppRoutes.agentProfileCategories:
        final profileData = settings.arguments as Map<String, dynamic>? ?? {};
        return MaterialPageRoute(
          builder: (_) => AgentProfileCategoriesPage(profileData: profileData),
        );

      case AppRoutes.agentProfileBrands:
        final profileData = settings.arguments as Map<String, dynamic>? ?? {};
        return MaterialPageRoute(
          builder: (_) => AgentProfileBrandsPage(profileData: profileData),
        );

      case AppRoutes.agentCardCreated:
        final profileData = settings.arguments as Map<String, dynamic>? ?? {};
        return MaterialPageRoute(
          builder: (_) => AgentCardCreatedPage(profileData: profileData),
        );

      case AppRoutes.agentCardDemo:
        return MaterialPageRoute(
          builder: (_) => const AgentCardDemoPage(),
        );

      case AppRoutes.agentLookbook:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (context) => sl<LookbookBloc>(),
            child: const AgentLookBookPage(),
          ),
        );

      case AppRoutes.createLookbook:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (context) => sl<LookbookBloc>(),
            child: const CreateLookbookPage(),
          ),
        );

      case AppRoutes.agentProducts:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (context) => sl<LookbookBloc>(),
            child: AgentProductsPage(
              lookbookId: args?['lookbookId'],
              mode: args?['mode'] ?? 'view',
            ),
          ),
        );

      case AppRoutes.permissions:
        return MaterialPageRoute(
          builder: (_) => const PermissionsPage(),
        );

      case AppRoutes.notificationBidding:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (context) => sl<NotificationBiddingBloc>(),
            child: const NotificationBiddingPage(),
          ),
        );

      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(
              child: Text('Route not found'),
            ),
          ),
        );
    }
  }
}

// Create Lookbook Page Implementation
class CreateLookbookPage extends StatefulWidget {
  const CreateLookbookPage({super.key});

  @override
  State<CreateLookbookPage> createState() => _CreateLookbookPageState();
}

class _CreateLookbookPageState extends State<CreateLookbookPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _isLoading = false;
  List<Product> _availableProducts = [];
  List<String> _selectedProductIds = [];
  bool _isLoadingProducts = true;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _loadProducts() async {
    setState(() {
      _isLoadingProducts = true;
    });

    // Fetch agent's products
    context.read<LookbookBloc>().add(const FetchProductsEvent());
  }

  void _createLookbook() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedProductIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.purple, Colors.pinkAccent],
              ),
              borderRadius: BorderRadius.all(Radius.circular(8)),
            ),
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            child: const Text(
              'Please select at least one product for the lookbook',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Dispatch create lookbook event
    context.read<LookbookBloc>().add(
          CreateLookbookEvent(
            lookbookName: _nameController.text.trim(),
            description: _descriptionController.text.trim().isEmpty
                ? null
                : _descriptionController.text.trim(),
            productIds: _selectedProductIds, // Use selected products
          ),
        );
  }

  Widget _buildProductSelection() {
    if (_isLoadingProducts) {
      return Container(
        height: 200,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF8213A5)),
          ),
        ),
      );
    }

    if (_availableProducts.isEmpty) {
      return Container(
        height: 200,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.inventory_2_outlined,
                size: 48,
                color: Colors.grey,
              ),
              SizedBox(height: 8),
              Text(
                'No products found',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                ),
              ),
              Text(
                'Add products to your inventory first',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      height: 300,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          // Header with selection count
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Text(
                  '${_selectedProductIds.length} of ${_availableProducts.length} products selected',
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      if (_selectedProductIds.length ==
                          _availableProducts.length) {
                        _selectedProductIds.clear();
                      } else {
                        _selectedProductIds =
                            _availableProducts.map((p) => p.productId).toList();
                      }
                    });
                  },
                  child: Text(
                    _selectedProductIds.length == _availableProducts.length
                        ? 'Deselect All'
                        : 'Select All',
                    style: const TextStyle(
                      color: Color(0xFF8213A5),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Product list
          Expanded(
            child: ListView.builder(
              itemCount: _availableProducts.length,
              itemBuilder: (context, index) {
                final product = _availableProducts[index];
                final isSelected =
                    _selectedProductIds.contains(product.productId);

                return Container(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFF8213A5)
                          : Colors.grey[300]!,
                      width: isSelected ? 2 : 1,
                    ),
                    color: isSelected
                        ? const Color(0xFF8213A5).withOpacity(0.05)
                        : Colors.white,
                  ),
                  child: ListTile(
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        product.productImage?.isNotEmpty == true
                            ? product.productImage!
                            : '',
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.image, color: Colors.grey),
                          );
                        },
                      ),
                    ),
                    title: Text(
                      product.productName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Row(
                      children: [
                        Text(
                          '\$${product.productPrice.toStringAsFixed(2)}',
                          style: const TextStyle(
                            color: Color(0xFF8213A5),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Stock: ${product.stockQuantity}',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    trailing: Icon(
                      isSelected ? Icons.check_circle : Icons.circle_outlined,
                      color: isSelected ? const Color(0xFF8213A5) : Colors.grey,
                    ),
                    onTap: () {
                      setState(() {
                        if (isSelected) {
                          _selectedProductIds.remove(product.productId);
                        } else {
                          _selectedProductIds.add(product.productId);
                        }
                      });
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Create Lookbook'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: BlocListener<LookbookBloc, LookbookState>(
        listener: (context, state) {
          if (state is LookbookCreated) {
            setState(() {
              _isLoading = false;
            });
            // Show success message
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.purple, Colors.pinkAccent],
                    ),
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                  ),
                  padding:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  child: Text(
                    'Lookbook "${state.lookbook.lookbookName}" created successfully!',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                backgroundColor: Colors.transparent,
                elevation: 0,
                behavior: SnackBarBehavior.floating,
              ),
            );
            // Navigate back with success result
            Navigator.pop(context, 'success');
          } else if (state is LookbookError) {
            setState(() {
              _isLoading = false;
            });
            // Show error message
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error: ${state.message}'),
                backgroundColor: Colors.red,
                behavior: SnackBarBehavior.floating,
              ),
            );
          } else if (state is ProductsLoaded) {
            setState(() {
              _availableProducts = state.products;
              _isLoadingProducts = false;
            });
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                const Text(
                  'Create New Lookbook',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Organize your products into curated collections',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 32),

                // Lookbook Name Field
                const Text(
                  'Lookbook Name *',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    hintText: 'e.g., Summer Collection, Office Wear',
                    hintStyle: TextStyle(color: Colors.grey[500]),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          const BorderSide(color: Colors.purple, width: 2),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a lookbook name';
                    }
                    if (value.trim().length < 3) {
                      return 'Name must be at least 3 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // Description Field
                const Text(
                  'Description (Optional)',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: 'Describe your lookbook theme or style...',
                    hintStyle: TextStyle(color: Colors.grey[500]),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          const BorderSide(color: Colors.purple, width: 2),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Product Selection Section
                const Text(
                  'Select Products',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 8),
                _buildProductSelection(),
                const SizedBox(height: 32),

                // Info Card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.purple.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.purple.withOpacity(0.2)),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Colors.purple,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'You can add products to your lookbook after creation.',
                          style: const TextStyle(
                            color: Colors.purple,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),

                // Create Button
                Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.purple, Colors.pinkAccent],
                    ),
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                  ),
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _createLookbook,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Text(
                            _selectedProductIds.isEmpty
                                ? 'Create Lookbook'
                                : 'Create Lookbook (${_selectedProductIds.length} products)',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class AgentProductsPage extends StatefulWidget {
  final String? lookbookId;
  final String mode;

  const AgentProductsPage({
    super.key,
    this.lookbookId,
    required this.mode,
  });

  @override
  State<AgentProductsPage> createState() => _AgentProductsPageState();
}

class _AgentProductsPageState extends State<AgentProductsPage> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearchVisible = false;

  @override
  void initState() {
    super.initState();
    // Fetch products when page loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context
          .read<LookbookBloc>()
          .add(FetchProductsEvent(lookbookId: widget.lookbookId));
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showAddProductsToLookbookDialog() {
    if (widget.lookbookId == null) return;

    // Get the BLoC before showing dialog
    final lookbookBloc = context.read<LookbookBloc>();

    showDialog(
      context: context,
      builder: (context) => BlocProvider.value(
        value: lookbookBloc,
        child: _AddProductsToLookbookDialog(
          lookbookId: widget.lookbookId!,
          onProductsAdded: () {
            // Refresh the lookbook products
            lookbookBloc.add(FetchProductsEvent(lookbookId: widget.lookbookId));
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButton: widget.lookbookId != null
          ? Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.purple, Colors.pinkAccent],
                ),
                borderRadius: BorderRadius.all(Radius.circular(16)),
              ),
              child: FloatingActionButton.extended(
                onPressed: _showAddProductsToLookbookDialog,
                backgroundColor: Colors.transparent,
                foregroundColor: Colors.white,
                elevation: 0,
                icon: const Icon(Icons.add),
                label: const Text('Add Products'),
              ),
            )
          : null,
      appBar: AppBar(
        title: Text(
            widget.lookbookId != null ? 'Lookbook Products' : 'All Products'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () {
            // Pop with a refresh signal
            Navigator.pop(context, 'refresh');
          },
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: IconButton(
              icon: Icon(_isSearchVisible ? Icons.close : Icons.search),
              onPressed: () {
                setState(() {
                  _isSearchVisible = !_isSearchVisible;
                  if (!_isSearchVisible) {
                    _searchController.clear();
                    context
                        .read<LookbookBloc>()
                        .add(const SearchProductsEvent(''));
                  }
                });
              },
            ),
          ),
          // Filter button - COMMENTED OUT
          // IconButton(
          //   icon: Icon(
          //     Icons.filter_list,
          //     color: Colors.grey[400], // Disabled appearance
          //   ),
          //   onPressed: null, // Disabled
          // ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          if (_isSearchVisible)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(
                  bottom: BorderSide(
                    color: Color(0xFFE0E0E0),
                    width: 1,
                  ),
                ),
              ),
              child: TextField(
                controller: _searchController,
                autofocus: true,
                onChanged: (query) {
                  context.read<LookbookBloc>().add(SearchProductsEvent(query));
                },
                decoration: InputDecoration(
                  hintText: 'Search products...',
                  hintStyle: const TextStyle(color: Color(0xFF757575)),
                  prefixIcon: const Icon(
                    Icons.search,
                    color: Colors.purple,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF757575)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        const BorderSide(color: Colors.purple, width: 2),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF757575)),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
            ),
          // Products Grid
          Expanded(
            child: BlocConsumer<LookbookBloc, LookbookState>(
              listener: (context, state) {
                if (state is ProductsLoadedWithOperation &&
                    state.operationMessage != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.purple, Colors.pinkAccent],
                          ),
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                        ),
                        padding: const EdgeInsets.symmetric(
                            vertical: 8, horizontal: 12),
                        child: Text(
                          state.operationMessage!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      backgroundColor: Colors.transparent,
                      elevation: 0,
                      duration: Duration(
                        seconds: state.isSuccess ? 2 : 3,
                      ),
                      behavior: SnackBarBehavior.floating,
                      margin: const EdgeInsets.all(16),
                    ),
                  );
                }
              },
              builder: (context, state) {
                if (state is LookbookLoading) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                } else if (state is ProductsLoaded) {
                  if (state.products.isEmpty) {
                    return _buildEmptyState();
                  }
                  return _buildProductsGrid(state.products);
                } else if (state is ProductsLoadedWithOperation) {
                  if (state.products.isEmpty) {
                    return _buildEmptyState();
                  }
                  return _buildProductsGrid(state.products);
                } else if (state is LookbookError) {
                  return _buildErrorState(state.message);
                } else {
                  return _buildEmptyState();
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  // Filter bottom sheet - COMMENTED OUT
  // void _showFilterBottomSheet(BuildContext context) {
  //   showModalBottomSheet(
  //     context: context,
  //     isScrollControlled: true,
  //     backgroundColor: Colors.transparent,
  //     builder: (context) => Container(
  //       height: MediaQuery.of(context).size.height * 0.4,
  //       decoration: const BoxDecoration(
  //         color: Colors.white,
  //         borderRadius: BorderRadius.only(
  //           topLeft: Radius.circular(20),
  //           topRight: Radius.circular(20),
  //         ),
  //       ),
  //       child: Column(
  //         children: [
  //           Container(
  //             margin: const EdgeInsets.only(top: 8),
  //             height: 4,
  //             width: 40,
  //             decoration: BoxDecoration(
  //               color: Colors.grey[300],
  //               borderRadius: BorderRadius.circular(2),
  //             ),
  //           ),
  //           Padding(
  //             padding: const EdgeInsets.all(20),
  //             child: Column(
  //               crossAxisAlignment: CrossAxisAlignment.start,
  //               children: [
  //                 Row(
  //                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                   children: [
  //                     const Text(
  //                       'Sort By',
  //                       style: TextStyle(
  //                         fontSize: 20,
  //                         fontWeight: FontWeight.bold,
  //                         color: Color(0xFF000000),
  //                       ),
  //                     ),
  //                     IconButton(
  //                       icon: const Icon(Icons.close),
  //                       onPressed: () => Navigator.pop(context),
  //                     ),
  //                   ],
  //                 ),
  //                 const SizedBox(height: 20),
  //                 _buildFilterOption(
  //                   context,
  //                   'Price (Low to High)',
  //                   Icons.attach_money,
  //                   'price',
  //                 ),
  //                 const SizedBox(height: 16),
  //                 _buildFilterOption(
  //                   context,
  //                   'Stock (High to Low)',
  //                   Icons.inventory,
  //                   'stock',
  //                 ),
  //                 const SizedBox(height: 16),
  //                 _buildFilterOption(
  //                   context,
  //                   'Name (A to Z)',
  //                   Icons.sort_by_alpha,
  //                   'name',
  //                 ),
  //               ],
  //             ),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  // Filter option widget - COMMENTED OUT
  // Widget _buildFilterOption(
  //   BuildContext context,
  //   String title,
  //   IconData icon,
  //   String sortByString,
  // ) {
  //   return GestureDetector(
  //     onTap: () {
  //       print(
  //           'Filter option tapped: $title, sortBy: $sortByString'); // Debug print
  //       Navigator.pop(context);

  //       // Convert string to enum
  //       ProductSortBy sortBy;
  //       switch (sortByString) {
  //         case 'price':
  //           sortBy = ProductSortBy.price;
  //           break;
  //         case 'stock':
  //           sortBy = ProductSortBy.stock;
  //           break;
  //         case 'name':
  //           sortBy = ProductSortBy.name;
  //           break;
  //         default:
  //           sortBy = ProductSortBy.name;
  //           break;
  //       }

  //       try {
  //         context.read<LookbookBloc>().add(FilterProductsEvent(sortBy));
  //         print(
  //             'FilterProductsEvent dispatched successfully with: $sortBy'); // Debug print
  //       } catch (e) {
  //         print('Error dispatching FilterProductsEvent: $e');
  //       }
  //     },
  //     child: Container(
  //       padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
  //       decoration: BoxDecoration(
  //         border: Border.all(color: const Color(0xFFE0E0E0)),
  //         borderRadius: BorderRadius.circular(12),
  //       ),
  //       child: Row(
  //         children: [
  //           Icon(
  //             icon,
  //             color: Colors.purple,
  //             size: 20,
  //           ),
  //           const SizedBox(width: 12),
  //           Text(
  //             title,
  //             style: const TextStyle(
  //               fontSize: 16,
  //               fontWeight: FontWeight.w500,
  //               color: Color(0xFF000000),
  //             ),
  //           ),
  //           const Spacer(),
  //           const Icon(
  //             Icons.arrow_forward_ios,
  //             color: Color(0xFF757575),
  //             size: 16,
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  Widget _buildProductsGrid(List<Product> products) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.65,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return ProductTile(
          product: product,
          onProductClicked: (productId) {
            // TODO: Navigate to product detail page
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Product: ${product.productName}'),
                duration: const Duration(seconds: 1),
              ),
            );
          },
          onUpdateStock: (productId, newStock) async {
            final lookbookBloc = context.read<LookbookBloc>();
            lookbookBloc.add(UpdateProductStockEvent(
              productId: productId,
              newStock: newStock,
            ));
          },
          onDeleteProduct: (productId) async {
            final lookbookBloc = context.read<LookbookBloc>();
            lookbookBloc.add(DeleteProductEvent(productId));
          },
          lookbookId: widget.lookbookId,
          onRemoveFromLookbook: widget.lookbookId != null
              ? (lookbookId, productId) async {
                  final lookbookBloc = context.read<LookbookBloc>();
                  lookbookBloc.add(RemoveProductFromLookbookEvent(
                    lookbookId: lookbookId,
                    productId: productId,
                  ));
                }
              : null,
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 24),
          Text(
            widget.lookbookId != null
                ? 'No Products in Lookbook'
                : 'No Products Found',
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
              widget.lookbookId != null
                  ? 'This lookbook doesn\'t have any products yet'
                  : 'You haven\'t added any products to your inventory yet',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 80,
            color: Colors.red[400],
          ),
          const SizedBox(height: 24),
          const Text(
            'Error Loading Products',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Colors.red,
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              message,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 16,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () {
              context
                  .read<LookbookBloc>()
                  .add(FetchProductsEvent(lookbookId: widget.lookbookId));
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}

class _AddProductsToLookbookDialog extends StatefulWidget {
  final String lookbookId;
  final VoidCallback onProductsAdded;

  const _AddProductsToLookbookDialog({
    required this.lookbookId,
    required this.onProductsAdded,
  });

  @override
  State<_AddProductsToLookbookDialog> createState() =>
      _AddProductsToLookbookDialogState();
}

class _AddProductsToLookbookDialogState
    extends State<_AddProductsToLookbookDialog> {
  List<String> _selectedProductIds = [];
  bool _isAddingProducts = false;
  List<Product> _allProducts = [];
  bool _isLoadingProducts = true;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) return;

      // Get current lookbook products to filter them out
      final lookbookBloc = context.read<LookbookBloc>();
      final currentState = lookbookBloc.state;
      List<String> currentLookbookProductIds = [];

      if (currentState is ProductsLoaded) {
        currentLookbookProductIds =
            currentState.products.map((p) => p.productId).toList();
      }

      // Fetch all agent products directly without affecting BLoC state
      final allProducts = await LookbookFirestoreService().getProducts(
        hushhId: currentUser.uid,
        lookbookId: null, // Get all products
      );

      // Filter out products already in the current lookbook
      final availableProducts = allProducts
          .where((product) =>
              !currentLookbookProductIds.contains(product.productId))
          .toList();

      setState(() {
        _allProducts = availableProducts;
        _isLoadingProducts = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingProducts = false;
      });
    }
  }

  Future<void> _addSelectedProducts() async {
    if (_selectedProductIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one product to add'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isAddingProducts = true;
    });

    try {
      final lookbookBloc = context.read<LookbookBloc>();

      // Add each selected product to the lookbook
      for (final productId in _selectedProductIds) {
        lookbookBloc.add(AddProductToLookbookEvent(
          lookbookId: widget.lookbookId,
          productId: productId,
        ));
      }

      // Wait a moment for the operations to complete
      await Future.delayed(const Duration(milliseconds: 500));

      // Close dialog
      Navigator.pop(context);

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.purple, Colors.pinkAccent],
              ),
              borderRadius: BorderRadius.all(Radius.circular(8)),
            ),
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            child: Text(
              '${_selectedProductIds.length} products added to lookbook',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          behavior: SnackBarBehavior.floating,
        ),
      );

      // Refresh the parent page
      widget.onProductsAdded();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.purple, Colors.pinkAccent],
              ),
              borderRadius: BorderRadius.all(Radius.circular(8)),
            ),
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            child: Text(
              'Error adding products: $e',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }

    setState(() {
      _isAddingProducts = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: Colors.white,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.95,
        height: MediaQuery.of(context).size.height * 0.85,
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Header
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Add Products to Lookbook',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: Colors.black54),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Products List
            Expanded(
              child: _isLoadingProducts
                  ? const Center(
                      child: CircularProgressIndicator(
                        valueColor:
                            AlwaysStoppedAnimation<Color>(Color(0xFF8213A5)),
                      ),
                    )
                  : _allProducts.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.check_circle,
                                  size: 64, color: Colors.green[600]),
                              const SizedBox(height: 16),
                              const Text(
                                'All products are already\nin this lookbook!',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.black87,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        )
                      : Column(
                          children: [
                            // Selection count
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFF8213A5).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color:
                                      const Color(0xFF8213A5).withOpacity(0.2),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      '${_selectedProductIds.length} of ${_allProducts.length} products selected',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w500,
                                        color: Colors.black87,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        if (_selectedProductIds.length ==
                                            _allProducts.length) {
                                          _selectedProductIds.clear();
                                        } else {
                                          _selectedProductIds = _allProducts
                                              .map((p) => p.productId)
                                              .toList();
                                        }
                                      });
                                    },
                                    child: Text(
                                      _selectedProductIds.length ==
                                              _allProducts.length
                                          ? 'Deselect All'
                                          : 'Select All',
                                      style: const TextStyle(
                                        color: Color(0xFF8213A5),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),

                            // Products list
                            Expanded(
                              child: ListView.builder(
                                itemCount: _allProducts.length,
                                itemBuilder: (context, index) {
                                  final product = _allProducts[index];
                                  final isSelected = _selectedProductIds
                                      .contains(product.productId);

                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 8),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: isSelected
                                            ? const Color(0xFF8213A5)
                                            : Colors.grey[300]!,
                                        width: isSelected ? 2 : 1,
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                      color: isSelected
                                          ? const Color(0xFF8213A5)
                                              .withOpacity(0.05)
                                          : Colors.white,
                                    ),
                                    child: ListTile(
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 8,
                                      ),
                                      leading: ClipRRect(
                                        borderRadius: BorderRadius.circular(6),
                                        child: Image.network(
                                          product.productImage?.isNotEmpty ==
                                                  true
                                              ? product.productImage!
                                              : '',
                                          width: 45,
                                          height: 45,
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (context, error, stackTrace) {
                                            return Container(
                                              width: 45,
                                              height: 45,
                                              decoration: BoxDecoration(
                                                color: Colors.grey[200],
                                                borderRadius:
                                                    BorderRadius.circular(6),
                                              ),
                                              child: const Icon(Icons.image,
                                                  color: Colors.grey, size: 20),
                                            );
                                          },
                                        ),
                                      ),
                                      title: Text(
                                        product.productName,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w500,
                                          color: Colors.black87,
                                          fontSize: 14,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      subtitle: Padding(
                                        padding: const EdgeInsets.only(top: 4),
                                        child: Row(
                                          children: [
                                            Flexible(
                                              child: Text(
                                                '\$${product.productPrice.toStringAsFixed(2)}',
                                                style: const TextStyle(
                                                  color: Color(0xFF8213A5),
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 13,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Flexible(
                                              child: Text(
                                                'Stock: ${product.stockQuantity}',
                                                style: TextStyle(
                                                  color: Colors.grey[600],
                                                  fontSize: 12,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      trailing: Icon(
                                        isSelected
                                            ? Icons.check_circle
                                            : Icons.circle_outlined,
                                        color: isSelected
                                            ? const Color(0xFF8213A5)
                                            : Colors.grey[400],
                                        size: 24,
                                      ),
                                      onTap: () {
                                        setState(() {
                                          if (isSelected) {
                                            _selectedProductIds
                                                .remove(product.productId);
                                          } else {
                                            _selectedProductIds
                                                .add(product.productId);
                                          }
                                        });
                                      },
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
            ),

            const SizedBox(height: 20),

            // Add button
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Colors.purple, Colors.pinkAccent],
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.purple.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: _isAddingProducts ? null : _addSelectedProducts,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.grey[300],
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: _isAddingProducts
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2),
                      )
                    : Text(
                        _selectedProductIds.isEmpty
                            ? 'Add Products'
                            : 'Add ${_selectedProductIds.length} Products',
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600),
                      ),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
