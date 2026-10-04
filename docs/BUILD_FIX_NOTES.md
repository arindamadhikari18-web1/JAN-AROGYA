# JAN AROGYA build fix

## Fixed Dart compile error
`nearby_hospitals_screen.dart` used `margin:` directly on `Ink`. Flutter's `Ink` widget does not have a `margin` parameter. The hospital card is now wrapped in `Padding` and the `margin` is removed from `Ink`.

## Dependency updates
- url_launcher: ^6.3.33
- geolocator: ^14.0.3
- permission_handler: ^12.0.3
- flutter_local_notifications: ^22.3.1
- flutter_timezone: ^5.1.0
- image_picker: ^1.2.3
- shared_preferences remains ^2.5.4

## Built-in Kotlin status
The project intentionally keeps `android.builtInKotlin=false` for now. The current stable permission_handler Android implementation has an open upstream AGP 9 / Built-in Kotlin migration issue, so enabling Built-in Kotlin would risk another build failure. Do not remove the Kotlin plugin from settings.gradle.kts until that dependency is migrated.

## After replacing files
Run:

flutter clean
flutter pub get
flutter run
