# Flutter
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-dontwarn io.flutter.embedding.**

# Firebase / Firestore / gRPC (used for online high scores)
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }
-keep class io.grpc.** { *; }
-dontwarn com.google.firebase.**
-dontwarn io.grpc.**
-dontwarn com.google.android.gms.**
