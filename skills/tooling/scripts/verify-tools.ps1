param(
    [string[]]$Categories = @("all"),
    [switch]$Json
)

$ErrorActionPreference = "Continue"
$results = @{}

function Check-Tool($name, $cmd, $versionArg) {
    $result = @{ name = $name; installed = $false; version = $null; error = $null }
    try {
        $out = cmd /c "where $name 2>nul"
        if ($LASTEXITCODE -ne 0) {
            $result.error = "not found in PATH"
        } else {
            $result.installed = $true
            $verOut = & cmd /c "$name $versionArg 2>nul"
            if ($?) { $result.version = ($verOut | Select-Object -First 1).Trim() }
        }
    } catch {
        $result.error = $_.Exception.Message
    }
    return $result
}

function Check-NpxTool($name, $package, $versionArg) {
    $result = @{ name = $name; installed = $false; version = $null; error = $null }
    try {
        $out = npx $package $versionArg 2>&1 | Select-Object -First 1
        if ($LASTEXITCODE -eq 0) {
            $result.installed = $true
            $result.version = $out.Trim()
        } else {
            $result.error = $out.Trim()
        }
    } catch {
        $result.error = $_.Exception.Message
    }
    return $result
}

Write-Host "=== sdlc-engineer Tool Verification ==="

# CLI tools (via PATH)
$clis = @(
    @{name="node"; check={Check-Tool "node" "node" "--version"}},
    @{name="npm"; check={Check-Tool "npm" "npm" "--version"}},
    @{name="git"; check={Check-Tool "git" "git" "--version"}},
    @{name="docker"; check={Check-Tool "docker" "docker" "--version"}},
    @{name="terraform"; check={Check-Tool "terraform" "terraform" "version"}},
    @{name="pulumi"; check={Check-Tool "pulumi" "pulumi" "version"}},
    @{name="semgrep"; check={Check-Tool "semgrep" "semgrep" "--version"}},
    @{name="gitleaks"; check={Check-Tool "gitleaks" "gitleaks" "--version"}},
    @{name="trivy"; check={Check-Tool "trivy" "trivy" "--version"}}
)

# npx-hosted tools
$npxTools = @(
    @{name="playwright"; package="@playwright/test"; arg="--version"},
    @{name="axe-core"; package="@axe-core/cli"; arg="--version"},
    @{name="lhci"; package="@lhci/cli"; arg="--version"},
    @{name="chrome-devtools-mcp"; package="@anthropic/chrome-devtools-mcp"; arg="--help"}
)

Write-Host ""
Write-Host "--- CLI Tools ---"
foreach ($t in $clis) {
    $r = & $t.check
    $results[$r.name] = $r
    $icon = if ($r.installed) { "[OK]" } else { "[MISSING]" }
    $ver = if ($r.version) { " $($r.version)" } else { "" }
    $err = if ($r.error) { " — $($r.error)" } else { "" }
    Write-Host "  $icon $($r.name)$ver$err"
}

Write-Host ""
Write-Host "--- npx Tools ---"
foreach ($t in $npxTools) {
    $r = Check-NpxTool $t.name $t.package $t.arg
    $results[$r.name] = $r
    $icon = if ($r.installed) { "[OK]" } else { "[MISSING]" }
    $ver = if ($r.version) { " $($r.version)" } else { "" }
    $err = if ($r.error) { " — $($r.error)" } else { "" }
    Write-Host "  $icon $($r.name)$ver$err"
}

# Summary
Write-Host ""
$total = $clis.Count + $npxTools.Count
$ok = ($results.Values | Where-Object { $_.installed }).Count
Write-Host "=== $ok/$total tools available ==="

# Available categories
$categories = @{}
if ($results['playwright'].installed -and $results['axe-core'].installed -and $results['lhci'].installed) {
    $categories['frontend'] = $true
}
if ($results['semgrep'].installed -and $results['gitleaks'].installed -and $results['trivy'].installed) {
    $categories['security'] = $true
}
if ($results['docker'].installed -and ($results['terraform'].installed -or $results['pulumi'].installed)) {
    $categories['infra'] = $true
}

if ($categories.Count -gt 0) {
    Write-Host "Ready categories: $($categories.Keys -join ', ')"
}
if ($ok -lt $total) {
    Write-Host "Run install-tools.ps1 to install missing tools."
}

if ($Json) { return ($results | ConvertTo-Json) }
exit ($ok -eq $total ? 0 : 1)
