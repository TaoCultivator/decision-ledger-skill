[CmdletBinding()]
param(
    [string]$SourceSkill = (Join-Path $env:USERPROFILE ".codex\skills\decision-ledger"),
    [string]$Version,
    [switch]$Push,
    [switch]$NoTag,
    [switch]$AllowDirty
)

$ErrorActionPreference = "Stop"
$env:PYTHONUTF8 = "1"

function Invoke-Git {
    param([Parameter(ValueFromRemainingArguments = $true)][string[]]$Args)
    & git -c "safe.directory=$RepoRoot" @Args
    if ($LASTEXITCODE -ne 0) {
        throw "git command failed: git $($Args -join ' ')"
    }
}

function Assert-UnderPath {
    param([string]$Path, [string]$Parent)
    $fullPath = [System.IO.Path]::GetFullPath($Path)
    $fullParent = [System.IO.Path]::GetFullPath($Parent)
    if (-not $fullPath.StartsWith($fullParent, [System.StringComparison]::OrdinalIgnoreCase)) {
        throw "Refusing path outside expected parent: $fullPath"
    }
}

function Get-NextPatchVersion {
    $tags = (& git -c "safe.directory=$RepoRoot" -C $RepoRoot tag --list "v[0-9]*.[0-9]*.[0-9]*") | Where-Object { $_ -match '^v(\d+)\.(\d+)\.(\d+)$' }
    $versions = foreach ($tag in $tags) {
        if ($tag -match '^v(\d+)\.(\d+)\.(\d+)$') {
            [pscustomobject]@{ Tag = $tag; Major = [int]$Matches[1]; Minor = [int]$Matches[2]; Patch = [int]$Matches[3] }
        }
    }
    $latest = $versions | Sort-Object Major, Minor, Patch | Select-Object -Last 1
    if ($null -eq $latest) { return "v0.1.0" }
    return "v$($latest.Major).$($latest.Minor).$($latest.Patch + 1)"
}

$RepoRoot = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot ".."))
$PublicSkill = Join-Path $RepoRoot "decision-ledger"
$SourceSkill = [System.IO.Path]::GetFullPath($SourceSkill)

if (-not (Test-Path -LiteralPath $SourceSkill)) {
    throw "Source skill not found: $SourceSkill"
}
if (-not (Test-Path -LiteralPath (Join-Path $SourceSkill "SKILL.md"))) {
    throw "Source skill is missing SKILL.md: $SourceSkill"
}
if (-not (Test-Path -LiteralPath (Join-Path $RepoRoot ".git"))) {
    throw "Repository root is missing .git: $RepoRoot"
}

if (-not $AllowDirty) {
    $dirtyBefore = (& git -c "safe.directory=$RepoRoot" -C $RepoRoot status --porcelain)
    if ($dirtyBefore) {
        throw "Repository has uncommitted changes before sync. Commit, stash, or rerun with -AllowDirty."
    }
}

Assert-UnderPath -Path $PublicSkill -Parent $RepoRoot
if (Test-Path -LiteralPath $PublicSkill) {
    Remove-Item -LiteralPath $PublicSkill -Recurse -Force
}
New-Item -ItemType Directory -Force -Path $PublicSkill | Out-Null
$sourceSkillMd = Join-Path $SourceSkill "SKILL.md"
$publicSkillMd = Join-Path $PublicSkill "SKILL.md"
[System.IO.File]::Copy($sourceSkillMd, $publicSkillMd, $true)
if (-not (Test-Path -LiteralPath $publicSkillMd)) { Get-ChildItem -LiteralPath $PublicSkill -Force | Format-Table Name,Mode,Length | Out-String | Write-Host; throw "SKILL.md copy failed: $sourceSkillMd -> $publicSkillMd" }
foreach ($name in @("agents", "references", "scripts", "assets")) {
    $sourceChild = Join-Path $SourceSkill $name
    if (Test-Path -LiteralPath $sourceChild) {
        Copy-Item -LiteralPath $sourceChild -Destination $PublicSkill -Recurse -Force
    }
}

