# Android Dockerfile based on uber/android-build-environment

FROM ubuntu:16.04

# Never ask for confirmations
ENV DEBIAN_FRONTEND noninteractive

# SDK version
ENV ANDROID_SDK_VERSION 3859397

# Update apt-get
RUN apt-get update \
  && apt-get install -y --no-install-recommends \
      build-essential \
      software-properties-common \
      unzip \
      wget \
      zip \
  && apt-add-repository ppa:openjdk-r/ppa \
  && apt-get update \
  && apt-get install -y openjdk-9-jdk \
  && apt-get autoremove -y \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

# Install Android SDK
RUN wget https://dl.google.com/android/repository/sdk-tools-linux-$ANDROID_SDK_VERSION.zip \
  && unzip sdk-tools-linux-$ANDROID_SDK_VERSION.zip \
  && mv tools /usr/local/android-tools \
  && rm sdk-tools-linux-$ANDROID_SDK_VERSION.zip

RUN echo y | /usr/local/android-tools/bin/sdkmanager \
  "platform-tools" \
  "platforms;android-26" \
  "build-tools;26.0.2" \
  \
  "ndk-bundle" \
  "lldb;2.3" \
  "cmake;3.6.4111459"

# Environment variables
ENV ANDROID_HOME /usr/local/android-tools
ENV PATH $ANDROID_HOME:$PATH
ENV PATH $ANDROID_HOME/platform-tools:$PATH
ENV PATH $ANDROID_HOME/tools:$PATH
ENV PATH $ANDROID_HOME/bin:$PATH

# Export JAVA_HOME variable
ENV JAVA_HOME /usr/lib/jvm/java-9-openjdk-amd64/

# Support Gradle
ENV TERM dumb
ENV JAVA_OPTS "-Xms512m -Xmx1024m"
ENV GRADLE_OPTS "-XX:+UseG1GC -XX:MaxGCPauseMillis=1000"

# Add build user account, values are set to default below
ENV RUN_USER builder
ENV RUN_UID 5000

RUN id $RUN_USER || adduser --uid "$RUN_UID" \
    --gecos 'Build User' \
    --shell '/bin/sh' \
    --disabled-login \
    --disabled-password "$RUN_USER"

# Fix permissions
RUN chown -R $RUN_USER:$RUN_USER $ANDROID_HOME
RUN chmod -R a+rx $ANDROID_HOME

# Creating project directories prepared for build when running
# `docker run`
ENV PROJECT /project
RUN mkdir $PROJECT
RUN chown -R $RUN_USER:$RUN_USER $PROJECT
WORKDIR $PROJECT

USER $RUN_USER
RUN echo "sdk.dir=$ANDROID_HOME" > local.properties

CMD ["./gradlew", "build"]
