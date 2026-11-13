# Masayon Navigation App

Flutter classroom activity on `StatefulWidget`, `setState()`, and bottom navigation.

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

- **Home:** welcome message and application overview.
- **Calculator:** Laboratory Activity 4 calculator with two number inputs,
  addition, subtraction, multiplication, division, input validation, and Clear.
- **Profile:** Carl John Paul Masayon, student ID 554004, CCE106L - 3450,
  c.masayon.554004@umindanao.edu.ph.
- **Social Media:** sample Facebook, Instagram, and YouTube accounts. Tapping an
  account displays its username in a SnackBar.

Each screen lives in its own Dart file under `lib/`. `main_screen.dart` switches
tabs using `setState()` and an `IndexedStack`, keeping the calculator's inputs
and result when another tab is selected. The calculator was copied from the
adjacent `masayon_calculator` project, with its override annotations corrected.

## Verify

```sh
flutter analyze
flutter test
```
