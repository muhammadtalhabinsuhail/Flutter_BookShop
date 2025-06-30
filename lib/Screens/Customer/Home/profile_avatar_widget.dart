import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:project/Screens/Customer/Home/user_controller.dart';

import '../../Models/user_model.dart';


class ProfileAvatarWidget extends StatefulWidget {
  final VoidCallback? onLoginRequired;
  final VoidCallback? onLogoutSuccess;

  const ProfileAvatarWidget({
    Key? key,
    this.onLoginRequired,
    this.onLogoutSuccess,
  }) : super(key: key);

  @override
  State<ProfileAvatarWidget> createState() => _ProfileAvatarWidgetState();
}

class _ProfileAvatarWidgetState extends State<ProfileAvatarWidget> {
  final UserController _userController = UserController();
  UserModel? _currentUser;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    try {
      UserModel? user = await _userController.getCurrentUser();
      setState(() {
        _currentUser = user;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showProfileMenu() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_currentUser != null) ...[
              ListTile(
                leading: const Icon(Icons.person, color: Colors.black),
                title: Text(_currentUser!.userName),
                subtitle: Text(_currentUser!.email),
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: const Text('Logout', style: TextStyle(color: Colors.red)),
                onTap: () async {
                  Navigator.pop(context);
                  await _userController.logoutUser();
                  setState(() {
                    _currentUser = null;
                  });
                  if (widget.onLogoutSuccess != null) {
                    widget.onLogoutSuccess!();
                  }
                  // Navigate to SplashScreen
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/splash',
                    (route) => false,
                  );
                },
              ),
            ] else ...[
              ListTile(
                leading: const Icon(Icons.login, color: Colors.black),
                title: const Text('Login'),
                onTap: () {
                  Navigator.pop(context);
                  if (widget.onLoginRequired != null) {
                    widget.onLoginRequired!();
                  }
                  // Navigate to LoginScreen
                  Navigator.pushNamed(context, '/login');
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const CircleAvatar(
        radius: 25,
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    }

    return GestureDetector(
      onTap: _showProfileMenu,
      child: CircleAvatar(
        radius: 25,
        backgroundImage: _currentUser?.profile != null
            ? MemoryImage(base64Decode(_currentUser!.profile!))
            : null,
        child: _currentUser?.profile == null
            ? const Icon(Icons.person, color: Colors.grey)
            : null,
      ),
    );
  }
}