import 'package:anpr_frontend/home.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Home screen has image upload button',
      (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(MaterialApp(
        home: MyHomePage(title: 'ANPR App'))); // Use the MyHomePage widget

    // Verify that the welcome message is displayed.
    expect(find.text('Welcome to Automatic License Plate Detection'),
        findsOneWidget);

    // Verify that the upload image button is present
    expect(find.text('Upload Image from Gallery'), findsOneWidget);

    // Optionally, check for other buttons as well
    expect(find.text('Capture Image from Camera'), findsOneWidget);
    expect(find.text('Send Image to Backend'), findsOneWidget);
  });
}
