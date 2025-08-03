import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/agent_brand.dart';
import '../../data/models/agent_brand_model.dart';
import '../../../../../shared/constants/app_routes.dart';

class AgentProfileBrandsPage extends StatefulWidget {
  final Map<String, dynamic> profileData;

  const AgentProfileBrandsPage({
    super.key,
    required this.profileData,
  });

  @override
  State<AgentProfileBrandsPage> createState() => _AgentProfileBrandsPageState();
}

class _AgentProfileBrandsPageState extends State<AgentProfileBrandsPage> {
  final TextEditingController _searchController = TextEditingController();
  AgentBrand? _selectedBrand;
  List<AgentBrand> _allBrands = [];
  List<AgentBrand> _filteredBrands = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchBrands();
    _searchController.addListener(_filterBrands);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchBrands() async {
    try {
      print('🔍 Fetching brands from brand_collections...');
      final QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('brand_collections')
          .orderBy('brand_name')
          .get();

      print('📊 Found ${snapshot.docs.length} brands');

      final List<AgentBrand> brands = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        print('📝 Processing brand: ${data['brand_name']}');

        // Map the brand_collections fields to AgentBrandModel fields
        return AgentBrandModel(
          id: doc.id,
          brandName: data['brand_name'] ?? '',
          domain: data['Domain'] ?? '',
          brandLogo: data['brand_logo'] ?? '',
          description: data['brand_name'] ??
              '', // Using brand_name as description for now
          isClaimed: data['custom_brand'] ?? false,
          isVerified: data['brand_approval_status'] == 'approved' ?? false,
          createdAt: DateTime.now(), // Default value
          updatedAt: DateTime.now(), // Default value
        );
      }).toList();

      print('✅ Successfully processed ${brands.length} brands');

