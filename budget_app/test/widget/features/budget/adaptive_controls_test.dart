import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/adaptive_test_harness.dart';

/// US1 (T019): the two RefreshIndicator call sites (budget comparison and
/// disposable history pages) migrate to RefreshIndicator.adaptive; this
/// dual-branch probe pins the spinner behavior of that shared mechanism
/// (CupertinoActivityIndicator on iOS/macOS per the framework adaptive
/// constructor).
void main() {
  Widget surface(Completer<void> refreshCompleter) {
    return Scaffold(
      body: RefreshIndicator.adaptive(
        onRefresh: () => refreshCompleter.future,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: const <Widget>[
            SizedBox(height: 900, child: Text('Content row')),
          ],
        ),
      ),
    );
  }

  Future<void> pullToRefresh(WidgetTester tester) async {
    await tester.drag(find.text('Content row'), const Offset(0, 300));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));
  }

  testWidgets('iOS shows the Cupertino refresh spinner', (tester) async {
    final Completer<void> refreshCompleter = Completer<void>();
    await AdaptiveTestHarness.pump(
      tester,
      platform: TargetPlatform.iOS,
      child: surface(refreshCompleter),
    );

    await pullToRefresh(tester);

    expect(find.byType(CupertinoActivityIndicator), findsOneWidget);
    expect(tester.takeException(), isNull);

    refreshCompleter.complete();
    await tester.pumpAndSettle();
  });

  testWidgets('Android keeps the Material refresh spinner', (tester) async {
    final Completer<void> refreshCompleter = Completer<void>();
    await AdaptiveTestHarness.pump(
      tester,
      platform: TargetPlatform.android,
      child: surface(refreshCompleter),
    );

    await pullToRefresh(tester);

    expect(find.byType(RefreshProgressIndicator), findsOneWidget);
    expect(find.byType(CupertinoActivityIndicator), findsNothing);
    expect(tester.takeException(), isNull);

    refreshCompleter.complete();
    await tester.pumpAndSettle();
  });

  testWidgets('macOS shows the Cupertino refresh spinner', (tester) async {
    final Completer<void> refreshCompleter = Completer<void>();
    await AdaptiveTestHarness.pump(
      tester,
      platform: TargetPlatform.macOS,
      child: surface(refreshCompleter),
    );

    await pullToRefresh(tester);

    expect(find.byType(CupertinoActivityIndicator), findsOneWidget);
    expect(tester.takeException(), isNull);

    refreshCompleter.complete();
    await tester.pumpAndSettle();
  });
}
