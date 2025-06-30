import 'package:cloud_firestore/cloud_firestore.dart';
import '../../Models/cart_model.dart';
import '../Home/user_controller.dart';


class CartController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final UserController _userController = UserController();

  // Add item to cart
  Future<bool> addToCart(String productId, double productPrice) async {
    try {
      String? userEmail = await _userController.getCurrentUserEmail();
      if (userEmail == null) {
        print('❌ User not logged in');
        return false;
      }

      // Get user document ID
      var userDoc = await _userController.getUserByEmail(userEmail);
      if (userDoc == null) {
        print('❌ User not found');
        return false;
      }

      // Check if item already exists in cart
      QuerySnapshot existingItem = await _firestore
          .collection('Cart')
          .where('UserId', isEqualTo: userDoc.id)
          .where('ProductId', isEqualTo: productId)
          .where('isCheckedOut', isEqualTo: false)
          .get();

      if (existingItem.docs.isNotEmpty) {
        // Update existing item quantity
        DocumentSnapshot doc = existingItem.docs.first;
        CartModel existingCart = CartModel.fromSnapshot(doc);
        
        int newQuantity = existingCart.quantity + 1;
        double newTotalPrice = productPrice * newQuantity;

        await doc.reference.update({
          'quantity': newQuantity,
          'TotalPrice': newTotalPrice,
          'AddedItem': FieldValue.serverTimestamp(),
        });
      } else {
        // Add new item to cart
        CartModel newCartItem = CartModel(
          userId: userDoc.id!,
          productId: productId,
          quantity: 1,
          isCheckedOut: false,
          totalPrice: productPrice,
        );

        await _firestore.collection('Cart').add(newCartItem.toMap());
      }

      print('✅ Item added to cart successfully');
      return true;
    } catch (e) {
      print('❌ Error adding item to cart: $e');
      return false;
    }
  }

  // Get cart items for current user
  Future<List<CartModel>> getCartItems() async {
    try {
      String? userEmail = await _userController.getCurrentUserEmail();
      if (userEmail == null) return [];

      var userDoc = await _userController.getUserByEmail(userEmail);
      if (userDoc == null) return [];

      QuerySnapshot snapshot = await _firestore
          .collection('Cart')
          .where('UserId', isEqualTo: userDoc.id)
          .where('isCheckedOut', isEqualTo: false)
          .orderBy('AddedItem', descending: true)
          .get();

      return CartModel.fromQuerySnapshot(snapshot);
    } catch (e) {
      print('❌ Error getting cart items: $e');
      return [];
    }
  }

  // Get cart count
  Future<int> getCartCount() async {
    try {
      List<CartModel> cartItems = await getCartItems();
      int sum = 0;
      for (var item in cartItems) {
        int q = await item.quantity;  // if quantity is Future<int>
        sum += q;
      }
      return sum;
    } catch (e) {
      print('❌ Error getting cart count: $e');
      return 0;
    }
  }


  // Update cart item quantity
  Future<bool> updateCartItemQuantity(String cartId, int newQuantity, double productPrice) async {
    try {
      if (newQuantity <= 0) {
        return await removeCartItem(cartId);
      }

      double newTotalPrice = productPrice * newQuantity;

      await _firestore.collection('Cart').doc(cartId).update({
        'quantity': newQuantity,
        'TotalPrice': newTotalPrice,
        'AddedItem': FieldValue.serverTimestamp(),
      });

      print('✅ Cart item quantity updated');
      return true;
    } catch (e) {
      print('❌ Error updating cart item quantity: $e');
      return false;
    }
  }

  // Remove item from cart
  Future<bool> removeCartItem(String cartId) async {
    try {
      await _firestore.collection('Cart').doc(cartId).delete();
      print('✅ Cart item removed');
      return true;
    } catch (e) {
      print('❌ Error removing cart item: $e');
      return false;
    }
  }

  // Clear cart
  Future<bool> clearCart() async {
    try {
      String? userEmail = await _userController.getCurrentUserEmail();
      if (userEmail == null) return false;

      var userDoc = await _userController.getUserByEmail(userEmail);
      if (userDoc == null) return false;

      QuerySnapshot snapshot = await _firestore
          .collection('Cart')
          .where('UserId', isEqualTo: userDoc.id)
          .where('isCheckedOut', isEqualTo: false)
          .get();

      WriteBatch batch = _firestore.batch();
      for (DocumentSnapshot doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();

      print('✅ Cart cleared successfully');
      return true;
    } catch (e) {
      print('❌ Error clearing cart: $e');
      return false;
    }
  }

  // Get cart total price
  Future<double> getCartTotalPrice() async {
    try {
      List<CartModel> cartItems = await getCartItems();
      double sum = 0.0;
      for (var item in cartItems) {
        double price = await item.totalPrice;  // if totalPrice is Future<double>
        sum += price;
      }
      return sum;
    } catch (e) {
      print('❌ Error getting cart total price: $e');
      return 0.0;
    }
  }




}