# CivilSite

A Flutter + Firebase platform for house-building projects, hosting multiple
construction companies. For each project, a company can:

- Attach the architect's plan drawing and turn its room dimensions into a
  **structured takeoff** that auto-generates a starting cost estimate
  spanning every trade - foundation, substructure, walls, roofing,
  electrical, plumbing, and finishes - with material and labor cost per
  line item.
- Manage **projects and tasks**, assigning company workers and tracking
  progress from foundation to key-handover.
- Log **site inspection reports** with photos and defect severity.

## Roles

- **Super Admin** - the platform owner. Approves or suspends companies and
  can see every project on the platform, but doesn't manage day-to-day work.
  There is no self-registration flow for this role (see "Bootstrapping the
  super admin" below) - it has to be deliberately granted.
- **Company Admin** - registers their company (which starts `pending` until
  the super admin approves it), then manages that company's projects,
  workers, plans/specs, and estimates.
- **Company Worker** - joins an already-approved company from a list at
  registration, sees only the projects they're assigned to, and submits
  inspection reports and tasks.

Role and company membership are stored in Firestore (`users/{uid}.role`,
`users/{uid}.companyId`) and enforced server-side by `firestore.rules` - a
user cannot self-escalate their own role or company after registration.

## Why the estimator doesn't "read" the plan image

Automatically extracting exact dimensions, electrical runs, and pipe layouts
from a scanned/photographed architectural drawing is a hard computer-vision
problem that isn't reliable enough for a v1. Instead: the plan image/PDF is
attached to the project as a reference everyone can view, and whoever is
looking at it enters the room-by-room dimensions into a structured form
(`lib/screens/projects/plan_specs_tab.dart`). From that, `TakeoffCalculator`
(`lib/models/building_spec.dart`) computes a starting quantity for each
trade using simple, documented rules of thumb - e.g. wall area = perimeter ×
height × floors, roofing area = footprint × a pitch multiplier, electrical
points = a per-room-type allowance. Every generated line item is fully
editable before the estimate is saved, same as a manually-built one.

## Tech stack

- Flutter (Material 3)
- Firebase Auth (email/password)
- Cloud Firestore (companies, projects, tasks, inspections, estimates)
- Firebase Storage (plan drawings, inspection photos)
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

## Bootstrapping the super admin

There's no in-app way to register as super admin (a public "become platform
owner" button would defeat the point). Instead:

1. Register normally, choosing "Register a company" (this makes you a
   company admin of a new, pending company).
2. In the Firebase console, open your `users/{your-uid}` document and change
   `role` from `companyAdmin` to `superAdmin`. Clear `companyId` (set it to
   `null`) since super admins don't belong to a company.
3. Sign out and back in - you'll land on the platform oversight screen.

From there, approve your test companies (or any others that register) so
their admins and workers can get in.

## Project structure

```
lib/
  models/       Plain Dart data classes + Firestore (de)serialization
                (company.dart, building_spec.dart holds the takeoff calculator)
  services/     Firebase-backed repositories (auth, companies, projects, inspections, estimates)
  screens/
    auth/               Login, register (create-company / join-company)
    super_admin/         Company oversight (approve/suspend, view a company's projects)
    projects/             Project list/detail, tasks, plan & specs tab, worker assignment
    inspections/          Site inspection reports
    estimator/            Cost estimate builder & detail
  theme/         App-wide Material theme
firestore.rules         Role- and company-scoped Firestore access rules
storage.rules            Access rules for plan drawings and inspection photos
firestore.indexes.json   Composite indexes required by the app's queries
```

## Data model

- `companies/{id}` — name, contactEmail, phone, status (`pending` | `approved` | `suspended`), ownerId
- `users/{uid}` — name, email, role (`superAdmin` | `companyAdmin` | `companyWorker`), companyId
- `projects/{id}` — companyId, name, location, description, client name/phone/address,
  status, assignedWorkerIds, planFileUrl/planFileName, buildingSpec (floors,
  footprint, wall height, foundation/roof type, rooms[])
  - `projects/{id}/tasks/{taskId}` — title, notes, status, assignedToId
- `inspections/{id}` — companyId, projectId, inspectorId, summary, severity, photoUrls
- `estimates/{id}` — companyId, projectId, title, items[] (each with phase,
  description, quantity, unit, unitMaterialCost, laborCost)

## Visual QA without Firebase

`lib/main_preview.dart` renders every screen with sample in-memory data - no
Firebase project or network connection needed:

```bash
flutter run -d chrome -t lib/main_preview.dart
```

## Tests

```bash
flutter test
flutter analyze
```

## Roadmap (not in this build)

This is phase 1 of a larger vision. Deliberately out of scope for now, to
keep the core (companies → projects → plan-based estimates) solid first:

- A jobs marketplace where individual tradespeople list certifications/
  experience and companies hire from that pool.
- A materials marketplace with supplier-maintained live pricing, so
  estimates can pull real market prices instead of manually entered ones.
- Delivery tracking: buyer location + a driver's map view for materials
  bought through the marketplace.
