import 'package:fit_progressor/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fit_progressor/injection_container.dart' as di;
import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() {
  setUpAll(() async {
    // Initialize Hive for testing
    await Hive.initFlutter();
    await di.init();
  });

  tearDown(() {
    GetIt.I.reset();
  });

  testWidgets('App starts without crashing', (WidgetTester tester) async {
    await tester.pumpWidget(const FitProgressorApp());
    // Expect to find at least one widget, indicating the app has started.
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
