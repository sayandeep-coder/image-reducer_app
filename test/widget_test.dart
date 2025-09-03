// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ripehash/app/app.dart';

void main() {
  testWidgets('App renders correctly', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ProviderScope(child: App()));

    // Verify that the app builds without errors
    expect(find.byType(MaterialApp), findsOneWidget);
    
    // Wait for animations to complete
    await tester.pumpAndSettle();
    
    // The app should navigate to the splash screen initially
    // We can verify the app is running by checking for MaterialApp
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
