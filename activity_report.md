# Integrated Flutter Application Activity

**Student:** Carl John Paul Masayon  
**Student ID:** 554004  
**Course and section:** CCE106L - 3450  
**Email:** c.masayon.554004@umindanao.edu.ph  
**Verification date:** November 18, 2026

## Test results

All 14 activity checkpoints below passed through automated Flutter widget
tests in `test/widget_test.dart` and `test/social_feed_test.dart`. These are
actual automated results, not a claim that every row was tested manually.
`flutter analyze --no-pub` reported no issues, and `flutter test --no-pub`
passed all 9 tests. Several tests cover multiple activity checkpoints.

| No. | Test | Actual result | Pass/Fail |
|---|---|---|---|
| 1 | Open the application. | Login appears before Dashboard. | Pass |
| 2 | Submit empty login fields. | Username and password validation messages appear. | Pass |
| 3 | Enter incorrect credentials. | An invalid-credentials message appears; navigation is rejected. | Pass |
| 4 | Enter admin / admin123. | Dashboard opens after successful login. | Pass |
| 5 | Read the dashboard greeting. | Displays **Welcome, admin!** | Pass |
| 6 | Calculate 10 + 5. | Displays **15.0**. | Pass |
| 7 | Switch tabs and return to Calculator. | The inputs **10** and **5**, and result **15.0**, remain. | Pass |
| 8 | Create a social post. | The new post appears at the top under **admin**. | Pass |
| 9 | Like a post and add a comment. | The heart and label toggle; the comment and count update. | Pass |
| 10 | Switch tabs and return to Social. | Posts, likes, and comments remain. They also stay attached to the correct post after insertion and scrolling. | Pass |
| 11 | Open Profile. | Displays the supplied student information and **Logged in as: admin**. | Pass |
| 12 | Tap Logout. | Login appears, `currentUsername` becomes null, and the old routes cannot be reopened with Back. | Pass |
| 13 | Register a valid account and log in. | Registration returns to Login; Dashboard then displays **Welcome, carl!** | Pass |
| 14 | Create a post using the registered account. | The post displays **carl** as its author. | Pass |

The required four-operation check also passed using **20** and **5**:
addition **25.0**, subtraction **15.0**, multiplication **100.0**, and
division **4.0**. Empty and invalid input, division by zero, Clear, password
visibility, registration validation, post validation, cancellation, and the
broken-image placeholder were also checked.

The widget tests use Flutter's offline test HTTP client, so they verify image
failure handling rather than availability of external image servers. Live
images require internet access. Whole-number results retain one decimal place
on both Dart VM and Flutter Web.

## Browser verification and proof

The app was also launched with `flutter run -d web-server --web-hostname
127.0.0.1 --web-port 8765 --no-pub` and checked in a browser. The browser check
confirmed the admin greeting, **10 + 5 = 15.0**, a new post authored by admin,
Like and Comment updates, state retention across tabs, student details with the
session username, and return to Login after Logout. The sample network image
loaded successfully during this check.

Screenshots of the running app are saved in `proof/`:

- [Login](proof/01-login.jpg)
- [Dashboard with the admin greeting](proof/02-dashboard.jpg)
- [Calculator with 10 + 5 = 15.0](proof/03-calculator.jpg)
- [Social post with a like and comment](proof/04-social.jpg)
- [Profile with student information and the current username](proof/05-profile.jpg)

## Guide questions

### 1. How does DemoAuth connect Login to Dashboard, Social, and Profile?

DemoAuth checks the username and password when the user logs in.
If they are correct, it keeps the username so Dashboard, Social, and Profile
can show who is logged in.

### 2. Why must the order of pages match the bottom navigation destinations?

Each navigation button opens the page in the same position in the page list.
The order must match so tapping a button opens the correct page.

### 3. Why is IndexedStack useful for the Calculator and Social pages?

IndexedStack keeps the pages open while showing only the selected page.
This keeps the calculator's numbers and result, as well as social posts,
likes, and comments, when the user switches tabs.

### 4. Why should Logout clear the current username and remove previous routes?

Logout clears the current username to show that no user is logged in.
It also removes the previous screens so pressing Back cannot open them again.

### 5. Which information is lost when this demo application restarts?

The registered account, login session, new posts, likes, comments, and
calculator numbers and result are lost when the app restarts.
The default admin account, student details, and sample posts are still
available because they are included in the app's code.
