import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/entities/lookbook.dart';
import '../../domain/entities/product.dart';
import '../../data/datasources/lookbook_firestore_service.dart';

// Events
abstract class LookbookEvent extends Equatable {
  const LookbookEvent();

  @override
  List<Object?> get props => [];
}

class FetchLookbooksEvent extends LookbookEvent {}

class CreateLookbookEvent extends LookbookEvent {
  final String name;
  final String? description;
  final List<Product> selectedProducts;

  const CreateLookbookEvent({
    required this.name,
    this.description,
    required this.selectedProducts,
  });

  @override
  List<Object?> get props => [name, description, selectedProducts];
}

class DeleteLookbookEvent extends LookbookEvent {
  final String lookbookId;

  const DeleteLookbookEvent(this.lookbookId);

  @override
  List<Object> get props => [lookbookId];
}

class SearchLookbooksEvent extends LookbookEvent {
  final String query;

  const SearchLookbooksEvent(this.query);

  @override
  List<Object> get props => [query];
}

class FetchProductsEvent extends LookbookEvent {
  final String? lookbookId;

  const FetchProductsEvent({this.lookbookId});

  @override
  List<Object?> get props => [lookbookId];
}

class AddProductEvent extends LookbookEvent {
  final Product product;

  const AddProductEvent(this.product);

  @override
  List<Object> get props => [product];
}

class AddBulkProductsEvent extends LookbookEvent {
  final List<Product> products;

  const AddBulkProductsEvent(this.products);

  @override
  List<Object> get props => [products];
}

class UpdateProductStockEvent extends LookbookEvent {
  final String productId;
  final int newStock;

  const UpdateProductStockEvent({
    required this.productId,
    required this.newStock,
  });

  @override
  List<Object> get props => [productId, newStock];
}

class DeleteProductEvent extends LookbookEvent {
  final String productId;

  const DeleteProductEvent(this.productId);

  @override
  List<Object> get props => [productId];
}

class FetchAgentProductsEvent extends LookbookEvent {
  final String agentId;
  final String? lookbookId;
  final int? limit;

  const FetchAgentProductsEvent({
    required this.agentId,
    this.lookbookId,
    this.limit,
  });

  @override
  List<Object?> get props => [agentId, lookbookId, limit];
}

class UploadCsvToAgentEvent extends LookbookEvent {
  final String agentId;
  final List<Product> products;

  const UploadCsvToAgentEvent({
    required this.agentId,
    required this.products,
  });

  @override
  List<Object> get props => [agentId, products];
}

// States
abstract class LookbookState extends Equatable {
  const LookbookState();

  @override
  List<Object?> get props => [];
}

class LookbookInitial extends LookbookState {}

class LookbookLoading extends LookbookState {}

class LookbookLoaded extends LookbookState {
  final List<Lookbook> lookbooks;

  const LookbookLoaded(this.lookbooks);

  @override
  List<Object> get props => [lookbooks];
}

class LookbookError extends LookbookState {
  final String message;

  const LookbookError(this.message);

  @override
  List<Object> get props => [message];
}

class ProductsLoaded extends LookbookState {
  final List<Product> products;

  const ProductsLoaded(this.products);

  @override
  List<Object> get props => [products];
}

class LookbookCreated extends LookbookState {
  final Lookbook lookbook;

  const LookbookCreated(this.lookbook);

  @override
  List<Object> get props => [lookbook];
}

class ProductAdded extends LookbookState {
  final Product product;

  const ProductAdded(this.product);

  @override
  List<Object> get props => [product];
}

class AgentProductsLoaded extends LookbookState {
  final List<Product> products;
  final String agentId;

  const AgentProductsLoaded({
    required this.products,
    required this.agentId,
  });

  @override
  List<Object> get props => [products, agentId];
}

class CsvUploadResult extends LookbookState {
  final Map<String, dynamic> result;

  const CsvUploadResult(this.result);

