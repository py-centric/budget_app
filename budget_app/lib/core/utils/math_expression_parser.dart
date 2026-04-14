import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MathExpressionParser {
  static double? evaluate(String expression) {
    if (expression.isEmpty) return null;

    try {
      final sanitized = expression.replaceAll(' ', '');
      if (!_isValidExpression(sanitized)) return null;
      return _evaluate(sanitized);
    } catch (e) {
      return null;
    }
  }

  static bool _isValidExpression(String expr) {
    if (expr.isEmpty) return false;

    final clean = expr.replaceAll(RegExp(r'\d+\.?\d*'), '').replaceAll('.', '');
    for (final char in clean.split('')) {
      if (!'+-*/().'.contains(char)) return false;
    }

    int parenCount = 0;
    for (final char in expr.split('')) {
      if (char == '(') parenCount++;
      if (char == ')') parenCount--;
      if (parenCount < 0) return false;
    }
    return parenCount == 0;
  }

  static double _evaluate(String expr) {
    expr = expr.replaceAll(' ', '');

    if (expr.isEmpty) return 0;
    if (!expr.contains(RegExp(r'[+\-*/]'))) {
      return double.tryParse(expr) ?? 0;
    }

    final parenStart = expr.lastIndexOf('(');
    if (parenStart != -1) {
      final parenEnd = expr.indexOf(')', parenStart);
      if (parenEnd == -1) throw Exception('Mismatched parentheses');

      final innerResult = _evaluate(expr.substring(parenStart + 1, parenEnd));
      final newExpr =
          expr.substring(0, parenStart) +
          innerResult.toString() +
          expr.substring(parenEnd + 1);
      return _evaluate(newExpr);
    }

    return _evaluateBODMAS(expr);
  }

  static double _evaluateBODMAS(String expr) {
    expr = expr.replaceAll(' ', '');

    while (expr.contains('*') || expr.contains('/')) {
      final multIdx = expr.indexOf('*');
      final divIdx = expr.indexOf('/');

      int opIdx = -1;
      bool isMult = false;

      if (multIdx != -1 && divIdx != -1) {
        opIdx = multIdx < divIdx ? multIdx : divIdx;
        isMult = opIdx == multIdx;
      } else if (multIdx != -1) {
        opIdx = multIdx;
        isMult = true;
      } else if (divIdx != -1) {
        opIdx = divIdx;
        isMult = false;
      }

      if (opIdx == -1) break;

      int leftStart = opIdx - 1;
      while (leftStart >= 0 &&
          (RegExp(r'\d|\.').hasMatch(expr[leftStart]) ||
              expr[leftStart] == '.')) {
        leftStart--;
      }
      leftStart++;

      int rightEnd = opIdx + 1;
      while (rightEnd < expr.length &&
          (RegExp(r'\d|\.').hasMatch(expr[rightEnd]) ||
              expr[rightEnd] == '.')) {
        rightEnd++;
      }

      final leftNum = double.tryParse(expr.substring(leftStart, opIdx)) ?? 0;
      final rightNum =
          double.tryParse(expr.substring(opIdx + 1, rightEnd)) ?? 0;
      final result = isMult
          ? leftNum * rightNum
          : (rightNum != 0 ? leftNum / rightNum : leftNum);

      expr =
          expr.substring(0, leftStart) +
          result.toString() +
          expr.substring(rightEnd);
    }

    double result = 0;
    String currentNum = '';
    String lastOp = '+';
    bool isFirstNumber = true;

    for (int i = 0; i < expr.length; i++) {
      final char = expr[i];

      if (RegExp(r'\d|\.').hasMatch(char) ||
          (char == '.' && currentNum.isNotEmpty)) {
        currentNum += char;
      } else if ('+-'.contains(char)) {
        final num = double.tryParse(currentNum) ?? 0;
        if (isFirstNumber) {
          result = num;
          isFirstNumber = false;
        } else {
          result = _applyOperation(result, num, lastOp);
        }
        lastOp = char;
        currentNum = '';
      }
    }

    if (currentNum.isNotEmpty) {
      final num = double.tryParse(currentNum) ?? 0;
      if (isFirstNumber) {
        result = num;
      } else {
        result = _applyOperation(result, num, lastOp);
      }
    }

    return result;
  }

  static double _applyOperation(double a, double b, String op) {
    switch (op) {
      case '+':
        return a + b;
      case '-':
        return a - b;
      case '*':
        return a * b;
      case '/':
        return b != 0 ? a / b : a;
      default:
        return b;
    }
  }

  static String getPreview(String expression) {
    final result = evaluate(expression);
    if (result == null) return '';
    return '= ${result.toStringAsFixed(2)}';
  }

  static TextSpan highlightSyntax(String text, {TextStyle? baseStyle}) {
    if (text.isEmpty) return TextSpan(text: text, style: baseStyle);

    final List<TextSpan> spans = [];
    final regex = RegExp(r'(\d+\.?\d*)|([+\-*/()])|(\s+)');

    for (final match in regex.allMatches(text)) {
      if (match.group(1) != null) {
        spans.add(
          TextSpan(
            text: match.group(1),
            style:
                baseStyle?.copyWith(fontWeight: FontWeight.bold) ??
                const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
          ),
        );
      } else if (match.group(2) != null) {
        final op = match.group(2)!;
        spans.add(
          TextSpan(
            text: op,
            style:
                baseStyle?.copyWith(
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                ) ??
                const TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                ),
          ),
        );
      } else if (match.group(3) != null) {
        spans.add(TextSpan(text: match.group(3), style: baseStyle));
      }
    }

    return TextSpan(children: spans);
  }
}

class MathTextField extends StatefulWidget {
  final TextEditingController controller;
  final String labelText;
  final String? prefixText;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;

  const MathTextField({
    super.key,
    required this.controller,
    required this.labelText,
    this.prefixText,
    this.validator,
    this.onChanged,
  });

  @override
  State<MathTextField> createState() => _MathTextFieldState();
}

class _MathTextFieldState extends State<MathTextField> {
  String _preview = '';

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_updatePreview);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_updatePreview);
    super.dispose();
  }

  void _updatePreview() {
    final preview = MathExpressionParser.getPreview(widget.controller.text);
    if (preview != _preview) {
      setState(() {
        _preview = preview;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextFormField(
          controller: widget.controller,
          decoration: InputDecoration(
            labelText: widget.labelText,
            prefixText: widget.prefixText,
            suffixIcon: _preview.isNotEmpty
                ? Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: Text(
                      _preview,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  )
                : null,
          ),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[\d+\-*/().\s]')),
          ],
          validator: widget.validator,
          onChanged: widget.onChanged,
        ),
      ],
    );
  }
}
