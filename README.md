# Masayon Navigation App

Flutter classroom activity integrating demo authentication, `StatefulWidget`,
`setState()`, and bottom navigation.

## Run

```sh
flutter pub get
flutter run
```

Log in with **admin / admin123**, or tap **Register** to create a demo account.
Registration requires a username of at least 3 characters (except `admin`), a
password of at least 6 characters, and matching password confirmation.

This classroom demo keeps one registered account in memory. Registering another
account replaces it; restarting the app removes it. The default admin account
remains available. No database or extra dependencies are used.

## Pages

- **Dashboard:** welcomes the logged-in username and introduces the application.
- **Calculator:** Laboratory Activity 4 calculator with two number inputs,
  addition, subtraction, multiplication, division, input validation, and Clear.
- **Social:** two sample posts and a Create Post button. Enter a caption
  and an HTTP or HTTPS image URL to add a post under the logged-in username.
  Like or unlike posts and add comments using the Send button. Failed images
  display a broken-image placeholder.
- **Profile:** Carl John Paul Masayon, student ID 554004, CCE106L - 3450,
  c.masayon.554004@umindanao.edu.ph, the logged-in username, and Logout.

The tab order is **Dashboard → Calculator → Social → Profile**.

Use **Logout** on the Profile page to return to Login and clear the
session. Back cannot reopen the previous session. Accounts, posts, likes, and
comments are held in memory and are not saved after an application restart.
Logging out also discards the current feed.

Each screen lives in its own Dart file under `lib/`. `main_screen.dart` switches
tabs using `setState()` and an `IndexedStack`, keeping the calculator's inputs
and result when another tab is selected. Feed cards retain likes and comments
across tab switches, scrolling, and insertion of new posts. The four feed files
are in `lib/social_media/`. Network images require an internet connection.
The calculator was copied from the
adjacent `masayon_calculator` project, with its override annotations corrected.

## Verify

```sh
flutter analyze
flutter test
```

See `activity_report.md` for the activity's test-results table and answers to
the five guide questions. The results identify the automated checks used.
