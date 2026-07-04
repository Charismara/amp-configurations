#!/bin/bash
# AMP launcher for the Gradle Java App template.
#
# AMP starts this script as the instance process. Its arguments are:
#   --amp-java <path>       absolute path to the JDK 'java' binary to run
#   --amp-env-file <path>   file holding the user's environment variables
#   --                      end of launcher options; everything after it is
#                           passed verbatim to the JVM
#
# Any number of environment variables can be defined - one NAME=VALUE per line -
# in the env file (edit it in AMP's File Manager). Names are used exactly as
# written; no prefixes are added and no helper variables leak to the app.
# `exec` keeps the same PID so AMP's process monitoring, console I/O and stop
# signals target the JVM directly.
set -u

java_bin="/opt/java/jdk-21/bin/java"
env_file=""

while [ $# -gt 0 ]; do
    case "$1" in
        --amp-java)     java_bin="$2"; shift 2 ;;
        --amp-env-file) env_file="$2"; shift 2 ;;
        --)             shift; break ;;
        *)              break ;;
    esac
done

if [ -n "$env_file" ]; then
    # Drop a commented example on first start so it is easy to find and edit.
    if [ ! -e "$env_file" ] && [ -d "$(dirname "$env_file")" ]; then
        {
            echo "# Environment variables for this instance."
            echo "# One NAME=VALUE per line (no spaces around =). Unlimited entries."
            echo "# Blank lines and lines starting with # are ignored."
            echo "# Example:"
            echo "#   MY_TOKEN=abc123"
            echo "#   GREETING=hello world"
        } > "$env_file" 2>/dev/null || true
    fi

    if [ -f "$env_file" ]; then
        while IFS= read -r line || [ -n "$line" ]; do
            line="${line%$'\r'}"
            case "$line" in
                ''|'#'*) continue ;;
                *=*)     : ;;
                *)       continue ;;
            esac
            key="${line%%=*}"
            case "$key" in
                ''|[!A-Za-z_]*|*[!A-Za-z0-9_]*) continue ;;
            esac
            export "$line"
        done < "$env_file"
    fi
fi

exec "$java_bin" "$@"