#!/bin/bash

# Android Emulator Setup Script for Flutter Projects
# This script configures and starts an Android emulator for testing

set -e

# Default values
API_LEVEL=31
ARCH="x86_64"
EMULATOR_NAME="flutter_emulator"
VERBOSE=false

# Parse arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    --api-level)
      API_LEVEL="$2"
      shift 2
      ;;
    --arch)
      ARCH="$2"
      shift 2
      ;;
    --name)
      EMULATOR_NAME="$2"
      shift 2
      ;;
    --verbose)
      VERBOSE=true
      shift
      ;;
    *)
      echo "Unknown option: $1"
      exit 1
      ;;
  esac
done

# Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

log_info() {
  echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
  echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
  echo -e "${RED}[ERROR]${NC} $1"
}

# Check if ANDROID_HOME is set
if [ -z "$ANDROID_HOME" ]; then
  log_error "ANDROID_HOME environment variable not set"
  exit 1
fi

log_info "Starting Android Emulator Setup"
log_info "API Level: $API_LEVEL"
log_info "Architecture: $ARCH"
log_info "Emulator Name: $EMULATOR_NAME"

# Verify Android SDK tools
log_info "Verifying Android SDK tools..."
if [ ! -f "$ANDROID_HOME/cmdline-tools/latest/bin/sdkmanager" ]; then
  log_warn "SDK Manager not found in expected location"
fi

# Install system image if not present
log_info "Ensuring Android API $API_LEVEL system image is installed..."
$ANDROID_HOME/cmdline-tools/latest/bin/sdkmanager \
  "system-images;android-$API_LEVEL;google_apis;$ARCH" \
  --accept_licenses || true

# Create emulator AVD if it doesn't exist
log_info "Checking for existing emulator AVD..."
AVD_LIST=$($ANDROID_HOME/cmdline-tools/latest/bin/avdmanager list avd | grep "Name: $EMULATOR_NAME" || true)

if [ -z "$AVD_LIST" ]; then
  log_info "Creating new Android Virtual Device: $EMULATOR_NAME"
  $ANDROID_HOME/cmdline-tools/latest/bin/avdmanager create avd \
    --force \
    --name "$EMULATOR_NAME" \
    --package "system-images;android-$API_LEVEL;google_apis;$ARCH" \
    --device "Nexus 5X"
else
  log_info "Emulator AVD already exists: $EMULATOR_NAME"
fi

# Start emulator in background
log_info "Starting emulator..."
$ANDROID_HOME/emulator/emulator \
  -avd "$EMULATOR_NAME" \
  -no-snapshot-load \
  -no-snapshot-save \
  -no-window \
  -no-boot-anim \
  -cores 2 \
  -memory 2048 \
  -disk-datadir ~/.android/avd/"$EMULATOR_NAME".avd &

EMULATOR_PID=$!
log_info "Emulator started with PID: $EMULATOR_PID"

# Wait for emulator to be ready
log_info "Waiting for emulator to boot (this may take 2-3 minutes)..."

WAIT_TIME=0
MAX_WAIT_TIME=300  # 5 minutes
CHECK_INTERVAL=5

while [ $WAIT_TIME -lt $MAX_WAIT_TIME ]; do
  if $ANDROID_HOME/platform-tools/adb devices | grep -q "device$"; then
    BOOT_COMPLETE=$($ANDROID_HOME/platform-tools/adb shell getprop sys.boot_completed 2>/dev/null || echo "")
    if [ "$BOOT_COMPLETE" = "1" ]; then
      log_info "Emulator is ready!"
      break
    fi
  fi

  WAIT_TIME=$((WAIT_TIME + CHECK_INTERVAL))
  if [ $((WAIT_TIME % 30)) -eq 0 ]; then
    log_info "Still waiting for emulator to boot... ($WAIT_TIME seconds elapsed)"
  fi
  sleep $CHECK_INTERVAL
done

if [ $WAIT_TIME -ge $MAX_WAIT_TIME ]; then
  log_error "Emulator failed to start within timeout period"
  kill $EMULATOR_PID || true
  exit 1
fi

# Verify emulator is accessible
log_info "Verifying emulator connectivity..."
$ANDROID_HOME/platform-tools/adb devices
$ANDROID_HOME/platform-tools/adb shell "echo 'Emulator connection successful'"

log_info "Android emulator setup completed successfully!"
log_info "Emulator API Level: $API_LEVEL"
log_info "Emulator Architecture: $ARCH"
log_info "Emulator Name: $EMULATOR_NAME"
