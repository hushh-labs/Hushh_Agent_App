const admin = require('firebase-admin');

// Initialize Firebase Admin SDK
// You'll need to download your service account key from Firebase Console
// and place it in the project root as 'serviceAccountKey.json'
const serviceAccount = require('./serviceAccountKey.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const db = admin.firestore();

// Categories data
const categories = [
  // Fashion & Apparel
  {
    name: 'Fashion & Apparel',
    description: 'Clothing, accessories, and fashion items',
    isActive: true,
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
  },
  {
    name: 'Jewelry & Watches',
    description: 'Jewelry, watches, and luxury accessories',
    isActive: true,
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
  },
  {
    name: 'Beauty & Personal Care',
    description: 'Cosmetics, skincare, and personal care products',
    isActive: true,
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
  },
  {
    name: 'Footwear',
    description: 'Shoes, boots, and footwear accessories',
    isActive: true,
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
  },
  {
    name: 'Handbags & Bags',
    description: 'Bags, purses, and travel accessories',
    isActive: true,
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
  },
  
  // Technology & Electronics
  {
    name: 'Technology & Electronics',
    description: 'Electronic devices and gadgets',
    isActive: true,
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
  },
  {
    name: 'Smartphones',
    description: 'Mobile phones and accessories',
    isActive: true,
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
  },
  {
    name: 'Computers & Laptops',
    description: 'Computers, laptops, and peripherals',
    isActive: true,
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
  },
  {
    name: 'Gaming',
    description: 'Gaming consoles, games, and accessories',
    isActive: true,
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
  },
  {
    name: 'Audio & Music',
    description: 'Headphones, speakers, and audio equipment',
    isActive: true,
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
  },
  {
    name: 'Cameras & Photography',
    description: 'Cameras, lenses, and photography equipment',
    isActive: true,
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
  },
  
  // Home & Living
  {
    name: 'Home & Living',
    description: 'Home decor, furniture, and household items',
    isActive: true,
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
  },
  {
    name: 'Kitchen & Dining',
    description: 'Kitchen appliances and dining accessories',
    isActive: true,
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
  },
  {
    name: 'Garden & Outdoor',
    description: 'Gardening tools and outdoor equipment',
    isActive: true,
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
  },
  
  // Sports & Fitness
  {
    name: 'Sports & Fitness',
    description: 'Sports equipment, fitness gear, and athletic wear',
    isActive: true,
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
  },
  {
    name: 'Outdoor Recreation',
    description: 'Camping, hiking, and outdoor adventure gear',
    isActive: true,
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
  },
  
  // Automotive
  {
    name: 'Automotive',
    description: 'Car parts, accessories, and automotive products',
    isActive: true,
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
  },
  
  // Books & Media
  {
    name: 'Books & Media',
    description: 'Books, magazines, and digital media',
    isActive: true,
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
  },
  
  // Toys & Games
  {
    name: 'Toys & Games',
    description: 'Toys, board games, and entertainment products',
    isActive: true,
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
  },
  
  // Health & Wellness
  {
    name: 'Health & Wellness',
    description: 'Health supplements, medical devices, and wellness products',
    isActive: true,
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
  },
  
  // Pet Supplies
  {
    name: 'Pet Supplies',
    description: 'Pet food, toys, and accessories',
    isActive: true,
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
  },
  
  // Baby & Kids
  {
    name: 'Baby & Kids',
    description: 'Baby products, children\'s clothing, and toys',
    isActive: true,
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
  },
  
  // Office & Business
  {
    name: 'Office & Business',
    description: 'Office supplies, business equipment, and professional tools',
    isActive: true,
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
  },
  
  // Art & Crafts
  {
    name: 'Art & Crafts',
    description: 'Art supplies, craft materials, and creative tools',
    isActive: true,
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
  },
  
  // Musical Instruments
  {
    name: 'Musical Instruments',
    description: 'Musical instruments and accessories',
    isActive: true,
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
  },
  
  // Food & Beverages
  {
    name: 'Food & Beverages',
    description: 'Gourmet foods, beverages, and specialty items',
    isActive: true,
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
  },
  
  // Travel & Tourism
  {
    name: 'Travel & Tourism',
    description: 'Travel accessories, luggage, and tourism products',
    isActive: true,
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
  },
];

async function uploadCategories() {
  console.log('🚀 Starting category upload script...');
  
  try {
    const categoriesCollection = db.collection('agent_categories');
    
    console.log(`📝 Uploading ${categories.length} categories to Firestore...`);
    
    // Upload each category
    for (let i = 0; i < categories.length; i++) {
      const category = categories[i];
      const categoryName = category.name;
      
      console.log(`📤 Uploading category ${i + 1}/${categories.length}: ${categoryName}`);
      
      // Add document to Firestore
      await categoriesCollection.add(category);
      
      console.log(`✅ Successfully uploaded: ${categoryName}`);
    }
    
    console.log('🎉 All categories uploaded successfully!');
    console.log(`📊 Total categories uploaded: ${categories.length}`);
    
  } catch (error) {
    console.error('❌ Error uploading categories:', error);
    process.exit(1);
  }
  
  console.log('🏁 Script completed successfully!');
  process.exit(0);
}

// Run the upload function
uploadCategories(); 