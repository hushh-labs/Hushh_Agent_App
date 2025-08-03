import '../entities/agent_category.dart';
import '../repositories/category_repository.dart';
import '../../../../../shared/domain/usecases/base_usecase.dart';

/// Parameters for uploading categories
class UploadCategoriesParams extends UseCaseParams {
  final List<Map<String, dynamic>> categories;

  const UploadCategoriesParams({required this.categories});

  @override
  List<Object?> get props => [categories];
}

/// Use case for uploading multiple categories to the remote data source
class UploadCategoriesUseCase extends UseCase<bool, UploadCategoriesParams> {
  final CategoryRepository _repository;

  UploadCategoriesUseCase(this._repository);

  @override
  Future<Result<bool>> call(UploadCategoriesParams params) async {
    return await _repository.uploadCategories(params.categories);
  }
}

/// Default categories data that can be uploaded
class DefaultCategoriesData {
  static List<Map<String, dynamic>> get categories => [
        // Fashion & Apparel
        {
          'name': 'Fashion & Apparel',
          'description': 'Clothing, accessories, and fashion items',
          'isActive': true,
        },
        {
          'name': 'Jewelry & Watches',
          'description': 'Jewelry, watches, and luxury accessories',
          'isActive': true,
        },
        {
          'name': 'Beauty & Personal Care',
          'description': 'Cosmetics, skincare, and personal care products',
          'isActive': true,
        },
        {
          'name': 'Footwear',
          'description': 'Shoes, boots, and footwear accessories',
          'isActive': true,
        },
        {
          'name': 'Handbags & Bags',
          'description': 'Bags, purses, and travel accessories',
          'isActive': true,
        },

        // Technology & Electronics
        {
          'name': 'Technology & Electronics',
          'description': 'Electronic devices and gadgets',
          'isActive': true,
        },
        {
          'name': 'Smartphones',
          'description': 'Mobile phones and accessories',
          'isActive': true,
        },
        {
          'name': 'Computers & Laptops',
          'description': 'Computers, laptops, and peripherals',
          'isActive': true,
        },
        {
          'name': 'Gaming',
          'description': 'Gaming consoles, games, and accessories',
          'isActive': true,
        },
        {
          'name': 'Audio & Music',
          'description': 'Headphones, speakers, and audio equipment',
          'isActive': true,
        },
        {
          'name': 'Cameras & Photography',
          'description': 'Cameras, lenses, and photography equipment',
          'isActive': true,
        },

        // Home & Living
        {
          'name': 'Home & Living',
          'description': 'Home decor, furniture, and household items',
          'isActive': true,
        },
        {
          'name': 'Kitchen & Dining',
          'description': 'Kitchen appliances and dining accessories',
          'isActive': true,
        },
        {
          'name': 'Garden & Outdoor',
          'description': 'Gardening tools and outdoor equipment',
          'isActive': true,
        },

        // Sports & Fitness
        {
          'name': 'Sports & Fitness',
          'description': 'Sports equipment, fitness gear, and athletic wear',
          'isActive': true,
        },
        {
          'name': 'Outdoor Recreation',
          'description': 'Camping, hiking, and outdoor adventure gear',
          'isActive': true,
        },

        // Automotive
        {
          'name': 'Automotive',
          'description': 'Car parts, accessories, and automotive products',
          'isActive': true,
        },

        // Books & Media
        {
          'name': 'Books & Media',
          'description': 'Books, magazines, and digital media',
          'isActive': true,
        },

        // Toys & Games
        {
          'name': 'Toys & Games',
          'description': 'Toys, board games, and entertainment products',
          'isActive': true,
        },

        // Health & Wellness
        {
          'name': 'Health & Wellness',
          'description':
              'Health supplements, medical devices, and wellness products',
          'isActive': true,
        },

        // Pet Supplies
        {
          'name': 'Pet Supplies',
          'description': 'Pet food, toys, and accessories',
          'isActive': true,
        },

        // Baby & Kids
        {
          'name': 'Baby & Kids',
          'description': 'Baby products, children\'s clothing, and toys',
          'isActive': true,
        },

        // Office & Business
        {
          'name': 'Office & Business',
          'description':
              'Office supplies, business equipment, and professional tools',
          'isActive': true,
        },

        // Art & Crafts
        {
          'name': 'Art & Crafts',
          'description': 'Art supplies, craft materials, and creative tools',
          'isActive': true,
        },

        // Musical Instruments
        {
          'name': 'Musical Instruments',
          'description': 'Musical instruments and accessories',
          'isActive': true,
        },

        // Food & Beverages
        {
          'name': 'Food & Beverages',
          'description': 'Gourmet foods, beverages, and specialty items',
          'isActive': true,
        },

        // Travel & Tourism
        {
          'name': 'Travel & Tourism',
          'description': 'Travel accessories, luggage, and tourism products',
          'isActive': true,
        },
      ];
}
