# Pre-commit hook for SreerajP ToDo
# Runs: flutter analyze, offline dep audit, manifest check, tests
$ErrorActionPreference = "Stop"

Write-Host "=== Running flutter analyze ==="
flutter analyze --no-fatal-infos
if ($LASTEXITCODE -ne 0) {
    Write-Host "flutter analyze failed. Commit aborted."
    exit 1
}

Write-Host "=== Running offline dependency audit ==="
# 1. Ensure no direct networking dependencies in pubspec.yaml
$pubspecPath = Join-Path $PSScriptRoot "..\pubspec.yaml"
if (Test-Path $pubspecPath) {
    $pubspecContent = Get-Content $pubspecPath -Raw
    $directDeps = ($pubspecContent -split "dev_dependencies:")[0]
    $directBlocked = $directDeps | Select-String -Pattern "(?m)^\s+(http|dio|chopper|retrofit|web_socket_channel|socket_io_client|firebase\w*|supabase\w*|sentry\w*|crashlytics|analytics\w*|amplitude\w*|mixpanel\w*|datadog\w*|connectivity_plus|internet_connection_checker)\s*:"
    if ($directBlocked) {
        Write-Host "Offline dependency audit FAILED. Direct prohibited dependency in pubspec.yaml:"
        $directBlocked | ForEach-Object { Write-Host $_.Line.Trim() }
        Write-Host "Commit aborted."
        exit 1
    }
}

# 2. Check runtime dependencies (--no-dev excludes build_runner, flutter_test, etc.)
# image_cropper_platform_interface declares http: ^1.0.0 for web support, but the
# plugin is strictly local (uCrop on Android) and makes no network calls.
# Filter out this approved transitive http dependency.
$depsOutput = flutter pub deps --no-dev 2>$null
$filteredDeps = $depsOutput | Where-Object { $_ -notmatch '\bhttp\s+\d' }
$blocked = $filteredDeps | Select-String -Pattern "\b(http|dio|chopper|retrofit|socket|firebase|supabase|sentry|crashlytics|analytics|amplitude|mixpanel|datadog|connectivity_plus|internet_connection_checker)\b"
if ($blocked) {
    Write-Host "Offline dependency audit FAILED. Networking packages found in runtime deps:"
    $blocked | ForEach-Object { Write-Host $_.Line.Trim() }
    Write-Host "Commit aborted."
    exit 1
}
Write-Host "Offline dep audit passed."

Write-Host "=== Checking AndroidManifest.xml for network permissions ==="
$manifestPath = Join-Path $PSScriptRoot "..\android\app\src\main\AndroidManifest.xml"
if (Test-Path $manifestPath) {
    $manifestMatch = Select-String -Path $manifestPath -Pattern "INTERNET|NETWORK_STATE" -Quiet
    if ($manifestMatch) {
        Write-Host "AndroidManifest.xml contains network permissions. Commit aborted."
        exit 1
    }
}
Write-Host "Manifest check passed."

Write-Host "=== Running tests ==="
flutter test
if ($LASTEXITCODE -ne 0) {
    Write-Host "Tests failed. Commit aborted."
    exit 1
}

Write-Host "=== All pre-commit checks passed ==="
exit 0
