import 'package:flutter/material.dart';

class DeleteConfirmationDialog extends StatefulWidget {
  final String title;
  final String message;

  const DeleteConfirmationDialog({
    super.key,
    required this.title,
    required this.message,
  });

  @override
  State<DeleteConfirmationDialog> createState() => _DeleteConfirmationDialogState();
}

class _DeleteConfirmationDialogState extends State<DeleteConfirmationDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Map<String, dynamic> _getDialogSizing(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    if (screenWidth < 360) {
      return {
        'titleFontSize': 16.0,
        'textFontSize': 12.0,
        'buttonFontSize': 12.0,
        'iconSize': 18.0,
        'borderRadius': 12.0,
        'padding': 8.0,
        'spacing': 6.0,
      };
    } else if (screenWidth < 600) {
      return {
        'titleFontSize': 18.0,
        'textFontSize': 14.0,
        'buttonFontSize': 14.0,
        'iconSize': 20.0,
        'borderRadius': 16.0,
        'padding': 10.0,
        'spacing': 8.0,
      };
    } else {
      return {
        'titleFontSize': 20.0,
        'textFontSize': 16.0,
        'buttonFontSize': 16.0,
        'iconSize': 24.0,
        'borderRadius': 20.0,
        'padding': 12.0,
        'spacing': 12.0,
      };
    }
  }

  @override
  Widget build(BuildContext context) {
    final sizing = _getDialogSizing(context);

    return ScaleTransition(
      scale: _scaleAnimation,
      child: AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(sizing['borderRadius']),
        ),
        title: Row(
          children: [
            Container(
              padding: EdgeInsets.all(sizing['padding']),
              decoration: BoxDecoration(
                color: Colors.red[100],
                borderRadius: BorderRadius.circular(sizing['padding']),
              ),
              child: Icon(
                Icons.warning_amber_rounded,
                color: Colors.red[600],
                size: sizing['iconSize'],
              ),
            ),
            SizedBox(width: sizing['spacing']),
            Expanded(
              child: Text(
                widget.title,
                style: TextStyle(
                  fontSize: sizing['titleFontSize'],
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.message,
              style: TextStyle(
                fontSize: sizing['textFontSize'],
                color: Colors.grey[700],
                height: 1.4,
              ),
            ),
            SizedBox(height: sizing['spacing']),
            Container(
              padding: EdgeInsets.all(sizing['padding']),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(sizing['borderRadius'] * 0.5),
                border: Border.all(color: Colors.red[200]!),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Colors.red[600],
                    size: sizing['iconSize'] - 2,
                  ),
                  SizedBox(width: sizing['spacing'] * 0.75),
                  Expanded(
                    child: Text(
                      'This action cannot be undone.',
                      style: TextStyle(
                        fontSize: sizing['textFontSize'] - 2,
                        color: Colors.red[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: sizing['buttonFontSize'],
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[600],
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(sizing['borderRadius'] * 0.5),
              ),
              padding: EdgeInsets.symmetric(
                horizontal: sizing['padding'] + 4,
                vertical: sizing['padding'] * 0.75,
              ),
            ),
            child: Text(
              'Delete',
              style: TextStyle(
                fontSize: sizing['buttonFontSize'],
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}