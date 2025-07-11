import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:project/screen/model/ProductModel.dart';
import 'package:project/screen/model/cart_model.dart';
import 'package:project/screen/model/orders_model.dart';
import 'package:project/screen/model/user_model.dart';
import 'package:project/screen/model/CategoryModel.dart';
import 'package:project/screen/model/order_tracker_model.dart';
import 'package:project/screen/model/status_history_model.dart';
import 'package:project/screen/model/selected_area_model.dart';

class AdminDashboardController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Dashboard Statistics
  Future<DashboardStats> getDashboardStats() async {
    try {
      // Get all collections data in parallel
      final results = await Future.wait([
        _getTotalUsers(),
        _getTotalProducts(),
        _getTotalOrders(),
        _getTotalCategories(),
        _getTotalRevenue(),
        _getActiveOrders(),
        _getDeliveredOrders(),
        _getTotalCartItems(),
      ]);

      return DashboardStats(
        totalUsers: results[0] as int,
        totalProducts: results[1] as int,
        totalOrders: results[2] as int,
        totalCategories: results[3] as int,
        totalRevenue: results[4] as double,
        activeOrders: results[5] as int,
        deliveredOrders: results[6] as int,
        totalCartItems: results[7] as int,
      );
    } catch (e) {
      print('Error getting dashboard stats: $e');
      return DashboardStats.empty();
    }
  }

  // User Analytics
  Future<UserAnalytics> getUserAnalytics() async {
    try {
      final usersSnapshot = await _firestore.collection('User').get();
      final users = UserModel.fromQuerySnapshot(usersSnapshot);

      final now = DateTime.now();
      final thisMonth = DateTime(now.year, now.month, 1);
      final lastMonth = DateTime(now.year, now.month - 1, 1);

      int newUsersThisMonth = 0;
      int newUsersLastMonth = 0;
      int adminUsers = 0;
      int customerUsers = 0;

      for (var user in users) {
        if (user.createdAt != null) {
          if (user.createdAt!.isAfter(thisMonth)) {
            newUsersThisMonth++;
          } else if (user.createdAt!.isAfter(lastMonth) && user.createdAt!.isBefore(thisMonth)) {
            newUsersLastMonth++;
          }
        }

        if (user.role.toLowerCase() == 'admin') {
          adminUsers++;
        } else {
          customerUsers++;
        }
      }

      double growthRate = newUsersLastMonth > 0
          ? ((newUsersThisMonth - newUsersLastMonth) / newUsersLastMonth) * 100
          : 0;

      return UserAnalytics(
        totalUsers: users.length,
        newUsersThisMonth: newUsersThisMonth,
        newUsersLastMonth: newUsersLastMonth,
        growthRate: growthRate,
        adminUsers: adminUsers,
        customerUsers: customerUsers,
        recentUsers: users.take(5).toList(),
      );
    } catch (e) {
      print('Error getting user analytics: $e');
      return UserAnalytics.empty();
    }
  }

  // Product Analytics
  Future<ProductAnalytics> getProductAnalytics() async {
    try {
      final productsSnapshot = await _firestore.collection('Books').get();
      final products = ProductModel.fromQuerySnapshot(productsSnapshot);

      int lowStockProducts = 0;
      int outOfStockProducts = 0;
      double totalInventoryValue = 0;

      for (var product in products) {
        if (product.quantity <= 5 && product.quantity > 0) {
          lowStockProducts++;
        } else if (product.quantity == 0) {
          outOfStockProducts++;
        }
        totalInventoryValue += (product.price * product.quantity);
      }

      // Get most popular products from cart data
      final cartSnapshot = await _firestore.collection('Cart').get();
      final cartItems = CartModel.fromQuerySnapshot(cartSnapshot);

      Map<String, int> productPopularity = {};
      for (var item in cartItems) {
        productPopularity[item.productId] = (productPopularity[item.productId] ?? 0) + item.quantity;
      }

      return ProductAnalytics(
        totalProducts: products.length,
        lowStockProducts: lowStockProducts,
        outOfStockProducts: outOfStockProducts,
        totalInventoryValue: totalInventoryValue,
        averagePrice: products.isNotEmpty ? products.map((p) => p.price).reduce((a, b) => a + b) / products.length : 0,
        topProducts: products.take(5).toList(),
        productPopularity: productPopularity,
      );
    } catch (e) {
      print('Error getting product analytics: $e');
      return ProductAnalytics.empty();
    }
  }

  // Order Analytics
  Future<OrderAnalytics> getOrderAnalytics() async {
    try {
      final ordersSnapshot = await _firestore.collection('Orders').get();
      final orders = OrdersModel.fromQuerySnapshot(ordersSnapshot);

      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final thisWeek = now.subtract(Duration(days: 7));
      final thisMonth = DateTime(now.year, now.month, 1);

      int todayOrders = 0;
      int weekOrders = 0;
      int monthOrders = 0;
      double todayRevenue = 0;
      double weekRevenue = 0;
      double monthRevenue = 0;

      Map<String, int> statusCount = {};
      Map<String, int> paymentMethodCount = {};

      for (var order in orders) {
        // Count by status
        statusCount[order.orderStatus] = (statusCount[order.orderStatus] ?? 0) + 1;

        // Count by payment method
        paymentMethodCount[order.paymentMethod] = (paymentMethodCount[order.paymentMethod] ?? 0) + 1;

        // Time-based analytics
        if (order.orderDate.isAfter(today)) {
          todayOrders++;
          todayRevenue += order.totalAmount;
        }
        if (order.orderDate.isAfter(thisWeek)) {
          weekOrders++;
          weekRevenue += order.totalAmount;
        }
        if (order.orderDate.isAfter(thisMonth)) {
          monthOrders++;
          monthRevenue += order.totalAmount;
        }
      }

      return OrderAnalytics(
        totalOrders: orders.length,
        todayOrders: todayOrders,
        weekOrders: weekOrders,
        monthOrders: monthOrders,
        todayRevenue: todayRevenue,
        weekRevenue: weekRevenue,
        monthRevenue: monthRevenue,
        statusBreakdown: statusCount,
        paymentMethodBreakdown: paymentMethodCount,
        recentOrders: orders.take(10).toList(),
      );
    } catch (e) {
      print('Error getting order analytics: $e');
      return OrderAnalytics.empty();
    }
  }

  // Revenue Analytics
  Future<RevenueAnalytics> getRevenueAnalytics() async {
    try {
      final ordersSnapshot = await _firestore.collection('Orders').get();
      final orders = OrdersModel.fromQuerySnapshot(ordersSnapshot);

      final now = DateTime.now();
      final thisMonth = DateTime(now.year, now.month, 1);
      final lastMonth = DateTime(now.year, now.month - 1, 1);

      double thisMonthRevenue = 0;
      double lastMonthRevenue = 0;
      double totalRevenue = 0;

      List<double> dailyRevenue = List.filled(30, 0);

      for (var order in orders) {
        totalRevenue += order.totalAmount;

        if (order.orderDate.isAfter(thisMonth)) {
          thisMonthRevenue += order.totalAmount;

          // Calculate daily revenue for last 30 days
          int dayIndex = now.difference(order.orderDate).inDays;
          if (dayIndex >= 0 && dayIndex < 30) {
            dailyRevenue[29 - dayIndex] += order.totalAmount;
          }
        } else if (order.orderDate.isAfter(lastMonth) && order.orderDate.isBefore(thisMonth)) {
          lastMonthRevenue += order.totalAmount;
        }
      }

      double growthRate = lastMonthRevenue > 0
          ? ((thisMonthRevenue - lastMonthRevenue) / lastMonthRevenue) * 100
          : 0;

      return RevenueAnalytics(
        totalRevenue: totalRevenue,
        thisMonthRevenue: thisMonthRevenue,
        lastMonthRevenue: lastMonthRevenue,
        growthRate: growthRate,
        averageOrderValue: orders.isNotEmpty ? totalRevenue / orders.length : 0,
        dailyRevenue: dailyRevenue,
      );
    } catch (e) {
      print('Error getting revenue analytics: $e');
      return RevenueAnalytics.empty();
    }
  }

  // Helper methods
  Future<int> _getTotalUsers() async {
    final snapshot = await _firestore.collection('User').get();
    return snapshot.docs.length;
  }

  Future<int> _getTotalProducts() async {
    final snapshot = await _firestore.collection('Books').get();
    return snapshot.docs.length;
  }

  Future<int> _getTotalOrders() async {
    final snapshot = await _firestore.collection('Orders').get();
    return snapshot.docs.length;
  }

  Future<int> _getTotalCategories() async {
    final snapshot = await _firestore.collection('Categories').get();
    return snapshot.docs.length;
  }

  Future<double> _getTotalRevenue() async {
    final snapshot = await _firestore.collection('Orders').get();
    double total = 0;
    for (var doc in snapshot.docs) {
      total += (doc.data()['totalAmount'] ?? 0).toDouble();
    }
    return total;
  }

  Future<int> _getActiveOrders() async {
    final snapshot = await _firestore.collection('Orders')
        .where('orderStatus', whereNotIn: ['Delivered', 'Cancelled']).get();
    return snapshot.docs.length;
  }

  Future<int> _getDeliveredOrders() async {
    final snapshot = await _firestore.collection('Orders')
        .where('orderStatus', isEqualTo: 'Delivered').get();
    return snapshot.docs.length;
  }

  Future<int> _getTotalCartItems() async {
    final snapshot = await _firestore.collection('Cart').get();
    int total = 0;
    for (var doc in snapshot.docs) {
      total += (doc.data()['quantity'] ?? 0) as int;
    }
    return total;
  }
}

