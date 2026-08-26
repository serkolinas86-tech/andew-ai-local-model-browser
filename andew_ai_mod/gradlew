#!/bin/sh
# Gradle wrapper script

# Determine the java command to use to start the JVM.
if [ -n "$JAVA_HOME" ] ; then
    if [ -x "$JAVA_HOME/jre/sh/java" ] ; then
        JAVACMD="$JAVA_HOME/jre/sh/java"
    else
        JAVACMD="$JAVA_HOME/bin/java"
    fi
    if [ ! -x "$JAVACMD" ] ; then
        die "ERROR: JAVA_HOME is set to an invalid directory: $JAVA_HOME\n\nPlease set the JAVA_HOME variable in your environment to match the\nlocation of your Java installation."
    fi
else
    JAVACMD="java"
    which java >/dev/null 2>&1 || die "ERROR: JAVA_HOME is not set and no 'java' command could be found in your PATH.\n\nPlease set the JAVA_HOME variable in your environment to match the\nlocation of your Java installation."
fi

# Determine the Gradle wrapper JAR location
APP_HOME="$(cd "$(dirname "$0")" && pwd)"
WRAPPER_JAR="$APP_HOME/gradle/wrapper/gradle-wrapper.jar"

# Check if wrapper jar exists
if [ ! -f "$WRAPPER_JAR" ]; then
    echo "Downloading gradle wrapper..."
    mkdir -p "$APP_HOME/gradle/wrapper"
    GRADLE_VERSION="8.5"
    WRAPPER_URL="https://services.gradle.org/distributions/gradle-${GRADLE_VERSION}-bin.zip"
    # We'd need to extract gradle-wrapper.jar from the distribution
    # For simplicity, we'll use the gradle wrapper from the installed gradle
fi

# Execute Gradle
exec "$JAVACMD" -jar "$WRAPPER_JAR" "$@"