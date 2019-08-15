#!/usr/bin/env bash
# https://github.com/circleci/circleci-images/blob/staging/android/Dockerfile.m4
set -eux -o pipefail

echo "build_android_gradle.sh"
echo "$(pwd)"

ls -la ~/workspace

export sdk_version=sdk-tools-linux-3859397.zip
export android_home=/opt/android/sdk

sudo mkdir -p ${android_home}
curl --silent --show-error --location --fail --retry 3 --output /tmp/${sdk_version} https://dl.google.com/android/repository/${sdk_version}
sudo unzip -q /tmp/${sdk_version} -d ${android_home}
rm /tmp/${sdk_version}

export ANDROID_HOME=${android_home}
export ADB_INSTALL_TIMEOUT=120

export PATH=${ANDROID_HOME}/emulator:${ANDROID_HOME}/tools:${ANDROID_HOME}/tools/bin:${ANDROID_HOME}/platform-tools:${PATH}

mkdir ~/.android && echo '### User Sources for Android SDK Manager' > ~/.android/repositories.cfg
sudo yes | sudo sdkmanager --licenses && yes | sudo sdkmanager --update

sudo sdkmanager \
  "tools" \
  "platform-tools" \
   "emulator"

sudo sdkmanager \
  "build-tools;28.0.3"

export API_LEVEL=28
# API_LEVEL string gets replaced by m4
sudo sdkmanager "platforms;android-${API_LEVEL}"

# https://github.com/keeganwitt/docker-gradle/blob/a206b4a26547df6d8b29d06dd706358e3801d4a9/jdk8/Dockerfile

export GRADLE_VERSION=5.1.1
export gradle_home=/opt/gradle
sudo mkdir -p ${gradle_home}

wget --no-verbose --output-document=/tmp/gradle.zip \
"https://services.gradle.org/distributions/gradle-${GRADLE_VERSION}-bin.zip"

sudo unzip -q /tmp/gradle.zip -d ${gradle_home}
rm /tmp/gradle.zip

export GRADLE_HOME=${gradle_home}
${GRADLE_HOME}/bin/gradle --version

TMP_ANDROID_ABI=x86 # parse from arguments or etc.
BUILD_ANDROID_INCLUDE_DIR=~/workspace/build_android/install/include/
BUILD_ANDROID_LIB_DIR=~/workspace/build_android/install/lib/

PYTORCH_ANDROID_SRC_MAIN_DIR=~/workspace/android/pytorch_android/src/main/

JNI_LIBS_DIR=${PYTORCH_ANDROID_SRC_MAIN_DIR}/jniLibs/${TMP_ANDROID_ABI}/

cp -R ${BUILD_ANDROID_INCLUDE_DIR} ${PYTORCH_ANDROID_SRC_MAIN_DIR}/cpp/

LIBC10_SO=${BUILD_ANDROID_LIB_DIR}/libc10.so
ls -la ${LIBC10_SO}
LIBTORCH_SO=${BUILD_ANDROID_LIB_DIR}/libtorch.so
ls -la ${LIBTORCH_SO}

cp ${LIBC10_SO} ${JNI_LIBS_DIR}
cp ${LIBTORCH_SO} ${JNI_LIBS_DIR}

${GRADLE_HOME}/bin/gradle -p ~/workspace/android/pytorch_android buildRelease

echo "build_android_gradle.sh end"
