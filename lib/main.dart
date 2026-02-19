
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: CalculatorUI(),
    );
  }
}

class CalculatorUI extends StatefulWidget {
  const CalculatorUI({super.key});

  @override
  State<CalculatorUI> createState() => _CalculatorUIState();
}

class _CalculatorUIState extends State<CalculatorUI> {
  String display = "0";
  String expression = "";
  double? firstNumber;
  String operator = "";
  bool shouldClear = false;

  bool isDarkMode = true;

  void onButtonPressed(String value) {
    setState(() {
      if (value == "C") {
        display = "0";
        expression = "";
        firstNumber = null;
        operator = "";
        shouldClear = false;
        return;
      }

      if (value == "+/-") {
        if (display.startsWith("-")) {
          display = display.substring(1);
        } else if (display != "0") {
          display = "-$display";
        }
        return;
      }

      if (value == "%") {
        double number = double.parse(display);
        display = _format(number / 100);
        return;
      }

      if (["+", "−", "×", "÷"].contains(value)) {
        if (firstNumber != null && operator.isNotEmpty && !shouldClear) {
          _calculate();
        }
        firstNumber = double.parse(display);
        operator = value;
        expression = "$display $value";
        shouldClear = true;
        return;
      }

      if (value == "=") {
        if (firstNumber != null && operator.isNotEmpty) {
          expression = "$expression $display =";
          _calculate();
          operator = "";
          firstNumber = null;
        }
        return;
      }

      if (value == ".") {
        if (!display.contains(".")) {
          display += ".";
        }
        return;
      }

      if (shouldClear) {
        display = value;
        shouldClear = false;
      } else {
        display = display == "0" ? value : display + value;
      }
    });
  }

  void _calculate() {
    double secondNumber = double.parse(display);
    double result = 0;

    switch (operator) {
      case "+":
        result = firstNumber! + secondNumber;
        break;
      case "−":
        result = firstNumber! - secondNumber;
        break;
      case "×":
        result = firstNumber! * secondNumber;
        break;
      case "÷":
        if (secondNumber == 0) {
          display = "Error";
          return;
        }
        result = firstNumber! / secondNumber;
        break;
    }

    display = _format(result);
    firstNumber = result;
    shouldClear = true;
  }

  String _format(double number) {
    if (number == number.toInt()) {
      return number.toInt().toString();
    }
    return number.toString();
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = isDarkMode ? Colors.black : Colors.grey[200]!;
    final displayColor = isDarkMode ? Colors.white : Colors.black;
    final expressionColor = isDarkMode ? Colors.white.withOpacity(0.4) : Colors.black54;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(isDarkMode ? Icons.wb_sunny_outlined : Icons.nightlight_round, color: displayColor),
          onPressed: () {
            setState(() {
              isDarkMode = !isDarkMode;
            });
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.info_outline, color: displayColor),
            onPressed: () {
              showModalBottomSheet(
                backgroundColor: isDarkMode ? Colors.grey[900] : Colors.grey[300],
                context: context,
                builder: (_) {
                  return SizedBox(
                    height: 200,
                    child: Center(
                      child: Text(
                        "Created by Behnam Taheri",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: isDarkMode ? Colors.white : Colors.black,
                          fontSize: 20,
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          )
        ],
      ),
      body: Column(
        children: [
          /// DISPLAY
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              alignment: Alignment.bottomRight,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    expression,
                    style: TextStyle(color: expressionColor, fontSize: 28),
                  ),
                  const SizedBox(height: 10),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      display,
                      style: TextStyle(
                        color: displayColor,
                        fontSize: 90,
                        fontWeight: FontWeight.w200,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          /// BUTTONS
          Expanded(
            flex: 4,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  buildRow(["C", "+/-", "%", "÷"], isTop: true),
                  buildRow(["7", "8", "9", "×"]),
                  buildRow(["4", "5", "6", "−"]),
                  buildRow(["1", "2", "3", "+"]),
                  buildLastRow(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildRow(List<String> texts, {bool isTop = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: texts.map((text) {
        return buildButton(
          text,
          bgColor: isTop
              ? (isDarkMode ? const Color(0xFFA5A5A5) : Colors.grey[300]!)
              : (isOperator(text)
                  ? const Color(0xFFFF9500)
                  : (isDarkMode ? const Color(0xFF333333) : Colors.grey[400]!)),
          textColor: isTop
              ? Colors.black
              : (isOperator(text) ? Colors.white : isDarkMode ? Colors.white : Colors.black),
        );
      }).toList(),
    );
  }

  Widget buildLastRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        buildWideButton("0"),
        buildButton("."),
        buildButton("=", bgColor: const Color(0xFFFF9500)),
      ],
    );
  }

  Widget buildWideButton(String text) {
    return SizedBox(
      width: 170,
      height: 75,
      child: _animatedButton(
        text,
        bgColor: isDarkMode ? const Color(0xFF333333) : Colors.grey[400]!,
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 30),
        borderRadius: 40,
      ),
    );
  }

  Widget buildButton(String text,
      {Color bgColor = const Color(0xFF333333),
      Color textColor = Colors.white}) {
    return SizedBox(
      width: 75,
      height: 75,
      child: _animatedButton(
        text,
        bgColor: bgColor,
        textColor: textColor,
        borderRadius: 75,
      ),
    );
  }

  Widget _animatedButton(
    String text, {
    required Color bgColor,
    Color textColor = Colors.white,
    Alignment alignment = Alignment.center,
    EdgeInsets padding = EdgeInsets.zero,
    double borderRadius = 75,
  }) {
    return Material(
      color: bgColor,
      borderRadius: BorderRadius.circular(borderRadius),
      child: InkWell(
        borderRadius: BorderRadius.circular(borderRadius),
        splashColor: Colors.white24,
        onTap: () => onButtonPressed(text),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          alignment: alignment,
          padding: padding,
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                offset: const Offset(2, 2),
                blurRadius: 4,
              ),
            ],
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          child: Text(
            text,
            style: TextStyle(
              color: textColor,
              fontSize: 28,
            ),
          ),
        ),
      ),
    );
  }

  bool isOperator(String text) {
    return ["÷", "×", "−", "+", "="].contains(text);
  }
}
