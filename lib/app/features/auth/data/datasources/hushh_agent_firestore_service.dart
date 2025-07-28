import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/hushh_agent_model.dart';

class HushhAgentFirestoreService {
  static const String _collectionName = 'Hushhagents';
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Get collection reference
  CollectionReference<HushhAgentModel> get _collection {
    return _firestore.collection(_collectionName).withConverter<HushhAgentModel>(
      fromFirestore: (snapshot, options) => HushhAgentModel.fromFirestore(snapshot, options),
      toFirestore: (agent, options) => agent.toFirestore(),
    );
  }

  /// Create or update agent record
  Future<HushhAgentModel> createOrUpdateAgent({
    String? phone,
    String? email,
    String? fullName,
  }) async {
    try {
      if (phone == null && email == null) {
        throw Exception('Either phone or email must be provided');
      }

      print('🔥 [Firestore] Creating/updating agent for phone: $phone, email: $email');

      QuerySnapshot<HushhAgentModel>? existingAgentQuery;

      // Check if agent already exists by phone number or email
      if (phone != null && phone.isNotEmpty) {
        existingAgentQuery = await _collection
            .where('phone', isEqualTo: phone)
            .limit(1)
            .get();
      } else if (email != null && email.isNotEmpty) {
        existingAgentQuery = await _collection
            .where('email', isEqualTo: email)
            .limit(1)
            .get();
      }

      if (existingAgentQuery != null && existingAgentQuery.docs.isNotEmpty) {
        // Update existing agent
        final existingDoc = existingAgentQuery.docs.first;
        final existingAgent = existingDoc.data();
        
        final updatedAgent = existingAgent.copyWith(
          phone: phone ?? existingAgent.phone,
          email: email ?? existingAgent.email,
          fullName: fullName ?? existingAgent.fullName,
          isActive: true,
          updatedAt: DateTime.now(),
        );

        await existingDoc.reference.update(updatedAgent.toFirestore());
        
        print('✅ [Firestore] Agent updated successfully: ${existingDoc.id}');
        return updatedAgent.copyWith(id: existingDoc.id);
      } else {
        // Create new agent
        final newAgent = HushhAgentModel.create(
          phone: phone ?? '',
          email: email,
          fullName: fullName,
        );

        final docRef = await _collection.add(newAgent);
        
        print('✅ [Firestore] New agent created successfully: ${docRef.id}');
        return newAgent.copyWith(id: docRef.id);
      }
    } catch (e) {
      print('❌ [Firestore] Error creating/updating agent: $e');
      rethrow;
    }
  }

  /// Get agent by phone number
  Future<HushhAgentModel?> getAgentByPhone(String phone) async {
    try {
      print('🔍 [Firestore] Searching for agent with phone: $phone');

      final querySnapshot = await _collection
          .where('phone', isEqualTo: phone)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final doc = querySnapshot.docs.first;
        final agent = doc.data().copyWith(id: doc.id);
        print('✅ [Firestore] Agent found: ${agent.agentId}');
        return agent;
      } else {
        print('ℹ️ [Firestore] No agent found with phone: $phone');
        return null;
      }
    } catch (e) {
      print('❌ [Firestore] Error getting agent by phone: $e');
      rethrow;
    }
  }

  /// Get agent by ID
  Future<HushhAgentModel?> getAgentById(String id) async {
    try {
      print('🔍 [Firestore] Getting agent by ID: $id');

      final docSnapshot = await _collection.doc(id).get();

      if (docSnapshot.exists) {
        final agent = docSnapshot.data()!.copyWith(id: docSnapshot.id);
        print('✅ [Firestore] Agent found: ${agent.agentId}');
        return agent;
      } else {
        print('ℹ️ [Firestore] No agent found with ID: $id');
        return null;
      }
    } catch (e) {
      print('❌ [Firestore] Error getting agent by ID: $e');
      rethrow;
    }
  }

  /// Update agent login status
  Future<void> updateAgentLoginStatus(String agentId, bool isActive) async {
    try {
      print('🔄 [Firestore] Updating login status for agent: $agentId');

      final querySnapshot = await _collection
          .where('agentId', isEqualTo: agentId)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final doc = querySnapshot.docs.first;
        await doc.reference.update({
          'isActive': isActive,
          'updatedAt': Timestamp.fromDate(DateTime.now()),
        });
        
        print('✅ [Firestore] Agent login status updated: $isActive');
      }
    } catch (e) {
      print('❌ [Firestore] Error updating agent login status: $e');
      rethrow;
    }
  }

  /// Update agent email
  Future<void> updateAgentEmail(String agentId, String email) async {
    try {
      print('🔄 [Firestore] Updating email for agent: $agentId');

      final querySnapshot = await _collection
          .where('agentId', isEqualTo: agentId)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final doc = querySnapshot.docs.first;
        await doc.reference.update({
          'email': email,
          'updatedAt': Timestamp.fromDate(DateTime.now()),
        });
        
        print('✅ [Firestore] Agent email updated successfully');
      }
    } catch (e) {
      print('❌ [Firestore] Error updating agent email: $e');
      rethrow;
    }
  }

  /// Initialize collection (create if doesn't exist)
  Future<void> initializeCollection() async {
    try {
      print('🚀 [Firestore] Initializing Hushhagents collection...');
      
      // Check if collection exists by trying to get documents
      final snapshot = await _collection.limit(1).get();
      
      if (snapshot.docs.isEmpty) {
        print('ℹ️ [Firestore] Collection is empty, it will be created when first document is added');
      } else {
        print('✅ [Firestore] Hushhagents collection already exists');
      }
    } catch (e) {
      print('❌ [Firestore] Error initializing collection: $e');
      rethrow;
    }
  }
} 