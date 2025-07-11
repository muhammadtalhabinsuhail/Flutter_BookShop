import 'dart:convert';
import 'package:flutter/material.dart';

import '../../model/Users.dart';


class CustomerCard extends StatelessWidget {
  final UsersModel user;
  final int cardNumber;
  final VoidCallback onTap;

  const CustomerCard({
    super.key,
    required this.user,
    required this.cardNumber,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      
      child: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.15),
              spreadRadius: 1,
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Card Number Tag
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$cardNumber',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            // Card Content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Profile Picture
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.blue.withOpacity(0.3),
                        width: 2,
                      ),
                    ),
                    child: ClipOval(
                      child: user.profile != null && user.profile!.isNotEmpty
                          ? Image.memory(
                        base64Decode(user.profile!),
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                      )
                          : Container(
                        color: Colors.blue.withOpacity(0.1),
                        child: Icon(
                          Icons.person,
                          color: Colors.blue,
                          size: 30,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // User Name
                  Text(
                    user.userName,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),

                  // User Email
                  Text(
                    user.email,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}