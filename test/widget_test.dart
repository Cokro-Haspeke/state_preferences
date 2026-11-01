import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:state_preference/main.dart';

void main() {
  testWidgets('saving a profile replaces the guest greeting', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();
    expect(find.text('Selamat datang, Tamu!'), findsOneWidget);

    await tester.tap(find.text('Login / Daftar'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).at(0), 'Ayu');
    await tester.enterText(find.byType(TextFormField).at(1), 'ayu@example.com');
    await tester.tap(find.text('Simpan Profil'));
    await tester.pumpAndSettle();
    await tester.pageBack();
    await tester.pumpAndSettle();

    expect(find.text('Selamat datang, Ayu!'), findsOneWidget);
    expect(find.text('Aplikasi sudah dibuka 1 kali'), findsOneWidget);

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('user_name'), 'Ayu');
    expect(prefs.getBool('is_logged_in'), isTrue);
  });

  testWidgets('visit count increases on a new app launch', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();
    expect(find.text('Aplikasi sudah dibuka 1 kali'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();
    expect(find.text('Aplikasi sudah dibuka 2 kali'), findsOneWidget);
  });

  testWidgets('logged-out user cannot reuse a registered email', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({
      'user_email': 'ayu@example.com',
      'is_logged_in': false,
      'registered_emails': ['ayu@example.com'],
    });

    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();
    await tester.tap(find.text('Login / Daftar'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).at(0), 'Pengguna lain');
    await tester.enterText(find.byType(TextFormField).at(1), 'AYU@example.com');
    await tester.tap(find.text('Simpan Profil'));
    await tester.pumpAndSettle();

    expect(find.text('Email sudah digunakan'), findsOneWidget);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getBool('is_logged_in'), isFalse);
  });
}
