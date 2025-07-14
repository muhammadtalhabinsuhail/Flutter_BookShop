import 'package:flutter/material.dart';

class RichTextFormatter {
  // Apply formatting to selected text only
  static String applyFormattingToSelection(
      String fullText,
      int selectionStart,
      int selectionEnd,
      String formatType, // 'bold', 'italic', 'underline'
      bool isRemoving, // true if removing format, false if adding
      ) {
    if (selectionStart == selectionEnd) return fullText;

    String beforeSelection = fullText.substring(0, selectionStart);
    String selectedText = fullText.substring(selectionStart, selectionEnd);
    String afterSelection = fullText.substring(selectionEnd);

    String formattedSelection;

    if (isRemoving) {
      // Remove formatting tags
      formattedSelection = _removeFormatting(selectedText, formatType);
    } else {
      // Add formatting tags
      formattedSelection = _addFormatting(selectedText, formatType);
    }

    return beforeSelection + formattedSelection + afterSelection;
  }

  static String _addFormatting(String text, String formatType) {
    switch (formatType) {
      case 'bold':
        return '<b>$text</b>';
      case 'italic':
        return '<i>$text</i>';
      case 'underline':
        return '<u>$text</u>';
      default:
        return text;
    }
  }

  static String _removeFormatting(String text, String formatType) {
    switch (formatType) {
      case 'bold':
        return text.replaceAll('<b>', '').replaceAll('</b>', '');
      case 'italic':
        return text.replaceAll('<i>', '').replaceAll('</i>', '');
      case 'underline':
        return text.replaceAll('<u>', '').replaceAll('</u>', '');
      default:
        return text;
    }
  }

  // Check if selected text has specific formatting
  static bool hasFormatting(String selectedText, String formatType) {
    switch (formatType) {
      case 'bold':
        return selectedText.contains('<b>') && selectedText.contains('</b>');
      case 'italic':
        return selectedText.contains('<i>') && selectedText.contains('</i>');
      case 'underline':
        return selectedText.contains('<u>') && selectedText.contains('</u>');
      default:
        return false;
    }
  }

  // Parse formatted text for display (removes tags and applies formatting)
  static List<TextSpan> parseFormattedText(String formattedText) {
    List<TextSpan> spans = [];
    String remainingText = formattedText;

    while (remainingText.isNotEmpty) {
      int nextTagIndex = _findNextTag(remainingText);

      if (nextTagIndex == -1) {
        // No more tags, add remaining text as normal
        if (remainingText.isNotEmpty) {
          spans.add(TextSpan(
            text: remainingText,
            style: TextStyle(
              fontSize: 14,
              color: Colors.black87,
              height: 1.5,
            ),
          ));
        }
        break;
      }

      // Add text before tag as normal
      if (nextTagIndex > 0) {
        spans.add(TextSpan(
          text: remainingText.substring(0, nextTagIndex),
          style: TextStyle(
            fontSize: 14,
            color: Colors.black87,
            height: 1.5,
          ),
        ));
      }

      // Process the tagged text
      String taggedPortion = remainingText.substring(nextTagIndex);
      TextSpan taggedSpan = _parseTaggedText(taggedPortion);
      spans.add(taggedSpan);

      // Remove processed portion
      int tagEndIndex = _findTagEnd(taggedPortion);
      remainingText = remainingText.substring(nextTagIndex + tagEndIndex);
    }

    return spans;
  }

  static int _findNextTag(String text) {
    List<String> tags = ['<b>', '<i>', '<u>'];
    int minIndex = -1;

    for (String tag in tags) {
      int index = text.indexOf(tag);
      if (index != -1 && (minIndex == -1 || index < minIndex)) {
        minIndex = index;
      }
    }

    return minIndex;
  }

  static TextSpan _parseTaggedText(String taggedText) {
    bool isBold = false;
    bool isItalic = false;
    bool isUnderline = false;
    String content = taggedText;

    // Check for bold
    if (content.startsWith('<b>')) {
      isBold = true;
      int endIndex = content.indexOf('</b>');
      if (endIndex != -1) {
        content = content.substring(3, endIndex);
      } else {
        content = content.substring(3);
      }
    }
    // Check for italic
    else if (content.startsWith('<i>')) {
      isItalic = true;
      int endIndex = content.indexOf('</i>');
      if (endIndex != -1) {
        content = content.substring(3, endIndex);
      } else {
        content = content.substring(3);
      }
    }
    // Check for underline
    else if (content.startsWith('<u>')) {
      isUnderline = true;
      int endIndex = content.indexOf('</u>');
      if (endIndex != -1) {
        content = content.substring(3, endIndex);
      } else {
        content = content.substring(3);
      }
    }

    return TextSpan(
      text: content,
      style: TextStyle(
        fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
        fontStyle: isItalic ? FontStyle.italic : FontStyle.normal,
        decoration: isUnderline ? TextDecoration.underline : TextDecoration.none,
        fontSize: 14,
        color: Colors.black87,
        height: 1.5,
      ),
    );
  }

  static int _findTagEnd(String taggedText) {
    if (taggedText.startsWith('<b>')) {
      int endIndex = taggedText.indexOf('</b>');
      return endIndex != -1 ? endIndex + 4 : taggedText.length;
    } else if (taggedText.startsWith('<i>')) {
      int endIndex = taggedText.indexOf('</i>');
      return endIndex != -1 ? endIndex + 4 : taggedText.length;
    } else if (taggedText.startsWith('<u>')) {
      int endIndex = taggedText.indexOf('</u>');
      return endIndex != -1 ? endIndex + 4 : taggedText.length;
    }
    return 1;
  }

  // Get clean text without HTML tags for display in input
  static String getCleanText(String formattedText) {
    return formattedText
        .replaceAll('<b>', '')
        .replaceAll('</b>', '')
        .replaceAll('<i>', '')
        .replaceAll('</i>', '')
        .replaceAll('<u>', '')
        .replaceAll('</u>','');
  }
}