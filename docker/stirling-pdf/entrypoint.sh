#!/bin/bash
# Custom AMP entrypoint for the Stirling-PDF image.
#
# Stirling-PDF performs Office (Word/Excel/PowerPoint <-> PDF) conversions by
# calling `unoconvert`, which talks to a running LibreOffice UNO server. The
# official Stirling container starts that server from its own entrypoint; AMP
# launches the app directly and bypasses it, so we start unoserver here and
# then hand off to AMP's normal startup (which launches & manages the instance).
set -u

UNO_PORT=2003
UNO_UNOPORT=2002

if command -v unoserver >/dev/null 2>&1; then
    # Only start if nothing is already listening on the default UNO port.
    if ! (exec 3<>/dev/tcp/127.0.0.1/${UNO_PORT}) 2>/dev/null; then
        mkdir -p /tmp/unoserver-profile
        nohup unoserver \
            --interface 127.0.0.1 --port "${UNO_PORT}" --uno-port "${UNO_UNOPORT}" \
            --user-installation /tmp/unoserver-profile \
            >/tmp/unoserver.log 2>&1 &
    fi
    exec 3>&- 2>/dev/null || true
fi

exec /ampstart.sh "$@"
