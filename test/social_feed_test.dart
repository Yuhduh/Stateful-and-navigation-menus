import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lastname_navigation_app/demo_auth.dart';
import 'package:lastname_navigation_app/login_screen.dart';
import 'package:lastname_navigation_app/main.dart';
import 'package:lastname_navigation_app/main_screen.dart';
import 'package:lastname_navigation_app/social_media/create_post_sheet.dart';
import 'package:lastname_navigation_app/social_media/post_card.dart';
import 'package:lastname_navigation_app/social_media/social_media.dart';

Future<void> tap(WidgetTester tester, Finder target) async {
  await tester.ensureVisible(target);
  await tester.tap(target);
  await tester.pumpAndSettle();
}

Future<void> signIn(
  WidgetTester tester,
  String username,
  String password,
) async {
  await tester.enterText(find.byType(TextFormField).at(0), username);
  await tester.enterText(find.byType(TextFormField).at(1), password);
  await tap(tester, find.widgetWithText(ElevatedButton, 'Login'));
  await tap(tester, find.byIcon(Icons.share_outlined));
}

Finder card(String caption) =>
    find.ancestor(of: find.text(caption), matching: find.byType(PostCard));

Finder inside(Finder parent, Finder child) =>
    find.descendant(of: parent, matching: child);

Finder get feedScrollable =>
    inside(find.byType(SocialMediaPage), find.byType(Scrollable)).first;

Future<void> createPost(WidgetTester tester, String caption) async {
  await tap(tester, find.byTooltip('Create Post'));
  final fields = inside(find.byType(CreatePostSheet), find.byType(TextField));
  await tester.enterText(fields.at(0), caption);
  await tester.enterText(fields.at(1), 'https://example.com/photo.jpg');
  await tap(tester, find.text('Submit Post'));
  expect(find.byType(CreatePostSheet), findsNothing);
}

