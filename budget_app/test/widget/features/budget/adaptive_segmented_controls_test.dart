import 'package:budget_app/features/budget/domain/entities/category_limit.dart';
import 'package:budget_app/features/budget/presentation/widgets/category_limit_dialog.dart';
import 'package:budget_app/features/export/domain/entities/export_format.dart';
import 'package:budget_app/features/export/presentation/bloc/export_bloc.dart';
import 'package:budget_app/features/export/presentation/bloc/export_state.dart';
import 'package:budget_app/features/export/presentation/widgets/export_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/adaptive_test_harness.dart';

class MockExportBloc extends Mock implements ExportBloc {}

/// US1 call-site tests (T016): real SegmentedButton call sites (category limit
/// period selector and export format selector) must render the
/// AdaptiveSegmentedControl with the Cupertino sliding control on iOS and the
/// Material SegmentedButton on Android, single-select preserved.
void main() {
  late MockExportBloc mockExportBloc;

  setUp(() {
    mockExportBloc = MockExportBloc();
    when(() => mockExportBloc.state).thenReturn(const ExportState());
    when(
      () => mockExportBloc.stream,
    ).thenAnswer((_) => const Stream<ExportState>.empty());
  });

  Widget limitDialogSurface() {
    return Scaffold(
      body: CategoryLimitDialog(
        categories: const [],
        onSave: (String categoryId, double amount, LimitPeriod period) {},
      ),
    );
  }

  Widget exportDialogSurface() {
    return Scaffold(
      body: BlocProvider<ExportBloc>.value(
        value: mockExportBloc,
        child: const ExportDialog(),
      ),
    );
  }

  group('segmented call sites - Android branch (zero-regression)', () {
    testWidgets('category limit period stays a Material SegmentedButton',
        (tester) async {
      await AdaptiveTestHarness.pump(
        tester,
        platform: TargetPlatform.android,
        child: limitDialogSurface(),
      );

      expect(find.byType(SegmentedButton<LimitPeriod>), findsOneWidget);
      expect(
        find.byType(CupertinoSlidingSegmentedControl<LimitPeriod>),
        findsNothing,
      );
    });

    testWidgets('export format stays a Material SegmentedButton',
        (tester) async {
      await AdaptiveTestHarness.pump(
        tester,
        platform: TargetPlatform.android,
        child: exportDialogSurface(),
      );

      expect(find.byType(SegmentedButton<ExportFormat>), findsOneWidget);
      expect(
        find.byType(CupertinoSlidingSegmentedControl<ExportFormat>),
        findsNothing,
      );
    });
  });

  group('segmented call sites - iOS branch', () {
    testWidgets('category limit period renders the Cupertino sliding control',
        (tester) async {
      await AdaptiveTestHarness.pump(
        tester,
        platform: TargetPlatform.iOS,
        child: limitDialogSurface(),
      );

      expect(
        find.byType(CupertinoSlidingSegmentedControl<LimitPeriod>),
        findsOneWidget,
      );
      expect(find.byType(SegmentedButton<LimitPeriod>), findsNothing);
    });

    testWidgets('export format renders the Cupertino sliding control',
        (tester) async {
      await AdaptiveTestHarness.pump(
        tester,
        platform: TargetPlatform.iOS,
        child: exportDialogSurface(),
      );

      expect(
        find.byType(CupertinoSlidingSegmentedControl<ExportFormat>),
        findsOneWidget,
      );
      expect(find.byType(SegmentedButton<ExportFormat>), findsNothing);
    });

    testWidgets('single-select behavior is preserved (tap does not throw)',
        (tester) async {
      await AdaptiveTestHarness.pump(
        tester,
        platform: TargetPlatform.iOS,
        child: limitDialogSurface(),
      );

      await tester.tap(find.byType(CupertinoSlidingSegmentedControl<LimitPeriod>));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });

    testWidgets('no overflow at max text scale', (tester) async {
      await AdaptiveTestHarness.pump(
        tester,
        platform: TargetPlatform.iOS,
        child: MediaQuery(
          data: const MediaQueryData(textScaler: TextScaler.linear(2.0)),
          child: limitDialogSurface(),
        ),
      );

      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  });
}
