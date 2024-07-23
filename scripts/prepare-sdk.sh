#!/bin/sh
set -e
sudo apt update
sudo apt install -y sdkmanager apksigner
sudo sdkmanager --install "build-tools;28.0.3"
sudo sdkmanager --install "platforms;android-28"
