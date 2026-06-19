# ClubHub

ClubHub is a Flutter mobile app to manage college club workflows: event proposals, multi-stage approvals, resource permission requests, and role-based dashboards.

**Tech stack:** Flutter, Dart, Riverpod, go_router, Supabase

**Status:** Work in progress

**Config file:** lib/core/config/env.dart

**Table of contents**

- **Description**
- **Features**
- **Requirements**
- **Setup & Run**
- **Environment / Secrets**
- **Build**
- **Testing**
- **Contributing**

## Description

ClubHub helps student organizations submit event proposals, request resources, upload supporting documents, and route approvals to coordinators and approvers.

## Features

- Create and submit event proposals with budgets and attachments
- Multi-stage approval workflows and role-based views
- Resource/permission requests with document uploads
- Searchable event archive

## Requirements

- Flutter SDK (see `pubspec.yaml` for Dart SDK constraint)
- A Supabase project (for auth, database and storage)

## Setup & Run

1. Clone the repo and fetch dependencies:

```bash
git clone https://github.com/Nandini70594/ClubHub.git
cd ClubHub
flutter pub get
```

2. Configure Supabase credentials (see next section).

3. Run on a connected device or emulator:

```bash
flutter run
```

## Environment / Secrets

This project currently reads Supabase configuration from `lib/core/config/env.dart`.

- Replace the values in `lib/core/config/env.dart` with your Supabase project's `url` and `anon key` before running.
- Do NOT commit production keys to source control. Prefer using a secure mechanism (CI secrets, native platform env, or a `.env` file not checked in).

Example (lib/core/config/env.dart):

```dart
class Env {
	static const String supabaseUrl = 'https://YOUR-SUPABASE-URL.supabase.co';
	static const String supabaseAnonKey = 'YOUR_ANON_KEY';
}
```

## Build

- Android APK: `flutter build apk --release`
- iOS (macOS machine): `flutter build ios --release`

## Testing

Run the test suite with:

```bash
flutter test
```

## Contributing

- Open an issue or submit a pull request.
- Follow existing code style and run `flutter format` before committing.

## Notes

- The current `Env` file contains placeholder/hardcoded keys; move to a secure config before publishing.
- If you want, I can add environment-specific config (example: `.env` loader) and improve CI instructions.

---

If you'd like, I can further tailor this README (add screenshots, architecture diagram, or example flows).  
