# Keep Flutter and plugin entry points
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Keep classes referenced via reflection (common for plugins)
-keep class com.dexterous.** { *; }
-keep class com.maido.sdk.** { *; }

# Keep Kotlin metadata
-keep class kotlin.Metadata { *; }

# Keep WorkManager classes if used by plugins
-keep class androidx.work.** { *; }
-dontwarn javax.annotation.**
-dontwarn org.jetbrains.annotations.**

# Keep Parcelable CREATORs
-keepclassmembers class ** implements android.os.Parcelable {
    public static final android.os.Parcelable$Creator CREATOR;
}

# Keep generated plugin registrant
-keep class io.flutter.plugins.GeneratedPluginRegistrant { *; }

# Keep androidx.concurrent futures used by camera
-keep class androidx.concurrent.futures.** { *; }

# Don't warn about optional deps
-dontwarn org.conscrypt.**