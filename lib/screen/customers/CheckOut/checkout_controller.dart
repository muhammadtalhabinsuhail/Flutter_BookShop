import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:project/screen/model/checkout_model.dart';
import 'package:project/screen/model/order_tracker_model.dart';
import 'package:project/screen/model/orders_model.dart';
import 'package:project/screen/model/status_history_model.dart';
import 'package:project/screen/model/user_info_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../../model/cart_model.dart';



class CheckoutController {
  static final CollectionReference _checkoutCollection =
  FirebaseFirestore.instance.collection('Checkout');
  static final CollectionReference _userInfoCollection =
  FirebaseFirestore.instance.collection('UserInfo');
  static final CollectionReference _ordersCollection =
  FirebaseFirestore.instance.collection('Orders');
  static final CollectionReference _orderTrackerCollection =
  FirebaseFirestore.instance.collection('OrderTracker');
  static final CollectionReference _statusHistoryCollection =
  FirebaseFirestore.instance.collection('StatusHistory');

  // Get user by email
  static Future<String?> getUserIdByEmail(String email) async {
    try {
      QuerySnapshot userQuery = await FirebaseFirestore.instance
          .collection('User')
          .where('Email', isEqualTo: email)
          .limit(1)
          .get();

      if (userQuery.docs.isNotEmpty) {
        return userQuery.docs.first.id;
      }
      return null;
    } catch (e) {
      print('Error getting user by email: $e');
      return null;
    }
  }

  // Add checkout
  static Future<bool> addCheckout(CheckoutModel checkout) async {
    try {
      await _checkoutCollection.add(checkout.toMap());
      return true;
    } catch (e) {
      print('Error adding checkout: $e');
      return false;
    }
  }

  // Add user info
  static Future<bool> addUserInfo(UserInfoModel userInfo) async {
    try {
      await _userInfoCollection.add(userInfo.toMap());
      return true;
    } catch (e) {
      print('Error adding user info: $e');
      return false;
    }
  }

  // Get checkout items for user
  static Future<List<CheckoutModel>> getCheckoutItems(String userId) async {
    try {
      QuerySnapshot querySnapshot = await _checkoutCollection
          .where('userId', isEqualTo: userId)
          .where('orderStatus', isEqualTo: 'Pending')
          .get();

      return querySnapshot.docs
          .map((doc) => CheckoutModel.fromSnapshot(doc))
          .toList();
    } catch (e) {
      print('Error getting checkout items: $e');
      return [];
    }
  }

  // // Place order - move from checkout to orders
  // static Future<bool> placeOrder(List<CheckoutModel> checkoutItems) async {
  //   try {
  //     WriteBatch batch = FirebaseFirestore.instance.batch();
  //
  //     for (CheckoutModel checkout in checkoutItems) {
  //       // Set consistent timestamp
  //       DateTime now = DateTime.now();
  //       String orderId = 'ORD_${now.millisecondsSinceEpoch}_${const Uuid().v4()}';
  //
  //       // Order
  //       OrdersModel order = OrdersModel(
  //         orderId: orderId,
  //         userId: checkout.userId,
  //         productId: checkout.productId,
  //         totalAmount: checkout.totalAmount,
  //         paymentMethod: checkout.paymentMethod,
  //         orderStatus: 'Order Placed',
  //         orderDate: now,
  //         notes: checkout.notes,
  //         paymentStatus: checkout.paymentStatus,
  //       );
  //       DocumentReference orderRef = _ordersCollection.doc(orderId);
  //       batch.set(orderRef, order.toMap());
  //
  //       // Status History
  //       DocumentReference statusRef = _statusHistoryCollection.doc();
  //       StatusHistoryModel statusHistory = StatusHistoryModel(
  //         status: 'Order Placed',
  //         timestamp: now,
  //         message: 'Your order has been placed successfully.',
  //         orderId: orderId,
  //       );
  //       batch.set(statusRef, statusHistory.toMap());
  //
  //       // Order Tracker
  //       OrderTrackerModel tracker = OrderTrackerModel(
  //         orderId: orderId,
  //         userId: checkout.userId,
  //         cartId: checkout.productId,
  //         currentStatus: 'Order Placed',
  //         statusHistoryId: statusRef.id,
  //         estimatedDelivery: now.add(Duration(days: 7)),
  //         lastUpdated: now,
  //       );
  //       batch.set(_orderTrackerCollection.doc(), tracker.toMap());
  //
  //       // Update checkout status
  //       if (checkout.id != null) {
  //         batch.update(_checkoutCollection.doc(checkout.id!), {
  //           'orderStatus': 'Order Placed',
  //         });
  //       } else {
  //         print("Checkout ID is null for user: ${checkout.userId}");
  //       }
  //     }
  //
  //     await batch.commit();
  //     return true;
  //   } catch (e, stackTrace) {
  //     print('Error placing order: $e');
  //     print(stackTrace);
  //     return false;
  //   }
  // }

