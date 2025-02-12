@echo off
setlocal EnableDelayedExpansion

rem Main script
set /p "mod_id=Enter mod ID: "
set /p "github_repo_name=Enter GitHub repository name: "
set /p "mod_name=Enter mod name: "
set /p "description=Enter description: "
set /p "group=Enter Group: "
set /p "curseforge_id=Enter CurseForge ID: "
set /p "modrinth_id=Enter Modrinth ID: "

call :CreateModsTomlFile "%mod_id%" "%github_repo_name%" "%mod_name%" "%description%"
call :CreateIssueTemplates "%mod_name%"
call :CreateSettingsGradle "%mod_name%"
call :CreateMainClass "%mod_id%" "%mod_name%" "%group%"
call :CreateReadme "%mod_name%" "%description%" "%curseforge_id%" "%modrinth_id%" "%mod_id%"
call :EditBuildGradle %mod_id% %github_repo_name% %curseforge_id% %modrinth_id%

echo All files have been created successfully.
endlocal
pause

del "setup.*"
exit /b

rem Function to create neoforge.mods.toml file
:CreateModsTomlFile
set "mod_id=%~1"
set "github_repo_name=%~2"
set "mod_name=%~3"
set "description=%~4"

if not exist "src\main\resources\META-INF" (
    mkdir "src\main\resources\META-INF"
)

echo. > "src\main\resources\META-INF\accesstransformer.cfg"

(
echo modLoader="javafml"
echo loaderVersion="[4,)"
echo license="${mod.license}"
echo issueTrackerURL="${mod.issue_url}"
echo.
echo [[mods]]
echo modId="${mod.modid}"
echo version="${mod.version}"
echo displayName="%mod_name%"
echo displayURL="${mod.source_url}"
echo updateJSONURL="https://assets.melanx.de/updates/%mod_id%.json"
echo authors="MelanX"
echo description="""
echo %description%
echo """
echo.
echo [[dependencies.${mod.modid}]]
echo    modId = "neoforge"
echo    type = "required"
echo    versionRange = "[${mod.neoforge},)"
echo    ordering="NONE"
echo    side="BOTH"
echo.
echo [[dependencies.${mod.modid}]]
echo    modId="minecraft"
echo    type="required"
echo    versionRange="[${mod.minecraft},)"
echo    ordering="NONE"
echo    side="BOTH"
) > "src\main\resources\META-INF\neoforge.mods.toml"
goto :EOF

rem Function to create issue templates
:CreateIssueTemplates
set "mod_name=%~1"

if not exist ".github\ISSUE_TEMPLATE" (
    mkdir ".github\ISSUE_TEMPLATE"
)