// Data Models for Analytics
class DashboardStats {
  final int totalUsers;
  final int totalProducts;
  final int totalOrders;
  final int totalCategories;
  final double totalRevenue;
  final int activeOrders;
  final int deliveredOrders;
  final int totalCartItems;

  DashboardStats({
    required this.totalUsers,
    required this.totalProducts,
    required this.totalOrders,
    required this.totalCategories,
    required this.totalRevenue,
    required this.activeOrders,
    required this.deliveredOrders,
    required this.totalCartItems,
  });

  factory DashboardStats.empty() => DashboardStats(
    totalUsers: 0,
    totalProducts: 0,
    totalOrders: 0,
    totalCategories: 0,
    totalRevenue: 0,
    activeOrders: 0,
    deliveredOrders: 0,
    totalCartItems: 0,
  );
}

class UserAnalytics {
  final int totalUsers;
  final int newUsersThisMonth;
  final int newUsersLastMonth;
  final double growthRate;
  final int adminUsers;
  final int customerUsers;
  final List<UserModel> recentUsers;

  UserAnalytics({
    required this.totalUsers,
    required this.newUsersThisMonth,
    required this.newUsersLastMonth,
    required this.growthRate,
    required this.adminUsers,
    required this.customerUsers,
    required this.recentUsers,
  });

