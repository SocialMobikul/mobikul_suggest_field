
library mobikul_suggest_field;

import 'package:flutter/material.dart';
import 'dart:async';

// Enum to define how the suggestions are displayed (list, grid, chips)
enum SuggestionDisplayStyle {
  list,
  grid,
  chips,
}

// Class to define the theme of the suggestion field
class SuggestionTheme {
  final Color backgroundColor;
  final Color textColor;
  final Color highlightColor;
  final TextStyle suggestionStyle;
  final TextStyle inputStyle;
  final InputDecoration inputDecoration;
  final double borderRadius;
  final EdgeInsets padding;

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

// Main widget for the Mobikul Suggest Field
class MobikulSuggestField extends StatefulWidget {
  final List<String> suggestions;  // List of suggestions to show
  final Function(String) onSelected;  // Callback when a suggestion is selected
  final Function(String)? onSubmitted;  // Callback when the input is submitted
  final Function(String)? onChanged;  // Callback when the text changes
  final InputDecoration? decoration;  // Custom decoration for the text field
  final TextStyle? textStyle;  // Custom style for the input text
  final TextStyle? suggestionStyle;  // Custom style for the suggestions
  final int maxSuggestions;  // Maximum number of suggestions to show
  final Color? backgroundColor;  // Background color for the suggestion box
  final Color? highlightColor;  // Highlight color for selected suggestions
  final bool enableHistory;  // Enable search history feature
  final SuggestionDisplayStyle displayStyle;  // The display style of the suggestions (list, grid, chips)
  final bool showClearButton;  // Show clear button in the text field
  final bool autoCorrect;  // Enable autocorrect feature
  final Duration debounceTime;  // Delay before filtering suggestions
  final double suggestionItemHeight;  // Height of each suggestion item
  final Widget? prefixIcon;  // Custom prefix icon in the text field
  final Widget? suffixIcon;  // Custom suffix icon in the text field
  final bool enableVoiceInput;  // Enable voice input feature
  final bool enableEmoji;  // Enable emoji input feature
  final List<String>? recentSearches;  // List of recent searches
  final bool caseSensitive;  // Whether the suggestion matching should be case-sensitive
  final String? hintText;  // Hint text for the input field

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
  _MobikulSuggestFieldState createState() => _MobikulSuggestFieldState();
}

class _MobikulSuggestFieldState extends State<MobikulSuggestField> {
  final TextEditingController _controller = TextEditingController();  // Controller to manage text input
  final FocusNode _focusNode = FocusNode();  // Focus node to track text field focus
  List<String> _filteredSuggestions = [];  // Filtered suggestions list based on user input
  List<String> _recentSearches = [];  // Recent searches list
  Timer? _debounceTimer;  // Timer to delay suggestion filtering
  bool _isLoading = false;  // Flag to show loading state for suggestions
  bool _showEmoji = false;  // Flag to show emoji keyboard (if enabled)

  @override
  void initState() {
    super.initState();
    _recentSearches = widget.recentSearches ?? [];
    _controller.addListener(_onTextChanged);  // Add listener for text changes
    _focusNode.addListener(_onFocusChanged);  // Add listener for focus changes
  }

  // Triggered when the focus changes (text field gains or loses focus)
  void _onFocusChanged() {
    if (_focusNode.hasFocus && _controller.text.isEmpty) {
      setState(() {
        _filteredSuggestions = _recentSearches.take(widget.maxSuggestions).toList();
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
      _filteredSuggestions = _recentSearches.take(widget.maxSuggestions).toList();
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
      tileColor: isSelected ? widget.highlightColor?.withOpacity(0.1) : null,
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
      case SuggestionDisplayStyle.list:
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
    _controller.text = suggestion;  // Update text field with the selected suggestion
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

    widget.onSelected(suggestion);  // Call the callback when a suggestion is selected
    _filteredSuggestions.clear();  // Clear suggestions after selection
    _focusNode.unfocus();  // Remove focus from the text field
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
                      _controller.clear();  // Clear the text field
                      setState(() {
                        _filteredSuggestions.clear();  // Clear suggestions
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
                        _showEmoji = !_showEmoji;  // Toggle emoji keyboard
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
          onSubmitted: widget.onSubmitted,  // Handle text field submission
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
            child: _buildSuggestionsList(),  // Display the filtered suggestions
          ),

      ],
    );
  }

  @override
  void dispose() {
    _controller.dispose();  // Dispose the text controller
    _focusNode.dispose();  // Dispose the focus node
    _debounceTimer?.cancel();  // Cancel the debounce timer
    super.dispose();
  }
}
