#!/bin/bash

create_mods_toml_file() {
  local mod_id="$1"
  local github_repo_name="$2"
  local mod_name="$3"
  local description="$4"

  mkdir -p ./src/main/resources/META-INF
  touch ./src/main/resources/META-INF/accesstransformer.cfg

  cat <<EOF > ./src/main/resources/META-INF/neoforge.mods.toml
modLoader="javafml"
loaderVersion="\${loader_version_range}"
license="\${license}"
issueTrackerURL="https://github.com/ChaoticTrials/${github_repo_name}/issues"

[[mods]]
modId="\${modid}"
version="\${mod_version}"
displayName="${mod_name}"
updateJSONURL="https://assets.melanx.de/updates/${mod_id}.json"
displayURL="https://modrinth.com/user/MelanX"
authors="MelanX"
description="""
${description}
"""

[[dependencies.\${modid}]]
    modId = "neoforge"
    type = "required"
    versionRange = "[\${neo_version},)"
    ordering="NONE"
    side="BOTH"

[[dependencies.\${modid}]]
    modId="minecraft"
    type="required"
    versionRange="[\${minecraft_version},)"
    ordering="NONE"
    side="BOTH"
EOF
}

create_issue_templates() {
  local mod_name="$1"

  mkdir -p ./.github/ISSUE_TEMPLATE

  cat <<EOF > ./.github/ISSUE_TEMPLATE/bug_report.yml
name: Bug Report
description: Report an issue with supported versions of ${mod_name}
labels: [ bug ]
body:
  - type: dropdown
    id: mc-version
    attributes:
      label: Minecraft version
      options:
        - 1.21.x
    validations:
      required: true
  - type: input
    id: mod-version
    attributes:
      label: ${mod_name} version
      placeholder: eg. 1.21-1.0.0
    validations:
      required: true
  - type: input
    id: forge-version
    attributes:
      label: NeoForge version
      placeholder: eg. 21.0.0-beta
    validations:
      required: true
  - type: input
    id: log-file
    attributes:
      label: The latest.log file
      description: |
        Please use a paste site such as [gist](https://gist.github.com/) / [pastebin](https://pastebin.com/) / etc.
        For more information, see https://git.io/mclogs
    validations:
      required: true
  - type: textarea
    id: description
    attributes:
      label: Issue description
      placeholder: A description of the issue.
    validations:
      required: true
  - type: textarea
    id: steps-to-reproduce
    attributes:
      label: Steps to reproduce
      placeholder: |
        1. First step
        2. Second step
        3. etc...
  - type: textarea
    id: additional-information
    attributes:
      label: Other information
      description: Any other relevant information that is related to this issue, such as modpacks, other mods and their versions.
EOF

  cat <<EOF > ./.github/ISSUE_TEMPLATE/feature_request.yml
name: Feature request
description: Suggest an idea, or enhancement
labels: [ enhancement ]
body:
  - type: textarea
    id: description
    attributes:
      label: Describe your idea
      placeholder: A clear and reasoned description of your idea.
    validations:
      required: true
EOF
}

create_gradle_properties() {
  local mod_id="$1"
  local github_repo_name="$2"
  local mod_name="$3"
  local group="$4"
  local curseforge_id="$5"
  local modrinth_id="$6"

  cat <<EOF > ./gradle.properties
org.gradle.jvmargs=-Xmx6G
org.gradle.daemon=true
org.gradle.parallel=true
org.gradle.caching=true
org.gradle.configuration-cache=true

## Mappings
parchment_minecraft_version=1.21
parchment_mappings_version=2024.07.07

## Loader Properties
minecraft_version=1.21
neo_version=21.0.86-beta
loader_version_range=[4,)

## Mod Properties
modid=${mod_id}
mod_name=${mod_name}
group=${group}
base_version=1.0

## Upload Properties
upload_versions=1.21
upload_release=beta
modrinth_project=${modrinth_id}
curse_project=${curseforge_id}

## Misc
remote_maven=https://maven.melanx.de/release
license=The Apache License, Version 2.0
license_url=https://www.apache.org/licenses/LICENSE-2.0.txt
changelog_repository=https://github.com/ChaoticTrials/${github_repo_name}/commit/%H
EOF
}

create_settings_gradle() {
  local mod_name="$1"
  local mod_name_no_spaces=$(echo "${mod_name}" | tr -d ' ')

  cat <<EOF > ./settings.gradle
pluginManagement {
    repositories {
        mavenLocal()
        gradlePluginPortal()
        maven { url = 'https://maven.neoforged.net/releases' }
    }
}

plugins {
    id 'org.gradle.toolchains.foojay-resolver-convention' version '0.8.0'
}

rootProject.name = '${mod_name_no_spaces}'
EOF
}

create_main_class () {
  local mod_id="$1"
  local mod_name="$2"
  local group="$3"

  local package_path=$(echo "${group}" | tr '.' '/')
  local mod_name_no_spaces=$(echo "${mod_name}" | tr -d ' ')

  mkdir -p ./src/main/java/${package_path}/${mod_id}

  cat <<EOF > ./src/main/java/${package_path}/${mod_id}/${mod_name_no_spaces}.java
package ${group}.${mod_id};

import net.neoforged.api.distmarker.Dist;
import net.neoforged.bus.api.IEventBus;
import net.neoforged.fml.common.Mod;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

@Mod(${mod_name_no_spaces}.MODID)
public final class ${mod_name_no_spaces} {

    public static final String MODID = "${mod_id}";
    public static final Logger LOGGER = LoggerFactory.getLogger(${mod_name_no_spaces}.class);

    public ${mod_name_no_spaces}(IEventBus modBus, Dist dist) {
        // todo
    }
}
EOF
}

create_readme() {
  local mod_name="$1"
  local description="$2"
  local curseforge_id="$3"
  local modrinth_id="$4"
  local mod_id="$5"

  cat <<EOF > ./README.md
# §{mod_name}
${description}

[![Modrinth](https://badges.moddingx.org/modrinth/versions/${modrinth_id})](https://modrinth.com/mod/${mod_id})
[![Modrinth](https://badges.moddingx.org/modrinth/downloads/${modrinth_id})](https://modrinth.com/mod/${mod_id})

[![Curseforge](https://badges.moddingx.org/curseforge/versions/${curseforge_id})](https://www.curseforge.com/minecraft/mc-mods/${mod_id})
[![CurseForge](https://badges.moddingx.org/curseforge/downloads/${curseforge_id})](https://www.curseforge.com/minecraft/mc-mods/${mod_id})
EOF
}

# Main script
read -p "Enter mod ID: " mod_id
read -p "Enter GitHub repository name: " github_repo_name
read -p "Enter mod name: " mod_name
read -p "Enter description: " description
read -p "Enter Group: " group
read -p "Enter CurseForge ID: " curseforge_id
read -p "Enter Modrinth ID: " modrinth_id

# Call the function to create the file
create_mods_toml_file "$mod_id" "$github_repo_name" "$mod_name" "$description"
create_issue_templates "$mod_name"
create_gradle_properties "$mod_id" "$github_repo_name" "$mod_name" "$group" "$curseforge_id" "$modrinth_id"
create_settings_gradle "$mod_name"
create_main_class "$mod_id" "$mod_name" "$group"
create_readme "$mod_name" "$description" "$curseforge_id" "$modrinth_id" "$mod_id"

echo "All files have been created successfully."
echo "Delete setup scripts"
rm "setup.*"