(
echo name: Bug Report
echo description: Report an issue with supported versions of %mod_name%
echo labels: [ bug ]
echo body:
echo   - type: dropdown
echo     id: mc-version
echo     attributes:
echo       label: Minecraft version
echo       options:
echo         - 1.21.x
echo     validations:
echo       required: true
echo   - type: input
echo     id: mod-version
echo     attributes:
echo       label: %mod_name% version
echo       placeholder: eg. 21.1.0
echo     validations:
echo       required: true
echo   - type: input
echo     id: forge-version
echo     attributes:
echo       label: NeoForge version
echo       placeholder: eg. 21.1.0
echo     validations:
echo       required: true
echo   - type: input
echo     id: log-file
echo     attributes:
echo       label: The latest.log file
echo       description: ^|
echo         Please use a paste site such as [gist](https://gist.github.com/^) / [pastebin](https://pastebin.com/^) / etc.
echo         For more information, see https://git.io/mclogs
echo     validations:
echo       required: true
echo   - type: textarea
echo     id: description
echo     attributes:
echo       label: Issue description
echo       placeholder: A description of the issue.
echo     validations:
echo       required: true
echo   - type: textarea
echo     id: steps-to-reproduce
echo     attributes:
echo       label: Steps to reproduce
echo       placeholder: ^|
echo         1. First step
echo         2. Second step
echo         3. etc...
echo   - type: textarea
echo     id: additional-information
echo     attributes:
echo       label: Other information
echo       description: Any other relevant information that is related to this issue, such as modpacks, other mods and their versions.
) > ".github\ISSUE_TEMPLATE\bug_report.yml"

(
echo name: Feature request
echo description: Suggest an idea, or enhancement
echo labels: [ enhancement ]
echo body:
echo   - type: textarea
echo     id: description
echo     attributes:
echo       label: Describe your idea
echo       placeholder: A clear and reasoned description of your idea.
echo     validations:
echo       required: true
) > ".github\ISSUE_TEMPLATE\feature_request.yml"
goto :EOF

rem Function to create settings.gradle file
:CreateSettingsGradle
set "mod_name=%~1"

rem Remove spaces in mod_name
set "mod_name_no_spaces=%mod_name: =%"

(
echo pluginManagement {
echo     repositories {
echo         gradlePluginPortal(^)
echo         maven { url = 'https://maven.neoforged.net/releases' }
echo         maven { url = 'https://maven.moddingx.org/release' }
echo     }
echo }
echo.
echo rootProject.name = '%mod_name_no_spaces%'
) > ".\settings.gradle"
goto :EOF

rem Function to create main class file
:CreateMainClass
set "mod_id=%~1"
set "mod_name=%~2"
set "group=%~3"

rem Replace dots with slashes in group for package path
set "package_path=%group:.=\%"
rem Remove spaces in mod_name
set "mod_name_no_spaces=%mod_name: =%"

if not exist "src\main\java\%package_path%\%mod_id%" (
    mkdir "src\main\java\%package_path%\%mod_id%"
)

(
echo package %group%.%mod_id%;
echo.
echo import net.neoforged.api.distmarker.Dist;
echo import net.neoforged.bus.api.IEventBus;
echo import net.neoforged.fml.common.Mod;
echo import org.slf4j.Logger;
echo import org.slf4j.LoggerFactory;
echo.
echo @Mod(%mod_name_no_spaces%.MODID^)
echo public final class %mod_name_no_spaces% {
echo.
echo     public static final String MODID = "%mod_id%";
echo     public static final Logger LOGGER = LoggerFactory.getLogger(%mod_name_no_spaces%.class^);
echo.
echo     public %mod_name_no_spaces%(IEventBus modBus, Dist dist^) {
echo         // todo
echo     }
echo }
) > "src\main\java\%package_path%\%mod_id%\%mod_name_no_spaces%.java"
goto :EOF

rem Function to create README.md file
:CreateReadme
set "mod_name=%~1"
set "description=%~2"
set "curseforge_id=%~3"
set "modrinth_id=%~4"
set "mod_id=%~5"

(
echo # %mod_name%
echo %description%
echo.
echo [^^^![Modrinth](https://badges.moddingx.org/modrinth/versions/%modrinth_id%^)](https://modrinth.com/mod/%mod_id%^)
echo [^^^![Modrinth](https://badges.moddingx.org/modrinth/downloads/%modrinth_id%^)](https://modrinth.com/mod/%mod_id%^)
echo.
echo [^^^![CurseForge](https://badges.moddingx.org/curseforge/versions/%curseforge_id%^)](https://www.curseforge.com/minecraft/mc-mods/%mod_id%^)
echo [^^^![CurseForge](https://badges.moddingx.org/curseforge/downloads/%curseforge_id%^)](https://www.curseforge.com/minecraft/mc-mods/%mod_id%^)
) > README.md

goto :EOF

rem Function to edit build.gradle file
:EditBuildGradle
set "BUILD_FILE=build.gradle"
set "TEMP_FILE=%BUILD_FILE%.tmp"
(for /f "delims=" %%A in (%BUILD_FILE%) do (
    set "line=%%A"
    set "line=!line:%%mod_id%%=%mod_id%!"
    set "line=!line:%%github_repo_name%%=%github_repo_name%!"
    set "line=!line:%%curseforge_id%%=%curseforge_id%!"
    set "line=!line:%%modrinth_id%%=%modrinth_id%!"
    echo !line!
)) > %TEMP_FILE%
move /y %TEMP_FILE% %BUILD_FILE%
goto :EOF
