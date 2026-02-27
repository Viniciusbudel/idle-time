param(
  [string]$RepoRoot = "C:\Dev\idle-time",
  [string]$PlanPath = "docs\prestige\ralph-loop-prestige-plan.md",
  [string]$FeaturePrefix = "prestige"
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Info([string]$msg) { Write-Host $msg -ForegroundColor Cyan }
function Fail([string]$msg) { Write-Host $msg -ForegroundColor Red; exit 1 }

if (-not (Test-Path $RepoRoot)) { Fail "RepoRoot not found: $RepoRoot" }
Set-Location $RepoRoot

$planFull = Join-Path $RepoRoot $PlanPath
if (-not (Test-Path $planFull)) { Fail "Plan file not found: $planFull" }

$content = Get-Content $planFull -Raw
$pattern = "(?ms)^##\s*(STORY-\d+)\s*:\s*(.+?)\s*$\r?\n(.*?)(?=^##\s*STORY-\d+\s*:|\z)"
$matches = [regex]::Matches($content, $pattern)
if ($matches.Count -eq 0) { Fail "No STORY blocks found. Expected: ## STORY-1: Title" }

$next = $null
foreach ($m in $matches) {
  if ($m.Value -match "(?mi)^status:\s*todo\s*$") { $next = $m; break }
}
if ($null -eq $next) { Info "No TODO stories found. All done."; exit 0 }

$storyId = $next.Groups[1].Value
$storyTitle = $next.Groups[2].Value.Trim()
$commitMsg = "feat(" + $FeaturePrefix + "): " + $storyId

$scopeFiles = @(
  "lib/domain/entities/prestige_upgrade.dart",
  "lib/domain/entities/game_state.dart",
  "lib/presentation/state/game_state_provider.dart",
  "lib/presentation/ui/pages/prestige_tab.dart",
  "test/domain/prestige_usecase_test.dart",
  $PlanPath
)
$scopeFence = ($scopeFiles | ForEach-Object { "- " + $_ }) -join "`n"

$promptLines = @()
$promptLines += "Execute ONLY the next TODO story in $PlanPath."
$promptLines += ""
$promptLines += "Target story: $storyId - $storyTitle"
$promptLines += ""
$promptLines += "Hard rules:"
$promptLines += "- Implement ONLY $storyId."
$promptLines += "- Touch ONLY these files (no others):"
$promptLines += $scopeFence
$promptLines += "- Do NOT install dependencies and do NOT run network commands."
$promptLines += "- When done: set status to done for $storyId in the plan, commit '$commitMsg', then stop."
$prompt = $promptLines -join "`n"

Info ("Running YOLO for " + $storyId + "...")
& codex --cd $RepoRoot exec --yolo -- "$prompt"
Info ("Done.")