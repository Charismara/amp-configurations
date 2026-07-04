#!/bin/bash
# AMP launcher for the Gradle Java App template.
#
# AMP starts this script as the instance process. It:
#   1. Exports the user-defined "extra environment variables" (slots 1..5). AMP
#      passes them as AMP_ENVNAME_<n> / AMP_ENVVALUE_<n> so that leaving a slot
#      blank never results in an environment variable with an empty name.
#   2. Selects the JDK chosen in the config (AMP_JAVA_BIN) and execs Java with
#      the assembled command-line arguments. `exec` keeps the same PID, so AMP's
#      process monitoring, console I/O and stop signals target the JVM directly.
set -u

for i in 1 2 3 4 5; do
    name_var="AMP_ENVNAME_${i}"
    value_var="AMP_ENVVALUE_${i}"
    name="${!name_var-}"
    value="${!value_var-}"
    if [ -n "${name}" ]; then
        export "${name}=${value}"
    fi
    unset "${name_var}" "${value_var}"
done

java_bin="${AMP_JAVA_BIN:-/opt/java/jdk-21/bin/java}"
unset AMP_JAVA_BIN

exec "${java_bin}" "$@"
