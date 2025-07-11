import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Section Header Widget
class SectionHeader extends StatelessWidget {
  final String title;

  const SectionHeader({Key? key, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            color: Colors.green,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}

// Product Title Field Widget
class ProductTitleField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;

  const ProductTitleField({
    Key? key,
    required this.controller,
    required this.focusNode,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Product title',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
            SizedBox(width: 8),
            Icon(Icons.info_outline, size: 16, color: Colors.grey),
          ],
        ),
        SizedBox(height: 8),
        TextField(
          controller: controller,
          focusNode: focusNode,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!, width: 1.0),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.blue, width: 2.0),
            ),
            filled: true,
            fillColor: Colors.white,
          ),
        ),
      ],
    );
  }
}

// Rich Text Editor Widget
class RichTextEditor extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final TextEditingController searchController;
  final FocusNode searchFocusNode;
  final bool isFocused;
  final bool showSearchBar;
  final String searchQuery;
  final bool isBold;
  final bool isItalic;
  final bool isUnderline;
  final double fontSize;
  final VoidCallback onToggleSearch;
  final VoidCallback onToggleBold;
  final VoidCallback onToggleItalic;
  final VoidCallback onToggleUnderline;
  final VoidCallback onDecreaseFontSize;
  final VoidCallback onIncreaseFontSize;
  final VoidCallback onCloseSearch;

  const RichTextEditor({
    Key? key,
    required this.controller,
    required this.focusNode,
    required this.searchController,
    required this.searchFocusNode,
    required this.isFocused,
    required this.showSearchBar,
    required this.searchQuery,
    required this.isBold,
    required this.isItalic,
    required this.isUnderline,
    required this.fontSize,
    required this.onToggleSearch,
    required this.onToggleBold,
    required this.onToggleItalic,
    required this.onToggleUnderline,
    required this.onDecreaseFontSize,
    required this.onIncreaseFontSize,
    required this.onCloseSearch,
  }) : super(key: key);

  Widget _buildToolbarButton({
    required IconData icon,
    required VoidCallback onPressed,
    bool isActive = false,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 1),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(4),
          child: Container(
            padding: EdgeInsets.all(8),
            child: Icon(
              icon,
              size: 18,
              color: isActive ? Colors.blue : Colors.grey[600],
            ),
          ),
        ),
      ),
    );
  }

  void _pasteText() async {
    final clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
    if (clipboardData != null && clipboardData.text != null) {
      final text = controller.text;
      final selection = controller.selection;
      final newText = text.replaceRange(
        selection.start,
        selection.end,
        clipboardData.text!,
      );
      controller.text = newText;
      controller.selection = TextSelection.collapsed(
        offset: selection.start + clipboardData.text!.length,
      );
    }
  }

  void _insertBulletPoint() {
    final text = controller.text;
    final selection = controller.selection;
    final newText = text.replaceRange(
      selection.start,
      selection.end,
      '• ',
    );
    controller.text = newText;
    controller.selection = TextSelection.collapsed(
      offset: selection.start + 2,
    );
  }

  void _insertNumberedPoint() {
    final text = controller.text;
    final selection = controller.selection;
    final newText = text.replaceRange(
      selection.start,
      selection.end,
      '1. ',
    );
    controller.text = newText;
    controller.selection = TextSelection.collapsed(
      offset: selection.start + 3,
    );
  }

  void _cutText() {
    final selection = controller.selection;
    if (selection.isValid && !selection.isCollapsed) {
      final text = controller.text;
      final selectedText = text.substring(selection.start, selection.end);
      Clipboard.setData(ClipboardData(text: selectedText));
      final newText = text.replaceRange(selection.start, selection.end, '');
      controller.text = newText;
      controller.selection = TextSelection.collapsed(
        offset: selection.start,
      );
    }
  }

  List<TextSpan> _buildHighlightedText(String text, String query) {
    if (query.isEmpty) {
      return [TextSpan(text: text)];
    }

    List<TextSpan> spans = [];
    String lowerText = text.toLowerCase();
    String lowerQuery = query.toLowerCase();

    int start = 0;
    int index = lowerText.indexOf(lowerQuery);

    while (index != -1) {
      if (index > start) {
        spans.add(TextSpan(
          text: text.substring(start, index),
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            fontStyle: isItalic ? FontStyle.italic : FontStyle.normal,
            decoration: isUnderline ? TextDecoration.underline : TextDecoration.none,
          ),
        ));
      }

      spans.add(TextSpan(
        text: text.substring(index, index + query.length),
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          fontStyle: isItalic ? FontStyle.italic : FontStyle.normal,
          decoration: isUnderline ? TextDecoration.underline : TextDecoration.none,
          backgroundColor: Colors.blue.withOpacity(0.3),
          color: Colors.blue[800],
        ),
      ));

      start = index + query.length;
      index = lowerText.indexOf(lowerQuery, start);
    }

    if (start < text.length) {
      spans.add(TextSpan(
        text: text.substring(start),
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          fontStyle: isItalic ? FontStyle.italic : FontStyle.normal,
          decoration: isUnderline ? TextDecoration.underline : TextDecoration.none,
        ),
      ));
    }

    return spans;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Description',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
            SizedBox(width: 8),
            Icon(Icons.info_outline, size: 16, color: Colors.grey),
          ],
        ),
        SizedBox(height: 8),

        // Toolbar
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Wrap(
            spacing: 4,
            runSpacing: 4,
            children: [
              _buildToolbarButton(
                icon: Icons.format_bold,
                onPressed: onToggleBold,
                isActive: isBold,
              ),
              _buildToolbarButton(
                icon: Icons.format_italic,
                onPressed: onToggleItalic,
                isActive: isItalic,
              ),
              _buildToolbarButton(
                icon: Icons.format_underlined,
                onPressed: onToggleUnderline,
                isActive: isUnderline,
              ),
              _buildToolbarButton(
                icon: Icons.text_decrease,
                onPressed: onDecreaseFontSize,
              ),
              _buildToolbarButton(
                icon: Icons.text_increase,
                onPressed: onIncreaseFontSize,
              ),
              _buildToolbarButton(
                icon: Icons.content_cut,
                onPressed: _cutText,
              ),
              _buildToolbarButton(
                icon: Icons.content_paste,
                onPressed: _pasteText,
              ),
              _buildToolbarButton(
                icon: Icons.format_list_bulleted,
                onPressed: _insertBulletPoint,
              ),
              _buildToolbarButton(
                icon: Icons.format_list_numbered,
                onPressed: _insertNumberedPoint,
              ),
              _buildToolbarButton(
                icon: Icons.search,
                onPressed: onToggleSearch,
                isActive: showSearchBar,
              ),
            ],
          ),
        ),

        SizedBox(height: 8),

        // Text Editor
        Container(
          height: 200,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(
              color: isFocused ? Colors.blue : Colors.grey[300]!,
              width: isFocused ? 2.0 : 1.0,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: searchQuery.isNotEmpty
              ? SingleChildScrollView(
            padding: EdgeInsets.all(12),
            child: RichText(
              text: TextSpan(
                children: _buildHighlightedText(
                  controller.text,
                  searchQuery,
                ),
              ),
            ),
          )
              : TextField(
            controller: controller,
            focusNode: focusNode,
            maxLines: null,
            expands: true,
            textAlignVertical: TextAlignVertical.top,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              fontStyle: isItalic ? FontStyle.italic : FontStyle.normal,
              decoration: isUnderline ? TextDecoration.underline : TextDecoration.none,
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(12),
              hintText: 'Enter product description...',
              hintStyle: TextStyle(color: Colors.grey[400]),
            ),
          ),
        ),

        // Search Bar
        if (showSearchBar)
          Container(
            margin: EdgeInsets.only(top: 8),
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              border: Border.all(color: Colors.blue[200]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.search, size: 20, color: Colors.blue[700]),
                SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      hintText: 'Search in description...',
                      border: InputBorder.none,
                      isDense: true,
                      hintStyle: TextStyle(color: Colors.blue[400]),
                    ),
                    style: TextStyle(color: Colors.blue[800]),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close, size: 20, color: Colors.blue[700]),
                  onPressed: onCloseSearch,
                ),
              ],
            ),
          ),
      ],
    );
  }
}