Get-ChildItem -LiteralPath $PublicSkill -Recurse -Force -Directory -Filter "__pycache__" | Remove-Item -Recurse -Force
Get-ChildItem -LiteralPath $PublicSkill -Recurse -Force -File | Where-Object { $_.Extension -in @(".pyc", ".pyo") } | Remove-Item -Force

$skillMd = Join-Path $PublicSkill "SKILL.md"
$skillText = [System.IO.File]::ReadAllText($skillMd)
$skillText = $skillText -replace 'python\s+C:/Users/[^/\r\n]+/\.codex/skills/decision-ledger/scripts/ledger_search\.py', 'python path/to/decision-ledger/scripts/ledger_search.py'
$skillText = $skillText -replace 'python\s+C:\\Users\\[^\\\r\n]+\\\.codex\\skills\\decision-ledger\\scripts\\ledger_search\.py', 'python path/to/decision-ledger/scripts/ledger_search.py'
[System.IO.File]::WriteAllText($skillMd, $skillText, [System.Text.UTF8Encoding]::new($false))

$validator = Join-Path $env:USERPROFILE ".codex\skills\.system\skill-creator\scripts\quick_validate.py"
if (Test-Path -LiteralPath $validator) {
    & python $validator $PublicSkill
    if ($LASTEXITCODE -ne 0) { throw "quick_validate.py failed" }
} else {
    Write-Warning "quick_validate.py not found; skipping skill validator"
}

$searchScript = Join-Path $PublicSkill "scripts\ledger_search.py"
& python -c "import ast, pathlib; ast.parse(pathlib.Path(r'$searchScript').read_text(encoding='utf-8')); print('AST_OK')"
if ($LASTEXITCODE -ne 0) { throw "Python AST check failed" }

$tempIndex = Join-Path ([System.IO.Path]::GetTempPath()) "decision-ledger-sync-test-index.jsonl"
$sample = '{ "id":"rejected-fixed-delay", "status":"rejected", "project":"demo", "scope":"cursor-detection", "module":"waveform", "problem":"right cursor too late on smooth waveform", "keywords":["right cursor","smooth waveform","rejected"], "summary":"Fixed delay was rejected because it drifts across waveform types.", "path":"docs/decision-ledger/rejected/rejected-fixed-delay.md" }'
[System.IO.File]::WriteAllText($tempIndex, $sample, [System.Text.UTF8Encoding]::new($false))
& python $searchScript --index $tempIndex --query "smooth waveform right cursor" --top 1 | Out-Host
if ($LASTEXITCODE -ne 0) { throw "ledger_search.py smoke test failed" }

$files = Get-ChildItem -LiteralPath $RepoRoot -Recurse -Force -File | Where-Object { $_.FullName -notmatch '\\.git\\' }
$privatePatterns = @(
    [regex]::Escape($env:USERPROFILE),
    [regex]::Escape($SourceSkill)
)
foreach ($pattern in $privatePatterns) {
    $hits = Select-String -Path ($files | ForEach-Object FullName) -Pattern $pattern -ErrorAction SilentlyContinue
    if ($hits) {
        $hits | ForEach-Object { Write-Error "Private path hit: $($_.Path):$($_.LineNumber): $($_.Line)" }
        throw "Private path scan failed"
    }
}

$status = (& git -c "safe.directory=$RepoRoot" -C $RepoRoot status --porcelain)
if (-not $status) {
    Write-Host "No public skill changes to publish."
    exit 0
}

Invoke-Git -C $RepoRoot add .
$stamp = Get-Date -Format "yyyy-MM-dd"
Invoke-Git -C $RepoRoot commit -m "Sync decision-ledger skill $stamp"

$tagName = $null
if (-not $NoTag) {
    if ($Version) {
        $tagName = if ($Version.StartsWith("v")) { $Version } else { "v$Version" }
    } else {
        $tagName = Get-NextPatchVersion
    }
    Invoke-Git -C $RepoRoot tag $tagName
    Write-Host "Created tag $tagName"
}

if ($Push) {
    Invoke-Git -C $RepoRoot push origin main
    if ($tagName) {
        Invoke-Git -C $RepoRoot push origin $tagName
    }
}

Write-Host "Sync complete."