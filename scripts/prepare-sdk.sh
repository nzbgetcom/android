#!/bin/sh
set -e
sudo apt-get update
sudo apt-get purge -y temurin-* || true
sudo apt-get install -y sdkmanager apksigner openjdk-8-jdk
sudo update-alternatives --set java /usr/lib/jvm/java-8-openjdk-amd64/jre/bin/java
sudo sdkmanager --install "build-tools;28.0.3"
sudo sdkmanager --install "platforms;android-28"
echo y | sudo sdkmanager --licenses
