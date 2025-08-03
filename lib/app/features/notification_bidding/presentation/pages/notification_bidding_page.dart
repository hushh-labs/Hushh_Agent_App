import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:io';
import '../bloc/notification_bidding_bloc.dart';
import '../../data/datasources/fcm_service.dart';
import '../../data/datasources/notification_handler_service.dart';

class NotificationBiddingPage extends StatefulWidget {
  const NotificationBiddingPage({Key? key}) : super(key: key);

  @override
  State<NotificationBiddingPage> createState() =>
      _NotificationBiddingPageState();
}

class _NotificationBiddingPageState extends State<NotificationBiddingPage> {
  late NotificationBiddingBloc _bloc;
  late FcmService _fcmService;
  String? _currentToken;
  String _platform = '';

  @override
  void initState() {
    super.initState();
    _bloc = context.read<NotificationBiddingBloc>();
    _fcmService = FcmService();

    // Determine platform
    if (Platform.isIOS) {
      _platform = 'ios';
    } else if (Platform.isAndroid) {
      _platform = 'android';
    } else {
      _platform = 'web';
    }

    // Initialize FCM token
    _bloc.add(InitializeFcmTokenEvent(_platform));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification Bidding'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: BlocListener<NotificationBiddingBloc, NotificationBiddingState>(
        listener: (context, state) {
          if (state is FcmTokenSavedState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content:
                    Text('FCM Token saved successfully for ${state.platform}'),
                backgroundColor: Colors.green,
              ),
            );
            setState(() {
              _currentToken = state.token;
            });
          } else if (state is FcmTokenSaveFailureState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to save FCM token: ${state.message}'),
                backgroundColor: Colors.red,
              ),
            );
          } else if (state is FcmTokenInitializedState) {
            setState(() {
              _currentToken = state.token;
            });
          } else if (state is FcmTokenRetrievedState) {
            setState(() {
              _currentToken = state.fcmToken?.token;
            });
          }
        },
        child: BlocBuilder<NotificationBiddingBloc, NotificationBiddingState>(
          builder: (context, state) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Platform: $_platform',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Current FCM Token:',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              _currentToken ?? 'No token available',
                              style: const TextStyle(
                                fontSize: 12,
                                fontFamily: 'monospace',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Actions',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: state is FcmTokenSavingState
                                  ? null
                                  : () async {
                                      // Get actual FCM token
                                      final token =
                                          await _fcmService.getCurrentToken();
                                      if (token != null) {
                                        _bloc.add(SaveFcmTokenEvent(
                                          token: token,
                                          platform: _platform,
                                        ));
                                      } else {
                                        // Fallback to simulated token
                                        final newToken =
                                            'fcm_token_${DateTime.now().millisecondsSinceEpoch}';
                                        _bloc.add(SaveFcmTokenEvent(
                                          token: newToken,
                                          platform: _platform,
                                        ));
                                      }
                                    },
                              child: state is FcmTokenSavingState
                                  ? const CircularProgressIndicator()
                                  : const Text('Save FCM Token'),
                            ),
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: state is FcmTokenGettingState
                                  ? null
                                  : () {
                                      _bloc.add(GetFcmTokenEvent());
                                    },
                              child: state is FcmTokenGettingState
                                  ? const CircularProgressIndicator()
                                  : const Text('Get FCM Token'),
                            ),
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: state is FcmTokenUpdatingState
                                  ? null
                                  : () {
                                      if (_currentToken != null) {
                                        final updatedToken =
                                            'updated_${_currentToken}';
                                        _bloc.add(
                                            UpdateFcmTokenEvent(updatedToken));
                                      }
                                    },
                              child: state is FcmTokenUpdatingState
                                  ? const CircularProgressIndicator()
                                  : const Text('Update FCM Token'),
                            ),
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: state is FcmTokenDeletingState
                                  ? null
                                  : () {
                                      _bloc.add(DeleteFcmTokenEvent());
                                    },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                              ),
                              child: state is FcmTokenDeletingState
                                  ? const CircularProgressIndicator()
                                  : const Text('Delete FCM Token'),
                            ),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                // Test the bidding interface
                                final notificationHandler =
                                    NotificationHandlerService();
                                notificationHandler
                                    .testCartItemAddedNotification();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.purple,
                                foregroundColor: Colors.white,
                              ),
                              child: const Text('Test Bidding Interface'),
                            ),
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                // Test Firebase Cloud Function notification format
                                final notificationHandler =
                                    NotificationHandlerService();
                                notificationHandler
                                    .testFirebaseCloudFunctionNotification();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange,
                                foregroundColor: Colors.white,
                              ),
                              child: const Text(
                                  'Test Firebase Cloud Function Notification'),
                            ),
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                // Test real notification data format
                                final notificationHandler =
                                    NotificationHandlerService();
                                notificationHandler.testRealNotificationData();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                              ),
                              child: const Text('Test Real Notification Data'),
                            ),
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                // Show bidding overlay immediately
                                final notificationHandler =
                                    NotificationHandlerService();
                                notificationHandler.showBiddingOverlayNow();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                              ),
                              child: const Text('Show Bidding Overlay Now'),
                            ),
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                // Test different dialog approach
                                final notificationHandler =
                                    NotificationHandlerService();
                                notificationHandler
                                    .testDialogWithDifferentApproach();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.pink,
                                foregroundColor: Colors.white,
                              ),
                              child:
                                  const Text('Test Different Dialog Approach'),
                            ),
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                // Test real scenario with different UIDs
                                final notificationHandler =
                                    NotificationHandlerService();
                                notificationHandler
                                    .testRealScenarioNotification();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.indigo,
                                foregroundColor: Colors.white,
                              ),
                              child: const Text(
                                  'Test Real Scenario (Different UIDs)'),
                            ),
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                // Debug current user UID
                                final notificationHandler =
                                    NotificationHandlerService();
                                notificationHandler.debugCurrentUserUID();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.grey,
                                foregroundColor: Colors.white,
                              ),
                              child: const Text('Debug Current User UID'),
                            ),
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () async {
                                // Test Firebase Functions connectivity
                                final notificationHandler =
                                    NotificationHandlerService();
                                await notificationHandler
                                    .testFirebaseFunctionsConnectivity();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.teal,
                                foregroundColor: Colors.white,
                              ),
                              child: const Text(
                                  'Test Firebase Functions Connectivity'),
                            ),
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () async {
                                // Test Firebase Functions deployment
                                final notificationHandler =
                                    NotificationHandlerService();
                                await notificationHandler
                                    .testFunctionsDeployment();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.brown,
                                foregroundColor: Colors.white,
                              ),
                              child: const Text(
                                  'Test Firebase Functions Deployment'),
                            ),
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () async {
                                // Test basic Firebase connectivity
                                final notificationHandler =
                                    NotificationHandlerService();
                                await notificationHandler
                                    .testBasicFirebaseConnectivity();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.deepPurple,
                                foregroundColor: Colors.white,
                              ),
                              child: const Text(
                                  'Test Basic Firebase Connectivity'),
                            ),
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () async {
                                // Test iOS-specific Firebase Functions
                                final notificationHandler =
                                    NotificationHandlerService();
                                await notificationHandler
                                    .testIOSFirebaseFunctions();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                foregroundColor: Colors.white,
                              ),
                              child: const Text('Test iOS Firebase Functions'),
                            ),
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () async {
                                // Test simple Firebase Functions call
                                final notificationHandler =
                                    NotificationHandlerService();
                                await notificationHandler
                                    .testSimpleFunctionCall();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.cyan,
                                foregroundColor: Colors.white,
                              ),
                              child: const Text('Test Simple Function Call'),
                            ),
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () async {
                                // Test the new saveAgentBid function
                                final notificationHandler =
                                    NotificationHandlerService();
                                await notificationHandler.testSaveAgentBid();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.deepOrange,
                                foregroundColor: Colors.white,
                              ),
                              child: const Text('Test Save Agent Bid'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Status',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          _buildStatusWidget(state),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildStatusWidget(NotificationBiddingState state) {
    if (state is FcmTokenInitializingState) {
      return const Row(
        children: [
          CircularProgressIndicator(),
          SizedBox(width: 8),
          Text('Initializing FCM token...'),
        ],
      );
    } else if (state is FcmTokenSavingState) {
      return const Row(
        children: [
          CircularProgressIndicator(),
          SizedBox(width: 8),
          Text('Saving FCM token...'),
        ],
      );
    } else if (state is FcmTokenGettingState) {
      return const Row(
        children: [
          CircularProgressIndicator(),
          SizedBox(width: 8),
          Text('Getting FCM token...'),
        ],
      );
    } else if (state is FcmTokenUpdatingState) {
      return const Row(
        children: [
          CircularProgressIndicator(),
          SizedBox(width: 8),
          Text('Updating FCM token...'),
        ],
      );
    } else if (state is FcmTokenDeletingState) {
      return const Row(
        children: [
          CircularProgressIndicator(),
          SizedBox(width: 8),
          Text('Deleting FCM token...'),
        ],
      );
    } else if (state is FcmTokenSavedState) {
      return Row(
        children: [
          const Icon(Icons.check_circle, color: Colors.green),
          const SizedBox(width: 8),
          Text('FCM token saved for ${state.platform}'),
        ],
      );
    } else if (state is FcmTokenRetrievedState) {
      return Row(
        children: [
          const Icon(Icons.check_circle, color: Colors.green),
          const SizedBox(width: 8),
          Text('FCM token retrieved: ${state.fcmToken?.token ?? 'None'}'),
        ],
      );
    } else if (state is FcmTokenUpdatedState) {
      return Row(
        children: [
          const Icon(Icons.check_circle, color: Colors.green),
          const SizedBox(width: 8),
          Text('FCM token updated'),
        ],
      );
    } else if (state is FcmTokenDeletedState) {
      return Row(
        children: [
          const Icon(Icons.check_circle, color: Colors.green),
          const SizedBox(width: 8),
          const Text('FCM token deleted'),
        ],
      );
    } else {
      return const Text('Ready');
    }
  }
}
