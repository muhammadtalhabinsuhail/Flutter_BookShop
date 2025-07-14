import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'rich_text_formatter.dart';

class EnhancedRichTextEditor extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final TextEditingController searchController;
  final FocusNode searchFocusNode;
  final bool isFocused;
  final bool showSearchBar;
  final String searchQuery;
  final VoidCallback onToggleSearch;
  final VoidCallback onCloseSearch;

  const EnhancedRichTextEditor({
    Key? key,
    required this.controller,
    required this.focusNode,
    required this.searchController,
    required this.searchFocusNode,
    required this.isFocused,
    required this.showSearchBar,
    required this.searchQuery,
    required this.onToggleSearch,
    required this.onCloseSearch,
  }) : super(key: key);

  @override
  State<EnhancedRichTextEditor> createState() => _EnhancedRichTextEditorState();
}

class _EnhancedRichTextEditorState extends State<EnhancedRichTextEditor> {
  bool _isBoldActive = false;
  bool _isItalicActive = false;
  bool _isUnderlineActive = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_updateFormattingStates);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_updateFormattingStates);
    super.dispose();
  }

  void _updateFormattingStates() {
    final selection = widget.controller.selection;
    if (selection.isValid && !selection.isCollapsed) {
      String selectedText = widget.controller.text.substring(selection.start, selection.end);
      setState(() {
        _isBoldActive = RichTextFormatter.hasFormatting(selectedText, 'bold');
        _isItalicActive = RichTextFormatter.hasFormatting(selectedText, 'italic');
        _isUnderlineActive = RichTextFormatter.hasFormatting(selectedText, 'underline');
      });
    } else {
      setState(() {
        _isBoldActive = false;
        _isItalicActive = false;
        _isUnderlineActive = false;
      });
    }
  }

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
            decoration: BoxDecoration(
              color: isActive ? Colors.blue.withOpacity(0.1) : Colors.transparent,
              borderRadius: BorderRadius.circular(4),
              border: isActive ? Border.all(color: Colors.blue, width: 1) : null,
            ),
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

  void _applyFormatting(String formatType) {
    final selection = widget.controller.selection;
    if (!selection.isValid || selection.isCollapsed) {
      // Show message that text must be selected
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select text to apply formatting'),
          duration: Duration(seconds: 1),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    String selectedText = widget.controller.text.substring(selection.start, selection.end);
    bool hasFormat = RichTextFormatter.hasFormatting(selectedText, formatType);

    String newText = RichTextFormatter.applyFormattingToSelection(
      widget.controller.text,
      selection.start,
      selection.end,
      formatType,
      hasFormat, // Remove if already has format, add if doesn't
    );

    widget.controller.text = newText;

    // Clear selection after formatting
    widget.controller.selection = TextSelection.collapsed(offset: selection.start);

    // Update button states
    _updateFormattingStates();
  }

  void _pasteText() async {
    final clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
    if (clipboardData != null && clipboardData.text != null) {
      final text = widget.controller.text;
      final selection = widget.controller.selection;
      final newText = text.replaceRange(
        selection.start,
        selection.end,
        clipboardData.text!,
      );
      widget.controller.text = newText;
      widget.controller.selection = TextSelection.collapsed(
        offset: selection.start + clipboardData.text!.length,
      );
    }
  }

  void _insertBulletPoint() {
    final text = widget.controller.text;
    final selection = widget.controller.selection;
    final newText = text.replaceRange(
      selection.start,
      selection.end,
      '• ',
    );
    widget.controller.text = newText;
    widget.controller.selection = TextSelection.collapsed(
      offset: selection.start + 2,
    );
  }

  void _insertNumberedPoint() {
    final text = widget.controller.text;
    final selection = widget.controller.selection;
    final newText = text.replaceRange(
      selection.start,
      selection.end,
      '1. ',
    );
    widget.controller.text = newText;
    widget.controller.selection = TextSelection.collapsed(
      offset: selection.start + 3,
    );
  }

  void _cutText() {
    final selection = widget.controller.selection;
    if (selection.isValid && !selection.isCollapsed) {
      final text = widget.controller.text;
      final selectedText = text.substring(selection.start, selection.end);
      Clipboard.setData(ClipboardData(text: selectedText));
      final newText = text.replaceRange(selection.start, selection.end, '');
      widget.controller.text = newText;
      widget.controller.selection = TextSelection.collapsed(
        offset: selection.start,
      );
    }
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

        // Enhanced Toolbar
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
                onPressed: () => _applyFormatting('bold'),
                isActive: _isBoldActive,
              ),
              _buildToolbarButton(
                icon: Icons.format_italic,
                onPressed: () => _applyFormatting('italic'),
                isActive: _isItalicActive,
              ),
              _buildToolbarButton(
                icon: Icons.format_underlined,
                onPressed: () => _applyFormatting('underline'),
                isActive: _isUnderlineActive,
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
                onPressed: widget.onToggleSearch,
                isActive: widget.showSearchBar,
              ),
            ],
          ),
        ),

        SizedBox(height: 8),

        // Text Editor - Shows HTML tags
        Container(
          height: 200,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(
              color: widget.isFocused ? Colors.blue : Colors.grey[300]!,
              width: widget.isFocused ? 2.0 : 1.0,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: TextField(
            controller: widget.controller,
            focusNode: widget.focusNode,
            maxLines: null,
            expands: true,
            textAlignVertical: TextAlignVertical.top,
            style: TextStyle(
              fontSize: 14,
              fontFamily: 'monospace', // Monospace font to show HTML tags clearly
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(12),
              hintText: 'Enter product description. Select text and use toolbar to format...',
              hintStyle: TextStyle(color: Colors.grey[400]),
            ),
            onTap: _updateFormattingStates,
          ),
        ),

        SizedBox(height: 8),

        // Preview Section - Shows formatted text without HTML tags
        Container(
          width: double.infinity,
          constraints: BoxConstraints(minHeight: 100),
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.preview, size: 16, color: Colors.blue),
                  SizedBox(width: 4),
                  Text(
                    'Preview (How customers will see):',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              widget.controller.text.isNotEmpty
                  ? RichText(
                text: TextSpan(
                  children: RichTextFormatter.parseFormattedText(widget.controller.text),
                ),
              )
                  : Text(
                'Preview will appear here...',
                style: TextStyle(
                  color: Colors.grey[500],
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),

        // Search Bar
        if (widget.showSearchBar)
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
                    controller: widget.searchController,
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
                  onPressed: widget.onCloseSearch,
                ),
              ],
            ),
          ),
      ],
    );
  }
}