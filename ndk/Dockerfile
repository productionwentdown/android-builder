# Android Dockerfile based on uber/android-build-environment

FROM ubuntu:18.04

# SDK version
ENV ANDROID_SDK_VERSION 6200805
ENV PLATFORM_VERSION 29
ENV BUILD_TOOLS_VERSION 29.0.3

# Never ask for confirmations
ENV DEBIAN_FRONTEND noninteractive

# Update apt-get
RUN apt-get -qq update \
  && apt-get -qq install -y --no-install-recommends \
      software-properties-common \
      unzip \
      wget \
      zip \
      xxd \
  && apt-add-repository ppa:openjdk-r/ppa \
  && apt-get -qq update \
  && apt-get -qq install -y openjdk-8-jdk \
      -o Dpkg::Options::="--force-overwrite" \
  && apt-get -qq autoremove -y \
  && apt-get -qq clean \
  && rm -rf /var/lib/apt/lists/*

# Install Android SDK
RUN wget https://dl.google.com/android/repository/commandlinetools-linux-${ANDROID_SDK_VERSION}_latest.zip -q \
  && mkdir /usr/local/android \
  && unzip -q commandlinetools-linux-${ANDROID_SDK_VERSION}_latest.zip -d /usr/local/android \
  && rm commandlinetools-linux-${ANDROID_SDK_VERSION}_latest.zip

# Export JAVA_HOME variable
ENV JAVA_HOME /usr/lib/jvm/java-8-openjdk-amd64

# Environment variables
ENV ANDROID_HOME /usr/local/android
ENV ANDROID_SDK_HOME $ANDROID_HOME
ENV ANDROID_NDK_HOME $ANDROID_HOME/ndk-bundle
ENV PATH $ANDROID_HOME/tools/bin:$ANDROID_HOME/build-tools/$BUILD_TOOLS_VERSION:$PATH

# Install Android SDK components
RUN echo "y" | sdkmanager \
  "ndk-bundle" \
  "lldb;3.1" \
  "cmake;3.6.4111459" \
  "extras;google;m2repository" \
  "platform-tools" \
  "platforms;android-$PLATFORM_VERSION" \
  "build-tools;$BUILD_TOOLS_VERSION"

# Add release helper
COPY release /usr/local/bin/release

# Build directory
ENV SRC /src
RUN mkdir $SRC
WORKDIR $SRC

RUN echo "sdk.dir=$ANDROID_HOME" > local.properties
RUN echo "ndk.dir=$ANDROID_HOME" > local.properties

CMD ["./gradlew", "build"]
