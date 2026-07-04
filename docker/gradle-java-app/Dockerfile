# Custom AMP base image for the Gradle Java App template.
#
# Reproduces the environment of the official `gradle:8.7-jdk-21-and-22` image on
# top of the CubeCoders AMP base image:
#   * Gradle 8.7
#   * Eclipse Temurin JDK 21 (default runtime) and JDK 22 (Gradle toolchains)
#   * Eclipse Temurin JDK 8, exposed via JAVA_8_HOME
#   * git
#
# AMP's container deployment launches the instance through /ampstart.sh, which
# only exists in cubecoders/ampbase, so the image must extend that base rather
# than the plain gradle image. The JDKs are pulled from Adoptium as tarballs so
# the same versions work on both linux/amd64 and linux/arm64.
#
# This image is built and pushed automatically by
# .github/workflows/build-images.yml to
#   ghcr.io/charismara/gradle-java-app-ampbase   (tags: latest + <yyyy>-<mm>-<dd>.<build>)
#
# To build it manually instead (e.g. directly on the AMP host):
#   docker build -t ghcr.io/charismara/gradle-java-app-ampbase:latest docker/gradle-java-app/
#
# The template references it via:
#   Meta.SpecificDockerImage=ghcr.io/charismara/gradle-java-app-ampbase:latest
FROM cubecoders/ampbase:debian

# Persist Gradle's download/build caches across container rebuilds when this
# path is mounted as a Docker volume (matches the official gradle image).
VOLUME /root/.gradle/caches

ENV DEBIAN_FRONTEND=noninteractive

# ampbase clears the apt lists, so refresh them before installing.
RUN apt-get update && apt-get install -y --no-install-recommends \
        git \
        ca-certificates \
        curl \
        unzip \
    && rm -rf /var/lib/apt/lists/*

# --- JDKs (Eclipse Temurin) -------------------------------------------------
# JDK 8, 21 and 22 are installed side by side under /opt/java. JDK 21 is the
# default runtime; JDK 8 is what JAVA_8_HOME points at for Gradle toolchains.
RUN set -eux; \
    arch="$(dpkg --print-architecture)"; \
    case "$arch" in \
        amd64) jarch=x64 ;; \
        arm64) jarch=aarch64 ;; \
        *) echo "Unsupported architecture: $arch" >&2; exit 1 ;; \
    esac; \
    mkdir -p /opt/java; \
    for spec in "8:/opt/java/jdk-8" "21:/opt/java/jdk-21" "22:/opt/java/jdk-22"; do \
        ver="${spec%%:*}"; dest="${spec#*:}"; \
        echo "Downloading Eclipse Temurin JDK ${ver} (${jarch})..."; \
        curl -fsSL "https://api.adoptium.net/v3/binary/latest/${ver}/ga/linux/${jarch}/jdk/hotspot/normal/eclipse" -o /tmp/jdk.tar.gz; \
        mkdir -p "$dest"; \
        tar -xzf /tmp/jdk.tar.gz -C "$dest" --strip-components=1; \
        rm -f /tmp/jdk.tar.gz; \
    done

# --- Gradle 8.7 -------------------------------------------------------------
ARG GRADLE_VERSION=8.7
RUN set -eux; \
    curl -fsSL "https://services.gradle.org/distributions/gradle-${GRADLE_VERSION}-bin.zip" -o /tmp/gradle.zip; \
    unzip -q /tmp/gradle.zip -d /opt; \
    mv "/opt/gradle-${GRADLE_VERSION}" /opt/gradle; \
    ln -sf /opt/gradle/bin/gradle /usr/local/bin/gradle; \
    rm -f /tmp/gradle.zip

ENV JAVA_HOME=/opt/java/jdk-21 \
    JAVA_8_HOME=/opt/java/jdk-8 \
    JAVA_21_HOME=/opt/java/jdk-21 \
    JAVA_22_HOME=/opt/java/jdk-22 \
    GRADLE_HOME=/opt/gradle \
    PATH=/opt/gradle/bin:/opt/java/jdk-21/bin:$PATH

# Launcher that AMP runs as the instance process (see App.ExecutableLinux). It
# applies the user-defined extra environment variables and then execs the JVM.
COPY run-jar.sh /usr/local/bin/run-jar.sh
# Strip any CR (in case the repo was checked out with CRLF) so the shebang works.
RUN sed -i 's/\r$//' /usr/local/bin/run-jar.sh \
    && chmod 0755 /usr/local/bin/run-jar.sh

# AMP's in-container bootstrap. Must remain the entrypoint so the instance is
# launched and supervised correctly.
ENTRYPOINT ["/ampstart.sh"]
CMD []
