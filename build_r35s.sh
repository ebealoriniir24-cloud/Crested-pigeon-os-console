#!/bin/bash
# ====================================================================
# Crested Pigeons OS - Automated Compilation & Packaging Engine
# Target Device: Anbernic R35S / R36S (Rockchip RK3326 Base)
# Architecture: Android Go 10/11 Framework
# ====================================================================

# Set terminal coloring for output tracking
PRIMARY_ACCENT="\e[38;5;129m" # Iridescent Purple
SUCCESS_GREEN="\e[38;5;34m"   # Wing Green
ERROR_RED="\e[38;5;196m"      # Alert Red
RESET_COLOR="\e[0m"

echo -e "${PRIMARY_ACCENT}=================================================="
echo -e "       LAUNCHING CRESTED PIGEONS OS BUILD ENGINE   "
echo -e "               TARGET PROFILE: R35S               "
echo -e "==================================================${RESET_COLOR}"

# Step 1: Initialize the Android build environment
echo -e "\n[1/5] Sourcing core Android environment variables..."
if [ -f "build/envsetup.sh" ]; then
    source build/envsetup.sh
else
    echo -e "${ERROR_RED}Error: Run this script from the root of your Android source tree.${RESET_COLOR}"
    exit 1
fi

# Step 2: Select the target compilation device configurations
echo -e "\n[2/5] Injecting device specific lunch configurations..."
# Targeting R35S under userdebug parameters for testing/logs optimization
lunch rk3326_r35s-userdebug

if [ $? -ne 0 ]; then
    echo -e "${ERROR_RED}Error: Failed to register lunch target rk3326_r35s.${RESET_COLOR}"
    exit 1
fi

# Step 3: Run the system compiler engine utilizing all processor threads
echo -e "\n[3/5] Compiling system architecture code (this may take some time)..."
# Dynamically allocates processing threads via nproc
make -j$(nproc)

if [ $? -ne 0 ]; then
    echo -e "${ERROR_RED}Error: System build compilation halted due to compiler error.${RESET_COLOR}"
    exit 1
fi

# Step 4: Inject custom low-level assets and configs into output path
echo -e "\n[4/5] Staging custom boot animations and system overlays..."
OUT_DIR="out/target/product/rk3326_r35s"
mkdir -p "$OUT_DIR/system/media"

# Pack the boot animation with the correct 640x480 resolution frame parameters
if [ -f "themes/bootanimation.zip" ]; then
    cp themes/bootanimation.zip "$OUT_DIR/system/media/"
    echo -e "-> Injected custom Crested Pigeons boot animation successfully."
else
    echo "-> Warning: Custom bootanimation.zip not found in /themes. Falling back to default."
fi

# Step 5: Packaging the final system binaries into a flashable image map
echo -e "\n[5/5] Compiling partitions into monolithic flashable storage layout..."
if [ -f "device/rockchip/common/mkimage.sh" ]; then
    ./device/rockchip/common/mkimage.sh
else
    echo -e "${ERROR_RED}Error: Rockchip imaging tool missing from device/rockchip/common.${RESET_COLOR}"
    exit 1
fi

echo -e "\n${SUCCESS_GREEN}=================================================="
echo -e " BUILD SUCCESSFUL! CRESTED PIGEONS OS COMPILED!   "
echo -e " Flash target location: $OUT_DIR/CrestedPigeonsOS_R35S.img "
echo -e "==================================================${RESET_COLOR}"
