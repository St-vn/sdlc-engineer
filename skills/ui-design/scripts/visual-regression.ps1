param(
    [Parameter(Mandatory)] [string]$Url,
    [Parameter()] [string]$OutputDir = "./__screenshots__",
    [Parameter()] [float]$Threshold = 0.001
)

$ErrorActionPreference = "Stop"

if (-not (Get-Command "npx" -ErrorAction SilentlyContinue)) {
    Write-Error "npx is required but not found. Install Node.js."
    exit 1
}

# Run Playwright visual regression tests
Write-Host "Running visual regression tests against $Url"
Write-Host "Threshold: $($Threshold * 100)% max diff per component"

npx playwright test --grep "@visual" --reporter=line 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host "FAIL: Visual regression detected differences."
    Write-Host "Review screenshots in $OutputDir"
    Write-Host "To update: npx playwright test --grep '@visual' --update-snapshots"
    exit 1
}

Write-Host "PASS: No visual regression detected"
