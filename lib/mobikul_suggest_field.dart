/// A library for creating a customizable suggest field with various features.
library mobikul_suggest_field;

import 'package:flutter/material.dart';
import 'dart:async';

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

/// Defines the visual theme for the suggestion field.
///
/// Allows customization of colors, text styles, and other visual properties.
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

/// A highly customizable suggestion field widget.
///
/// Provides features like:
/// - Dynamic suggestion filtering
/// - Multiple display styles
/// - Search history
/// - Voice and emoji input support
class MobikulSuggestField extends StatefulWidget {
  /// List of suggestions to be displayed.
  final List<String> suggestions;

  /// Callback triggered when a suggestion is selected.
  final Function(String) onSelected;

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
  final TextEditingController _controller =
      TextEditingController(); // Controller to manage text input
  final FocusNode _focusNode =
      FocusNode(); // Focus node to track text field focus
  List<String> _filteredSuggestions =
      []; // Filtered suggestions list based on user input
  List<String> _recentSearches = []; // Recent searches list
  Timer? _debounceTimer; // Timer to delay suggestion filtering
  bool _isLoading = false; // Flag to show loading state for suggestions
  bool _showEmoji = false; // Flag to show emoji keyboard (if enabled)

  @override
  void initState() {
    super.initState();
    _recentSearches = widget.recentSearches ?? [];
    _controller.addListener(_onTextChanged); // Add listener for text changes
    _focusNode.addListener(_onFocusChanged); // Add listener for focus changes
  }

  // Triggered when the focus changes (text field gains or loses focus)
  void _onFocusChanged() {
    if (_focusNode.hasFocus && _controller.text.isEmpty) {
      setState(() {
        _filteredSuggestions =
            _recentSearches.take(widget.maxSuggestions).toList();
      });
    }
  }

  // Triggered when the text input changes
  void _onTextChanged() {
    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();
    _debounceTimer = Timer(widget.debounceTime, () {
      _filterSuggestions(_controller.text);
    });

    if (widget.onChanged != null) {
      widget.onChanged!(_controller.text);
    }
  }

  // Filter suggestions based on user input
  void _filterSuggestions(String input) {
    setState(() {
      _isLoading = true;
    });

    if (input.isEmpty) {
      _filteredSuggestions =
          _recentSearches.take(widget.maxSuggestions).toList();
    } else {
      _filteredSuggestions = widget.suggestions
          .where((suggestion) => widget.caseSensitive
              ? suggestion.contains(input)
              : suggestion.toLowerCase().contains(input.toLowerCase()))
          .take(widget.maxSuggestions)
          .toList();
    }

    setState(() {
      _isLoading = false;
    });
  }

  // Build individual suggestion item
  Widget _buildSuggestionItem(String suggestion) {
    final bool isSelected = _controller.text == suggestion;
    return ListTile(
      title: Text(
        suggestion,
        style: widget.suggestionStyle?.copyWith(
          color: isSelected ? widget.highlightColor : null,
        ),
      ),
      onTap: () => _onSuggestionSelected(suggestion),
    );
  }

  // Build the suggestions list based on display style
  Widget _buildSuggestionsList() {
    switch (widget.displayStyle) {
      case SuggestionDisplayStyle.grid:
        return GridView.builder(
          shrinkWrap: true,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 3,
          ),
          itemCount: _filteredSuggestions.length,
          itemBuilder: (context, index) {
            return _buildSuggestionItem(_filteredSuggestions[index]);
          },
        );
      case SuggestionDisplayStyle.chips:
        return Wrap(
          spacing: 8.0,
          children: _filteredSuggestions
              .map((suggestion) => ActionChip(
                    label: Text(suggestion),
                    onPressed: () => _onSuggestionSelected(suggestion),
                  ))
              .toList(),
        );
      default:
        return ListView.builder(
          shrinkWrap: true,
          itemCount: _filteredSuggestions.length,
          itemBuilder: (context, index) {
            return _buildSuggestionItem(_filteredSuggestions[index]);
          },
        );
    }
  }

  // Triggered when a suggestion is selected
  void _onSuggestionSelected(String suggestion) {
    _controller.text =
        suggestion; // Update text field with the selected suggestion
    _controller.selection = TextSelection.fromPosition(
      TextPosition(offset: suggestion.length),
    );

    if (widget.enableHistory && !_recentSearches.contains(suggestion)) {
      setState(() {
        _recentSearches.insert(0, suggestion);
        if (_recentSearches.length > widget.maxSuggestions) {
          _recentSearches.removeLast();
        }
      });
    }

    widget.onSelected(
        suggestion); // Call the callback when a suggestion is selected
    _filteredSuggestions.clear(); // Clear suggestions after selection
    _focusNode.unfocus(); // Remove focus from the text field
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
                      _controller.clear(); // Clear the text field
                      setState(() {
                        _filteredSuggestions.clear(); // Clear suggestions
                      });
                    },
                  ),
                if (widget.enableVoiceInput)
                  IconButton(
                    icon: const Icon(Icons.mic),
                    onPressed: () {
                      // Implement voice input functionality here
                    },
                  ),
                if (widget.enableEmoji)
                  IconButton(
                    icon: const Icon(Icons.emoji_emotions),
                    onPressed: () {
                      setState(() {
                        _showEmoji = !_showEmoji; // Toggle emoji keyboard
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
          onSubmitted: widget.onSubmitted, // Handle text field submission
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
            child: _buildSuggestionsList(), // Display the filtered suggestions
          ),
      ],
    );
  }

  @override
  void dispose() {
    _controller.dispose(); // Dispose the text controller
    _focusNode.dispose(); // Dispose the focus node
    _debounceTimer?.cancel(); // Cancel the debounce timer
    super.dispose();
  }
}
