# Attachment Placement — Mobile App (Flutter)

The student-facing mobile app for the Student Industrial Attachment &
Placement System. It talks to the same Django REST API as the web console.

Students can: register/login, browse and search opportunities, view details,
apply with a cover letter, track application status, withdraw applications,
edit their profile, and read notifications. (Company users can also log in;
the app focuses on the student experience as described in the report.)

## ⚠️ Read this first — it has NOT been compiled

This source was written against the live, tested API contract, but it was
**not built or run** in the environment where it was generated (no Flutter SDK
there). Treat your first run as a "compile, run, fix any small issues" pass.
The code has been checked for structure, imports, and API-method consistency,
but only a real `flutter run` will surface anything the analyzer catches.

## Prerequisites

- Flutter SDK 3.3+ installed (`flutter doctor` should be clean)
- An Android emulator, iOS simulator, or a physical device
- The Django backend running and seeded (`seed_demo`)

## First-time setup

This project ships the `lib/`, `pubspec.yaml`, and Android files, but **not**
the auto-generated platform glue. The cleanest way to fill that in:

```bash
# 1. From inside the mobile_app folder, let Flutter regenerate platform files
flutter create .

#    This creates the missing iOS/Android/build scaffolding WITHOUT
#    overwriting your lib/ code or pubspec.yaml.

# 2. Get packages
flutter pub get

# 3. Run it (emulator/device must be attached)
flutter run
```

If `flutter create .` changes the Android package name, that's fine — or pass
`--org com.group9a` to match the included files.

## Pointing the app at your backend (important)

The API base URL is in `lib/api/api_service.dart` as `kApiUrl`. The default is:

```
http://10.0.2.2:8000/api
```

- **Android emulator**: `10.0.2.2` is the host machine's localhost — keep the default.
- **iOS simulator**: change it to `http://127.0.0.1:8000/api`.
- **Physical device**: use your computer's LAN IP, e.g. `http://192.168.1.20:8000/api`
  (the phone and computer must be on the same network).

You can override without editing code:

```bash
flutter run --dart-define=API_URL=http://192.168.1.20:8000/api
```

### Cleartext HTTP

The dev backend is plain HTTP. Android blocks cleartext by default, so the
included `AndroidManifest.xml` sets `android:usesCleartextTraffic="true"`. This
is fine for development; use HTTPS in production and remove that flag.

## Demo login

After running `seed_demo` on the backend:

- Student — `student@demo.local` / `student1234`
- Or tap "Create a student account" to register a fresh one.

## Project structure

```
lib/
├── main.dart                     entry; routes login vs home by auth state
├── auth_state.dart               ChangeNotifier holding auth state
├── theme.dart                    colours + Material theme + status colours
├── api/
│   └── api_service.dart          HTTP client, JWT storage, token refresh, endpoints
├── models/
│   └── models.dart               Posting, Application, NotificationItem
├── widgets/
│   └── common.dart               StatusBadge, Loading/Empty/Error views
└── screens/
    ├── login_screen.dart         login + student registration
    ├── home_screen.dart          bottom-nav shell (4 tabs)
    ├── opportunities_screen.dart browse + search postings
    ├── posting_detail_screen.dart details + apply bottom sheet
    ├── applications_screen.dart  my applications + withdraw
    ├── notifications_screen.dart notifications + mark all read
    └── profile_screen.dart       view/edit profile + sign out
```

## Dependencies

- `http` — REST calls
- `provider` — auth state
- `flutter_secure_storage` — stores JWT tokens securely on device
- `intl` — date formatting

## How auth works

On login the app stores the JWT access + refresh tokens via
`flutter_secure_storage`. Every request carries the access token; on a 401 the
client transparently refreshes once and retries. On logout the tokens are
cleared. Role and email are decoded from the JWT payload.
