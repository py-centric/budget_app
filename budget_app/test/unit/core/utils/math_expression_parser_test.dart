import 'package:flutter_test/flutter_test.dart';
import 'package:budget_app/core/utils/math_expression_parser.dart';

void main() {
  group('MathExpressionParser', () {
    group('evaluate', () {
      test('parses simple number', () {
        expect(MathExpressionParser.evaluate('100'), 100.0);
      });

      test('parses decimal number', () {
        expect(MathExpressionParser.evaluate('99.50'), 99.50);
      });

      test('adds two numbers', () {
        expect(MathExpressionParser.evaluate('50 + 50'), 100.0);
      });

      test('subtracts two numbers', () {
        expect(MathExpressionParser.evaluate('100 - 30'), 70.0);
      });

      test('multiplies two numbers', () {
        expect(MathExpressionParser.evaluate('10 * 10'), 100.0);
      });

      test('divides two numbers', () {
        expect(MathExpressionParser.evaluate('100 / 4'), 25.0);
      });

      test('handles division by zero', () {
        expect(MathExpressionParser.evaluate('100 / 0'), 100.0);
      });

      test('evaluates multiplication before addition (BODMAS)', () {
        expect(MathExpressionParser.evaluate('10 + 5 * 10'), 60.0);
      });

      test('evaluates division before addition (BODMAS)', () {
        expect(MathExpressionParser.evaluate('100 + 50 / 2'), 125.0);
      });

      test('evaluates multiplication before subtraction (BODMAS)', () {
        expect(MathExpressionParser.evaluate('100 - 20 * 3'), 40.0);
      });

      test('handles complex expression with BODMAS', () {
        expect(MathExpressionParser.evaluate('100 - 200 + 300 * 2'), 500.0);
      });

      test('handles multiple operations in sequence', () {
        expect(MathExpressionParser.evaluate('1 + 2 + 3 + 4'), 10.0);
      });

      test('handles subtraction chain', () {
        expect(MathExpressionParser.evaluate('100 - 20 - 30'), 50.0);
      });

      test('handles multiple multiplications', () {
        expect(MathExpressionParser.evaluate('2 * 3 * 4'), 24.0);
      });

      test('evaluates parentheses first', () {
        expect(MathExpressionParser.evaluate('(10 + 5) * 2'), 30.0);
      });

      test('evaluates nested parentheses', () {
        expect(MathExpressionParser.evaluate('((10 + 5)) * 2'), 30.0);
      });

      test('handles parentheses with BODMAS inside', () {
        expect(MathExpressionParser.evaluate('(10 + 5 * 2)'), 20.0);
      });

      test('handles multiple parentheses groups', () {
        expect(MathExpressionParser.evaluate('(10 + 5) + (3 * 2)'), 21.0);
      });

      test('ignores whitespace', () {
        expect(MathExpressionParser.evaluate('10 + 5 * 2'), 20.0);
      });

      test('returns null for empty string', () {
        expect(MathExpressionParser.evaluate(''), null);
      });

      test('returns null for invalid expression', () {
        expect(MathExpressionParser.evaluate('abc'), null);
      });

      test('returns null for mismatched parentheses', () {
        expect(MathExpressionParser.evaluate('(10 + 5'), null);
        expect(MathExpressionParser.evaluate('10 + 5)'), null);
      });

      test('handles expression with only negative result', () {
        expect(MathExpressionParser.evaluate('50 - 100'), -50.0);
      });
    });

    group('getPreview', () {
      test('returns formatted preview for valid expression', () {
        expect(MathExpressionParser.getPreview('100 + 50'), '= 150.00');
      });

      test('returns empty string for invalid expression', () {
        expect(MathExpressionParser.getPreview('abc'), '');
      });

      test('returns empty string for empty expression', () {
        expect(MathExpressionParser.getPreview(''), '');
      });

      test('shows 2 decimal places', () {
        expect(MathExpressionParser.getPreview('10 / 3'), '= 3.33');
      });
    });

    group('highlightSyntax', () {
      test('returns empty span for empty text', () {
        final span = MathExpressionParser.highlightSyntax('');
        expect(span.text, '');
      });

      test('highlights numbers with bold', () {
        final span = MathExpressionParser.highlightSyntax('100');
        expect(span.children, isNotNull);
      });

      test('highlights operators in blue', () {
        final span = MathExpressionParser.highlightSyntax('100 + 50');
        expect(span.children, isNotNull);
      });
    });
  });
}