// Price Section Widget
class PriceSection extends StatelessWidget {
  final TextEditingController priceController;
  final TextEditingController minPriceController;
  final TextEditingController maxPriceController;
  final bool allowCustomAmount;
  final GlobalKey<FormState> formKey;
  final Function(bool) onToggleCustomAmount;

  PriceSection({
    Key? key,
    required this.priceController,
    required this.minPriceController,
    required this.maxPriceController,
    required this.allowCustomAmount,
    required this.formKey,
    required this.onToggleCustomAmount,
  }) : super(key: key);


  final List<TextInputFormatter> _numberInputFormatters = [
    FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
  ];

  String? _validatePositiveNumber(String? value) {
    if (value == null || value.isEmpty) return 'Required';
    final num? number = num.tryParse(value);
    if (number == null || number <= 0) return 'Enter number > 0';
    return null;
  }

  String? _validateMinMax() {
    final min = num.tryParse(minPriceController.text);
    final max = num.tryParse(maxPriceController.text);
    if (min != null && max != null && min >= max) return 'Minimum must be less than Maximum';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(title: 'Price'),
        SizedBox(height: 16),

        // Main Price Field
        TextFormField(
          controller: priceController,
          keyboardType: TextInputType.number,
          inputFormatters: _numberInputFormatters,
          validator: _validatePositiveNumber,
          decoration: InputDecoration(
            prefixIcon: Padding(
              padding: EdgeInsets.all(14.0),
              child: Text('PKR', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.blue, width: 2.0),
            ),
            filled: true,
            fillColor: Colors.white,
          ),
        ),
        SizedBox(height: 24),

        // Toggle Switch
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Text(
                  'Allow customers to pay they want',
                  style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w500),
                ),
                SizedBox(width: 6),
                Icon(Icons.info_outline, size: 16, color: Colors.grey),
              ],
            ),
            Switch(
              value: allowCustomAmount,
              activeColor: Colors.blue,
              onChanged: onToggleCustomAmount,
            ),
          ],
        ),
        SizedBox(height: 16),

        // Min & Max Fields
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: minPriceController,
                enabled: allowCustomAmount,
                keyboardType: TextInputType.number,
                inputFormatters: _numberInputFormatters,
                onChanged: (_) {
                  if (formKey.currentState != null) {
                    formKey.currentState!.validate();
                  }
                },
                validator: (val) {
                  final baseValidation = _validatePositiveNumber(val);
                  final logicValidation = _validateMinMax();
                  return baseValidation ?? logicValidation;
                },
                decoration: InputDecoration(
                  labelText: 'Minimum Amount',
                  prefixIcon: Padding(
                    padding: EdgeInsets.all(14.0),
                    child: Text('PKR', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.blue, width: 2.0),
                  ),
                  filled: true,
                  fillColor: allowCustomAmount ? Colors.white : Colors.grey[100],
                ),
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                controller: maxPriceController,
                enabled: allowCustomAmount,
                keyboardType: TextInputType.number,
                inputFormatters: _numberInputFormatters,
                onChanged: (_) {
                  if (formKey.currentState != null) {
                    formKey.currentState!.validate();
                  }
                },
                validator: (val) {
                  final baseValidation = _validatePositiveNumber(val);
                  final logicValidation = _validateMinMax();
                  return baseValidation ?? logicValidation;
                },
                decoration: InputDecoration(
                  labelText: 'Maximum Amount',
                  prefixIcon: Padding(
                    padding: EdgeInsets.all(14.0),
                    child: Text('PKR', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.blue, width: 2.0),
                  ),
                  filled: true,
                  fillColor: allowCustomAmount ? Colors.white : Colors.grey[100],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}










