param(
    [Parameter(Mandatory)] [string]$Url,
    [Parameter()] [int]$Threshold = 0
)

$ErrorActionPreference = "Stop"

if (-not (Get-Command "npx" -ErrorAction SilentlyContinue)) {
    Write-Error "npx is required but not found. Install Node.js."
    exit 1
}

Write-Host "Running axe-core a11y audit against $Url"
Write-Host "Threshold: $Threshold violations (0 = zero tolerance)"

$result = npx @axe-core/cli $Url --exit --threshold $Threshold 2>&1
$exitCode = $LASTEXITCODE

if ($exitCode -eq 0) {
    Write-Host "PASS: No accessibility violations found"
} else {
    Write-Host "FAIL: $exitCode accessibility violation(s) found"
    Write-Host $result
    exit 1
}
