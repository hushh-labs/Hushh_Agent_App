import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../agent_profile/domain/entities/agent_category.dart';
import '../../../agent_profile/data/models/agent_category_model.dart';
import '../../../../../shared/constants/app_routes.dart';

class AuthCategoriesPage extends StatefulWidget {
  final Map<String, dynamic> profileData;

  const AuthCategoriesPage({
    super.key,
    required this.profileData,
  });

  @override
  State<AuthCategoriesPage> createState() => _AuthCategoriesPageState();
}

class _AuthCategoriesPageState extends State<AuthCategoriesPage> {
  final TextEditingController _searchController = TextEditingController();
  final List<AgentCategory> _selectedCategories = [];
  List<AgentCategory> _allCategories = [];
  List<AgentCategory> _filteredCategories = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchCategories();
    _searchController.addListener(_filterCategories);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchCategories() async {
    try {
      final QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('agent_categories')
          .where('isActive', isEqualTo: true)
          .orderBy('name')
          .get();

      final List<AgentCategory> categories = snapshot.docs
          .map((doc) => AgentCategoryModel.fromFirestore(
                doc.data() as Map<String, dynamic>,
                doc.id,
              ))
          .toList();

      setState(() {
        _allCategories = categories;
        _filteredCategories = categories;
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching categories: $e');
      // Create mock categories if Firestore fails
      _createMockCategories();
    }
  }

  void _createMockCategories() {
    final mockCategories = [
      // Fashion
      AgentCategoryModel(
        id: '1',
        name: 'Fashion & Apparel',
        description: 'Clothing, accessories, and fashion items',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      AgentCategoryModel(
        id: '2',
        name: 'Jewelry & Watches',
        description: 'Jewelry, watches, and luxury accessories',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      AgentCategoryModel(
        id: '3',
        name: 'Beauty & Personal Care',
        description: 'Cosmetics, skincare, and personal care products',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      AgentCategoryModel(
        id: '4',
        name: 'Footwear',
        description: 'Shoes, boots, and footwear accessories',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      AgentCategoryModel(
        id: '5',
        name: 'Handbags & Bags',
        description: 'Bags, purses, and travel accessories',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      // Technology
      AgentCategoryModel(
        id: '6',
        name: 'Technology & Electronics',
        description: 'Electronic devices and gadgets',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      AgentCategoryModel(
        id: '7',
        name: 'Smartphones',
        description: 'Mobile phones and accessories',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      AgentCategoryModel(
        id: '8',
        name: 'Computers & Laptops',
        description: 'Computers, laptops, and peripherals',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      AgentCategoryModel(
        id: '9',
        name: 'Gaming',
        description: 'Gaming consoles, games, and accessories',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      AgentCategoryModel(
        id: '10',
        name: 'Audio & Music',
        description: 'Headphones, speakers, and audio equipment',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      AgentCategoryModel(
        id: '11',
        name: 'Cameras & Photography',
        description: 'Cameras, lenses, and photography equipment',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      // Home & Living
      AgentCategoryModel(
        id: '12',
        name: 'Home & Living',
        description: 'Home decor, furniture, and household items',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      AgentCategoryModel(
        id: '13',
        name: 'Kitchen & Dining',
        description: 'Kitchen appliances and dining accessories',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      AgentCategoryModel(
        id: '14',
        name: 'Garden & Outdoor',
        description: 'Gardening tools and outdoor equipment',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ];

    setState(() {
      _allCategories = mockCategories;
      _filteredCategories = mockCategories;
      _isLoading = false;
    });
  }

  void _filterCategories() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredCategories = _allCategories;
      } else {
        _filteredCategories = _allCategories
            .where((category) =>
                category.name.toLowerCase().contains(query) ||
                (category.description?.toLowerCase().contains(query) ?? false))
            .toList();
      }
    });
  }

  Map<String, List<AgentCategory>> get _categoriesBySection {
    final Map<String, List<AgentCategory>> sections = {};

    for (final category in _filteredCategories) {
      String section = 'Other';

      if (category.name.toLowerCase().contains('fashion') ||
          category.name.toLowerCase().contains('jewelry') ||
          category.name.toLowerCase().contains('beauty') ||
          category.name.toLowerCase().contains('footwear') ||
          category.name.toLowerCase().contains('bag')) {
        section = 'Fashion';
      } else if (category.name.toLowerCase().contains('technology') ||
          category.name.toLowerCase().contains('smartphone') ||
          category.name.toLowerCase().contains('computer') ||
          category.name.toLowerCase().contains('gaming') ||
          category.name.toLowerCase().contains('audio') ||
          category.name.toLowerCase().contains('camera')) {
        section = 'Technology';
      } else if (category.name.toLowerCase().contains('home') ||
          category.name.toLowerCase().contains('kitchen') ||
          category.name.toLowerCase().contains('garden')) {
        section = 'Home & Living';
      }

      sections[section] = sections[section] ?? [];
      sections[section]!.add(category);
    }

    return sections;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 0,
        titleSpacing: 20,
        title: Text(
          'Complete profile',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              foregroundColor: Colors.black,
            ),
            child: const Text('BACK'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Progress indicator
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                '75%',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(50),
              child: LinearProgressIndicator(
                value: 0.75,
                backgroundColor: Colors.grey[300],
                valueColor:
                    const AlwaysStoppedAnimation<Color>(Color(0xFF6725F2)),
                minHeight: 10,
              ),
            ),

            const SizedBox(height: 26),

            // Title
            const Text(
              'What product categories you deal in?',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.8,
                color: Colors.black,
              ),
            ),

            const SizedBox(height: 8),

            // Subtitle
            const Text(
              'Select categories',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
                letterSpacing: 0.4,
              ),
            ),

            const SizedBox(height: 32),

            // Search field
            Container(
              height: 56,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFF8391a1).withOpacity(0.5),
                ),
              ),
              child: TextFormField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search',
                  hintStyle: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 16,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  border: InputBorder.none,
                  prefixIcon: const Icon(
                    Icons.search,
                    color: Color(0xFF8391a1),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Categories sections
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: _categoriesBySection.entries.map((entry) {
                          final sectionName = entry.key;
                          final categories = entry.value;

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                sectionName,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Wrap(
                                spacing: 8.0,
                                runSpacing: 8.0,
                                children: categories.map((category) {
                                  final isSelected =
                                      _selectedCategories.contains(category);
                                  return _CategoryChip(
                                    label: category.name,
                                    isSelected: isSelected,
                                    onTap: () {
                                      setState(() {
                                        if (isSelected) {
                                          _selectedCategories.remove(category);
                                        } else {
                                          _selectedCategories.add(category);
                                        }
                                      });
                                    },
                                  );
                                }).toList(),
                              ),
                              const SizedBox(height: 24),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
            ),

            // Continue button
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(43),
                  gradient: _selectedCategories.isNotEmpty
                      ? const LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [
                            Color(0xFFA342FF),
                            Color(0xFFE54D60),
                          ],
                        )
                      : null,
                  color: _selectedCategories.isEmpty ? Colors.grey : null,
                ),
                child: ElevatedButton(
                  onPressed: _selectedCategories.isNotEmpty
                      ? () {
                          final updatedData =
                              Map<String, dynamic>.from(widget.profileData);
                          updatedData['categories'] =
                              _selectedCategories.map((c) => c.id).toList();

                          Navigator.pushNamed(
                            context,
                            AppRoutes.authBrands,
                            arguments: updatedData,
                          );
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(43),
                    ),
                  ),
                  child: Text(
                    _selectedCategories.isEmpty
                        ? 'Continue'
                        : 'Continue (${_selectedCategories.length} selected)',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          gradient: isSelected 
              ? const LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [Color(0xFFA342FF), Color(0xFFE54D60)],
                )
              : null,
          color: isSelected ? null : Colors.white,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: isSelected 
                ? Colors.transparent 
                : const Color(0xFFA2A09D),
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : const Color(0xFFA2A09D),
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}
