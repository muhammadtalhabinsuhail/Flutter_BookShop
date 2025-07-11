import 'package:flutter/material.dart';
import 'package:project/screen/model/orders_model.dart';
import '../OrdersTracking/my_orders_screen.dart';
import '../OrdersTracking/order_tracking_screen.dart';

class CustomerNavigationHelper {
  static void navigateToMyOrders(BuildContext context) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => MyOrdersScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: animation.drive(
              Tween(begin: Offset(1.0, 0.0), end: Offset.zero)
                  .chain(CurveTween(curve: Curves.easeInOut)),
            ),
            child: child,
          );
        },
      ),
    );
  }
  //
  // static void navigateToOrderTracking(BuildContext context, OrdersModel order) {
  //   Navigator.push(
  //     context,
  //     PageRouteBuilder(
  //       pageBuilder: (context, animation, secondaryAnimation) =>
  //           OrderTrackingScreen(order: order),
  //       transitionsBuilder: (context, animation, secondaryAnimation, child) {
  //         return FadeTransition(
  //           opacity: animation,
  //           child: SlideTransition(
  //             position: animation.drive(
  //               Tween(begin: Offset(0.0, 1.0), end: Offset.zero)
  //                   .chain(CurveTween(curve: Curves.easeInOut)),
  //             ),
  //             child: child,
  //           ),
  //         );
  //       },
  //     ),
  //   );
  // }
}