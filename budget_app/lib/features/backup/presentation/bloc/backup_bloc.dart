import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/services/backup_service.dart';
import 'backup_event.dart';
import 'backup_state.dart';

class BackupBloc extends Bloc<BackupEvent, BackupState> {
  final BackupService _backupService;

  BackupBloc({required BackupService backupService})
    : _backupService = backupService,
      super(const BackupState()) {
    on<BackupExport>(_onExport);
    on<BackupImport>(_onImport);
    on<BackupShare>(_onShare);
    on<BackupReset>(_onReset);
  }

  Future<void> _onExport(BackupExport event, Emitter<BackupState> emit) async {
    emit(state.copyWith(status: BackupStatus.loading));

    try {
      final filePath = await _backupService.exportDatabase();
      emit(
        state.copyWith(
          status: BackupStatus.success,
          filePath: filePath,
          successMessage: 'Database backup created successfully',
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: BackupStatus.error,
          errorMessage: 'Failed to export database: ${e.toString()}',
        ),
      );
    }
  }

  Future<void> _onImport(BackupImport event, Emitter<BackupState> emit) async {
    emit(state.copyWith(status: BackupStatus.loading));

    try {
      final isValid = await _backupService.validateBackup(event.filePath);
      if (!isValid) {
        emit(
          state.copyWith(
            status: BackupStatus.error,
            errorMessage: 'Invalid backup file',
          ),
        );
        return;
      }

      final result = await _backupService.importDatabase(event.filePath);

      if (result.success) {
        emit(
          state.copyWith(
            status: BackupStatus.success,
            successMessage:
                'Database restored: ${result.tablesImported} tables, ${result.recordsImported} records',
            tableCount: result.tablesImported,
            recordCount: result.recordsImported,
          ),
        );
      } else {
        emit(
          state.copyWith(
            status: BackupStatus.error,
            errorMessage: result.errorMessage ?? 'Failed to import database',
          ),
        );
      }
    } catch (e) {
      emit(
        state.copyWith(
          status: BackupStatus.error,
          errorMessage: 'Failed to import database: ${e.toString()}',
        ),
      );
    }
  }

  Future<void> _onShare(BackupShare event, Emitter<BackupState> emit) async {
    try {
      await _backupService.shareBackup(event.filePath);
    } catch (e) {
      emit(
        state.copyWith(
          status: BackupStatus.error,
          errorMessage: 'Failed to share backup: ${e.toString()}',
        ),
      );
    }
  }

  void _onReset(BackupReset event, Emitter<BackupState> emit) {
    emit(const BackupState());
  }
}
