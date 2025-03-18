/// A library for creating a customizable suggest field with various features.
library mobikul_suggest_field;

import 'package:flutter/material.dart';
import 'dart:async';

import 'mobikul_suggest_helper.dart';

/// Defines the display style for suggestions.
///
/// Provides different ways to present suggestions to the user.

enum SuggestionDisplayStyle {
  /// Displays suggestions in a vertical list.
  list,

  /// Displays suggestions in a grid layout.
  grid,

  /// Displays suggestions as clickable chips.
  chips,
}

class SuggestionTheme {
  /// The background color of the suggestion field.
  final Color backgroundColor;

  /// The color of the text in the suggestion field.
  final Color textColor;

  /// The color used to highlight selected or active suggestions.
  final Color highlightColor;

  /// The text style for suggestions.
  final TextStyle suggestionStyle;

  /// The text style for the input field.
  final TextStyle inputStyle;

  /// The input decoration for the text field.
  final InputDecoration inputDecoration;

  /// The border radius for the suggestion field.
  final double borderRadius;

  /// The padding around the suggestion field.
  final EdgeInsets padding;

  /// Creates a [SuggestionTheme] with optional customization.
  ///
  /// Provides default values if not specified.
  const SuggestionTheme({
    this.backgroundColor = Colors.white,
    this.textColor = Colors.black,
    this.highlightColor = Colors.blue,
    this.suggestionStyle = const TextStyle(),
    this.inputStyle = const TextStyle(),
    this.inputDecoration = const InputDecoration(),
    this.borderRadius = 4.0,
    this.padding = const EdgeInsets.all(8.0),
  });
}

class MobikulSuggestField extends StatefulWidget {
  /// List of suggestions (of type Suggestion) to be displayed.
  final List<Suggestion> suggestions;

  /// Callback triggered when a suggestion is selected.
  final Function(Suggestion) onSelected;

  /// Optional callback when input is submitted.
  final Function(String)? onSubmitted;

  /// Optional callback when text changes.
  final Function(String)? onChanged;

  /// Optional custom input decoration.
  final InputDecoration? decoration;

  /// Optional custom text style for input.
  final TextStyle? textStyle;

  /// Optional custom text style for suggestions.
  final TextStyle? suggestionStyle;

  /// Maximum number of suggestions to display.
  final int maxSuggestions;

  /// Background color for the suggestion box.
  final Color? backgroundColor;

  /// Highlight color for selected suggestions.
  final Color? highlightColor;

  /// Enable search history feature.
  final bool enableHistory;

  /// Display style for suggestions (list, grid, or chips).
  final SuggestionDisplayStyle displayStyle;

  /// Show clear button in the text field.
  final bool showClearButton;

  /// Enable autocorrect feature.
  final bool autoCorrect;

  /// Delay before filtering suggestions.
  final Duration debounceTime;

  /// Height of each suggestion item.
  final double suggestionItemHeight;

  /// Custom prefix icon for the text field.
  final Widget? prefixIcon;

  /// Custom suffix icon for the text field.
  final Widget? suffixIcon;

  /// Enable voice input feature.
  final bool enableVoiceInput;

  /// Enable emoji input feature.
  final bool enableEmoji;

  /// List of recent searches.
  final List<String>? recentSearches;

  /// Whether suggestion matching should be case-sensitive.
  final bool caseSensitive;

  /// Hint text for the input field.
  final String? hintText;

  /// Constructs a [MobikulSuggestField] with various configuration options.
  const MobikulSuggestField({
    super.key,
    required this.suggestions,
    required this.onSelected,
    this.onSubmitted,
    this.onChanged,
    this.decoration,
    this.textStyle,
    this.suggestionStyle,
    this.maxSuggestions = 5,
    this.backgroundColor,
    this.highlightColor,
    this.enableHistory = true,
    this.displayStyle = SuggestionDisplayStyle.list,
    this.showClearButton = true,
    this.autoCorrect = true,
    this.debounceTime = const Duration(milliseconds: 300),
    this.suggestionItemHeight = 50.0,
    this.prefixIcon,
    this.suffixIcon,
    this.enableVoiceInput = false,
    this.enableEmoji = false,
    this.recentSearches,
    this.caseSensitive = false,
    this.hintText,
  });

  @override
  State<MobikulSuggestField> createState() => _MobikulSuggestFieldState();
}

class _MobikulSuggestFieldState extends State<MobikulSuggestField> {
  final TextEditingController _controller = TextEditingController();
  List<Suggestion> _filteredSuggestions = [];
  final FocusNode _focusNode = FocusNode();

  Timer? _debounceTimer;
  final bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _filteredSuggestions = widget.suggestions;
    _controller.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    setState(() {
      _filteredSuggestions = widget.suggestions
          .where((suggestion) => suggestion.name
              .toLowerCase()
              .contains(_controller.text.toLowerCase()))
          .toList();
    });
  }

  // Triggered when a suggestion is selected
  void _onSuggestionSelected(Suggestion suggestion) {
    _controller.text = suggestion.name;
    _controller.selection = TextSelection.fromPosition(
        TextPosition(offset: suggestion.name.length));

    widget.onSelected(suggestion);
    _filteredSuggestions.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: _controller,
          focusNode: _focusNode,
          decoration: widget.decoration?.copyWith(
            prefixIcon: widget.prefixIcon,
            suffixIcon: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_isLoading)
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                if (widget.showClearButton && _controller.text.isNotEmpty)
                  IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _controller.clear();
                      setState(() {
                        _filteredSuggestions.clear();
                      });
                    },
                  ),
                if (widget.suffixIcon != null) widget.suffixIcon!,
              ],
            ),
            hintText: widget.hintText,
          ),
          style: widget.textStyle,
          autocorrect: widget.autoCorrect,
          onSubmitted: widget.onSubmitted,
        ),
        if (_filteredSuggestions.isNotEmpty)
          Container(
            constraints: BoxConstraints(
              maxHeight: widget.suggestionItemHeight * widget.maxSuggestions,
            ),
            decoration: BoxDecoration(
              color: widget.backgroundColor ?? Colors.white,
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(4),
            ),
            child: SuggestHelper.buildSuggestionsList(
                _filteredSuggestions, widget.displayStyle,
                text: _controller.text,
                highlightColor: widget.highlightColor,
                suggestionStyle: widget.suggestionStyle,
                onSuggestionSelected:
                    _onSuggestionSelected), // Display the filtered suggestions
          ),
      ],
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }
}

// Suggestion  model

class Suggestion {
  final String name;
  final IconData? icon; // Optional icon field

  Suggestion({
    required this.name,
    this.icon,
  });
}