      setState(() {
        _allBrands = brands;
        _filteredBrands = brands;
        _isLoading = false;
      });
    } catch (e) {
      print('❌ Error fetching brands: $e');
      // Create mock brands if Firestore fails
      _createMockBrands();
    }
  }

  void _createMockBrands() {
    final mockBrands = [
      AgentBrandModel(
        id: '1',
        brandName: 'American Express',
        domain: 'americanexpress.com',
        brandLogo: 'https://via.placeholder.com/50/0000FF/FFFFFF?text=AE',
        description: 'Financial services company',
        isClaimed: false,
        isVerified: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      AgentBrandModel(
        id: '2',
        brandName: 'St. Regis',
        domain: 'marriott.com',
        brandLogo: 'https://via.placeholder.com/50/8B0000/FFFFFF?text=SR',
        description: 'Luxury hotel chain',
        isClaimed: false,
        isVerified: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      AgentBrandModel(
        id: '3',
        brandName: 'Chanel',
        domain: 'chanel.com',
        brandLogo: 'https://via.placeholder.com/50/000000/FFFFFF?text=CH',
        description: 'Luxury fashion and beauty brand',
        isClaimed: true,
        isVerified: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      AgentBrandModel(
        id: '4',
        brandName: 'Ikea',
        domain: 'ikea.com',
        brandLogo: 'https://via.placeholder.com/50/0051BA/FFFFFF?text=IK',
        description: 'Furniture and home accessories retailer',
        isClaimed: false,
        isVerified: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      AgentBrandModel(
        id: '5',
        brandName: 'Firebase',
        domain: 'firebase.google.com',
        brandLogo: 'https://via.placeholder.com/50/FFCA28/000000?text=FB',
        description: 'Google app development platform',
        isClaimed: false,
        isVerified: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      AgentBrandModel(
        id: '6',
        brandName: 'Microsoft',
        domain: 'microsoft.com',
        brandLogo: 'https://via.placeholder.com/50/00BCF2/FFFFFF?text=MS',
        description: 'Technology corporation',
        isClaimed: false,
        isVerified: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      AgentBrandModel(
        id: '7',
        brandName: 'Apple',
        domain: 'apple.com',
        brandLogo: 'https://via.placeholder.com/50/000000/FFFFFF?text=AP',
        description: 'Technology company',
        isClaimed: false,
        isVerified: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      AgentBrandModel(
        id: '8',
        brandName: 'Nike',
        domain: 'nike.com',
        brandLogo: 'https://via.placeholder.com/50/000000/FFFFFF?text=NK',
        description: 'Athletic footwear and apparel',
        isClaimed: false,
        isVerified: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ];

    setState(() {
      _allBrands = mockBrands;
      _filteredBrands = mockBrands;
      _isLoading = false;
    });
  }

  void _filterBrands() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredBrands = _allBrands;
      } else {
        _filteredBrands = _allBrands
            .where((brand) =>
                brand.brandName.toLowerCase().contains(query) ||
                (brand.domain?.toLowerCase().contains(query) ?? false) ||
                (brand.description?.toLowerCase().contains(query) ?? false))
            .toList();
      }
    });
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
                '100%',
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
                value: 1.0,
                backgroundColor: Colors.grey[300],
                valueColor:
                    const AlwaysStoppedAnimation<Color>(Color(0xFF6725F2)),
                minHeight: 10,
              ),
            ),

            const SizedBox(height: 26),

            // Title
            const Text(
              'Select Your Brand',
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
              'Choose the brand',
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

            // Create new brand option
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: const Color(0xFFE51A5E).withOpacity(0.1),
                border: Border.all(
                  color: const Color(0xFFE51A5E).withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFFE51A5E),
                    ),
                    child: const Icon(
                      Icons.add,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Create & Customize Your Brand',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Color(0xFFE51A5E),
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'Ready to Make Your Mark? Create and Customize Your Brand Now!',
                          style: TextStyle(
                            color: Color(0xFF666666),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Brands list
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      padding: EdgeInsets.zero,
                      itemCount: _filteredBrands.length,
                      itemBuilder: (context, index) {
                        final brand = _filteredBrands[index];
                        final isSelected = _selectedBrand == brand;
                        final isUnclaimed = !brand.isClaimed;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected
                                  ? Colors.transparent
                                  : const Color(0xFFE5E5E5),
                              width: isSelected ? 2 : 1,
                            ),
                            gradient: isSelected
                                ? const LinearGradient(
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                    colors: [
                                      Color(0xFFA342FF),
                                      Color(0xFFE54D60),
                                    ],
                                  )
                                : null,
                            color: isSelected ? null : Colors.white,
                          ),
                          child: Container(
                            margin: isSelected ? const EdgeInsets.all(2) : EdgeInsets.zero,
                            decoration: isSelected 
                                ? BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: Colors.white,
                                  )
                                : null,
                            child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            onTap: () {
                              setState(() {
                                _selectedBrand = brand;
                              });
                            },
                            leading: CircleAvatar(
                              radius: 20,
                              backgroundColor: const Color(0xFF0051BA),
                              child: brand.brandLogo != null &&
                                      brand.brandLogo!.isNotEmpty
                                  ? ClipOval(
                                      child: Image.network(
                                        brand.brandLogo!,
                                        width: 40,
                                        height: 40,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                          // Fallback to initials if image fails to load
                                          return Text(
                                            brand.brandName
                                                .substring(0, 2)
                                                .toUpperCase(),
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                            ),
                                          );
                                        },
                                        loadingBuilder:
                                            (context, child, loadingProgress) {
                                          if (loadingProgress == null)
                                            return child;
                                          return const SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                      Colors.white),
                                            ),
                                          );
                                        },
                                      ),
                                    )
                                  : Text(
                                      // Fallback to initials if no logo URL
                                      brand.brandName
                                          .substring(0, 2)
                                          .toUpperCase(),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                            ),
                            title: Text(
                              brand.brandName,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                            subtitle: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    brand.domain ?? 'Domain Not Found',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                                if (brand.isVerified) ...[
                                  const SizedBox(width: 8),
                                  const Icon(
                                    Icons.verified,
                                    color: Colors.blue,
                                    size: 16,
                                  ),
                                ],
                              ],
                            ),
                            trailing: isUnclaimed && !isSelected
                                ? Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 8),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(6),
                                      gradient: const LinearGradient(
                                        begin: Alignment.centerLeft,
                                        end: Alignment.centerRight,
                                        colors: [Color(0xFFA342FF), Color(0xFFE54D60)],
                                      ),
                                    ),
                                    child: const Text(
                                      'Claim',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 12,
                                      ),
                                    ),
                                  )
                                : isSelected
                                    ? ShaderMask(
                                        shaderCallback: (bounds) => const LinearGradient(
                                          colors: [Color(0xFFA342FF), Color(0xFFE54D60)],
                                        ).createShader(bounds),
                                        child: const Icon(
                                          Icons.check_circle,
                                          color: Colors.white,
                                          size: 24,
                                        ),
                                      )
                                    : null,
                            ),
                          ),
                        );
                      },
                    ),
            ),

            // Continue button
            if (_selectedBrand != null) ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(43),
                    gradient: const LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        Color(0xFFA342FF),
                        Color(0xFFE54D60),
                      ],
                    ),
                  ),
                  child: ElevatedButton(
                    onPressed: () {
                      final updatedData =
                          Map<String, dynamic>.from(widget.profileData);
                      updatedData['brand'] = _selectedBrand!.id;
                      updatedData['brandName'] = _selectedBrand!.brandName;

                      Navigator.pushNamed(
                        context,
                        AppRoutes.agentCardCreated,
                        arguments: updatedData,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(43),
                      ),
                    ),
                    child: Text(
                      'Continue with ${_selectedBrand!.brandName}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
