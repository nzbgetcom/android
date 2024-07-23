#!/bin/sh
set -e
sudo apt-get update
sudo apt-get install -y sdkmanager apksigner openjdk-8-jdk
sudo sdkmanager --install "build-tools;28.0.3"
sudo sdkmanager --install "platforms;android-28"