  @override
  List<Object> get props => [result];
}

// BLoC
class LookbookBloc extends Bloc<LookbookEvent, LookbookState> {
  final LookbookFirestoreService _firestoreService = LookbookFirestoreService();
  List<Lookbook> _allLookbooks = [];

  LookbookBloc() : super(LookbookInitial()) {
    on<FetchLookbooksEvent>(_onFetchLookbooks);
    on<CreateLookbookEvent>(_onCreateLookbook);
    on<DeleteLookbookEvent>(_onDeleteLookbook);
    on<SearchLookbooksEvent>(_onSearchLookbooks);
    on<FetchProductsEvent>(_onFetchProducts);
    on<AddProductEvent>(_onAddProduct);
    on<AddBulkProductsEvent>(_onAddBulkProducts);
    on<UpdateProductStockEvent>(_onUpdateProductStock);
    on<DeleteProductEvent>(_onDeleteProduct);
    on<FetchAgentProductsEvent>(_onFetchAgentProducts);
    on<UploadCsvToAgentEvent>(_onUploadCsvToAgent);
  }

  Future<void> _onFetchLookbooks(
    FetchLookbooksEvent event,
    Emitter<LookbookState> emit,
  ) async {
    try {
      emit(LookbookLoading());

      // Get current user's hushhId from Firebase Auth
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        emit(LookbookError('User not authenticated'));
        return;
      }
      final hushhId = currentUser.uid;

      final lookbooks = await _firestoreService.getLookbooks(hushhId);
      _allLookbooks = lookbooks;

      emit(LookbookLoaded(lookbooks));
    } catch (e) {
      emit(LookbookError('Failed to fetch lookbooks: ${e.toString()}'));
    }
  }

  Future<void> _onCreateLookbook(
    CreateLookbookEvent event,
    Emitter<LookbookState> emit,
  ) async {
    try {
      emit(LookbookLoading());

      // Get current user's hushhId from Firebase Auth
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        emit(LookbookError('User not authenticated'));
        return;
      }
      final hushhId = currentUser.uid;

      final lookbook = await _firestoreService.createLookbook(
        name: event.name,
        description: event.description,
        hushhId: hushhId,
        selectedProducts: event.selectedProducts,
      );

      // Update local list
      _allLookbooks.add(lookbook);

      emit(LookbookCreated(lookbook));
      emit(LookbookLoaded(_allLookbooks));
    } catch (e) {
      emit(LookbookError('Failed to create lookbook: ${e.toString()}'));
    }
  }

  Future<void> _onDeleteLookbook(
    DeleteLookbookEvent event,
    Emitter<LookbookState> emit,
  ) async {
    try {
      emit(LookbookLoading());

      await _firestoreService.deleteLookbook(event.lookbookId);

      // Update local list
      _allLookbooks.removeWhere((lookbook) => lookbook.id == event.lookbookId);

      emit(LookbookLoaded(_allLookbooks));
    } catch (e) {
      emit(LookbookError('Failed to delete lookbook: ${e.toString()}'));
    }
  }

  Future<void> _onSearchLookbooks(
    SearchLookbooksEvent event,
    Emitter<LookbookState> emit,
  ) async {
    if (event.query.isEmpty) {
      emit(LookbookLoaded(_allLookbooks));
      return;
    }

    final filteredLookbooks = _allLookbooks
        .where((lookbook) =>
            lookbook.name.toLowerCase().contains(event.query.toLowerCase()) ||
            (lookbook.description
                    ?.toLowerCase()
                    .contains(event.query.toLowerCase()) ??
                false))
        .toList();

    emit(LookbookLoaded(filteredLookbooks));
  }

  Future<void> _onFetchProducts(
    FetchProductsEvent event,
    Emitter<LookbookState> emit,
  ) async {
    try {
      emit(LookbookLoading());

      // Get current user's hushhId from Firebase Auth
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        emit(LookbookError('User not authenticated'));
        return;
      }
      final hushhId = currentUser.uid;

      final products = await _firestoreService.getProducts(
        hushhId: hushhId,
        lookbookId: event.lookbookId,
      );

      emit(ProductsLoaded(products));
    } catch (e) {
      emit(LookbookError('Failed to fetch products: ${e.toString()}'));
    }
  }

  Future<void> _onAddProduct(
    AddProductEvent event,
    Emitter<LookbookState> emit,
  ) async {
    try {
      emit(LookbookLoading());

      final product = await _firestoreService.addProduct(event.product);

      emit(ProductAdded(product));
    } catch (e) {
      emit(LookbookError('Failed to add product: ${e.toString()}'));
    }
  }

  Future<void> _onAddBulkProducts(
    AddBulkProductsEvent event,
    Emitter<LookbookState> emit,
  ) async {
    try {
      emit(LookbookLoading());

      await _firestoreService.addBulkProducts(event.products);

      // Refresh products list
      add(const FetchProductsEvent());
    } catch (e) {
      emit(LookbookError('Failed to add products: ${e.toString()}'));
    }
  }

  Future<void> _onUpdateProductStock(
    UpdateProductStockEvent event,
    Emitter<LookbookState> emit,
  ) async {
    try {
      emit(LookbookLoading());

      // Get current user's hushhId from Firebase Auth
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        emit(LookbookError('User not authenticated'));
        return;
      }

      // Get the current product from Firestore to ensure we have the latest data
      final products = await _firestoreService.getProducts(
        hushhId: currentUser.uid,
      );

      final product = products.firstWhere(
        (product) => product.productId == event.productId,
        orElse: () => throw Exception('Product not found'),
      );

      final updatedProduct = product.copyWith(stockQuantity: event.newStock);

      // Update in Firestore
      await _firestoreService.updateProduct(updatedProduct);

      // Refresh the products list
      final updatedProducts = await _firestoreService.getProducts(
        hushhId: currentUser.uid,
      );

      emit(ProductsLoaded(updatedProducts));
    } catch (e) {
      emit(LookbookError('Failed to update product stock: ${e.toString()}'));
    }
  }

  Future<void> _onDeleteProduct(
    DeleteProductEvent event,
    Emitter<LookbookState> emit,
  ) async {
    try {
      emit(LookbookLoading());

      // Get current user's hushhId from Firebase Auth
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        emit(LookbookError('User not authenticated'));
        return;
      }

      // Delete from Firestore
      await _firestoreService.deleteProduct(event.productId);

      // Refresh the products list
      final updatedProducts = await _firestoreService.getProducts(
        hushhId: currentUser.uid,
      );

      emit(ProductsLoaded(updatedProducts));
    } catch (e) {
      emit(LookbookError('Failed to delete product: ${e.toString()}'));
    }
  }

  Future<void> _onFetchAgentProducts(
    FetchAgentProductsEvent event,
    Emitter<LookbookState> emit,
  ) async {
    try {
      emit(LookbookLoading());

      final products = await _firestoreService.getAgentProducts(
        agentId: event.agentId,
        lookbookId: event.lookbookId,
        limit: event.limit,
      );

      emit(AgentProductsLoaded(products: products, agentId: event.agentId));
    } catch (e) {
      emit(LookbookError('Failed to fetch agent products: ${e.toString()}'));
    }
  }

  Future<void> _onUploadCsvToAgent(
    UploadCsvToAgentEvent event,
    Emitter<LookbookState> emit,
  ) async {
    try {
      emit(LookbookLoading());

      final result = await _firestoreService.uploadCsvProductsToAgent(
        agentId: event.agentId,
        products: event.products,
      );

      emit(CsvUploadResult(result));
    } catch (e) {
      emit(LookbookError('Failed to upload CSV to agent: ${e.toString()}'));
    }
  }
}
