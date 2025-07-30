import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  // Initialize Firebase
  await Firebase.initializeApp();

  print('🚀 Starting category upload script...');

  // Categories data
  final List<Map<String, dynamic>> categories = [
    // Fashion & Apparel
    {
      'name': 'Fashion & Apparel',
      'description': 'Clothing, accessories, and fashion items',
      'isActive': true,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    },
    {
      'name': 'Jewelry & Watches',
      'description': 'Jewelry, watches, and luxury accessories',
      'isActive': true,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    },
    {
      'name': 'Beauty & Personal Care',
      'description': 'Cosmetics, skincare, and personal care products',
      'isActive': true,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    },
    {
      'name': 'Footwear',
      'description': 'Shoes, boots, and footwear accessories',
      'isActive': true,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    },
    {
      'name': 'Handbags & Bags',
      'description': 'Bags, purses, and travel accessories',
      'isActive': true,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    },

    // Technology & Electronics
    {
      'name': 'Technology & Electronics',
      'description': 'Electronic devices and gadgets',
      'isActive': true,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    },
    {
      'name': 'Smartphones',
      'description': 'Mobile phones and accessories',
      'isActive': true,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    },
    {
      'name': 'Computers & Laptops',
      'description': 'Computers, laptops, and peripherals',
      'isActive': true,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    },
    {
      'name': 'Gaming',
      'description': 'Gaming consoles, games, and accessories',
      'isActive': true,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    },
    {
      'name': 'Audio & Music',
      'description': 'Headphones, speakers, and audio equipment',
      'isActive': true,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    },
    {
      'name': 'Cameras & Photography',
      'description': 'Cameras, lenses, and photography equipment',
      'isActive': true,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    },

    // Home & Living
    {
      'name': 'Home & Living',
      'description': 'Home decor, furniture, and household items',
      'isActive': true,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    },
    {
      'name': 'Kitchen & Dining',
      'description': 'Kitchen appliances and dining accessories',
      'isActive': true,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    },
    {
      'name': 'Garden & Outdoor',
      'description': 'Gardening tools and outdoor equipment',
      'isActive': true,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    },

    // Sports & Fitness
    {
      'name': 'Sports & Fitness',
      'description': 'Sports equipment, fitness gear, and athletic wear',
      'isActive': true,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    },
    {
      'name': 'Outdoor Recreation',
      'description': 'Camping, hiking, and outdoor adventure gear',
      'isActive': true,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    },

    // Automotive
    {
      'name': 'Automotive',
      'description': 'Car parts, accessories, and automotive products',
      'isActive': true,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    },

    // Books & Media
    {
      'name': 'Books & Media',
      'description': 'Books, magazines, and digital media',
      'isActive': true,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    },

    // Toys & Games
    {
      'name': 'Toys & Games',
      'description': 'Toys, board games, and entertainment products',
      'isActive': true,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    },

    // Health & Wellness
    {
      'name': 'Health & Wellness',
      'description':
          'Health supplements, medical devices, and wellness products',
      'isActive': true,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    },

    // Pet Supplies
    {
      'name': 'Pet Supplies',
      'description': 'Pet food, toys, and accessories',
      'isActive': true,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    },

    // Baby & Kids
    {
      'name': 'Baby & Kids',
      'description': 'Baby products, children\'s clothing, and toys',
      'isActive': true,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    },

    // Office & Business
    {
      'name': 'Office & Business',
      'description':
          'Office supplies, business equipment, and professional tools',
      'isActive': true,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    },

    // Art & Crafts
    {
      'name': 'Art & Crafts',
      'description': 'Art supplies, craft materials, and creative tools',
      'isActive': true,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    },

    // Musical Instruments
    {
      'name': 'Musical Instruments',
      'description': 'Musical instruments and accessories',
      'isActive': true,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    },

    // Food & Beverages
    {
      'name': 'Food & Beverages',
      'description': 'Gourmet foods, beverages, and specialty items',
      'isActive': true,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    },

    // Travel & Tourism
    {
      'name': 'Travel & Tourism',
      'description': 'Travel accessories, luggage, and tourism products',
      'isActive': true,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    },
  ];

  try {
    // Get Firestore instance
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    // Reference to the agent_categories collection
    final CollectionReference categoriesCollection =
        firestore.collection('agent_categories');

    print('📝 Uploading ${categories.length} categories to Firestore...');

    // Upload each category
    for (int i = 0; i < categories.length; i++) {
      final category = categories[i];
      final categoryName = category['name'] as String;

      print(
          '📤 Uploading category ${i + 1}/${categories.length}: $categoryName');

      // Add document to Firestore
      await categoriesCollection.add(category);

      print('✅ Successfully uploaded: $categoryName');
    }

    print('🎉 All categories uploaded successfully!');
    print('📊 Total categories uploaded: ${categories.length}');
  } catch (e) {
    print('❌ Error uploading categories: $e');
    exit(1);
  }

  print('🏁 Script completed successfully!');
  exit(0);
}
