import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:budget_app/features/export/domain/entities/export_configuration.dart';
import 'package:budget_app/features/export/domain/entities/export_format.dart';
import 'package:budget_app/features/export/domain/entities/export_period.dart';
import 'package:budget_app/features/export/domain/services/export_service.dart';
import 'package:budget_app/features/export/presentation/bloc/export_bloc.dart';
import 'package:budget_app/features/export/presentation/bloc/export_event.dart';
import 'package:budget_app/features/export/presentation/bloc/export_state.dart';

class MockExportService extends Mock implements ExportService {}

class FakeExportConfiguration extends Fake implements ExportConfiguration {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeExportConfiguration());
  });
  group('ExportBloc', () {
    late MockExportService mockExportService;
    late ExportBloc bloc;

    setUp(() {
      mockExportService = MockExportService();
    });

    tearDown(() {
      bloc.close();
    });

    test('initial state is ExportStatus.initial', () {
      bloc = ExportBloc(exportService: mockExportService);
      expect(bloc.state.status, equals(ExportStatus.initial));
    });

    group('ExportConfigure', () {
      blocTest<ExportBloc, ExportState>(
        'emits configured state with configuration',
        build: () => ExportBloc(exportService: mockExportService),
        act: (bloc) => bloc.add(
          ExportConfigure(
            const ExportConfiguration(
              period: ExportPeriod.currentMonth,
              format: ExportFormat.csv,
            ),
          ),
        ),
        expect: () => [
          isA<ExportState>().having(
            (s) => s.status,
            'status',
            ExportStatus.configured,
          ),
        ],
      );
    });

    group('ExportGenerate', () {
      final testTransactions = [
        {
          'date': '2024-01-01',
          'amount': 100.0,
          'category': 'Food',
          'description': 'Test',
        },
      ];
      final testSummary = {
        'totalIncome': 100.0,
        'totalExpenses': 50.0,
        'balance': 50.0,
      };
      const testConfig = ExportConfiguration(
        period: ExportPeriod.currentMonth,
        format: ExportFormat.csv,
      );

      blocTest<ExportBloc, ExportState>(
        'emits success when export succeeds',
        build: () {
          when(
            () => mockExportService.getTransactions(testConfig),
          ).thenAnswer((_) async => testTransactions);
          when(
            () => mockExportService.getSummary(testConfig),
          ).thenAnswer((_) async => testSummary);
          when(
            () => mockExportService.generateCsv(testTransactions),
          ).thenAnswer((_) async => '/path/to/export.csv');
          return ExportBloc(exportService: mockExportService);
        },
        seed: () => const ExportState(
          status: ExportStatus.configured,
          configuration: testConfig,
        ),
        act: (bloc) => bloc.add(ExportGenerate()),
        expect: () => [
          isA<ExportState>().having(
            (s) => s.status,
            'status',
            ExportStatus.loading,
          ),
          isA<ExportState>().having(
            (s) => s.status,
            'status',
            ExportStatus.generating,
          ),
          isA<ExportState>()
              .having((s) => s.status, 'status', ExportStatus.success)
              .having((s) => s.filePath, 'filePath', '/path/to/export.csv'),
        ],
      );

      blocTest<ExportBloc, ExportState>(
        'emits error when no configuration',
        build: () => ExportBloc(exportService: mockExportService),
        act: (bloc) => bloc.add(ExportGenerate()),
        expect: () => [
          isA<ExportState>()
              .having((s) => s.status, 'status', ExportStatus.error)
              .having(
                (s) => s.errorMessage,
                'errorMessage',
                contains('configure'),
              ),
        ],
      );

      blocTest<ExportBloc, ExportState>(
        'emits error when no transactions found',
        build: () {
          when(
            () => mockExportService.getTransactions(any()),
          ).thenAnswer((_) async => []);
          return ExportBloc(exportService: mockExportService);
        },
        seed: () => const ExportState(
          status: ExportStatus.configured,
          configuration: testConfig,
        ),
        act: (bloc) => bloc.add(ExportGenerate()),
        expect: () => [
          isA<ExportState>().having(
            (s) => s.status,
            'status',
            ExportStatus.loading,
          ),
          isA<ExportState>()
              .having((s) => s.status, 'status', ExportStatus.error)
              .having(
                (s) => s.errorMessage,
                'errorMessage',
                contains('No transactions'),
              ),
        ],
      );
    });

    group('ExportReset', () {
      blocTest<ExportBloc, ExportState>(
        'resets to initial state',
        build: () => ExportBloc(exportService: mockExportService),
        seed: () => const ExportState(
          status: ExportStatus.success,
          filePath: '/some/path',
        ),
        act: (bloc) => bloc.add(ExportReset()),
        expect: () => [const ExportState()],
      );
    });
  });
}
