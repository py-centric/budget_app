import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:budget_app/features/reminders/presentation/widgets/bill_reminder_badge.dart';
import 'package:budget_app/features/tags/presentation/widgets/tag_widgets.dart';
import 'package:budget_app/features/tags/domain/entities/tag.dart';
import 'package:budget_app/shared/widgets/pycentric_footer_widget.dart';
import 'package:budget_app/shared/widgets/branding_footer.dart';
import 'package:budget_app/features/budget/presentation/widgets/slidable_transaction_item.dart';
import 'package:budget_app/features/reminders/presentation/bloc/reminder_bloc.dart';
import 'package:budget_app/features/reminders/presentation/bloc/reminder_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';

class MockReminderBloc extends Mock implements ReminderBloc {}

void main() {
  group('Accessibility & Touch Targets Tests', () {
    testWidgets('TagChip has minimum 48dp height and proper Semantics', (tester) async {
      bool tapped = false;
      final tag = Tag(
        id: 'tag_1',
        name: 'Groceries',
        createdAt: DateTime(2026, 1, 1),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TagChip(
              tag: tag,
              selected: true,
              onTap: () => tapped = true,
            ),
          ),
        ),
      );

      final chipFinder = find.byType(TagChip);
      expect(chipFinder, findsOneWidget);

      final renderBox = tester.renderObject<RenderBox>(chipFinder);
      expect(renderBox.size.height, greaterThanOrEqualTo(48.0));

      final semantics = tester.getSemantics(chipFinder);
      expect(semantics.label, contains('Groceries'));

      await tester.tap(chipFinder);
      expect(tapped, isTrue);
    });

    testWidgets('PyCentricFooterWidget has 48x48dp minimum bounds and Semantics button', (tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PyCentricFooterWidget(
              onTap: () => tapped = true,
            ),
          ),
        ),
      );

      final footerFinder = find.byType(PyCentricFooterWidget);
      expect(footerFinder, findsOneWidget);

      final renderBox = tester.renderObject<RenderBox>(footerFinder);
      expect(renderBox.size.height, greaterThanOrEqualTo(48.0));
      expect(renderBox.size.width, greaterThanOrEqualTo(48.0));

      final inkWellFinder = find.descendant(
        of: footerFinder,
        matching: find.byType(InkWell),
      );
      final inkWellBox = tester.renderObject<RenderBox>(inkWellFinder);
      expect(inkWellBox.size.height, greaterThanOrEqualTo(48.0));
      expect(inkWellBox.size.width, greaterThanOrEqualTo(48.0));

      await tester.tap(inkWellFinder);
      expect(tapped, isTrue);
    });

    testWidgets('BrandingFooter has 48x48dp minimum bounds on interactive element', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: BrandingFooter(),
          ),
        ),
      );

      final inkWellFinder = find.descendant(
        of: find.byType(BrandingFooter),
        matching: find.byType(InkWell),
      );
      expect(inkWellFinder, findsOneWidget);

      final inkWellBox = tester.renderObject<RenderBox>(inkWellFinder);
      expect(inkWellBox.size.height, greaterThanOrEqualTo(48.0));
      expect(inkWellBox.size.width, greaterThanOrEqualTo(48.0));
    });

    testWidgets('SlidableTransactionItem provides custom Semantics actions for Edit, Delete, Confirm', (tester) async {
      bool editCalled = false;
      bool deleteCalled = false;
      bool confirmCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SlidableTransactionItem(
              onEdit: () => editCalled = true,
              onDelete: () => deleteCalled = true,
              onConfirm: () => confirmCalled = true,
              isIncome: true,
              child: const ListTile(title: Text('Salary')),
            ),
          ),
        ),
      );

      final itemFinder = find.byType(SlidableTransactionItem);
      expect(itemFinder, findsOneWidget);

      // Verify custom semantics actions are defined on the Semantics widget
      final semanticsWidget = tester.widget<Semantics>(
        find.descendant(of: itemFinder, matching: find.byType(Semantics)).first,
      );
      final customActions = semanticsWidget.properties.customSemanticsActions;
      expect(customActions, isNotNull);
      final actionLabels = customActions!.keys.map((a) => a.label).toList();
      expect(actionLabels, contains('Edit'));
      expect(actionLabels, contains('Delete'));
      expect(actionLabels, contains('Mark as Received'));

      // Invoke actions
      final editAction = customActions.keys.firstWhere((a) => a.label == 'Edit');
      customActions[editAction]!();
      expect(editCalled, isTrue);

      final deleteAction = customActions.keys.firstWhere((a) => a.label == 'Delete');
      customActions[deleteAction]!();
      expect(deleteCalled, isTrue);

      final confirmAction = customActions.keys.firstWhere((a) => a.label == 'Mark as Received');
      customActions[confirmAction]!();
      expect(confirmCalled, isTrue);
    });

    testWidgets('BillReminderBadge has 48x48dp minimum bounds and Semantics button', (tester) async {
      final mockBloc = MockReminderBloc();
      when(() => mockBloc.state).thenReturn(
        const ReminderLoaded(
          reminders: [],
          unreadCount: 3,
        ),
      );
      when(() => mockBloc.stream).thenAnswer((_) => const Stream.empty());

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BlocProvider<ReminderBloc>.value(
              value: mockBloc,
              child: const BillReminderBadge(
                child: Icon(Icons.notifications),
              ),
            ),
          ),
        ),
      );

      final badgeFinder = find.descendant(
        of: find.byType(BillReminderBadge),
        matching: find.byType(GestureDetector),
      );
      expect(badgeFinder, findsOneWidget);

      final badgeBox = tester.renderObject<RenderBox>(badgeFinder);
      expect(badgeBox.size.height, greaterThanOrEqualTo(48.0));
      expect(badgeBox.size.width, greaterThanOrEqualTo(48.0));
    });
  });
}
