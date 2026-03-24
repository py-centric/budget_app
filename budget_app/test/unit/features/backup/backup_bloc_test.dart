import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:budget_app/features/backup/domain/entities/import_result.dart';
import 'package:budget_app/features/backup/domain/services/backup_service.dart';
import 'package:budget_app/features/backup/presentation/bloc/backup_bloc.dart';
import 'package:budget_app/features/backup/presentation/bloc/backup_event.dart';
import 'package:budget_app/features/backup/presentation/bloc/backup_state.dart';

class MockBackupService extends Mock implements BackupService {}

class FakeImportResult extends Fake implements ImportResult {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeImportResult());
  });
  group('BackupBloc', () {
    late MockBackupService mockBackupService;
    late BackupBloc bloc;

    setUp(() {
      mockBackupService = MockBackupService();
    });

    tearDown(() {
      bloc.close();
    });

    test('initial state is BackupStatus.initial', () {
      bloc = BackupBloc(backupService: mockBackupService);
      expect(bloc.state.status, equals(BackupStatus.initial));
    });

    group('BackupExport', () {
      blocTest<BackupBloc, BackupState>(
        'emits success when export succeeds',
        build: () {
          when(
            () => mockBackupService.exportDatabase(),
          ).thenAnswer((_) async => '/path/to/backup.db');
          return BackupBloc(backupService: mockBackupService);
        },
        act: (bloc) => bloc.add(BackupExport()),
        expect: () => [
          isA<BackupState>().having(
            (s) => s.status,
            'status',
            BackupStatus.loading,
          ),
          isA<BackupState>()
              .having((s) => s.status, 'status', BackupStatus.success)
              .having((s) => s.filePath, 'filePath', '/path/to/backup.db')
              .having(
                (s) => s.successMessage,
                'successMessage',
                contains('created successfully'),
              ),
        ],
      );

      blocTest<BackupBloc, BackupState>(
        'emits error when export fails',
        build: () {
          when(
            () => mockBackupService.exportDatabase(),
          ).thenThrow(Exception('Database not found'));
          return BackupBloc(backupService: mockBackupService);
        },
        act: (bloc) => bloc.add(BackupExport()),
        expect: () => [
          isA<BackupState>().having(
            (s) => s.status,
            'status',
            BackupStatus.loading,
          ),
          isA<BackupState>()
              .having((s) => s.status, 'status', BackupStatus.error)
              .having(
                (s) => s.errorMessage,
                'errorMessage',
                contains('Failed to export'),
              ),
        ],
      );
    });

    group('BackupImport', () {
      blocTest<BackupBloc, BackupState>(
        'emits success when import succeeds',
        build: () {
          when(
            () => mockBackupService.validateBackup(any()),
          ).thenAnswer((_) async => true);
          when(() => mockBackupService.importDatabase(any())).thenAnswer(
            (_) async => const ImportResult(
              success: true,
              tablesImported: 5,
              recordsImported: 100,
            ),
          );
          return BackupBloc(backupService: mockBackupService);
        },
        act: (bloc) =>
            bloc.add(const BackupImport(filePath: '/path/to/backup.db')),
        expect: () => [
          isA<BackupState>().having(
            (s) => s.status,
            'status',
            BackupStatus.loading,
          ),
          isA<BackupState>()
              .having((s) => s.status, 'status', BackupStatus.success)
              .having(
                (s) => s.successMessage,
                'successMessage',
                contains('5 tables'),
              )
              .having((s) => s.tableCount, 'tableCount', 5)
              .having((s) => s.recordCount, 'recordCount', 100),
        ],
      );

      blocTest<BackupBloc, BackupState>(
        'emits error when file is invalid',
        build: () {
          when(
            () => mockBackupService.validateBackup(any()),
          ).thenAnswer((_) async => false);
          return BackupBloc(backupService: mockBackupService);
        },
        act: (bloc) =>
            bloc.add(const BackupImport(filePath: '/invalid/file.db')),
        expect: () => [
          isA<BackupState>().having(
            (s) => s.status,
            'status',
            BackupStatus.loading,
          ),
          isA<BackupState>()
              .having((s) => s.status, 'status', BackupStatus.error)
              .having(
                (s) => s.errorMessage,
                'errorMessage',
                contains('Invalid backup'),
              ),
        ],
      );

      blocTest<BackupBloc, BackupState>(
        'emits error when import fails',
        build: () {
          when(
            () => mockBackupService.validateBackup(any()),
          ).thenAnswer((_) async => true);
          when(
            () => mockBackupService.importDatabase(any()),
          ).thenAnswer((_) async => ImportResult.failure('Corrupted file'));
          return BackupBloc(backupService: mockBackupService);
        },
        act: (bloc) =>
            bloc.add(const BackupImport(filePath: '/path/to/backup.db')),
        expect: () => [
          isA<BackupState>().having(
            (s) => s.status,
            'status',
            BackupStatus.loading,
          ),
          isA<BackupState>()
              .having((s) => s.status, 'status', BackupStatus.error)
              .having(
                (s) => s.errorMessage,
                'errorMessage',
                contains('Corrupted file'),
              ),
        ],
      );
    });

    group('BackupShare', () {
      blocTest<BackupBloc, BackupState>(
        'calls share service',
        build: () {
          when(
            () => mockBackupService.shareBackup(any()),
          ).thenAnswer((_) async {});
          return BackupBloc(backupService: mockBackupService);
        },
        act: (bloc) =>
            bloc.add(const BackupShare(filePath: '/path/to/backup.db')),
        verify: (_) {
          verify(
            () => mockBackupService.shareBackup('/path/to/backup.db'),
          ).called(1);
        },
      );
    });

    group('BackupReset', () {
      blocTest<BackupBloc, BackupState>(
        'resets to initial state',
        build: () => BackupBloc(backupService: mockBackupService),
        seed: () => const BackupState(
          status: BackupStatus.success,
          filePath: '/some/path',
        ),
        act: (bloc) => bloc.add(BackupReset()),
        expect: () => [const BackupState()],
      );
    });
  });
}
