import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lastname_navigation_app/calculator_screen.dart';
import 'package:lastname_navigation_app/demo_auth.dart';
import 'package:lastname_navigation_app/main.dart';

Future<void> tapText(WidgetTester tester, String text) async {
  final target = find.text(text);
  await tester.ensureVisible(target);
  await tester.tap(target);
  await tester.pumpAndSettle();
}

Future<void> login(
  WidgetTester tester,
  String username,
  String password,
) async {
  await tester.enterText(find.byType(TextFormField).at(0), username);
  await tester.enterText(find.byType(TextFormField).at(1), password);
  await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
  await tester.pumpAndSettle();
}

void main() {
  setUp(() {
    DemoAuth.registeredUsername = null;
    DemoAuth.registeredPassword = null;
  });

  test('Registration replaces the demo account and preserves admin login', () {
    expect(DemoAuth.login('admin', 'admin123'), isTrue);
    expect(DemoAuth.login('admin', 'wrong'), isFalse);
    DemoAuth.register('first', 'password1');
    expect(DemoAuth.login('first', 'password1'), isTrue);
    DemoAuth.register('second', 'password2');
    expect(DemoAuth.login('first', 'password1'), isFalse);
    expect(DemoAuth.login('second', 'password2'), isTrue);
    expect(DemoAuth.login('admin', 'admin123'), isTrue);
  });

  testWidgets(
    'Login validates fields, toggles visibility, and rejects bad credentials',
    (tester) async {
      await tester.pumpWidget(const StudentApp());
      await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
      await tester.pumpAndSettle();
      expect(find.text('Enter your username.'), findsOneWidget);
      expect(find.text('Enter your password.'), findsOneWidget);

      expect(
        tester.widget<TextField>(find.byType(TextField).at(1)).obscureText,
        isTrue,
      );
      await tester.tap(find.byTooltip('Show password'));
      await tester.pump();
      expect(
        tester.widget<TextField>(find.byType(TextField).at(1)).obscureText,
        isFalse,
      );

      await login(tester, 'admin', 'wrong');
      expect(find.text('Invalid username or password.'), findsOneWidget);
      expect(find.byType(NavigationBar), findsNothing);
    },
  );

  testWidgets('Registration validates input and the new account can log in', (
    tester,
  ) async {
    await tester.pumpWidget(const StudentApp());
    await tapText(tester, "Don't have an account? Register");

    Future<void> register() async {
      final button = find.widgetWithText(ElevatedButton, 'Register');
      await tester.ensureVisible(button);
      await tester.tap(button);
      await tester.pumpAndSettle();
    }

    await register();
    expect(find.text('Use at least 3 characters.'), findsOneWidget);
    expect(find.text('Enter a password.'), findsOneWidget);
    expect(find.text('Confirm your password.'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField).at(0), 'ADMIN');
    await tester.enterText(find.byType(TextFormField).at(1), '123');
    await tester.enterText(find.byType(TextFormField).at(2), 'different');
    await register();
    expect(find.text('This username is reserved.'), findsOneWidget);
    expect(find.text('Use at least 6 characters.'), findsOneWidget);
    expect(find.text('Passwords do not match.'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField).at(0), '  carl  ');
    await tester.enterText(find.byType(TextFormField).at(1), 'student123');
    await tester.enterText(find.byType(TextFormField).at(2), 'student123');
    await register();
    expect(
      find.text('Registration successful! You can now log in.'),
      findsOneWidget,
    );
    await login(tester, 'carl', 'student123');
    expect(find.text('Welcome, Student!'), findsOneWidget);
  });

  testWidgets(
    'Four tabs preserve calculator state and show profile and social accounts',
    (tester) async {
      await tester.pumpWidget(const StudentApp());
      await login(tester, 'admin', 'admin123');
      expect(find.text('Welcome, Student!'), findsOneWidget);
      expect(find.byType(NavigationDestination), findsNWidgets(4));

      await tester.tap(find.byIcon(Icons.calculate_outlined));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField).at(0), '12');
      await tester.enterText(find.byType(TextField).at(1), '3');
      await tapText(tester, '+');
      expect(find.text('15.0'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.person_outline));
      await tester.pumpAndSettle();
      expect(find.text('Carl John Paul Masayon'), findsOneWidget);
      expect(find.text('554004'), findsOneWidget);
      expect(find.text('CCE106L - 3450'), findsOneWidget);
      expect(find.text('c.masayon.554004@umindanao.edu.ph'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.share_outlined));
      await tester.pumpAndSettle();
      for (final account in {
        'Facebook': 'student.sample',
        'Instagram': '@student.sample',
        'YouTube': '@StudentChannel',
      }.entries) {
        await tapText(tester, account.key);
        expect(
          find.text('Selected account: ${account.key}: ${account.value}'),
          findsOneWidget,
        );
        await tester.pump(const Duration(seconds: 4));
        await tester.pumpAndSettle();
      }

      await tester.tap(find.byIcon(Icons.home_outlined));
      await tester.pumpAndSettle();
      expect(find.text('Welcome, Student!'), findsOneWidget);
      await tester.tap(find.byIcon(Icons.calculate_outlined));
      await tester.pumpAndSettle();
      expect(
        tester.widget<TextField>(find.byType(TextField).at(0)).controller!.text,
        '12',
      );
      expect(
        tester.widget<TextField>(find.byType(TextField).at(1)).controller!.text,
        '3',
      );
      expect(find.text('15.0'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'Calculator handles all operations, invalid input, division by zero, and Clear',
    (tester) async {
      await tester.pumpWidget(const MaterialApp(home: CalculatorScreen()));
      await tapText(tester, '+');
      expect(find.text('Invalid input'), findsOneWidget);

      await tester.enterText(find.byType(TextField).at(0), '12.5');
      await tester.enterText(find.byType(TextField).at(1), '-2');
      for (final operation in {
        '+': '10.5',
        '−': '14.5',
        '×': '-25.0',
        '÷': '-6.25',
      }.entries) {
        await tapText(tester, operation.key);
        expect(find.text(operation.value), findsOneWidget);
      }

      await tester.enterText(find.byType(TextField).at(1), '0');
      await tapText(tester, '÷');
      expect(find.text('Cannot divide by zero'), findsOneWidget);
      for (final invalid in ['abc', 'NaN', 'Infinity']) {
        await tester.enterText(find.byType(TextField).at(0), invalid);
        await tapText(tester, '+');
        expect(find.text('Invalid input'), findsOneWidget);
      }

      await tapText(tester, 'Clear');
      expect(find.text('0'), findsOneWidget);
      expect(find.text('Enter two numbers'), findsOneWidget);
      for (final field in tester.widgetList<TextField>(
        find.byType(TextField),
      )) {
        expect(field.controller!.text, isEmpty);
      }
    },
  );
}
