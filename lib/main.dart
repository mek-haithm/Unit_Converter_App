import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

void main() {
  runApp(const UnitConverterApp());
}

class UnitConverterApp extends StatelessWidget {
  const UnitConverterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Unit Converter',
      theme: ThemeData(scaffoldBackgroundColor: Colors.grey[100]),
      home: const ConverterScreen(),
    );
  }
}

class ConverterScreen extends StatefulWidget {
  const ConverterScreen({super.key});

  @override
  _ConverterScreenState createState() => _ConverterScreenState();
}

class _ConverterScreenState extends State<ConverterScreen> {
  final TextEditingController _controller = TextEditingController();
  String _category = 'Length';
  String _fromUnit = 'Meters';
  String _toUnit = 'Feet';
  double? _result;
  bool _isFlipped = false;

  final Map<String, List<String>> _units = {
    'Length': ['Meters', 'Feet', 'Kilometers', 'Miles'],
    'Weight': ['Kilograms', 'Pounds', 'Grams', 'Ounces'],
    'Temperature': ['Celsius', 'Fahrenheit'],
  };

  final Map<String, Map<String, Map<String, double>>> _conversions = {
    'Length': {
      'Meters': {'Feet': 3.28084, 'Kilometers': 0.001, 'Miles': 0.000621371},
      'Feet': {'Meters': 0.3048, 'Kilometers': 0.0003048, 'Miles': 0.000189394},
      'Kilometers': {'Meters': 1000, 'Feet': 3280.84, 'Miles': 0.621371},
      'Miles': {'Meters': 1609.34, 'Feet': 5280, 'Kilometers': 1.60934},
    },
    'Weight': {
      'Kilograms': {'Pounds': 2.20462, 'Grams': 1000, 'Ounces': 35.274},
      'Pounds': {'Kilograms': 0.453592, 'Grams': 453.592, 'Ounces': 16},
      'Grams': {'Kilograms': 0.001, 'Pounds': 0.00220462, 'Ounces': 0.035274},
      'Ounces': {'Kilograms': 0.0283495, 'Pounds': 0.0625, 'Grams': 28.3495},
    },
    'Temperature': {
      'Celsius': {'Fahrenheit': 1.8}, // Special case handled in _convert
      'Fahrenheit': {'Celsius': 0.555556}, // Special case
    },
  };

  void _convert() {
    final input = double.tryParse(_controller.text);
    if (input == null) {
      setState(() => _result = null);
      return;
    }

    double result;
    if (_category == 'Temperature') {
      if (_fromUnit == 'Celsius' && _toUnit == 'Fahrenheit') {
        result = input * 1.8 + 32;
      } else if (_fromUnit == 'Fahrenheit' && _toUnit == 'Celsius') {
        result = (input - 32) * 0.555556;
      } else {
        result = input; // Same unit
      }
    } else {
      if (_fromUnit == _toUnit) {
        result = input;
      } else {
        result = input * _conversions[_category]![_fromUnit]![_toUnit]!;
      }
    }

    setState(() {
      _result = double.parse(result.toStringAsFixed(2));
      _isFlipped = !_isFlipped; // Trigger flip animation
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: 200,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.orange[300]!, Colors.red[300]!],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: const Center(
                child: Text(
                  'Unit Converter',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: [Shadow(blurRadius: 10, color: Colors.black26)],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  DropdownButton<String>(
                    value: _category,
                    isExpanded: true,
                    items: _units.keys
                        .map((category) => DropdownMenuItem(
                      value: category,
                      child: Text(category),
                    ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _category = value!;
                        _fromUnit = _units[_category]![0];
                        _toUnit = _units[_category]![1];
                        _result = null;
                        _controller.clear();
                      });
                    },
                  ).animate().fadeIn(),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButton<String>(
                          value: _fromUnit,
                          isExpanded: true,
                          items: _units[_category]!
                              .map((unit) => DropdownMenuItem(
                            value: unit,
                            child: Text(unit),
                          ))
                              .toList(),
                          onChanged: (value) => setState(() {
                            _fromUnit = value!;
                            _result = null;
                          }),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: DropdownButton<String>(
                          value: _toUnit,
                          isExpanded: true,
                          items: _units[_category]!
                              .map((unit) => DropdownMenuItem(
                            value: unit,
                            child: Text(unit),
                          ))
                              .toList(),
                          onChanged: (value) => setState(() {
                            _toUnit = value!;
                            _result = null;
                          }),
                        ),
                      ),
                    ],
                  ).animate().slideY(begin: 0.2),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _controller,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: 'Enter value',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onSubmitted: (_) => _convert(),
                  ).animate().fadeIn(),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _convert,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                      backgroundColor: Colors.orange[400],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text(
                      'Convert',
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ).animate().shake(),
                  const SizedBox(height: 20),
                  if (_result != null)
                    Animate(
                      effects: [
                        FlipEffect(
                          duration: 600.ms,
                          direction: Axis.horizontal,
                        ),
                      ],
                      key: ValueKey(_isFlipped),
                      child: Card(
                        elevation: 5,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            '$_result $_toUnit',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}