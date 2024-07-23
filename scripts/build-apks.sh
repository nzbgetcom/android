#!/bin/sh
set -e
rm -rf build/*

VERSION=$(cat app/build.gradle | grep versionName | cut -d '"' -f 2)
if [ -z $ANDROID_HOME ]; then
    export ANDROID_HOME="/usr/local/lib/android/sdk"
fi

# build debug
./gradlew assembleDebug
cp app/build/outputs/apk/debug/app-debug.apk build/

# build unsigned release
./gradlew assembleRelease
cp app/build/outputs/apk/release/app-release-unsigned.apk build/

# build signed release
if [ ! -z $SIGN_STORE ] && [ ! -z $SIGN_PASSWORD ]; then
    ./gradlew assembleRelease \
        -Pandroid.injected.signing.store.file=$SIGN_STORE \
        -Pandroid.injected.signing.store.password=$SIGN_PASSWORD \
        -Pandroid.injected.signing.key.alias=nzbget-key \
        -Pandroid.injected.signing.key.password=$SIGN_PASSWORD
    cp app/build/outputs/apk/release/app-release.apk build/
fi

# rename apks
for FILE in build/*.apk; do
    NEW_FILE=${FILE/app-/nzbget-android-$VERSION-}
    NEW_FILE=${NEW_FILE/-release/}
    NEW_FILE=${NEW_FILE/.apk/-bin.apk}
    mv $FILE $NEW_FILE
done
