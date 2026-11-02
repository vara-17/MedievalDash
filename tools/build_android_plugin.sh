#!/bin/sh
# Compila el plugin de Android GoogleSignIn y copia el .aar al addon de Godot.
# Uso: sh tools/build_android_plugin.sh
set -e
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SRC="$ROOT/plugins/google_sign_in_android"
DEST="$ROOT/addons/google_sign_in/bin"

export ANDROID_HOME="${ANDROID_HOME:-$HOME/Library/Android/sdk}"
if [ -z "$JAVA_HOME" ] && [ -d /Library/Java/JavaVirtualMachines/temurin-17.jdk ]; then
	export JAVA_HOME=/Library/Java/JavaVirtualMachines/temurin-17.jdk/Contents/Home
fi

cd "$SRC"
./gradlew --no-daemon assembleRelease
mkdir -p "$DEST"
cp build/outputs/aar/GoogleSignIn-release.aar "$DEST/GoogleSignIn.aar"
echo "Plugin copiado a $DEST/GoogleSignIn.aar"
