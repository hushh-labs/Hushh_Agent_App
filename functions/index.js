const functions = require('firebase-functions');
const admin = require('firebase-admin');

// Initialize Firebase Admin SDK
admin.initializeApp();

const db = admin.firestore();
const messaging = admin.messaging();
const rtdb = admin.database(); // Add Realtime Database

/**
 * Simple test function that doesn't require authentication
 */
exports.helloWorld = functions.https.onCall((data, context) => {
  console.log('Hello World function called');
  console.log('Data received:', data);
  console.log('Context auth:', context.auth);
  
  return { 
    message: 'Hello from Firebase Functions!',
    timestamp: new Date().toISOString(),
    data: data,
    authenticated: context.auth ? true : false
  };
});

/**
 * Cloud Function to save agent bid to Realtime Database and send notification
 * This function is triggered by HTTP request
 */
exports.saveAgentBid = functions.https.onCall(async (data, context) => {
    try {
      // Extract data from HTTP request
      const {
        productId,
        productName,
        productPrice,
        agentId,
        agentName,
        userId,
        userName,
        bidAmount,
        quantity = 1
      } = data;

      console.log('Agent bid save requested:', { 
        productId, 
        productName, 
        agentId, 
        agentName,
        userId, 
        userName,
        bidAmount
      });

      // Validate required fields
      if (!agentId || !productId || !userId || !userName || !bidAmount) {
        console.log('Missing required fields, skipping bid save');
        return { success: false, error: 'Missing required fields' };
      }

      // Calculate validity (24 hours from now)
      const now = new Date();
      const validity = new Date(now.getTime() + 24 * 60 * 60 * 1000); // 24 hours from now

      // Create bid data
      const bidData = {
        agentId: agentId,
        agentName: agentName,
        userId: userId,
        userName: userName,
        productId: productId,
        productName: productName,
        productPrice: productPrice,
        bidAmount: bidAmount,
        quantity: quantity,
        status: 'pending', // Default status
        validity: validity.toISOString(),
        createdAt: now.toISOString(),
        updatedAt: now.toISOString()
      };

      // Generate unique bid ID
      const bidId = `bid_${agentId}_${productId}_${Date.now()}`;

      console.log('Saving bid data to Realtime Database:', bidData);

      // Save to Realtime Database under 'bids' node
      await rtdb.ref(`bids/${bidId}`).set(bidData);

      console.log('Bid saved successfully to Realtime Database');

      // Also save to Firestore for backup/querying
      await db.collection('bids').doc(bidId).set(bidData);

      console.log('Bid also saved to Firestore for backup');

      // Send notification to user about the bid
      try {
        console.log('Sending notification to user about the bid...');
        
        // Get user's FCM token
        const userInfo = await getUserFCMToken(userId);
        
        if (userInfo && userInfo.fcmToken) {
          console.log('User FCM token found:', userInfo.fcmToken.substring(0, 20) + '...');

          // Create notification data
          const notificationId = `agent_bid_${agentId}_${productId}_${Date.now()}`;
          const notificationData = {
            notificationId: notificationId,
            type: 'agent_bid',
            userId: userId,
            userName: userName,
            productId: productId,
            productName: productName,
            productPrice: productPrice,
            agentId: agentId,
            agentName: agentName,
            bidAmount: bidAmount,
            quantity: quantity,
            timestamp: now.toISOString(),
            action: 'view_bid',
            expiresAt: validity.toISOString(),
            showBidDetails: 'true'
          };

          // Create notification message
          const notificationMessage = `${agentName} has offered you ${bidAmount} hushh coins for ${productName}! Valid for 24 hours and automatically applied at checkout.`;

          console.log('Sending bid notification message:', notificationMessage);

          // Send FCM notification
          const message = {
            token: userInfo.fcmToken,
            notification: {
              title: 'Hushh Coins Offer!',
              body: notificationMessage,
            },
            data: {
              notificationId: notificationId,
              type: 'agent_bid',
              userId: userId,
              userName: userName,
              productId: productId,
              productName: productName,
              productPrice: productPrice.toString(),
              agentId: agentId,
              agentName: agentName,
              bidAmount: bidAmount.toString(),
              quantity: quantity.toString(),
              timestamp: notificationData.timestamp,
              action: 'view_bid',
              expiresAt: notificationData.expiresAt,
              showBidDetails: 'true'
            },
            android: {
              notification: {
                channelId: 'bid_notifications',
                priority: 'high',
                defaultSound: true,
                defaultVibrateTimings: true,
                icon: 'ic_notification',
                color: '#FFD700'
              },
              data: {
                notificationId: notificationId,
                type: 'agent_bid',
                userId: userId,
                userName: userName,
                productId: productId,
                productName: productName,
                productPrice: productPrice.toString(),
                agentId: agentId,
                agentName: agentName,
                bidAmount: bidAmount.toString(),
                quantity: quantity.toString(),
                timestamp: notificationData.timestamp,
                action: 'view_bid',
                expiresAt: notificationData.expiresAt,
                showBidDetails: 'true'
              }
            },
            apns: {
              payload: {
                aps: {
                  alert: {
                    title: 'Hushh Coins Offer!',
                    body: notificationMessage
                  },
                  badge: 1,
                  sound: 'default',
                  category: 'bid_notification'
                },
                data: notificationData
              }
            }
          };

          const response = await messaging.send(message);
          console.log('Bid notification sent successfully:', response);
          
        } else {
          console.log('User FCM token not found, skipping notification');
        }
        
      } catch (notificationError) {
        console.error('Error sending bid notification:', notificationError);
        // Don't fail the entire operation if notification fails
        console.log('Continuing with bid save despite notification error');
      }

      return { 
        success: true, 
        bidId: bidId,
        message: 'Bid saved successfully and notification sent',
        data: bidData
      };

    } catch (error) {
      console.error('Error saving agent bid:', error);
      throw new functions.https.HttpsError(
        'internal',
        'Failed to save agent bid',
        error
      );
    }
  });

