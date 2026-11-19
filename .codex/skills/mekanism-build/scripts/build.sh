#!/usr/bin/env bash
set -euo pipefail

skill_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
repo_root="$(cd "$skill_dir/../../.." && pwd)"
tools_root="/opt/minecraft-tools"
gradle_home="$tools_root/gradle-home"
java_home="$tools_root/jdks/jdk-25.0.4.1+1"
gradle_bin="$tools_root/gradle/gradle-9.8.0/bin/gradle"
proxy_url="http://192.168.30.118:7890"

for required_path in "$gradle_home" "$java_home" "$gradle_bin"; do
    if [[ ! -e "$required_path" ]]; then
        echo "Missing Minecraft build tool: $required_path" >&2
        exit 1
    fi
done

if [[ ! -x "$gradle_bin" || ! -x "$java_home/bin/java" ]]; then
    echo "Minecraft build tool is not executable" >&2
    exit 1
fi

mod_version="$(awk -F '=' '/^[[:space:]]*mod_version[[:space:]]*=/{gsub(/[[:space:]]/, "", $2); print $2; exit}' "$repo_root/gradle.properties")"
if [[ -z "$mod_version" ]]; then
    echo "Could not read mod_version from gradle.properties" >&2
    exit 1
fi
if [[ -n "${EXPECTED_VERSION:-}" && "$mod_version" != "$EXPECTED_VERSION" ]]; then
    echo "Expected mod_version $EXPECTED_VERSION, found $mod_version" >&2
    exit 1
fi

export GRADLE_USER_HOME="$gradle_home"
export JAVA_HOME="$java_home"
export PATH="$java_home/bin:$(dirname "$gradle_bin"):$PATH"

if [[ "${BUILD_ONLINE:-0}" == "1" ]]; then
    export http_proxy="${http_proxy:-$proxy_url}"
    export https_proxy="${https_proxy:-$proxy_url}"
    export HTTP_PROXY="$http_proxy"
    export HTTPS_PROXY="$https_proxy"
    offline_args=()
else
    offline_args=(--offline)
fi

if (($# == 0)); then
    set -- build
fi

cd "$repo_root"
"$gradle_bin" --no-daemon "${offline_args[@]}" "$@"

case "$1" in
    build|assemble|jar|reobfJar)
        artifact="$(find "$repo_root/build/libs" -maxdepth 1 -type f -name "*-${mod_version}.jar" \
            ! -name "*-dev.jar" ! -name "*-sources.jar" -print -quit 2>/dev/null || true)"
        if [[ -z "$artifact" ]]; then
            echo "Build succeeded, but no packaged artifact for version $mod_version was found" >&2
            exit 1
        fi
        echo "Built artifact: $artifact"
        ;;
esac
