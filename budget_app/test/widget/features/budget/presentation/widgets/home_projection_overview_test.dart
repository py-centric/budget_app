import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:budget_app/features/budget/presentation/widgets/home_projection_overview.dart';
import 'package:budget_app/features/budget/presentation/bloc/projection_bloc.dart';
import 'package:budget_app/features/budget/presentation/bloc/projection_event.dart';
import 'package:budget_app/features/budget/presentation/bloc/projection_state.dart';
import 'package:budget_app/features/budget/data/models/user_settings.dart';
import 'package:budget_app/features/settings/presentation/bloc/settings_bloc.dart';

class MockProjectionBloc extends MockBloc<ProjectionEvent, ProjectionState> implements ProjectionBloc {}
class MockSettingsBloc extends MockBloc<SettingsEvent, SettingsState> implements SettingsBloc {}

void main() {
  late MockProjectionBloc mockProjectionBloc;
  late MockSettingsBloc mockSettingsBloc;

  setUp(() {
    mockProjectionBloc = MockProjectionBloc();
    mockSettingsBloc = MockSettingsBloc();
    when(() => mockSettingsBloc.state).thenReturn(const SettingsState());
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: MultiBlocProvider(
        providers: [
          BlocProvider<ProjectionBloc>.value(value: mockProjectionBloc),
          BlocProvider<SettingsBloc>.value(value: mockSettingsBloc),
        ],
        child: const Scaffold(body: HomeProjectionOverview()),
      ),
    );
  }

  testWidgets('HomeProjectionOverview displays loading state', (WidgetTester tester) async {
    when(() => mockProjectionBloc.state).thenReturn(ProjectionLoading());

    await tester.pumpWidget(createWidgetUnderTest());

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('HomeProjectionOverview displays loaded state', (WidgetTester tester) async {
    when(() => mockProjectionBloc.state).thenReturn(const ProjectionLoaded(
      points: [],
      isWeekly: false,
      settings: UserSettings(),
      showActuals: false,
    ));

    await tester.pumpWidget(createWidgetUnderTest());

    expect(find.text('Projection Overview'), findsOneWidget);
  });
}
