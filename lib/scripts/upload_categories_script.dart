import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import '../firebase_options.dart';

// Categories feature dependencies
import '../app/features/categories/di/category_injection.dart';
import '../app/features/categories/domain/usecases/upload_categories_usecase.dart';
import '../shared/domain/usecases/base_usecase.dart';

/// Command-line script to upload categories using clean architecture
void main() async {
  print('🚀 Starting Categories Upload Script...');
  print('📁 Using Clean Architecture Pattern');

  try {
    // Initialize Firebase
    print('🔥 Initializing Firebase...');
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('✅ Firebase initialized successfully!');

    // Initialize dependencies
    print('🔧 Setting up dependencies...');
    await initializeCategoryFeature();
    print('✅ Dependencies initialized successfully!');

    // Get upload use case
    final uploadCategoriesUseCase = sl<UploadCategoriesUseCase>();

    // Prepare categories data
    final categories = DefaultCategoriesData.categories;
    print('📝 Prepared ${categories.length} categories for upload');

    // Upload categories
    print('📤 Starting upload...');
    final params = UploadCategoriesParams(categories: categories);
    final result = await uploadCategoriesUseCase.call(params);

    // Handle result
    switch (result) {
      case Success<bool>():
        print('🎉 Categories uploaded successfully!');
        print('📊 Total categories uploaded: ${categories.length}');
        break;
      case Failed<bool>():
        print('❌ Upload failed: ${result.failure.message}');
        exit(1);
    }
  } catch (e) {
    print('❌ Unexpected error: $e');
    exit(1);
  }

  print('🏁 Script completed successfully!');
  exit(0);
}