  // Get orders by user


  static Future<int> getCartDocument(String cartId) async {
    try {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('Cart')
          .doc(cartId)
          .get();

      if (snapshot.exists) {
        CartModel cartItem = CartModel.fromSnapshot(snapshot);

        print('🛒 Quantity: ${cartItem.quantity}');
        print('📦 ProductId: ${cartItem.productId}');

        return cartItem.quantity;
      } else {
        print('❌ No such cart document found');
        return 0;
      }
    } catch (e) {
      print('🔥 Error fetching cart document: $e');
      return 0;
    }
  }

  static Future<void> updateUserInfo(UserInfoModel model) async {
    if (model.id == null) {
      throw Exception("Document ID is null. Cannot update without a valid ID.");
    }

    try {
      await FirebaseFirestore.instance
          .collection('UserInfo')
          .doc(model.id)
          .update(model.toMap());
      print('UserInfo updated successfully.');
    } catch (e) {
      print('Error updating UserInfo: $e');
      throw Exception('Failed to update user info.');
    }
  }







 static Future<void> updateBookQuantityAfterOrder(String productId, int quantityToBeMinusPlacedInOrder) async {
    try {
      DocumentReference docRef = FirebaseFirestore.instance.collection('Books').doc(productId);
      DocumentSnapshot snapshot = await docRef.get();

      if (snapshot.exists) {
        Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;

        int currentQuantity = data['Quantity'] ?? 0;

        int updatedQuantity = currentQuantity - quantityToBeMinusPlacedInOrder;
        if (updatedQuantity < 0) updatedQuantity = 0; // prevent negative stock

        // ✅ Update in Firestore
        await docRef.update({'Quantity': updatedQuantity});

        print("Updated Quantity: $updatedQuantity");
      } else {
        print("❌ Product not found in Books collection.");
      }
    } catch (e) {
      print("🔥 Error updating quantity: $e");
    }
  }








