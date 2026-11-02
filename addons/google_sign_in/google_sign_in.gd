@tool
extends EditorPlugin

# Añade el plugin Android GoogleSignIn (bin/GoogleSignIn.aar) a las exportaciones de Android.
# El .aar se compila con tools/build_android_plugin.sh.

var export_plugin: AndroidExportPlugin


func _enter_tree() -> void:
	export_plugin = AndroidExportPlugin.new()
	add_export_plugin(export_plugin)


func _exit_tree() -> void:
	remove_export_plugin(export_plugin)
	export_plugin = null


class AndroidExportPlugin extends EditorExportPlugin:
	# Deben coincidir con las de plugins/google_sign_in_android/build.gradle.
	const DEPENDENCIES := [
		"androidx.credentials:credentials:1.3.0",
		"androidx.credentials:credentials-play-services-auth:1.3.0",
		"com.google.android.libraries.identity.googleid:googleid:1.1.1",
		"org.jetbrains.kotlinx:kotlinx-coroutines-android:1.8.1",
	]

	func _get_name() -> String:
		return "GoogleSignIn"

	func _supports_platform(platform: EditorExportPlatform) -> bool:
		return platform is EditorExportPlatformAndroid

	func _get_android_libraries(_platform: EditorExportPlatform, _debug: bool) -> PackedStringArray:
		return PackedStringArray(["google_sign_in/bin/GoogleSignIn.aar"])

	func _get_android_dependencies(_platform: EditorExportPlatform, _debug: bool) -> PackedStringArray:
		return PackedStringArray(DEPENDENCIES)
