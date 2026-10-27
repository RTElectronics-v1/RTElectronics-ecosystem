#Requires -Version 5.1
<#
.SYNOPSIS
  Offline probes for install.ps1. No network, no npm, no Pester.

.DESCRIPTION
  Every probe runs the real installer with -NoScaffold against a throw-away
  BRAND_HOME under $env:TEMP, so nothing outside the temp folder is touched.
  Exit 0 = all probes pass.

.EXAMPLE
  powershell -NoProfile -ExecutionPolicy Bypass -File brand-ui-system\assets\tests\install-ps1.Tests.ps1
#>
$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$ps1 = Join-Path $root 'assets\install.ps1'
$fail = 0

function Check($name, $condition) {
  if ($condition) { Write-Host "  PASS $name" } else { Write-Host "  FAIL $name" -ForegroundColor Red; $script:fail++ }
}

function New-Scratch([string]$prefix) { Join-Path $env:TEMP ($prefix + "-" + [guid]::NewGuid().ToString('N')) }

function Invoke-Install([string]$fakeHome, [string[]]$installArgs) {
  $env:BRAND_HOME = $fakeHome
  & powershell -NoProfile -ExecutionPolicy Bypass -File $ps1 @installArgs | Out-Null
  return $LASTEXITCODE
}

$homes = @()
$origin = Get-Location
try {
  # A dropped -NoScaffold must never scaffold into the repository.
  Set-Location $env:TEMP

  # The script has to parse: a broken terminator here makes every other probe moot.
  $errs = $null
  $null = [System.Management.Automation.Language.Parser]::ParseFile($ps1, [ref]$null, [ref]$errs)
  Check 'parse' (-not $errs)

  # Two consecutive installs: the second has to replace existing junctions instead
  # of throwing NullReferenceException out of Remove-Item.
  $fake = New-Scratch 'brand-home'; $homes += $fake
  Check 'first install exits 0' ((Invoke-Install $fake @('-Agents', 'all', '-NoScaffold')) -eq 0)
  Check 'second install exits 0' ((Invoke-Install $fake @('-Agents', 'all', '-NoScaffold')) -eq 0)
  Check 'canonical copy intact' (Test-Path (Join-Path $fake '.agents\skills\brand-ui-system\SKILL.md'))
  foreach ($agentDir in @('.pi\agent\skills', '.claude\skills', '.codex\skills', '.gemini\skills', '.copilot\skills')) {
    $link = Get-Item -LiteralPath (Join-Path $fake ($agentDir + '\brand-ui-system')) -Force -ErrorAction SilentlyContinue
    Check "relinked $agentDir" ($link -and $link.LinkType -eq 'Junction')
  }

  # -File hands "pi,claude" over as a single argument; the README documents that form.
  $fakeList = New-Scratch 'brand-home'; $homes += $fakeList
  Check '-Agents pi,claude exits 0' ((Invoke-Install $fakeList @('-Agents', 'pi,claude', '-NoScaffold')) -eq 0)
  Check '-Agents pi,claude linked' (Test-Path (Join-Path $fakeList '.pi\agent\skills\brand-ui-system\SKILL.md'))

  # -NoScaffold leaves the target uncreated, so the handoff must not Resolve-Path it.
  $fakeNo = New-Scratch 'brand-home'; $homes += $fakeNo
  $target = New-Scratch 'brand-tgt'
  Check '-NoScaffold with missing target exits 0' ((Invoke-Install $fakeNo @('-Target', $target, '-Agents', 'pi', '-NoScaffold')) -eq 0)
  Check '-NoScaffold leaves target uncreated' (-not (Test-Path $target))

  # A canonical path the user already linked (dotfiles, another checkout) must be
  # replaced, not wiped through the link.
  $fakeLink = New-Scratch 'brand-home'; $homes += $fakeLink
  $real = New-Scratch 'brand-real'; $homes += $real
  New-Item -ItemType Directory -Force -Path $real | Out-Null
  Set-Content -Path (Join-Path $real 'MY-NOTES.md') -Value 'keep'
  New-Item -ItemType Directory -Force -Path (Join-Path $fakeLink '.agents\skills') | Out-Null
  New-Item -ItemType Junction -Path (Join-Path $fakeLink '.agents\skills\brand-ui-system') -Target $real | Out-Null
  Check 'linked canonical install exits 0' ((Invoke-Install $fakeLink @('-NoScaffold')) -eq 0)
  Check 'linked canonical: user file survived' (Test-Path (Join-Path $real 'MY-NOTES.md'))
  $canonical = Get-Item -LiteralPath (Join-Path $fakeLink '.agents\skills\brand-ui-system') -Force
  Check 'linked canonical: replaced by a real copy' (-not $canonical.LinkType)
  Check 'linked canonical: skill installed' (Test-Path (Join-Path $fakeLink '.agents\skills\brand-ui-system\SKILL.md'))

  # Documentation must never advertise one machine's home directory: a literal
  # C:\Users\<name> is a placeholder, any other C:\Users\ path is a leak.
  $readme = Join-Path $root '..\README.md'
  Check 'README has no literal user home path' (-not (Select-String -Path $readme -Pattern 'C:\\Users\\(?!<)' -Quiet))
} finally {
  Set-Location $origin
  $ErrorActionPreference = 'SilentlyContinue'
  Remove-Item Env:\BRAND_HOME -ErrorAction SilentlyContinue
  # cmd rmdir removes junctions without walking into them, unlike Remove-Item -Recurse.
  foreach ($path in $homes) {
    if (Test-Path -LiteralPath $path) { & cmd /c rmdir /s /q "$path" 2>$null | Out-Null }
  }
}

if ($fail) { Write-Host "`n$fail probe(s) failed" -ForegroundColor Red; exit 1 }
Write-Host "`nall install.ps1 probes passed" -ForegroundColor Green