class QuantitySection extends StatelessWidget {
  final TextEditingController quantityController;

  final GlobalKey<FormState> formKey;

  QuantitySection({
    Key? key,
    required this.quantityController,
    required this.formKey,
  }) : super(key: key);


  final List<TextInputFormatter> _numberInputFormatters = [
    FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
  ];

  String? _validatePositiveNumber(String? value) {
    if (value == null || value.isEmpty) return 'Required';
    final num? number = num.tryParse(value);
    if (number == null || number <= 0) return 'Enter number > 0';
    return null;
  }


  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(title: 'Quantity'),
        SizedBox(height: 16),

        // Main Price Field
        TextFormField(
          controller: quantityController,
          keyboardType: TextInputType.number,
          inputFormatters: _numberInputFormatters,
          validator: _validatePositiveNumber,
          decoration: InputDecoration(
            prefixIcon: Padding(
              padding: EdgeInsets.all(14.0),
              child: Icon(Icons.production_quantity_limits_outlined,color: Colors.black,),
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.blue, width: 2.0),
            ),
            filled: true,
            fillColor: Colors.white,
          ),
        ),
        SizedBox(height: 24),

      ],
    );
  }
}

// Category Dropdown Widget
class CategoryDropdown extends StatefulWidget {
  final TextEditingController controller;
  const CategoryDropdown({super.key, required this.controller});

  @override
  State<CategoryDropdown> createState() => _CategoryDropdownState();
}

class _CategoryDropdownState extends State<CategoryDropdown> {
  List<String> _categories = [];
  final FocusNode _focusNode = FocusNode();
  OverlayEntry? _overlayEntry;
  final GlobalKey _fieldKey = GlobalKey();
  String _searchQuery = '';

