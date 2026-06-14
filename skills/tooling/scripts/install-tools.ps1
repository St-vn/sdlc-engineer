param(
    [string[]]$Categories = @("all"),
    [string]$Profile,
    [switch]$Quiet
)

$ErrorActionPreference = "Continue"

# Profile-based mode: read .sdlc/project.yml and derive Categories from stack
if ($Profile -and (Test-Path $Profile)) {
    $yaml = Get-Content $Profile -Raw
    $Categories = @()
    # If framework is web-based, add frontend
    if ($yaml -match "framework:\s+(next\.js|react|vue|svelte|nuxt|angular)") { $Categories += "frontend" }
    # If database is postgres, add database tools
    if ($yaml -match "database:\s+postgres") { $Categories += "database" }
    # If deployment-target is cloud, add infra
    if ($yaml -match "deployment-target:\s+cloud") { $Categories += "infra" }
    # If security-tier is hardened, add extra security tools
    if ($yaml -match "security-tier:\s+hardened") { $Categories += "security-hardened" }
    # Security is always needed
    $Categories += "security"
    # MCP servers are always useful
    $Categories += "mcp"
    if (-not $Quiet) { Write-Host "Profile detected: installing for $($Categories -join ', ')" }
}
$installed = @()
$failed = @()

function Install-NpmGlobal($name, $cmd) {
    $check = cmd /c "where $cmd 2>nul"
    if ($LASTEXITCODE -eq 0) {
        if (-not $Quiet) { Write-Host "  [SKIP] $name already installed" }
        $installed += $name
        return
    }
    if (-not $Quiet) { Write-Host "  [INSTALL] npm i -g $name" }
    $out = npm install -g $name 2>&1
    if ($LASTEXITCODE -eq 0) {
        $installed += $name
    } else {
        if (-not $Quiet) { Write-Host "  [FAIL] $name — $out" }
        $failed += $name
    }
}

function Install-Winget($name, $wingetId) {
    $check = cmd /c "where $name 2>nul"
    if ($LASTEXITCODE -eq 0) {
        if (-not $Quiet) { Write-Host "  [SKIP] $name already installed" }
        $installed += $name
        return
    }
    if (-not $Quiet) { Write-Host "  [INSTALL] winget install $wingetId" }
    $out = winget install --id $wingetId --silent --accept-package-agreements 2>&1
    if ($LASTEXITCODE -eq 0) {
        $installed += $name
    } else {
        if (-not $Quiet) { Write-Host "  [FAIL] $name — $out" }
        $failed += $name
    }
}

Write-Host "=== sdlc-engineer Tool Installer ==="
Write-Host ""

# --- Frontend Testing Tools ---
if ($Categories -contains "all" -or $Categories -contains "frontend") {
    Write-Host "--- Frontend Testing ---"
    Install-NpmGlobal "@playwright/test" "playwright"
    if ($installed -contains "@playwright/test") {
        if (-not $Quiet) { Write-Host "  [INSTALL] npx playwright install chromium" }
        npx playwright install chromium 2>&1 | Out-Null
    }
    Install-NpmGlobal "@axe-core/cli" "axe"
    Install-NpmGlobal "@lhci/cli" "lhci"
}

# --- Security Tools ---
if ($Categories -contains "all" -or $Categories -contains "security") {
    Write-Host "--- Security ---"
    Install-NpmGlobal "semgrep" "semgrep"
    Install-Winget "gitleaks" "gitleaks.gitleaks"
    Install-NpmGlobal "trivy" "trivy"
}

# --- Infrastructure Tools ---
if ($Categories -contains "all" -or $Categories -contains "infra") {
    Write-Host "--- Infrastructure ---"
    Install-Winget "docker" "Docker.DockerDesktop"
    Install-Winget "terraform" "Hashicorp.Terraform"
    Install-Winget "pulumi" "Pulumi.Pulumi"
}

# --- Database Tools ---
if ($Categories -contains "all" -or $Categories -contains "database") {
    Write-Host "--- Database ---"
    Install-NpmGlobal "supabase" "supabase"
    Install-NpmGlobal "pglint" "pglint"
}

# --- Hardened Security ---
if ($Categories -contains "all" -or $Categories -contains "security-hardened") {
    Write-Host "--- Hardened Security ---"
    Install-Winget "zap" "ZAP.ZAP"
}

# --- MCP Servers ---
if ($Categories -contains "all" -or $Categories -contains "mcp") {
    Write-Host "--- MCP Servers (npx cache) ---"
    # Pre-cache MCP server packages so first run doesn't download
    npm install -g @anthropic/chrome-devtools-mcp @playwright/mcp 2>&1 | Out-Null
    $installed += "chrome-devtools-mcp"
    $installed += "playwright-mcp"
}

Write-Host ""
Write-Host "=== Results ==="
Write-Host "Installed: $($installed.Count)"
if ($failed.Count -gt 0) {
    Write-Host "Failed: $($failed -join ', ')"
    Write-Host "Run manually for these or check your environment."
    exit 1
} else {
    Write-Host "All tools installed successfully."
    exit 0
}
