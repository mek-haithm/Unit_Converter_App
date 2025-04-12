import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:confetti/confetti.dart';

void main() {
  runApp(const UnitConverterApp());
}

class UnitConverterApp extends StatelessWidget {
  const UnitConverterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Unit Converter',
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.transparent,
        textTheme: GoogleFonts.poppinsTextTheme(),
      ),
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
  late ConfettiController _confettiController;

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
      'Celsius': {'Fahrenheit': 1.8},
      'Fahrenheit': {'Celsius': 0.555556},
    },
  };

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 10));
  }

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
        result = input;
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
      _isFlipped = !_isFlipped;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          SizedBox(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              numberOfParticles: 50,
              emissionFrequency: 0.05,
              gravity: 0.05,
              colors: [Colors.white.withValues(alpha: 0.7)],
              maxBlastForce: 20,
              minBlastForce: 5,
              particleDrag: 0.05,
            ),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.black.withValues(alpha: 0.9),
                  Colors.deepPurple.withValues(alpha: 0.8),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  height: 220,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.cyan.withValues(alpha: 0.7),
                        Colors.pink.withValues(alpha: 0.7),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    border: Border(
                      bottom: BorderSide(
                        color: Colors.white.withValues(alpha: 0.2),
                        width: 1,
                      ),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      'Unit Converter',
                      style: GoogleFonts.poppins(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            blurRadius: 20,
                            color: Colors.cyan.withValues(alpha: 0.5),
                          ),
                        ],
                      ),
                    ),
                  ),
                ).animate().fadeIn(duration: 800.ms),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      _buildGlassDropdown(
                        value: _category,
                        items: _units.keys.toList(),
                        onChanged: (value) {
                          setState(() {
                            _category = value!;
                            _fromUnit = _units[_category]![0];
                            _toUnit = _units[_category]![1];
                            _result = null;
                            _controller.clear();
                          });
                        },
                      ).animate().slideX(begin: -0.2),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildGlassDropdown(
                              value: _fromUnit,
                              items: _units[_category]!,
                              onChanged: (value) => setState(() {
                                _fromUnit = value!;
                                _result = null;
                              }),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildGlassDropdown(
                              value: _toUnit,
                              items: _units[_category]!,
                              onChanged: (value) => setState(() {
                                _toUnit = value!;
                                _result = null;
                              }),
                            ),
                          ),
                        ],
                      ).animate().slideX(begin: 0.2),
                      const SizedBox(height: 24),
                      _buildGlassTextField().animate().scale(delay: 200.ms),
                      const SizedBox(height: 24),
                      GestureDetector(
                        onTap: () {
                          _convert();
                          _confettiController.play();
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 40,
                            vertical: 20,
                          ),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.cyan,
                                Colors.pink,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.cyan.withValues(alpha: 0.5),
                                blurRadius: 10,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: Text(
                            'Convert',
                            style: GoogleFonts.poppins(
                              fontSize: 20,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ).animate().scale(
                          begin: const Offset(1, 1),
                          end: const Offset(1.05, 1.05),
                          duration: 1000.ms,
                          curve: Curves.easeInOut),
                      const SizedBox(height: 24),
                      if (_result != null)
                        Animate(
                          effects: [
                            FlipEffect(
                              duration: 800.ms,
                              direction: Axis.horizontal,
                            ),
                            ShimmerEffect(
                              duration: 1000.ms,
                              color: Colors.cyan.withValues(alpha: 0.5),
                            ),
                          ],
                          key: ValueKey(_isFlipped),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.2),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.2),
                                  blurRadius: 10,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: BackdropFilter(
                                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                                child: Container(
                                  padding: const EdgeInsets.all(24),
                                  child: Text(
                                    '$_result $_toUnit',
                                    style: GoogleFonts.poppins(
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      shadows: [
                                        Shadow(
                                          blurRadius: 5,
                                          color: Colors.cyan.withValues(alpha: 0.5),
                                        ),
                                      ],
                                    ),
                                  ),
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
        ],
      ),
    );
  }

  Widget _buildGlassDropdown({
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: DropdownButton<String>(
            value: value,
            isExpanded: true,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            dropdownColor: Colors.black.withValues(alpha: 0.7),
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 16,
            ),
            icon: Icon(
              Icons.arrow_drop_down,
              color: Colors.cyan.withValues(alpha: 0.8),
            ),
            underline: const SizedBox(),
            items: items
                .map((item) => DropdownMenuItem(
              value: item,
              child: Text(item),
            ))
                .toList(),
            onChanged: onChanged,
          ),
        ),
      ),
    );
  }

  Widget _buildGlassTextField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.cyan.withValues(alpha: 0.3),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: TextField(
            controller: _controller,
            keyboardType: TextInputType.number,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 18,
            ),
            decoration: InputDecoration(
              hintText: 'Enter value',
              hintStyle: GoogleFonts.poppins(
                color: Colors.white.withValues(alpha: 0.5),
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 16,
              ),
            ),
            onSubmitted: (_) => _convert(),
          ),
        ),
      ),
    );
  }
}