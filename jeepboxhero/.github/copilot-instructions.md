# Copilot Instructions for AI Agents

## Project Overview
- **JeepBoxHero** is a Flutter/Flame game simulating a record shop, with narrative-driven encounters and shop management mechanics.
- The app uses **Supabase** for backend data and **Flame/FlameAudio** for game and audio logic.
- Main entry: `lib/main.dart` (initializes Supabase, audio, and launches `JeepBoxApp`).
- Core game logic: `lib/jeep_box_game.dart` (extends `FlameGame`).
- State management: Static classes in `lib/managers/` (e.g., `GameState`, `AudioManager`).
- UI screens: `lib/screens/` (each encounter and shop flow is a separate screen).
- Data models: `lib/components/records/`, `lib/components/customer/`.
- Constants: `lib/utils/game_constants.dart` (colors, timings, layout, prices).

## Developer Workflows
- **Build/Run:** Use standard Flutter commands (`flutter run`, `flutter build`).
- **Assets:** All game assets (audio, images) are in `assets/` and declared in `pubspec.yaml`.
- **Audio:** Preload common audio files via `AudioManager.initialize()` at startup.
- **Backend:** Supabase credentials are hardcoded in `main.dart` for dev; rotate for production.
- **Testing:** No custom test runner; use `flutter test` for unit tests in `test/` (if present).

## Project-Specific Patterns
- **State:** Game state is managed via static lists and methods in `GameState` (not Provider/Bloc).
- **Audio:** Two `AudioPlayer` instances in `AudioManager` for ambient and encounter music; assets loaded from `assets/audio/`.
- **Screen Navigation:** Each major flow (shop, encounters, cart, records) is a separate StatefulWidget in `lib/screens/`.
- **Data Flow:** Records and cart items are passed via static state, not via widget props.
- **Encounters:** Each encounter screen (`encounter1_screen.dart`, etc.) contains its own dialogue and logic.
- **Constants:** Use `GameConstants` for UI and gameplay values; update here for global changes.

## Integration Points
- **Supabase:** Used for cloud data; initialized in `main.dart`.
- **Flame/FlameAudio:** Used for game loop and audio; see `jeep_box_game.dart` and `audio_manager.dart`.

## Conventions
- **Assets:** Organize by type (`albums`, `audio`, `backgrounds`, etc.).
- **Screens:** Name as `<feature>_screen.dart`.
- **Managers:** Singleton pattern for managers (e.g., `AudioManager`).
- **No Bloc/Redux:** State is static, not reactive.

## Examples
- To preload new audio, add filenames to `AudioManager.initialize()` and declare in `pubspec.yaml`.
- To add a new encounter, create a new screen in `lib/screens/` and update navigation logic.

---

If any section is unclear or missing, please provide feedback for further refinement.