  // Place order - move from checkout to orders
  static Future<bool> placeOrder(List<CheckoutModel> checkoutItems) async {
    try {
      WriteBatch batch = FirebaseFirestore.instance.batch();
      DateTime now = DateTime.now();
      String orderId = 'ORD_${now.millisecondsSinceEpoch}_${const Uuid().v4()}';

      for (CheckoutModel checkout in checkoutItems) {
        QuerySnapshot snapshoter = await FirebaseFirestore.instance
            .collection('Checkout')
            .where('userId', isEqualTo: checkout.userId)
            .where('CartId', isEqualTo: checkout.CartId)
            .where('notes', isEqualTo: checkout.notes)
            .where('orderDate', isEqualTo: checkout.orderDate)
            .where('orderStatus', isEqualTo: checkout.orderStatus)
            .where('paymentMethod', isEqualTo: checkout.paymentMethod)
            .where('paymentStatus', isEqualTo: checkout.paymentStatus)
            .where('productId', isEqualTo: checkout.productId)
            .where('totalAmount', isEqualTo: checkout.totalAmount)
            .get();

        DocumentSnapshot doc = snapshoter.docs.first; // or snapshot.docs[0]

        CheckoutModel checkoutItem = CheckoutModel.fromMap(
            doc.data() as Map<String, dynamic>, doc.id);


        // Order
        OrdersModel order = OrdersModel(
          orderId: orderId,
          userId: checkout.userId,
          productId: checkout.productId,
          cartId: checkout.CartId,
          totalAmount: checkout.totalAmount,
          paymentMethod: checkout.paymentMethod,
          orderStatus: 'Order Placed',
          orderDate: now,
          notes: checkout.notes,
          paymentStatus: checkout.paymentStatus,
        );
        DocumentReference orderRef = _ordersCollection
            .doc(); // 👈 auto-generated ID

        batch.set(orderRef, order.toMap());

        // Status History
        DocumentReference statusRef = _statusHistoryCollection.doc();
        StatusHistoryModel statusHistory = StatusHistoryModel(
          status: 'Order Placed',
          timestamp: now,
          message: 'Your order has been placed successfully.',
          orderId: orderId,
        );
        batch.set(statusRef, statusHistory.toMap());

        // Order Tracker
        OrderTrackerModel tracker = OrderTrackerModel(
          orderId: orderId,
          userId: checkout.userId,
          cartId: checkout.productId,
          currentStatus: 'Order Placed',
          statusHistoryId: statusRef.id,
          estimatedDelivery: now.add(Duration(days: 7)),
          lastUpdated: now,
        );
        batch.set(_orderTrackerCollection.doc(), tracker.toMap());

        // Update checkout status
        if (checkoutItem.id != null) {
          batch.update(_checkoutCollection.doc(checkoutItem.id!), {
            'orderStatus': 'Order Placed',
          });
        } else {
          print("Checkout ID is null for user: ${checkout.userId}");
        }


        // ✅ Update Cart collection to set OrderPlaced = true
        if (checkout.CartId != null) {
          batch.update(FirebaseFirestore.instance.collection('Cart').doc(
              checkout.CartId), {
            'OrderPlaced': true,
          });
        } else {
          print("Cart ID is null for user: ${checkout.userId}");
        }

    print("cart id"+checkout.CartId);
        int quantityinorder = await getCartDocument(checkout.CartId,);
    print("quantity by order $quantityinorder");
        if (quantityinorder > 0) {
          await updateBookQuantityAfterOrder(
              checkoutItem.productId, quantityinorder);
        }
        print(checkoutItem.CartId);
      }
        await batch.commit();
        return true;

    } catch(e, stackTrace) {
      print('Error placing order: $e');
      print(stackTrace);
      return false;
    }
   }














    static Future<List<OrdersModel>> getOrdersByUser(String userId) async {
    try {
    QuerySnapshot querySnapshot = await _ordersCollection
        .where('userId', isEqualTo: userId)
        .orderBy('orderDate', descending: true)
        .get();

    return OrdersModel.fromQuerySnapshot(querySnapshot);
    } catch (e) {
    print('Error getting orders: $e');
    return [];
    }
    }

    // Track order
    static Future<OrderTrackerModel?> trackOrder(String orderId) async {
    try {
    QuerySnapshot querySnapshot = await _orderTrackerCollection
        .where('orderId', isEqualTo: orderId)
        .limit(1)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
    return OrderTrackerModel.fromSnapshot(querySnapshot.docs.first);
    }
    return null;
    } catch (e) {
    print('Error tracking order: $e');
    return null;
    }
    }

    // Get status history for order
    static Future<List<StatusHistoryModel>> getStatusHistory(String orderId) async {
    try {
    QuerySnapshot querySnapshot = await _statusHistoryCollection
        .where('orderId', isEqualTo: orderId)
        .orderBy('timestamp', descending: false)
        .get();

    return StatusHistoryModel.fromQuerySnapshot(querySnapshot);
    } catch (e) {
    print('Error getting status history: $e');
    return [];
    }
    }
  }