import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:budget_app/shared/widgets/pycentric_footer_widget.dart';
import 'package:budget_app/shared/widgets/branding_footer.dart';

void main() {
  group('PyCentricFooterWidget', () {
    testWidgets('renders Developed by PyCentric text', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PyCentricFooterWidget(),
          ),
        ),
      );

      expect(find.text('Developed by PyCentric'), findsOneWidget);
    });

    testWidgets('adapts to dark mode theme', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(),
          home: const Scaffold(
            body: PyCentricFooterWidget(),
          ),
        ),
      );

      expect(find.text('Developed by PyCentric'), findsOneWidget);
    });

    testWidgets('opens PyCentricAboutDialog on tap', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PyCentricFooterWidget(),
          ),
        ),
      );

      await tester.tap(find.text('Developed by PyCentric'));
      await tester.pumpAndSettle();

      expect(find.text('PyCentric'), findsOneWidget);
      expect(find.text('Close'), findsOneWidget);
    });
  });

  group('BrandingFooter', () {
    testWidgets('renders Developed by PyCentric text and triggers dialog on tap', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: BrandingFooter(),
          ),
        ),
      );

      expect(find.text('Developed by PyCentric'), findsOneWidget);

      await tester.tap(find.text('Developed by PyCentric'));
      await tester.pumpAndSettle();

      expect(find.text('PyCentric'), findsOneWidget);
      expect(find.text('Close'), findsOneWidget);
    });
  });
}
