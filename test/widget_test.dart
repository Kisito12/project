import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:civilsite_app/screens/auth/login_screen.dart';

void main() {
  testWidgets('Login screen shows app name and sign in form', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: LoginScreen()));

    expect(find.text('CivilSite'), findsOneWidget);
    expect(find.text('Sign in'), findsOneWidget);
    expect(find.text('Create an account'), findsOneWidget);
  });
}
