#!/bin/sh

echo "+ Scraping SDK website for version number"

ANDROID_SDK_VERSION=$(curl --silent https://developer.android.com/studio/ | grep -m 1 -o 'sdk-tools-linux-\d*' | cut -f 4 -d -)
if [ -z "$ANDROID_SDK_VERSION" ]; then
    echo "Version not found"
    exit 1
fi
echo "+ Found version $ANDROID_SDK_VERSION"

echo "+ Scraping Android repository-12.xml for build tools"

BUILD_TOOLS_VERSION=$(curl --silent https://dl.google.com/android/repository/repository-12.xml | grep -o "build-tools_r\d*\.\d*\.\d*" | cut -f 2 -d r | sort -r | head -n 1)
if [ -z "$BUILD_TOOLS_VERSION" ]; then
    echo "Version not found"
    exit 1
fi
echo "+ Found version $BUILD_TOOLS_VERSION"

PLATFORM_VERSION=$(echo $BUILD_TOOLS_VERSION | cut -f 1 -d .)
echo "+ Assuming platform version $PLATFORM_VERSION"

echo "+ Replacing ANDROID_SDK_VERSION in Dockerfile"

sed -i '' "s/ENV ANDROID_SDK_VERSION .*/ENV ANDROID_SDK_VERSION $ANDROID_SDK_VERSION/" Dockerfile

echo "+ Replacing BUILD_TOOLS_VERSION in Dockerfile"

sed -i '' "s/ENV BUILD_TOOLS_VERSION .*/ENV BUILD_TOOLS_VERSION $BUILD_TOOLS_VERSION/" Dockerfile

echo "+ Replacing PLATFORM_VERSION in Dockerfile"

sed -i '' "s/ENV PLATFORM_VERSION .*/ENV PLATFORM_VERSION $PLATFORM_VERSION/" Dockerfile

echo "+ Done!"

echo

echo "+ Committing"

git commit -a -m "Bump SDK version to $ANDROID_SDK_VERSION"

echo "+ Tagging"

git tag $ANDROID_SDK_VERSION

echo "+ Pushing"

git push --tags

echo "+ Done!"
