---
name: mekanism-build
description: Build this Mekanism CE 1.12.2 Forge repository with the machine-local Minecraft toolchain. Use when compiling, packaging, or validating this repository's mod JAR.
---

# Mekanism CE build

Run the bundled helper from the repository root for the normal build.

```bash
.codex/skills/mekanism-build/scripts/build.sh
```

The helper uses the machine-local toolchain under `/opt/minecraft-tools`.

- Java: `/opt/minecraft-tools/jdks/jdk-25.0.4.1+1`
- Gradle: `/opt/minecraft-tools/gradle/gradle-9.8.0/bin/gradle`
- Gradle cache and downloaded dependencies: `/opt/minecraft-tools/gradle-home`
- Default mode: Gradle `--offline`, so builds use local cached files

For a compile-only check, pass the task name.

```bash
.codex/skills/mekanism-build/scripts/build.sh compileJava
```

If the offline build reports a missing dependency, use the configured proxy to populate `/opt/minecraft-tools/gradle-home`, then rerun the build offline.

```bash
BUILD_ONLINE=1 .codex/skills/mekanism-build/scripts/build.sh build
```

`BUILD_ONLINE=1` sets HTTP and HTTPS proxy variables to `http://192.168.30.118:7890`. The script never changes `gradle.properties` or the mod version. Set `EXPECTED_VERSION` when a build must verify a specific version.

```bash
EXPECTED_VERSION=10.0.5.222.1 .codex/skills/mekanism-build/scripts/build.sh build
```

The packaged artifact is written under `build/libs/`. A successful `build` task is the normal validation target. This repository currently has no test sources.
