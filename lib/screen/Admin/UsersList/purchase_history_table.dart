
import 'dart:convert';
import 'package:flutter/material.dart';
import 'dart:typed_data';
import '../../model/ProductModel.dart';

class PurchaseHistoryTable extends StatefulWidget {
  final List<PurchaseHistoryModel> purchases;
  final Function(String) onProductImageTap;

  const PurchaseHistoryTable({
    super.key,
    required this.purchases,
    required this.onProductImageTap,
  });

  @override
  State<PurchaseHistoryTable> createState() => _PurchaseHistoryTableState();
}

class _PurchaseHistoryTableState extends State<PurchaseHistoryTable>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  String _sortBy = 'date';
  bool _isAscending = false;
  Set<String> _expandedProducts = <String>{};

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  double get grandTotal {
    return widget.purchases.fold(0.0, (sum, purchase) => sum + purchase.totalPrice);
  }

  // Group purchases by product and get comment counts
  Map<String, List<PurchaseHistoryModel>> get groupedPurchases {
    Map<String, List<PurchaseHistoryModel>> grouped = {};
    for (var purchase in sortedPurchases) {
      String productKey = '${purchase.productId.id}_${purchase.productName}';
      if (!grouped.containsKey(productKey)) {
        grouped[productKey] = [];
      }
      grouped[productKey]!.add(purchase);
    }
    return grouped;
  }

  List<PurchaseHistoryModel> get sortedPurchases {
    List<PurchaseHistoryModel> sorted = List.from(widget.purchases);
    switch (_sortBy) {
      case 'date':
        sorted.sort((a, b) => _isAscending
            ? a.purchaseDate.compareTo(b.purchaseDate)
            : b.purchaseDate.compareTo(a.purchaseDate));
        break;
      case 'amount':
        sorted.sort((a, b) => _isAscending
            ? a.totalPrice.compareTo(b.totalPrice)
            : b.totalPrice.compareTo(a.totalPrice));
        break;
      case 'product':
        sorted.sort((a, b) => _isAscending
            ? a.productName.compareTo(b.productName)
            : b.productName.compareTo(a.productName));
        break;
    }
    return sorted;
  }

  int getCommentCount(List<PurchaseHistoryModel> productPurchases) {
    return productPurchases
        .where((purchase) => purchase.comment != null && purchase.comment!.isNotEmpty)
        .length;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;
    final isMediumScreen = screenWidth >= 600 && screenWidth < 900;

    if (widget.purchases.isEmpty) {
      return _buildEmptyState(isSmallScreen);
    }

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        margin: EdgeInsets.all(isSmallScreen ? 8 : 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.blue.shade50,
              Colors.white,
              Colors.blue.shade50,
            ],
          ),
          borderRadius: BorderRadius.circular(isSmallScreen ? 16 : 20),
          boxShadow: [
            BoxShadow(
              color: Colors.blue.withOpacity(0.1),
              spreadRadius: 0,
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(isSmallScreen),
            _buildSortingOptions(isSmallScreen),
            _buildPurchasesList(isSmallScreen, isMediumScreen),
            _buildGrandTotal(isSmallScreen),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isSmallScreen) {
    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 24 : 48),
      margin: EdgeInsets.all(isSmallScreen ? 8 : 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.blue.shade50,
            Colors.white,
          ],
        ),
        borderRadius: BorderRadius.circular(isSmallScreen ? 16 : 20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 0,
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(isSmallScreen ? 16 : 24),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.shopping_bag_outlined,
              size: isSmallScreen ? 48 : 64,
              color: Colors.blue.shade400,
            ),
          ),
          SizedBox(height: isSmallScreen ? 16 : 24),
          Text(
            'No Purchase History',
            style: TextStyle(
              fontSize: isSmallScreen ? 20 : 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          SizedBox(height: isSmallScreen ? 4 : 8),
          Text(
            'This customer hasn\'t made any purchases yet',
            style: TextStyle(
              fontSize: isSmallScreen ? 14 : 16,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(bool isSmallScreen) {
    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 16 : 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.blue.shade600,
            Colors.blue.shade700,
          ],
        ),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(isSmallScreen ? 16 : 20),
          topRight: Radius.circular(isSmallScreen ? 16 : 20),
        ),
      ),
      child: isSmallScreen
          ? Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.history,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Purchase History',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${widget.purchases.length} transactions',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  '\$${grandTotal.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      )
          : Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.history,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Purchase History',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  '${widget.purchases.length} transactions',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '\$${grandTotal.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSortingOptions(bool isSmallScreen) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmallScreen ? 16 : 24,
        vertical: isSmallScreen ? 12 : 16,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: isSmallScreen
          ? Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Sort by:',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
              IconButton(
                onPressed: () {
                  setState(() {
                    _isAscending = !_isAscending;
                  });
                },
                icon: Icon(
                  _isAscending ? Icons.arrow_upward : Icons.arrow_downward,
                  color: Colors.blue,
                  size: 20,
                ),
                tooltip: _isAscending ? 'Ascending' : 'Descending',
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              _buildSortChip('Date', 'date', Icons.calendar_today, isSmallScreen),
              _buildSortChip('Amount', 'amount', Icons.attach_money, isSmallScreen),
              _buildSortChip('Product', 'product', Icons.shopping_bag, isSmallScreen),
            ],
          ),
        ],
      )
          : Row(
        children: [
          Text(
            'Sort by:',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(width: 16),
          _buildSortChip('Date', 'date', Icons.calendar_today, isSmallScreen),
          const SizedBox(width: 8),
          _buildSortChip('Amount', 'amount', Icons.attach_money, isSmallScreen),
          const SizedBox(width: 8),
          _buildSortChip('Product', 'product', Icons.shopping_bag, isSmallScreen),
          const Spacer(),
          IconButton(
            onPressed: () {
              setState(() {
                _isAscending = !_isAscending;
              });
            },
            icon: Icon(
              _isAscending ? Icons.arrow_upward : Icons.arrow_downward,
              color: Colors.blue,
            ),
            tooltip: _isAscending ? 'Ascending' : 'Descending',
          ),
        ],
      ),
    );
  }

  Widget _buildSortChip(String label, String value, IconData icon, bool isSmallScreen) {
    bool isSelected = _sortBy == value;
    return GestureDetector(
      onTap: () {
        setState(() {
          _sortBy = value;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
          horizontal: isSmallScreen ? 8 : 12,
          vertical: isSmallScreen ? 4 : 6,
        ),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(isSmallScreen ? 16 : 20),
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.grey.shade300,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: isSmallScreen ? 14 : 16,
              color: isSelected ? Colors.white : Colors.grey[600],
            ),
            SizedBox(width: isSmallScreen ? 2 : 4),
            Text(
              label,
              style: TextStyle(
                fontSize: isSmallScreen ? 10 : 12,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPurchasesList(bool isSmallScreen, bool isMediumScreen) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: groupedPurchases.length,
      itemBuilder: (context, index) {
        String productKey = groupedPurchases.keys.elementAt(index);
        List<PurchaseHistoryModel> productPurchases = groupedPurchases[productKey]!;
        return _buildProductGroup(productKey, productPurchases, index, isSmallScreen, isMediumScreen);
      },
    );
  }

  Widget _buildProductGroup(String productKey, List<PurchaseHistoryModel> productPurchases,
      int index, bool isSmallScreen, bool isMediumScreen) {

    PurchaseHistoryModel mainPurchase = productPurchases.first;
    int commentCount = getCommentCount(productPurchases);
    bool isExpanded = _expandedProducts.contains(productKey);

    return AnimatedContainer(
      duration: Duration(milliseconds: 200 + (index * 50)),
      margin: EdgeInsets.symmetric(
        horizontal: isSmallScreen ? 8 : 16,
        vertical: isSmallScreen ? 4 : 8,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(isSmallScreen ? 12 : 16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 0,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: Column(
          children: [
            InkWell(
              borderRadius: BorderRadius.circular(isSmallScreen ? 12 : 16),
              onTap: () => widget.onProductImageTap(mainPurchase.productId.id),
              child: Padding(
                padding: EdgeInsets.all(isSmallScreen ? 12 : 20),
                child: isSmallScreen
                    ? _buildSmallScreenLayout(mainPurchase, productPurchases, commentCount, productKey)
                    : _buildLargeScreenLayout(mainPurchase, productPurchases, commentCount, productKey, isMediumScreen),
              ),
            ),
            if (isExpanded && commentCount > 0)
              _buildExpandedComments(productPurchases, isSmallScreen),
          ],
        ),
      ),
    );
  }

  Widget _buildSmallScreenLayout(PurchaseHistoryModel mainPurchase,
      List<PurchaseHistoryModel> productPurchases, int commentCount, String productKey) {

    double totalAmount = productPurchases.fold(0.0, (sum, p) => sum + p.totalPrice);
    int totalQuantity = productPurchases.fold(0, (sum, p) => sum + p.quantity);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _buildProductImage(mainPurchase, 60),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    mainPurchase.productName,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${productPurchases.length} order${productPurchases.length > 1 ? 's' : ''}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue.shade600, Colors.blue.shade700],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '\$${totalAmount.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
              decoration: BoxDecoration(
                color: Colors.blue.shade100,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                'Total Qty: $totalQuantity',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: Colors.blue.shade700,
                ),
              ),
            ),
            const SizedBox(width: 8),
            if (commentCount > 0)
              GestureDetector(
                onTap: () {
                  setState(() {
                    if (_expandedProducts.contains(productKey)) {
                      _expandedProducts.remove(productKey);
                    } else {
                      _expandedProducts.add(productKey);
                    }
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade100,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.orange.shade300),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.comment,
                        size: 12,
                        color: Colors.orange.shade700,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        '$commentCount',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: Colors.orange.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildLargeScreenLayout(PurchaseHistoryModel mainPurchase,
      List<PurchaseHistoryModel> productPurchases, int commentCount, String productKey, bool isMediumScreen) {

    double totalAmount = productPurchases.fold(0.0, (sum, p) => sum + p.totalPrice);
    int totalQuantity = productPurchases.fold(0, (sum, p) => sum + p.quantity);

    return Row(
      children: [
        _buildProductImage(mainPurchase, isMediumScreen ? 70 : 80),
        SizedBox(width: isMediumScreen ? 12 : 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                mainPurchase.productName,
                style: TextStyle(
                  fontSize: isMediumScreen ? 16 : 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: isMediumScreen ? 6 : 8),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Total Qty: $totalQuantity',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.blue.shade700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${productPurchases.length} order${productPurchases.length > 1 ? 's' : ''}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.green.shade700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (commentCount > 0)
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          if (_expandedProducts.contains(productKey)) {
                            _expandedProducts.remove(productKey);
                          } else {
                            _expandedProducts.add(productKey);
                          }
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade100,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.orange.shade300),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.comment,
                              size: 14,
                              color: Colors.orange.shade700,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '$commentCount comment${commentCount > 1 ? 's' : ''}',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.orange.shade700,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              _expandedProducts.contains(productKey)
                                  ? Icons.expand_less
                                  : Icons.expand_more,
                              size: 16,
                              color: Colors.orange.shade700,
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.blue.shade600,
                Colors.blue.shade700,
              ],
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.blue.withOpacity(0.3),
                spreadRadius: 0,
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Text(
            '\$${totalAmount.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: isMediumScreen ? 16 : 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProductImage(PurchaseHistoryModel purchase, double size) {
    return Hero(
      tag: 'product_${purchase.productId.id}',
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(size * 0.2),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.blue.shade100,
              Colors.blue.shade50,
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.blue.withOpacity(0.2),
              spreadRadius: 0,
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(size * 0.2),
          child: purchase.productImage.isNotEmpty
              ? (purchase.productImage.startsWith('http')
              ? Image.network(
            purchase.productImage,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return _buildImagePlaceholder(size);
            },
          )
              : FutureBuilder<Uint8List?>(
            future: purchase.fetchProductImage(purchase),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.blue.shade400,
                  ),
                );
              } else if (!snapshot.hasData || snapshot.data == null) {
                return _buildImagePlaceholder(size);
              } else {
                return Image.memory(
                  snapshot.data!,
                  fit: BoxFit.cover,
                );
              }
            },
          ))
              : _buildImagePlaceholder(size),
        ),
      ),
    );
  }

  Widget _buildImagePlaceholder(double size) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.blue.shade200,
            Colors.blue.shade100,
          ],
        ),
      ),
      child: Icon(
        Icons.shopping_bag_outlined,
        color: Colors.blue.shade600,
        size: size * 0.4,
      ),
    );
  }

  Widget _buildExpandedComments(List<PurchaseHistoryModel> productPurchases, bool isSmallScreen) {
    List<PurchaseHistoryModel> purchasesWithComments = productPurchases
        .where((purchase) => purchase.comment != null && purchase.comment!.isNotEmpty)
        .toList();

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
      margin: EdgeInsets.only(
        left: isSmallScreen ? 12 : 16,
        right: isSmallScreen ? 12 : 16,
        bottom: isSmallScreen ? 12 : 16,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.orange.shade50,
            Colors.amber.shade50,
          ],
        ),
        borderRadius: BorderRadius.circular(isSmallScreen ? 8 : 12),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.comment_outlined,
                size: isSmallScreen ? 16 : 18,
                color: Colors.orange.shade700,
              ),
              SizedBox(width: isSmallScreen ? 6 : 8),
              Text(
                'Customer Comments (${purchasesWithComments.length})',
                style: TextStyle(
                  fontSize: isSmallScreen ? 12 : 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange.shade700,
                ),
              ),
            ],
          ),
          SizedBox(height: isSmallScreen ? 8 : 12),
          ...purchasesWithComments.map((purchase) => Container(
            margin: EdgeInsets.only(bottom: isSmallScreen ? 6 : 8),
            padding: EdgeInsets.all(isSmallScreen ? 8 : 12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.7),
              borderRadius: BorderRadius.circular(isSmallScreen ? 6 : 8),
              border: Border.all(color: Colors.orange.shade100),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: isSmallScreen ? 12 : 14,
                      color: Colors.grey[600],
                    ),
                    SizedBox(width: isSmallScreen ? 4 : 6),
                    Text(
                      '${purchase.purchaseDate.day}/${purchase.purchaseDate.month}/${purchase.purchaseDate.year}',
                      style: TextStyle(
                        fontSize: isSmallScreen ? 10 : 12,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade100,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'Qty: ${purchase.quantity}',
                        style: TextStyle(
                          fontSize: isSmallScreen ? 9 : 10,
                          fontWeight: FontWeight.w600,
                          color: Colors.blue.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: isSmallScreen ? 4 : 6),
                Text(
                  purchase.comment!,
                  style: TextStyle(
                    fontSize: isSmallScreen ? 11 : 13,
                    color: Colors.orange.shade800,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          )).toList(),
        ],
      ),
    );
  }

  Widget _buildGrandTotal(bool isSmallScreen) {
    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 16 : 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.green.shade600,
            Colors.green.shade700,
          ],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(isSmallScreen ? 16 : 20),
          bottomRight: Radius.circular(isSmallScreen ? 16 : 20),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Grand Total',
                style: TextStyle(
                  fontSize: isSmallScreen ? 14 : 16,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '${widget.purchases.length} transactions',
                style: TextStyle(
                  fontSize: isSmallScreen ? 10 : 12,
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
            ],
          ),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: isSmallScreen ? 12 : 16,
              vertical: isSmallScreen ? 8 : 12,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(isSmallScreen ? 12 : 16),
              border: Border.all(color: Colors.white.withOpacity(0.3)),
            ),
            child: Text(
              '\$${grandTotal.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: isSmallScreen ? 16 : 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}