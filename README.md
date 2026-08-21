# CivilSite

A Flutter + Firebase mobile app for civil engineering field teams. It covers
three workflows for a construction project:

- **Project & task management** — admins create projects, assign field
  engineers, and track task/milestone progress.
- **Site inspection & reporting** — field engineers log site visits with
  notes, defect severity, and photos captured on-device.
- **Cost estimating** — a bill-of-quantities style estimator covering every
  phase of a build (siteworks, foundation, substructure, superstructure,
  roofing, finishes), with material quantity/unit cost and labor cost per
  line item, rolling up to phase and grand totals.

## Roles

Every account is either:

- **Admin / Manager** — creates and manages projects, assigns field
  engineers, sees everything.
- **Field Engineer** — sees only the projects they're assigned to, submits
  inspection reports and cost estimates, updates their own tasks.

Role is chosen at registration and stored in Firestore (`users/{uid}.role`);
`firestore.rules` enforces it server-side.

## Tech stack

- Flutter (Material 3)
- Firebase Auth (email/password)
- Cloud Firestore (projects, tasks, inspections, estimates)
- Firebase Storage (inspection photos)
- `provider` for state management

## One-time setup

1. **Install Flutter** (stable channel): https://docs.flutter.dev/get-started/install

2. **Create a Firebase project** at https://console.firebase.google.com, then
   enable:
   - Authentication → Sign-in method → Email/Password
   - Firestore Database (start in production mode)
   - Storage

3. **Install the FlutterFire CLI** and connect this app to your project:

   ```bash
   dart pub global activate flutterfire_cli
   flutterfire configure
   ```

   This overwrites the placeholder `lib/firebase_options.dart` with your real
   project's config and wires up the Android/iOS native config files.

4. **Deploy the security rules** (requires the Firebase CLI:
   `npm install -g firebase-tools`, then `firebase login`):

   ```bash
   firebase deploy --only firestore:rules,firestore:indexes,storage
   ```

5. **Run the app**:

   ```bash
   flutter pub get
   flutter run
   ```

6. **Create your first admin account**: register normally in the app and
   choose "Admin / Manager" as the role. Admins can then assign field
   engineers to projects (field engineers register the same way, choosing
   "Field Engineer").

## Project structure

```
lib/
  models/       Plain Dart data classes + Firestore (de)serialization
  services/     Firebase-backed repositories (auth, projects, inspections, estimates)
  screens/      UI, organized by feature (auth, projects, inspections, estimator)
  theme/        App-wide Material theme
firestore.rules      Role-based Firestore access rules
storage.rules         Access rules for inspection photo uploads
firestore.indexes.json  Composite indexes required by the app's queries
```

## Data model

- `users/{uid}` — name, email, role (`admin` | `fieldEngineer`)
- `projects/{id}` — name, location, description, status, assignedEngineerIds
  - `projects/{id}/tasks/{taskId}` — title, notes, status, assignedToId
- `inspections/{id}` — projectId, inspectorId, summary, severity, photoUrls
- `estimates/{id}` — projectId, title, items[] (each with phase, description,
  quantity, unit, unitMaterialCost, laborCost)

## Tests

```bash
flutter test
flutter analyze
```