/**
 * Cloud Function to send notifications to agents when their items are added to cart
 * This function is triggered by HTTP request
 */
exports.sendCartItemNotification = functions.https.onCall(async (data, context) => {
    try {
      // Check if user is authenticated (optional for now)
      if (context.auth) {
        console.log('Authenticated user:', context.auth.uid);
      } else {
        console.log('No authentication context - proceeding with data validation');
      }

      // Extract data from HTTP request
      const {
        productId,
        productName,
        productPrice,
        productImage,
        agentId,
        agentName,
        userId,
        userName,
        quantity = 1
      } = data;

      console.log('Cart item notification requested:', { 
        productId, 
        productName, 
        agentId, 
        userId, 
        userName 
      });

      if (!agentId || !productId) {
        console.log('Missing agentId or productId, skipping notification');
        return { success: false, error: 'Missing agentId or productId' };
      }

      // Validate required fields
      if (!agentId || !productId || !userId || !userName) {
        console.log('Missing required fields, skipping notification');
        return { success: false, error: 'Missing required fields' };
      }

      // Get agent's FCM token and full name
      const agentInfo = await getAgentFCMToken(agentId);
      
      if (!agentInfo || !agentInfo.fcmToken) {
        console.log('Agent FCM token not found:', agentId);
        return { success: false, error: 'Agent FCM token not found' };
      }

      console.log('Agent FCM token found:', agentInfo.fcmToken.substring(0, 20) + '...');
      console.log('Agent full name:', agentInfo.fullName);

      // Create notification data with unique ID
      const notificationId = `cart_item_added_${userId}_${productId}_${Date.now()}`;
      const notificationData = {
        notificationId: notificationId,
        type: 'cart_item_added',
        userId: userId,
        userName: userName,
        productId: productId,
        productName: productName,
        productPrice: productPrice,
        quantity: quantity,
        agentId: agentId,
        agentName: agentInfo.fullName,
        timestamp: new Date().toISOString(),
        action: 'view_cart'
      };

      // Create notification message with new format
      const notificationMessage = `${userName} just added ${productName} to their cart. Tap to start bidding Hushh Coins!`;

      console.log('Sending notification message:', notificationMessage);

      // Send FCM notification
      const message = {
        token: agentInfo.fcmToken,
        notification: {
          title: 'New Item Added to Cart',
          body: notificationMessage,
        },
        data: {
          notificationId: notificationId,
          type: 'cart_item_added',
          userId: userId,
          userName: userName,
          productId: productId,
          productName: productName,
          productPrice: productPrice.toString(),
          quantity: quantity.toString(),
          agentId: agentId,
          agentName: agentInfo.fullName,
          timestamp: notificationData.timestamp,
          action: 'view_cart',
          showBiddingInterface: 'true'
        },
        android: {
          notification: {
            channelId: 'cart_notifications',
            priority: 'high',
            defaultSound: true,
            defaultVibrateTimings: true,
            icon: 'ic_notification',
            color: '#FF6B35'
          },
          data: {
            notificationId: notificationId,
            type: 'cart_item_added',
            userId: userId,
            userName: userName,
            productId: productId,
            productName: productName,
            productPrice: productPrice.toString(),
            quantity: quantity.toString(),
            agentId: agentId,
            agentName: agentInfo.fullName,
            timestamp: notificationData.timestamp,
            action: 'view_cart',
            showBiddingInterface: 'true'
          }
        },
        apns: {
          payload: {
            aps: {
              alert: {
                title: 'New Item Added to Cart',
                body: notificationMessage
              },
              badge: 1,
              sound: 'default',
              category: 'cart_notification'
            },
            data: notificationData
          }
        }
      };

      const response = await messaging.send(message);
      console.log('Notification sent successfully:', response);

      // Store notification in Firestore for the agent
      await storeNotificationForAgent(agentId, notificationData);

      return { success: true, notificationId: notificationId };

    } catch (error) {
      console.error('Error sending cart item notification:', error);
      throw new functions.https.HttpsError(
        'internal',
        'Failed to send cart item notification',
        error
      );
    }
  });