  List<String> get _filteredCategories {
    if (_searchQuery.isEmpty) return _categories;
    return _categories
        .where((cat) => cat.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

  @override
  void initState() {
    super.initState();
    _fetchCategoriesFromFirebase();

    _focusNode.addListener(() {
      if (_focusNode.hasFocus) _openDropdown();
      else Future.delayed(const Duration(milliseconds: 150), _closeDropdown);
    });

    widget.controller.addListener(() {
      setState(() {
        _searchQuery = widget.controller.text;
      });
      _overlayEntry?.markNeedsBuild();
    });
  }

  Future<void> _fetchCategoriesFromFirebase() async {
    final snapshot = await FirebaseFirestore.instance.collection('categories').get();
    setState(() {
      _categories = snapshot.docs
          .map((doc) => doc['categoriesname'].toString())
          .toList();
    });
  }

  void _openDropdown() {
    if (_overlayEntry == null) {
      _overlayEntry = _createOverlayEntry();
      Overlay.of(context).insert(_overlayEntry!);
    }
  }

  void _closeDropdown() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  OverlayEntry _createOverlayEntry() {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return OverlayEntry(
      builder: (context) {
        return GestureDetector(
          onTap: _closeDropdown,
          behavior: HitTestBehavior.translucent,
          child: Stack(
            children: [
              Positioned(
                left: screenWidth / 2 - 120,
                top: screenHeight / 2 - 100,
                width: 240,
                child: Material(
                  elevation: 4,
                  borderRadius: BorderRadius.circular(8),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 200),
                    child: _filteredCategories.isEmpty
                        ? const Padding(
                      padding: EdgeInsets.all(16),
                      child: Text('No categories found',
                          style: TextStyle(color: Colors.grey)),
                    )
                        : ListView(
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      children: _filteredCategories.map((cat) {
                        return InkWell(
                          onTap: () {
                            widget.controller.text = cat;
                            _focusNode.unfocus();
                            _closeDropdown();
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            child: Text(cat),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _overlayEntry?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      key: _fieldKey,
      child: TextField(
        controller: widget.controller,
        focusNode: _focusNode,
        decoration: InputDecoration(
          hintText: 'Select category',
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Colors.blue, width: 2),
          ),
          suffixIcon: const Icon(Icons.arrow_drop_down),
        ),
      ),
    );
  }
}

// Compatibility Section Widget
class CompatibilitySection extends StatelessWidget {
  final Map<String, bool> compatibilityOptions;
  final Function(String) onToggleOption;

  const CompatibilitySection({
    Key? key,
    required this.compatibilityOptions,
    required this.onToggleOption,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Compatibility',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
            SizedBox(width: 8),
            Icon(Icons.info_outline, size: 16, color: Colors.grey),
          ],
        ),
        SizedBox(height: 16),

        GridView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            childAspectRatio: 3.5,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: compatibilityOptions.length,
          itemBuilder: (context, index) {
            final option = compatibilityOptions.keys.elementAt(index);
            final isSelected = compatibilityOptions[option]!;

            return GestureDetector(
              onTap: () => onToggleOption(option),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.blue : Colors.transparent,
                      border: Border.all(
                        color: isSelected ? Colors.blue : Colors.grey[400]!,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: isSelected
                        ? Icon(
                      Icons.check,
                      size: 12,
                      color: Colors.white,
                    )
                        : null,
                  ),
                  SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      option,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.black87,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}

// Product Files Section Widget
class ProductFilesSection extends StatelessWidget {
  final dynamic imageBytes;
  final String imgUrl;
  final VoidCallback onImageTap;

  const ProductFilesSection({
    Key? key,
    required this.imageBytes,
    required this.imgUrl,
    required this.onImageTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Product Files',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        GestureDetector(
          onTap: onImageTap,
          child: Align(
            alignment: Alignment.centerLeft,
            child: Container(
              height: 180,
              width: 180,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(12),
              ),
              child: (imgUrl == "" || imageBytes == null)
                  ? Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.upload_file, size: 40),
                    SizedBox(height: 8),
                    Text("Click or drop files"),
                  ],
                ),
              )
                  : ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.memory(
                  imageBytes!,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// Register Button Widget
class RegisterButton extends StatelessWidget {
  final VoidCallback onPressed;

  const RegisterButton({Key? key, required this.onPressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(Icons.app_registration_rounded, color: Colors.white),
      label: Text(
        'Register Product',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        elevation: 5,
        shadowColor: Colors.blueAccent,
      ),
    );
  }
}