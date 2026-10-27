#Requires -Version 5.1
<#
.SYNOPSIS
  Installs brand-ui-system for one or more agents, scaffolds a new project, and
  proves it builds. Native Windows entry point: no bash, no WSL.

.DESCRIPTION
  Canonical install: <home>\.agents\skills\brand-ui-system
  Every other agent gets a DIRECTORY JUNCTION to it, so there is one copy to
  update and all agents read the same thing.

  Agent skill directories:
    agents   .agents\skills        (shared, read by pi and the registry)
    pi       .pi\agent\skills
    claude   .claude\skills
    codex    .codex\skills
    gemini   .gemini\skills
    copilot  .copilot\skills

.EXAMPLE
  .\install.ps1 -Target .\mi-proyecto -Agents all

.EXAMPLE
  .\install.ps1 -Target .\mi-proyecto -Agents pi,claude -From https://github.com/vos/brand-ui-system.git

.EXAMPLE
  .\install.ps1 -Agents all -NoScaffold

.EXAMPLE
  .\install.ps1 -Target .\mi-proyecto -Agents pi -Force
#>
[CmdletBinding()]
param(
  [Parameter(Position = 0)][string]$Target = '.'',
  [ValidateSet('user', 'project', 'both')][string]$Scope = 'user',
  [string[]]$Agents = @(),
  [string]$From = '',
  [switch]$NoScaffold,
  [switch]$SkipVerify,
  [switch]$Force
)

$ErrorActionPreference = 'Stop'

function Step($text) { Write-Host "`n> $text" -ForegroundColor Cyan }
function Fail($text) { Write-Host "  $text" -ForegroundColor Red; exit 1 }
function Skip($text) { Write-Host "  $text" -ForegroundColor Yellow }

$HOME_DIR = if ($env:BRAND_HOME) { $env:BRAND_HOME } else { $env:USERPROFILE }
$SKILL_NAME = 'brand-ui-system'
$AgentDirs = [ordered]@{
  agents  = '.agents\skills'
  pi      = '.pi\agent\skills'
  claude  = '.claude\skills'
  codex   = '.codex\skills'
  gemini  = '.gemini\skills'
  copilot = '.copilot\skills'
}

$SkillRoot = Split-Path -Parent $PSScriptRoot
if (-not (Test-Path (Join-Path $SkillRoot 'SKILL.md'))) {
  Fail "$SkillRoot is not a brand-ui-system skill (no SKILL.md)"
}

# ── 1. resolve the source ───────────────────────────────────────────────────
Step 'Resolving the skill'
if ($From) {
  if ($From -match '^(https?://|git@|git://)') {
    $tmp = Join-Path ([IO.Path]::GetTempPath()) ("brand-ui-" + [guid]::NewGuid().ToString('N'))
    & git clone --depth 1 --quiet $From $tmp
    if ($LASTEXITCODE -ne 0) { Fail "git clone failed: $From" }
    # A repo may host several skills: the skill root is the repo root or one level down.
    $SkillSrc = if (Test-Path (Join-Path $tmp 'SKILL.md')) { $tmp } else { Join-Path $tmp 'brand-ui-system' }
    Write-Host "  cloned $From"
  } elseif (Test-Path $From) {
    $SkillSrc = if (Test-Path (Join-Path $From 'SKILL.md')) { (Resolve-Path $From).Path } else { (Resolve-Path (Join-Path $From 'brand-ui-system')).Path }
    Write-Host "  using local path $SkillSrc"
  } else {
    Fail "cannot resolve -From: $From"
  }
} else {
  $SkillSrc = $SkillRoot
  Write-Host "  using bundled source $SkillSrc"
}

# ── 2. validate the target before writing anything into it ──────────────────
if ((-not $NoScaffold) -and (Test-Path (Join-Path $Target 'package.json')) -and -not $Force) {
  Fail "$Target already has a package.json. Re-run with -Force to overwrite, or pick another folder."
}

function Install-Copy([string]$dest) {
  $destFull = if (Test-Path $dest) { (Resolve-Path $dest).Path } else { [IO.Path]::GetFullPath($dest) }
  if ($destFull -eq (Resolve-Path $SkillSrc).Path) {
    Write-Host "  already at $dest (source), skipped"
    return
  }
  New-Item -ItemType Directory -Force -Path $dest | Out-Null
  Get-ChildItem -Path $dest -Force | Remove-Item -Recurse -Force
  Copy-Item -Path (Join-Path $SkillSrc '*') -Destination $dest -Recurse -Force
  Write-Host "  installed -> $dest"
}

$canonical = Join-Path $HOME_DIR (Join-Path $AgentDirs['agents'] $SKILL_NAME)
$projectDest = Join-Path $Target ".agents\skills\$SKILL_NAME"

