import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/services/export_service.dart';
import 'export_event.dart';
import 'export_state.dart';

class ExportBloc extends Bloc<ExportEvent, ExportState> {
  final ExportService _exportService;

  ExportBloc({required ExportService exportService})
    : _exportService = exportService,
      super(const ExportState()) {
    on<ExportInitialize>(_onInitialize);
    on<ExportConfigure>(_onConfigure);
    on<ExportGenerate>(_onGenerate);
    on<ExportShare>(_onShare);
    on<ExportSave>(_onSave);
    on<ExportReset>(_onReset);
  }

  Future<void> _onInitialize(
    ExportInitialize event,
    Emitter<ExportState> emit,
  ) async {
    emit(state.copyWith(status: ExportStatus.initial));
  }

  Future<void> _onConfigure(
    ExportConfigure event,
    Emitter<ExportState> emit,
  ) async {
    emit(
      state.copyWith(
        status: ExportStatus.configured,
        configuration: event.configuration,
      ),
    );
  }

  Future<void> _onGenerate(
    ExportGenerate event,
    Emitter<ExportState> emit,
  ) async {
    if (state.configuration == null) {
      emit(
        state.copyWith(
          status: ExportStatus.error,
          errorMessage: 'Please configure export first',
        ),
      );
      return;
    }

    emit(state.copyWith(status: ExportStatus.loading));

    try {
      final transactions = await _exportService.getTransactions(
        state.configuration!,
      );

      if (transactions.isEmpty) {
        emit(
          state.copyWith(
            status: ExportStatus.error,
            errorMessage: 'No transactions found for the selected period',
          ),
        );
        return;
      }

      final summary = await _exportService.getSummary(state.configuration!);

      emit(
        state.copyWith(
          status: ExportStatus.generating,
          transactions: transactions,
          summary: summary,
        ),
      );

      String filePath;
      filePath = await _exportService.generateCsv(transactions);

      emit(state.copyWith(status: ExportStatus.success, filePath: filePath));
    } catch (e) {
      emit(
        state.copyWith(
          status: ExportStatus.error,
          errorMessage: 'Failed to generate export: ${e.toString()}',
        ),
      );
    }
  }

  Future<void> _onShare(ExportShare event, Emitter<ExportState> emit) async {
    if (state.filePath == null) {
      emit(
        state.copyWith(
          status: ExportStatus.error,
          errorMessage: 'No file to share',
        ),
      );
      return;
    }

    emit(state.copyWith(status: ExportStatus.sharing));

    try {
      await _exportService.shareFile(state.filePath!);
      emit(state.copyWith(status: ExportStatus.success));
    } catch (e) {
      emit(
        state.copyWith(
          status: ExportStatus.error,
          errorMessage: 'Failed to share file: ${e.toString()}',
        ),
      );
    }
  }

  Future<void> _onSave(ExportSave event, Emitter<ExportState> emit) async {
    if (state.filePath == null) {
      emit(
        state.copyWith(
          status: ExportStatus.error,
          errorMessage: 'No file to save',
        ),
      );
      return;
    }

    try {
      final fileName = state.filePath!.split('/').last;
      await _exportService.saveFile(state.filePath!, fileName);
      emit(state.copyWith(status: ExportStatus.success));
    } catch (e) {
      emit(
        state.copyWith(
          status: ExportStatus.error,
          errorMessage: 'Failed to save file: ${e.toString()}',
        ),
      );
    }
  }

  Future<void> _onReset(ExportReset event, Emitter<ExportState> emit) async {
    if (state.filePath != null) {
      try {
        await _exportService.deleteFile(state.filePath!);
      } catch (_) {}
    }
    emit(const ExportState());
  }
}