void main() {
  setUp(() {
    DemoAuth.registeredUsername = null;
    DemoAuth.registeredPassword = null;
    DemoAuth.logout();
  });

  testWidgets(
    'Feed retains likes and comments after insertion, scrolling, and tab changes',
    (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(const StudentApp());
      await signIn(tester, 'admin', 'admin123');
      expect(DemoAuth.currentUsername, 'admin');

      const firstCaption = 'Enjoying the sunny weather!';
      final firstCard = card(firstCaption);
      final originalState = tester.state(firstCard);
      await tap(tester, inside(firstCard, find.text('Like')));
      expect(inside(firstCard, find.text('Liked')), findsOneWidget);
      await tap(tester, inside(firstCard, find.text('Liked')));
      expect(inside(firstCard, find.text('Like')), findsOneWidget);
      await tap(tester, inside(firstCard, find.text('Like')));

      final commentField = inside(firstCard, find.byType(TextField));
      await tester.enterText(commentField, '   ');
      await tap(tester, inside(firstCard, find.byTooltip('Send comment')));
      expect(inside(firstCard, find.text('0 Comments')), findsOneWidget);
      await tester.enterText(commentField, '  Great photo!  ');
      await tap(tester, inside(firstCard, find.byTooltip('Send comment')));
      expect(inside(firstCard, find.text('Great photo!')), findsOneWidget);
      expect(inside(firstCard, find.text('1 Comments')), findsOneWidget);
      expect(tester.widget<TextField>(commentField).controller!.text, isEmpty);

      await tester.scrollUntilVisible(
        find.text('JaneSmith'),
        250,
        scrollable: feedScrollable,
      );
      expect(find.text('Just finished a great book!'), findsOneWidget);
      await createPost(tester, 'My first Flutter social media post!');
      final newCard = card('My first Flutter social media post!');
      expect(inside(newCard, find.text('admin')), findsOneWidget);
      expect(tester.getTopLeft(newCard).dy, lessThan(100));
      expect(tester.state(firstCard), same(originalState));
      expect(inside(firstCard, find.text('Liked')), findsOneWidget);
      expect(inside(newCard, find.text('Like')), findsOneWidget);

      await tap(tester, inside(newCard, find.text('Like')));
      await tester.enterText(
        inside(newCard, find.byType(TextField)),
        'My comment',
      );
      await tap(tester, inside(newCard, find.byTooltip('Send comment')));

      for (final icon in [
        Icons.home_outlined,
        Icons.calculate_outlined,
        Icons.person_outline,
      ]) {
        await tap(tester, find.byIcon(icon));
      }
      await tap(tester, find.byIcon(Icons.share_outlined));
      expect(inside(newCard, find.text('Liked')), findsOneWidget);
      expect(inside(newCard, find.text('My comment')), findsOneWidget);

      await createPost(tester, 'Another post');
      await tester.scrollUntilVisible(
        find.text('JaneSmith'),
        300,
        scrollable: feedScrollable,
      );
      await tester.scrollUntilVisible(
        find.text('My first Flutter social media post!'),
        -300,
        scrollable: feedScrollable,
      );
      expect(inside(newCard, find.text('Liked')), findsOneWidget);
      expect(inside(newCard, find.text('My comment')), findsOneWidget);
      await tester.scrollUntilVisible(
        find.text(firstCaption),
        250,
        scrollable: feedScrollable,
      );
      expect(tester.state(firstCard), same(originalState));
      expect(inside(firstCard, find.text('Great photo!')), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'Create Post validates fields and URL, trims input, and can be cancelled',
    (tester) async {
      await tester.pumpWidget(const StudentApp());
      await signIn(tester, 'admin', 'admin123');
      await tap(tester, find.byTooltip('Create Post'));
      final fields = inside(
        find.byType(CreatePostSheet),
        find.byType(TextField),
      );
      await tap(tester, find.text('Submit Post'));
      expect(
        inside(
          find.byType(CreatePostSheet),
          find.text('Complete both fields before submitting!'),
        ),
        findsOneWidget,
      );
      expect(find.byType(CreatePostSheet), findsOneWidget);
      await tester.pump(const Duration(seconds: 5));
      await tester.pumpAndSettle();

      await tester.enterText(fields.at(0), '  New caption  ');
      for (final invalid in [
        'not a URL',
        'ftp://example.com/photo.jpg',
        'https://:443',
      ]) {
        await tester.enterText(fields.at(1), invalid);
        await tap(tester, find.text('Submit Post'));
        expect(
          inside(
            find.byType(CreatePostSheet),
            find.text('Enter a valid HTTP or HTTPS image URL.'),
          ),
          findsOneWidget,
        );
        expect(find.byType(CreatePostSheet), findsOneWidget);
        await tester.pump(const Duration(seconds: 5));
        await tester.pumpAndSettle();
      }

      await tester.enterText(fields.at(1), '  http://example.com/photo.jpg  ');
      await tap(tester, find.text('Submit Post'));
      final newCard = tester.widget<PostCard>(card('New caption'));
      expect(newCard.post.caption, 'New caption');
      expect(newCard.post.imageUrl, 'http://example.com/photo.jpg');
      expect(newCard.post.username, 'admin');

      await tap(tester, find.byTooltip('Create Post'));
      await tester.enterText(fields.at(0), 'Cancelled post');
      Navigator.of(tester.element(find.byType(CreatePostSheet))).pop();
      await tester.pumpAndSettle();
      expect(find.text('Cancelled post'), findsNothing);
      expect(find.text('New caption'), findsOneWidget);
    },
  );

  testWidgets(
    'Logout clears the session and route history; new posts use the next user',
    (tester) async {
      await tester.pumpWidget(const StudentApp());
      await signIn(tester, 'admin', 'admin123');
      await createPost(tester, 'Admin session post');
      await tap(tester, find.byIcon(Icons.person_outline));
      await tap(tester, find.byTooltip('Logout'));
      expect(DemoAuth.currentUsername, isNull);
      expect(find.byType(LoginScreen), findsOneWidget);
      expect(find.byType(MainScreen), findsNothing);
      final navigator = Navigator.of(tester.element(find.byType(LoginScreen)));
      expect(navigator.canPop(), isFalse);
      expect(await navigator.maybePop(), isFalse);

      DemoAuth.register('carl', 'student123');
      await signIn(tester, 'carl', 'student123');
      expect(find.text('Admin session post'), findsNothing);
      await createPost(tester, 'Student session post');
      expect(
        inside(card('Student session post'), find.text('carl')),
        findsOneWidget,
      );
    },
  );

  testWidgets('An unavailable network image displays the placeholder', (
    tester,
  ) async {
    // Flutter's widget-test HTTP client returns 400, so no live network is used.
    await tester.pumpWidget(const StudentApp());
    await signIn(tester, 'admin', 'admin123');
    await tester.runAsync(() async {
      await Future<void>.delayed(const Duration(milliseconds: 50));
    });
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.broken_image), findsWidgets);
    expect(find.text('Enjoying the sunny weather!'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
