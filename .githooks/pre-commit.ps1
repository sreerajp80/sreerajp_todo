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
# --no-dev excludes build_runner, flutter_test, and all their transitive deps
# (http, web_socket_channel, etc.) which are dev-only and never ship in release.
$depsOutput = flutter pub deps --no-dev 2>$null
$blocked = $depsOutput | Select-String -Pattern "\b(http|dio|chopper|retrofit|socket|firebase|supabase|sentry|crashlytics|analytics|amplitude|mixpanel|datadog|connectivity_plus|internet_connection_checker)\b"
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
