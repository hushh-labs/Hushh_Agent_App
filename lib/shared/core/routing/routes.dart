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
import '../../../app/features/inventory/presentation/components/product_tile.dart';
import '../../../app/features/inventory/domain/entities/product.dart';
import '../../../app/features/agent_profile/presentation/pages/agent_profile_email_page.dart';
import '../../../app/features/agent_profile/presentation/pages/agent_profile_name_page.dart';
import '../../../app/features/agent_profile/presentation/pages/agent_profile_categories_page.dart';
import '../../../app/features/agent_profile/presentation/pages/agent_profile_brands_page.dart';
import '../../../app/features/agent_profile/presentation/pages/agent_card_created_page.dart';

// New auth flow pages
import '../../../app/features/auth/presentation/pages/auth_email_page.dart';
import '../../../app/features/auth/presentation/pages/auth_name_page.dart';
import '../../../app/features/auth/presentation/pages/auth_categories_page.dart';
import '../../../app/features/auth/presentation/pages/auth_brands_page.dart';
import '../../../app/features/auth/presentation/pages/auth_card_created_page.dart';
import '../../../app/features/profile/presentation/pages/permissions_page.dart';

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

// Placeholder pages that need to be implemented
class CreateLookbookPage extends StatelessWidget {
  const CreateLookbookPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Lookbook'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: const Center(
        child: Text(
          'Create Lookbook Page\n(To be implemented)',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 18),
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
      context.read<LookbookBloc>().add(const FetchProductsEvent());
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
            widget.lookbookId != null ? 'Lookbook Products' : 'All Products'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
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
          IconButton(
            icon: Icon(
              Icons.filter_list,
              color: Colors.grey[400], // Disabled appearance
            ),
            onPressed: null, // Disabled
          ),
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
                    color: Color(0xFF2196F3),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF757575)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        const BorderSide(color: Color(0xFF2196F3), width: 2),
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
                      content: Text(state.operationMessage!),
                      backgroundColor:
                          state.isSuccess ? Colors.green : Colors.red,
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

  void _showFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.4,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 8),
              height: 4,
              width: 40,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Sort By',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF000000),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildFilterOption(
                    context,
                    'Price (Low to High)',
                    Icons.attach_money,
                    'price',
                  ),
                  const SizedBox(height: 16),
                  _buildFilterOption(
                    context,
                    'Stock (High to Low)',
                    Icons.inventory,
                    'stock',
                  ),
                  const SizedBox(height: 16),
                  _buildFilterOption(
                    context,
                    'Name (A to Z)',
                    Icons.sort_by_alpha,
                    'name',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterOption(
    BuildContext context,
    String title,
    IconData icon,
    String sortByString,
  ) {
    return GestureDetector(
      onTap: () {
        print(
            'Filter option tapped: $title, sortBy: $sortByString'); // Debug print
        Navigator.pop(context);

        // Convert string to enum
        ProductSortBy sortBy;
        switch (sortByString) {
          case 'price':
            sortBy = ProductSortBy.price;
            break;
          case 'stock':
            sortBy = ProductSortBy.stock;
            break;
          case 'name':
            sortBy = ProductSortBy.name;
            break;
          default:
            sortBy = ProductSortBy.name;
            break;
        }

        try {
          context.read<LookbookBloc>().add(FilterProductsEvent(sortBy));
          print(
              'FilterProductsEvent dispatched successfully with: $sortBy'); // Debug print
        } catch (e) {
          print('Error dispatching FilterProductsEvent: $e');
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFE0E0E0)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: const Color(0xFF2196F3),
              size: 20,
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Color(0xFF000000),
              ),
            ),
            const Spacer(),
            const Icon(
              Icons.arrow_forward_ios,
              color: Color(0xFF757575),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

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
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () {
              // Navigate back to lookbook page to add products
              Navigator.pop(context);
            },
            icon: const Icon(Icons.add),
            label: Text(
                widget.lookbookId != null ? 'Add Products' : 'Create Products'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
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
              context.read<LookbookBloc>().add(const FetchProductsEvent());
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}