/**
 * Helper function to get agent's FCM token and full name from Firestore
 */
async function getAgentFCMToken(agentId) {
  try {
    const agentDoc = await db.collection('Hushhagents').doc(agentId).get();
    
    if (!agentDoc.exists) {
      console.log('Agent document not found:', agentId);
      return null;
    }

    const agentData = agentDoc.data();
    return {
      fcmToken: agentData.fcm_token || null,
      fullName: agentData.fullname || agentData.fullName || 'Agent'
    };
  } catch (error) {
    console.error('Error getting agent FCM token:', error);
    return null;
  }
}

/**
 * Helper function to get user's FCM token from Firestore
 * Users are stored in HushUsers collection
 */
async function getUserFCMToken(userId) {
  try {
    console.log('🔍 [DEBUG] Looking for user FCM token for userId:', userId);
    
    const userDoc = await db.collection('HushUsers').doc(userId).get();
    
    if (!userDoc.exists) {
      console.log('❌ [DEBUG] User document not found in HushUsers collection:', userId);
      return null;
    }

    const userData = userDoc.data();
    console.log('✅ [DEBUG] User found in HushUsers collection');
    console.log('🔍 [DEBUG] User data keys:', Object.keys(userData));
    
    const fcmToken = userData.fcm_token || null;
    
    if (fcmToken) {
      console.log('✅ [DEBUG] FCM token found:', fcmToken.substring(0, 20) + '...');
      return {
        fcmToken: fcmToken,
        fullName: userData.fullname || userData.fullName || userData.name || 'User'
      };
    } else {
      console.log('⚠️ [DEBUG] No FCM token found for user:', userId);
      return null;
    }
  } catch (error) {
    console.error('❌ [DEBUG] Error getting user FCM token:', error);
    return null;
  }
}

/**
 * Helper function to store notification in Firestore for the agent
 */
async function storeNotificationForAgent(agentId, notificationData) {
  try {
    const notificationRef = db
      .collection('HushhAgents')
      .doc(agentId)
      .collection('notifications')
      .doc();

    const notification = {
      id: notificationRef.id,
      title: 'New Item Added to Cart',
      body: `${notificationData.productName} has been added to a customer's cart`,
      type: 'cart_item_added',
      priority: 'high',
      isRead: false,
      createdAt: new Date(),
      data: notificationData
    };

    await notificationRef.set(notification);
    console.log('Notification stored for agent:', agentId);
  } catch (error) {
    console.error('Error storing notification for agent:', error);
  }
}

 