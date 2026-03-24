import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:budget_app/features/app_lock/data/repositories/app_lock_repository_impl.dart';
import 'package:budget_app/features/app_lock/domain/entities/app_lock_settings.dart';
import 'package:budget_app/features/app_lock/domain/services/auth_service.dart';
import 'package:budget_app/features/app_lock/presentation/bloc/app_lock_bloc.dart';
import 'package:budget_app/features/app_lock/presentation/bloc/app_lock_event.dart';
import 'package:budget_app/features/app_lock/presentation/bloc/app_lock_state.dart';

class MockAuthService extends Mock implements AuthService {}

class MockAppLockRepository extends Mock implements AppLockRepository {}

void main() {
  group('AppLockBloc', () {
    late AppLockRepository mockRepository;
    late AppLockBloc bloc;

    setUp(() {
      mockRepository = MockAppLockRepository();
    });

    tearDown(() {
      bloc.close();
    });

    test('initial state is AppLockStatus.initial', () {
      when(
        () => mockRepository.getSettings(),
      ).thenAnswer((_) async => const AppLockSettings(isEnabled: false));
      bloc = AppLockBloc(repository: mockRepository);
      expect(bloc.state.status, equals(AppLockStatus.initial));
    });

    group('AppLockLoadSettings', () {
      blocTest<AppLockBloc, AppLockState>(
        'emits loaded state when lock is disabled',
        build: () {
          when(
            () => mockRepository.getSettings(),
          ).thenAnswer((_) async => const AppLockSettings(isEnabled: false));
          when(
            () => mockRepository.isBiometricAvailable(),
          ).thenAnswer((_) async => false);
          return AppLockBloc(repository: mockRepository);
        },
        act: (bloc) => bloc.add(AppLockLoadSettings()),
        expect: () => [
          isA<AppLockState>().having(
            (s) => s.status,
            'status',
            AppLockStatus.loading,
          ),
          isA<AppLockState>().having(
            (s) => s.status,
            'status',
            AppLockStatus.loaded,
          ),
        ],
      );

      blocTest<AppLockBloc, AppLockState>(
        'emits locked state when lock is enabled',
        build: () {
          when(() => mockRepository.getSettings()).thenAnswer(
            (_) async => const AppLockSettings(
              isEnabled: true,
              authMethod: AuthMethod.pin,
            ),
          );
          when(
            () => mockRepository.isBiometricAvailable(),
          ).thenAnswer((_) async => false);
          return AppLockBloc(repository: mockRepository);
        },
        act: (bloc) => bloc.add(AppLockLoadSettings()),
        expect: () => [
          isA<AppLockState>().having(
            (s) => s.status,
            'status',
            AppLockStatus.loading,
          ),
          isA<AppLockState>().having(
            (s) => s.status,
            'status',
            AppLockStatus.locked,
          ),
        ],
      );
    });

    group('AppLockAuthenticate', () {
      blocTest<AppLockBloc, AppLockState>(
        'emits authenticated when PIN is correct',
        build: () {
          when(
            () => mockRepository.verifyAuth(any()),
          ).thenAnswer((_) async => true);
          return AppLockBloc(repository: mockRepository);
        },
        act: (bloc) => bloc.add(const AppLockAuthenticate(pin: '1234')),
        expect: () => [
          isA<AppLockState>().having(
            (s) => s.status,
            'status',
            AppLockStatus.authenticating,
          ),
          isA<AppLockState>().having(
            (s) => s.status,
            'status',
            AppLockStatus.authenticated,
          ),
        ],
      );

      blocTest<AppLockBloc, AppLockState>(
        'emits error when PIN is incorrect',
        build: () {
          when(
            () => mockRepository.verifyAuth(any()),
          ).thenAnswer((_) async => false);
          return AppLockBloc(repository: mockRepository);
        },
        act: (bloc) => bloc.add(const AppLockAuthenticate(pin: 'wrong')),
        expect: () => [
          isA<AppLockState>().having(
            (s) => s.status,
            'status',
            AppLockStatus.authenticating,
          ),
          isA<AppLockState>()
              .having((s) => s.status, 'status', AppLockStatus.error)
              .having((s) => s.failedAttempts, 'failedAttempts', 1),
        ],
      );
    });

    group('AppLockCheckBiometricAvailability', () {
      blocTest<AppLockBloc, AppLockState>(
        'updates biometric availability',
        build: () {
          when(
            () => mockRepository.isBiometricAvailable(),
          ).thenAnswer((_) async => true);
          return AppLockBloc(repository: mockRepository);
        },
        act: (bloc) => bloc.add(AppLockCheckBiometricAvailability()),
        expect: () => [
          isA<AppLockState>().having(
            (s) => s.isBiometricAvailable,
            'isBiometricAvailable',
            true,
          ),
        ],
      );
    });
  });
}
