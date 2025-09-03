FROM cubecoders/ampbase

LABEL authors="Charismara"

RUN apt-get update && apt-get -y upgrade && \
    apt-get install -y curl gnupg && \
    mkdir -p /etc/apt/keyrings && \
    curl -fsSL https://repo.jellyfin.org/jellyfin_team.gpg.key | gpg --dearmor -o /etc/apt/keyrings/jellyfin.gpg && \
    VERSION_OS="$( awk -F'=' '/^ID=/{ print $NF }' /etc/os-release )" &&  \
    VERSION_CODENAME="$( awk -F'=' '/^VERSION_CODENAME=/{ print $NF }' /etc/os-release )" &&  \
    DPKG_ARCHITECTURE="$( dpkg --print-architecture )" && \
    echo "Types: deb\nURIs: https://repo.jellyfin.org/${VERSION_OS}\nSuites: ${VERSION_CODENAME}\nComponents: main\nArchitectures: ${DPKG_ARCHITECTURE}\nSigned-By: /etc/apt/keyrings/jellyfin.gpg" \
    > /etc/apt/sources.list.d/jellyfin.sources && \
    apt-get update && apt-get -y upgrade && \
    apt install -y jellyfin-server jellyfin-web && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

ENV PATH=$PATH:/usr/lib/jellyfin-ffmpeg

ENTRYPOINT ["/ampstart.sh"]
CMD []
