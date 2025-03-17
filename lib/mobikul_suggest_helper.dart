import 'package:flutter/material.dart';

import 'mobikul_suggest_field.dart';

class SuggestHelper {
  // Build the suggestions list based on display style
  static Widget buildSuggestionsList(
      List<Suggestion> filteredSuggestions, SuggestionDisplayStyle displayStyle,
      {required String text,
        TextStyle? suggestionStyle,
        Color? highlightColor,
        required Function(Suggestion) onSuggestionSelected}) {
    switch (displayStyle) {
      case SuggestionDisplayStyle.grid:
        return GridView.builder(
          shrinkWrap: true,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 3,
          ),
          itemCount: filteredSuggestions.length,
          itemBuilder: (context, index) {
            return buildSuggestionItem(
                suggestion: filteredSuggestions[index],
                suggestionStyle: suggestionStyle,
                highlightColor: highlightColor,
                text: text,
                onSuggestionSelected: onSuggestionSelected);
          },
        );
      case SuggestionDisplayStyle.chips:
        return SingleChildScrollView(
          scrollDirection: Axis.vertical, // Allows vertical scrolling if needed
          child: Wrap(
            spacing: 8.0,
            runSpacing: 4.0, // Adds spacing between rows
            children: filteredSuggestions
                .map((suggestion) => ActionChip(
              avatar: Icon(suggestion.icon),
              label: Text(suggestion.name),
              onPressed: () => onSuggestionSelected(suggestion),
            ))
                .toList(),
          ),
        );
      default:
        return ListView.builder(
          shrinkWrap: true,
          itemCount: filteredSuggestions.length,
          itemBuilder: (context, index) {
            return _buildHighlightedText(filteredSuggestions[index], text,
                suggestionStyle, onSuggestionSelected);
          },
        );
    }
  }

  static Widget _buildHighlightedText(
      Suggestion suggestion,
      String text,
      TextStyle? suggestionStyle,
      Function(Suggestion p1) onSuggestionSelected,
      ) {
    String input = text;
    if (input.isEmpty) {
      return Text(suggestion.name, style: suggestionStyle);
    }

    int startIndex = suggestion.name.toLowerCase().indexOf(input.toLowerCase());
    if (startIndex == -1) {
      return Text(suggestion.name, style: suggestionStyle);
    }

    int endIndex = startIndex + input.length;

    return ListTile(
      leading: Icon(suggestion.icon),
      title: RichText(
        text: TextSpan(
          style: suggestionStyle ?? const TextStyle(color: Colors.black),
          children: [
            TextSpan(text: suggestion.name.substring(0, startIndex)),
            TextSpan(
              text: suggestion.name.substring(startIndex, endIndex),
              style: const TextStyle(
                  fontWeight: FontWeight.bold, color: Colors.blue),
            ),
            TextSpan(text: suggestion.name.substring(endIndex)),
          ],
        ),
      ),
      onTap: () => onSuggestionSelected(suggestion),
    );
  }

  // Build individual suggestion item
  static Widget buildSuggestionItem(
      {required Suggestion suggestion,
        required String text,
        TextStyle? suggestionStyle,
        Color? highlightColor,
        required Function(Suggestion) onSuggestionSelected}) {
    final bool isSelected = text == suggestion.name;
    return ListTile(
      leading: Icon(suggestion.icon), // Wrap IconData inside Icon

      title: Text(
        suggestion.name,
        style: suggestionStyle?.copyWith(
          color: isSelected ? highlightColor : null,
        ),
      ),
      onTap: () => onSuggestionSelected(suggestion),
    );
  }
}