  factory UserAnalytics.empty() => UserAnalytics(
    totalUsers: 0,
    newUsersThisMonth: 0,
    newUsersLastMonth: 0,
    growthRate: 0,
    adminUsers: 0,
    customerUsers: 0,
    recentUsers: [],
  );
}

class ProductAnalytics {
  final int totalProducts;
  final int lowStockProducts;
  final int outOfStockProducts;
  final double totalInventoryValue;
  final double averagePrice;
  final List<ProductModel> topProducts;
  final Map<String, int> productPopularity;

  ProductAnalytics({
    required this.totalProducts,
    required this.lowStockProducts,
    required this.outOfStockProducts,
    required this.totalInventoryValue,
    required this.averagePrice,
    required this.topProducts,
    required this.productPopularity,
  });

  factory ProductAnalytics.empty() => ProductAnalytics(
    totalProducts: 0,
    lowStockProducts: 0,
    outOfStockProducts: 0,
    totalInventoryValue: 0,
    averagePrice: 0,
    topProducts: [],
    productPopularity: {},
  );
}

class OrderAnalytics {
  final int totalOrders;
  final int todayOrders;
  final int weekOrders;
  final int monthOrders;
  final double todayRevenue;
  final double weekRevenue;
  final double monthRevenue;
  final Map<String, int> statusBreakdown;
  final Map<String, int> paymentMethodBreakdown;
  final List<OrdersModel> recentOrders;

  OrderAnalytics({
    required this.totalOrders,
    required this.todayOrders,
    required this.weekOrders,
    required this.monthOrders,
    required this.todayRevenue,
    required this.weekRevenue,
    required this.monthRevenue,
    required this.statusBreakdown,
    required this.paymentMethodBreakdown,
    required this.recentOrders,
  });

  factory OrderAnalytics.empty() => OrderAnalytics(
    totalOrders: 0,
    todayOrders: 0,
    weekOrders: 0,
    monthOrders: 0,
    todayRevenue: 0,
    weekRevenue: 0,
    monthRevenue: 0,
    statusBreakdown: {},
    paymentMethodBreakdown: {},
    recentOrders: [],
  );
}

class RevenueAnalytics {
  final double totalRevenue;
  final double thisMonthRevenue;
  final double lastMonthRevenue;
  final double growthRate;
  final double averageOrderValue;
  final List<double> dailyRevenue;

  RevenueAnalytics({
    required this.totalRevenue,
    required this.thisMonthRevenue,
    required this.lastMonthRevenue,
    required this.growthRate,
    required this.averageOrderValue,
    required this.dailyRevenue,
  });

  factory RevenueAnalytics.empty() => RevenueAnalytics(
    totalRevenue: 0,
    thisMonthRevenue: 0,
    lastMonthRevenue: 0,
    growthRate: 0,
    averageOrderValue: 0,
    dailyRevenue: [],
  );
}