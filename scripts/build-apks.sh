#!/bin/sh
set -e
rm -rf build/*

VERSION=$(cat app/build.gradle | grep versionName | cut -d '"' -f 2)

# build debug
ANDROID_HOME=/opt/android-sdk/ ./gradlew assembleDebug

# build unsigned release
ANDROID_HOME=/opt/android-sdk/ ./gradlew assembleRelease

# build signed release
if [ ! -z $SIGN_STORE ] && [ ! -z $SIGN_PASSWORD ]; then
    ANDROID_HOME=/opt/android-sdk/ ./gradlew assembleRelease \
        -Pandroid.injected.signing.store.file=$SIGN_STORE \
        -Pandroid.injected.signing.store.password=$SIGN_PASSWORD \
        -Pandroid.injected.signing.key.alias=nzbget-key \
        -Pandroid.injected.signing.key.password=$SIGN_PASSWORD
fi

# copy apks to build directory
cp app/build/outputs/apk/debug/app-debug.apk build/
cp app/build/outputs/apk/release/app-release-unsigned.apk build/
cp app/build/outputs/apk/release/app-release.apk build/

# rename apks
for FILE in build/*.apk; do
    NEW_FILE=${FILE/app-/nzbget-android-$VERSION-}
    NEW_FILE=${NEW_FILE/-release/}
    NEW_FILE=${NEW_FILE/.apk/-bin.apk}
    mv $FILE $NEW_FILE
done
