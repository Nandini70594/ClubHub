# ClubHub

ClubHub is a Flutter mobile app to manage college club workflows: event proposals, multi-stage approvals, resource permission requests, and role-based dashboards.

**Tech stack:** Flutter, Dart, Riverpod, go_router, Supabase


 

## Description

ClubHub helps student organizations submit event proposals, request resources, upload supporting documents, and route approvals to coordinators and approvers.

## Features

- Create and submit event proposals with budgets and attachments
- Multi-stage approval workflows and role-based views
- Resource/permission requests with document uploads
- Searchable event archive
- Post-event workflow: map actual expenses against the submitted budget, submit proofs of expenses (receipts and supporting documents), and close the event after verification

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

Before running, include your Supabase credentials (URL and anon key) in your app's configuration or environment. 

## Build

- Android APK: `flutter build apk --release`
- iOS (macOS machine): `flutter build ios --release`




 
