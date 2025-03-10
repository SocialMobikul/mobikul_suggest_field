import 'package:flutter/material.dart';
import 'package:mobikul_suggest_field/mobikul_suggest_field.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mobikul Suggestions Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Example data
  List<Suggestion> suggestions = [
    Suggestion(name: 'Canada', icon: Icons.flag),
    Suggestion(name: 'Australia', icon: Icons.public),
    Suggestion(name: 'Germany', icon: Icons.language),
    Suggestion(name: 'France', icon: Icons.map),
    Suggestion(name: 'Italy', icon: Icons.travel_explore),
    Suggestion(name: 'Spain', icon: Icons.flight),
    Suggestion(name: 'Japan', icon: Icons.location_on),
    Suggestion(name: 'China', icon: Icons.apartment),
    Suggestion(name: 'India', icon: Icons.place),
    Suggestion(name: 'Brazil', icon: Icons.explore),
    Suggestion(name: 'Mexico', icon: Icons.terrain),
    Suggestion(name: 'Russia', icon: Icons.landscape),
    Suggestion(name: 'South Korea', icon: Icons.route),
    Suggestion(name: 'Argentina', icon: Icons.airplanemode_active),
    Suggestion(name: 'Belgium', icon: Icons.business),
    Suggestion(name: 'South Africa', icon: Icons.nature),
    Suggestion(name: 'Switzerland', icon: Icons.star),
    Suggestion(name: 'Sweden', icon: Icons.home),
    Suggestion(name: 'Netherlands', icon: Icons.account_balance),
    Suggestion(name: 'Norway', icon: Icons.museum),
    Suggestion(name: 'Greece', icon: Icons.beach_access),
    Suggestion(name: 'Egypt', icon: Icons.directions_boat),
    Suggestion(name: 'Thailand', icon: Icons.wb_sunny),
    Suggestion(name: 'Singapore', icon: Icons.eco),
    Suggestion(name: 'Turkey', icon: Icons.forest),
    Suggestion(name: 'Poland', icon: Icons.military_tech),
    Suggestion(name: 'Israel', icon: Icons.sports_soccer),
    Suggestion(name: 'Denmark', icon: Icons.sports_basketball),
    Suggestion(name: 'Finland', icon: Icons.sports_cricket),
    Suggestion(name: 'Indonesia', icon: Icons.monetization_on),
    Suggestion(name: 'Malaysia', icon: Icons.flag), // Icons repeat from start
    Suggestion(name: 'Vietnam', icon: Icons.public),
    Suggestion(name: 'Saudi Arabia', icon: Icons.language),
  ];

  String _selectedCountry = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Country Search Example'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              // Basic Usage
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Country Name',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    MobikulSuggestField(
                      displayStyle: SuggestionDisplayStyle.grid,
                      suggestions: suggestions,
                      decoration: InputDecoration(
                        labelText: 'Search Countries',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.grey[100],
                      ),
                      onSelected: (value) {
                        setState(() {
                          _selectedCountry = value.name;
                        });
                      },
                      hintText: 'Search Countries',
                    ),
                  ],
                ),
              ),

              if (_selectedCountry.isNotEmpty)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        const Text(
                          'Selected Country: ',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          _selectedCountry,
                          style: const TextStyle(
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
