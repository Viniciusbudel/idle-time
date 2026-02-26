# CONFIG
$planPath = "C:\Dev\idle-time\docs\prestige\ralph-loop-prestige-plan.md"

# Read file
$content = Get-Content $planPath -Raw

# Find first TODO story
$storyMatch = [regex]::Match($content, "## (STORY-[0-9]+:.*?)(?=##|$)", "Singleline")

if (-not $storyMatch.Success) {
    Write-Host "No stories found."
    exit
}

$storyBlock = $storyMatch.Value

if ($storyBlock -notmatch "status:\s*todo") {
    Write-Host "No TODO stories remaining."
    exit
}

# Extract story ID
$idMatch = [regex]::Match($storyBlock, "STORY-[0-9]+")
$storyId = $idMatch.Value

Write-Host "Executing $storyId..."

# Build instruction
$instruction = @"
You are executing $planPath.

Find $storyId.
Implement only this story.
Follow acceptance strictly.
Do not modify unrelated files.
When complete:
- Change its status to done
- Create commit message: feat(expeditions): $storyId
Stop after completion.
"@

# Run Codex
codex exec "$instruction"

Write-Host "Execution finished."