# -Agents always needs a user-scope canonical copy: junctions must not point
# inside a project, or deleting the project would delete the skill.
$wantAgents = @()
if ($Agents.Count -gt 0) {
  $wantAgents = if ($Agents -contains 'all') { @($AgentDirs.Keys) } else { $Agents }
  foreach ($a in $wantAgents) {
    if (-not $AgentDirs.Contains($a)) { Fail "unknown agent: $a (valid: $($AgentDirs.Keys -join ', '))" }
  }
}

switch ($Scope) {
  'user' { Step 'Installing the skill (user scope, for discovery)'; Install-Copy $canonical }
  'project' {
    Step 'Installing the skill (project scope, for reproducibility)'
    Install-Copy $projectDest
    if ($wantAgents.Count -gt 0) {
      Step 'Installing the canonical copy (required by -Agents)'
      Install-Copy $canonical
    }
  }
  'both' {
    Step 'Installing the skill (user scope, for discovery)'; Install-Copy $canonical
    Step 'Installing the skill (project scope, for reproducibility)'; Install-Copy $projectDest
  }
}

# ── 3. link the canonical copy into every requested agent ───────────────────
if ($wantAgents.Count -gt 0) {
  Step "Linking into agents: $($wantAgents -join ', ')"
  foreach ($name in $wantAgents) {
    $skillsDir = Join-Path $HOME_DIR $AgentDirs[$name]
    $link = Join-Path $skillsDir $SKILL_NAME
    New-Item -ItemType Directory -Force -Path $skillsDir | Out-Null

    if ((Resolve-Path -Path (Split-Path $link -Parent)).Path -eq (Resolve-Path -Path (Split-Path $canonical -Parent)).Path) {
      Write-Host "  $name -> $link (canonical, no link needed)"
      continue
    }

    if (Test-Path $link) {
      $item = Get-Item $link -Force
      if ($item.LinkType) {
        Remove-Item $link -Force
      } elseif ($Force) {
        Remove-Item $link -Recurse -Force
      } else {
        Skip "$name -> $link exists and is not a link; skipped (use -Force to replace)"
        continue
      }
    }

    New-Item -ItemType Junction -Path $link -Target $canonical | Out-Null
    Write-Host "  $name -> $link"
  }
}

# ── 4. scaffold ─────────────────────────────────────────────────────────────
$installed = if (Test-Path $projectDest) { $projectDest } else { $canonical }

if (-not $NoScaffold) {
Step "Scaffolding $Target"
$boot = Join-Path $SkillSrc 'assets\bootstrap'
$map = [ordered]@{
  'global.css'       = 'src\styles\global.css'
  'Base.astro'       = 'src\layouts\Base.astro'
  'reveal.ts'        = 'src\scripts\reveal.ts'
  'index.astro'      = 'src\pages\index.astro'
  'package.json'     = 'package.json'
  'astro.config.mjs' = 'astro.config.mjs'
  'tsconfig.json'    = 'tsconfig.json'
}
foreach ($src in $map.Keys) {
  $dst = Join-Path $Target $map[$src]
  New-Item -ItemType Directory -Force -Path (Split-Path -Parent $dst) | Out-Null
  Copy-Item -Path (Join-Path $boot $src) -Destination $dst -Force
}
Write-Host "  scaffolded $($map.Count) files into $Target"
}

# ── 5. dependencies and gate ────────────────────────────────────────────────
if ((-not $NoScaffold) -and (-not $SkipVerify)) {
  # Resolve npm.cmd explicitly: on nvm-for-windows, `& npm` hits npm.ps1 and mangles
  # the first argument ("install" arrives as "pm"). npm.cmd bypasses the shim.
  $npmCmd = Get-Command npm.cmd -ErrorAction SilentlyContinue
  $npm = if ($npmCmd) { $npmCmd.Source } else { (Get-Command npm -ErrorAction SilentlyContinue).Source }
  if (-not $npm) {
    Fail 'npm not found. Install Node 18.20 / 20.3 / 22+ and run: npm install; npm run verify'
  }

  Step 'Installing dependencies'
  Push-Location $Target
  try {
    & $npm install --no-audit --no-fund
    if ($LASTEXITCODE -ne 0) {
      Write-Host ''
      Write-Host '  npm install failed.' -ForegroundColor Red
      Write-Host '  On Windows the usual cause is a native module locked by another process:'
      Write-Host '  close any dev server, retry, or run npm install by hand in the target folder.'
      exit 1
    }

    Step 'Verifying the scaffold (astro check + build)'
    & $npm run verify
    if ($LASTEXITCODE -ne 0) { Fail 'npm run verify failed' }

    Step 'Brand lint'
    & node (Join-Path $installed 'assets\brand-lint.mjs') 'src' --quiet
  } finally {
    Pop-Location
  }
}

# ── 6. handoff ──────────────────────────────────────────────────────────────
$targetFull = (Resolve-Path $Target).Path

Write-Host "`nOK ready" -ForegroundColor Green
Write-Host @"

Next step, in a new agent session with cwd = $targetFull

  Read $installed\SKILL.md and follow its contract.
  Build <your feature>.

Canonical skill: $canonical\SKILL.md
"@
