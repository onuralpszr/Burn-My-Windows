#!/bin/bash

# -------------------------------------------------------------------------------------- #
#           )                                                   (                        #
#        ( /(   (  (               )    (       (  (  (         )\ )    (  (             #
#        )\()) ))\ )(   (         (     )\ )    )\))( )\  (    (()/( (  )\))(  (         #
#       ((_)\ /((_|()\  )\ )      )\  '(()/(   ((_)()((_) )\ )  ((_)))\((_)()\ )\        #
#       | |(_|_))( ((_)_(_/(    _((_))  )(_))  _(()((_|_)_(_/(  _| |((_)(()((_|(_)       #
#       | '_ \ || | '_| ' \))  | '  \()| || |  \ V  V / | ' \)) _` / _ \ V  V (_-<       #
#       |_.__/\_,_|_| |_||_|   |_|_|_|  \_, |   \_/\_/|_|_||_|\__,_\___/\_/\_//__/       #
#                                  |__/                                                  #
#                        Copyright (c) 2021 Simon Schneegans                             #
#           Released under the GPLv3 or later. See LICENSE file for details.             #
# -------------------------------------------------------------------------------------- #

# Exit the script when one command fails.
set -e

# Go to the script's directory.
cd "$( cd "$( dirname "$0" )" && pwd )" || \
  { echo "ERROR: Could not find kwin directory."; exit 1; }

BUILD_DIR="_build"

mkdir -p "${BUILD_DIR}"

# $1: The nick of the effect (e.g. "tv")
# $2: The name of the effect (e.g. "TV Effect")
# $3: A short description of the effect
generate() {
  cp -r "kwin4_effect_$1" "${BUILD_DIR}"

  # Create resource directories.
  mkdir -p "${BUILD_DIR}/kwin4_effect_$1/contents/shaders"
  mkdir -p "${BUILD_DIR}/kwin4_effect_$1/contents/code"

  sed -e "s;%NICK%;$1;g" -e "s;%NAME%;$2;g" -e "s;%DESCRIPTION%;$3;g" \
    metadata.desktop.in > "${BUILD_DIR}/kwin4_effect_$1/metadata.desktop"

  sed -e "s;%NICK%;$1;g" -e "s;%NAME%;$2;g" -e "s;%DESCRIPTION%;$3;g" \
    main.js.in > "${BUILD_DIR}/kwin4_effect_$1/contents/code/main.js"

  {
    echo "#version 140"
    echo "#define KWIN"
    echo ""
    echo "// This file is automatically generated during the build process."
    echo ""
    cat "../resources/shaders/common.glsl"
    cat "../resources/shaders/$1.frag"
  } > "${BUILD_DIR}/kwin4_effect_$1/contents/shaders/$1_core.frag"

  {
    echo "#version 100"
    echo "#define KWIN_LEGACY"
    echo ""
    echo "// This file is automatically generated during the build process."
    echo ""
    cat "../resources/shaders/common.glsl"
    cat "../resources/shaders/$1.frag"
  } > "${BUILD_DIR}/kwin4_effect_$1/contents/shaders/$1.frag"
}

generate "tv" "TV Effect" "Make windows close like turning off a TV"
# generate "fire" "Fire" "Make windows burn"