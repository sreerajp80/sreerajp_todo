# Flutter engine — always required
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Flutter Play Core (deferred components not used in offline build)
-dontwarn com.google.android.play.core.**

# sqflite native plugin
-keep class com.tekartik.sqflite.** { *; }

# Google ML Kit Text Recognition optional languages not bundled in default build
-dontwarn com.google.mlkit.vision.text.chinese.**
-dontwarn com.google.mlkit.vision.text.devanagari.**
-dontwarn com.google.mlkit.vision.text.japanese.**
-dontwarn com.google.mlkit.vision.text.korean.**
