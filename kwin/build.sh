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
# $3: A short description of the effect (e.g. "Make windows close like turning off a TV")
generate() {

  # Create resource directories.
  mkdir -p "${BUILD_DIR}/kwin4_effect_$1/contents/shaders"
  mkdir -p "${BUILD_DIR}/kwin4_effect_$1/contents/code"
  mkdir -p "${BUILD_DIR}/kwin4_effect_$1/contents/config"
  mkdir -p "${BUILD_DIR}/kwin4_effect_$1/contents/ui"

  cp "kwin4_effect_$1/main.xml" "${BUILD_DIR}/kwin4_effect_$1/contents/config"
  cp "kwin4_effect_$1/config.ui" "${BUILD_DIR}/kwin4_effect_$1/contents/ui"

  perl -pe "s/%LOAD_CONFIG%/`cat kwin4_effect_$1/loadConfig.js | tr '/' '\f' `/g;" \
       main.js.in | tr '\f' '/' > "${BUILD_DIR}/kwin4_effect_$1/contents/code/main.js"

  perl -pi -e "s/%NICK%/$1/g;" "${BUILD_DIR}/kwin4_effect_$1/contents/code/main.js"

  perl -pe "s/%NICK%/$1/g;" metadata.desktop.in > "${BUILD_DIR}/kwin4_effect_$1/metadata.desktop"
  perl -pi -e "s/%NAME%/$2/g;" "${BUILD_DIR}/kwin4_effect_$1/metadata.desktop"
  perl -pi -e "s/%DESCRIPTION%/$3/g;" "${BUILD_DIR}/kwin4_effect_$1/metadata.desktop"

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