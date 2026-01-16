<#
.SYNOPSIS
    Generates or updates the handoff document for phase transitions.

.DESCRIPTION
    Creates or updates docs/handoff.md with current phase information,
    document statistics from the MLDA registry, and templates for
    phase-specific content.

.PARAMETER Phase
    Current phase: analyst, architect, or developer (required)

.PARAMETER Status
    Phase status: in-progress, completed, handed-off (default: in-progress)

.PARAMETER Init
    Initialize a new handoff document (creates fresh file)

.PARAMETER Show
    Display current handoff status without modifying

.EXAMPLE
    .\mlda-handoff.ps1 -Phase analyst -Status completed
    .\mlda-handoff.ps1 -Phase architect -Init
    .\mlda-handoff.ps1 -Show
#>

param(
    [ValidateSet("analyst", "architect", "developer")]
    [string]$Phase,

    [ValidateSet("in-progress", "completed", "handed-off")]
    [string]$Status = "in-progress",

    [switch]$Init,
    [switch]$Show
)

$ErrorActionPreference = "Stop"

# Paths
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$MldaRoot = Split-Path -Parent $ScriptDir
$ProjectRoot = Split-Path -Parent $MldaRoot
$DocsDir = Join-Path $ProjectRoot "docs"
$HandoffFile = Join-Path $DocsDir "handoff.md"
$RegistryFile = Join-Path $MldaRoot "registry.yaml"

# Phase configuration
$PhaseConfig = @{
    analyst = @{
        Number = 1
        Name = "Analyst Discovery"
        Agent = "Maya (Analyst)"
        NextPhase = "architect"
        NextAgent = "Winston (Architect)"
        RequiredSection = "Open Questions for Architect"
    }
    architect = @{
        Number = 2
        Name = "Architecture Refinement"
        Agent = "Winston (Architect)"
        NextPhase = "developer"
        NextAgent = "Devon (Developer+QA)"
        RequiredSection = "Open Questions for Developer"
    }
    developer = @{
        Number = 3
        Name = "Implementation"
        Agent = "Devon (Developer+QA)"
        NextPhase = $null
        NextAgent = $null
        RequiredSection = $null
    }
}

# Get project name from folder
function Get-ProjectName {
    return (Get-Item $ProjectRoot).Name
}

# Read document stats from registry
function Get-RegistryStats {
    if (-not (Test-Path $RegistryFile)) {
        return @{
            Total = 0
            ByDomain = @{}
            Hubs = @()
            Orphans = 0
        }
    }

    $stats = @{
        Total = 0
        ByDomain = @{}
        Hubs = @()
        Orphans = 0
    }

    $content = Get-Content $RegistryFile -Raw

    # Parse total documents
    if ($content -match "total_documents:\s*(\d+)") {
        $stats.Total = [int]$Matches[1]
    }

    # Parse orphan count
    if ($content -match "orphan_documents:\s*(\d+)") {
        $stats.Orphans = [int]$Matches[1]
    }

    # Parse domains (simple extraction)
    $inDomains = $false
    foreach ($line in (Get-Content $RegistryFile)) {
        if ($line -match "^domains:") {
            $inDomains = $true
            continue
        }
        if ($inDomains) {
            if ($line -match "^\s+-\s*(\w+)") {
                $domain = $Matches[1].Trim()
                $stats.ByDomain[$domain] = 0  # Count will be updated
            }
            elseif ($line -match "^\w" -and $line -notmatch "^\s*#") {
                break
            }
        }
    }

    return $stats
}

# Display current status
if ($Show) {
    Write-Host "`n=== Handoff Status ===" -ForegroundColor Cyan

    if (-not (Test-Path $HandoffFile)) {
        Write-Host "No handoff document found at: $HandoffFile" -ForegroundColor Yellow
        Write-Host "Run with -Phase <phase> -Init to create one."
        exit 0
    }

    $content = Get-Content $HandoffFile -Raw

    # Extract current phase
    if ($content -match "Current Phase:\*\*\s*(.+)") {
        Write-Host "Current Phase: $($Matches[1])" -ForegroundColor Green
    }

    # Extract last handoff by
    if ($content -match "Last Handoff By:\*\*\s*(.+)") {
        Write-Host "Last Handoff By: $($Matches[1])"
    }

    # Extract last updated
    if ($content -match "Last Updated:\*\*\s*(.+)") {
        Write-Host "Last Updated: $($Matches[1])"
    }

    Write-Host "`nFile: $HandoffFile"
    Write-Host ""
    exit 0
}

# Validate phase is provided for non-show operations
if (-not $Phase) {
    Write-Host "Error: -Phase parameter is required" -ForegroundColor Red
    Write-Host "Usage: .\mlda-handoff.ps1 -Phase <analyst|architect|developer> [-Status <status>] [-Init]"
    exit 1
}

$config = $PhaseConfig[$Phase]
$date = Get-Date -Format "yyyy-MM-dd"
$timestamp = Get-Date -Format "yyyy-MM-ddTHH:mm:ssK"
$projectName = Get-ProjectName
$stats = Get-RegistryStats

Write-Host "`n=== MLDA Handoff ===" -ForegroundColor Cyan
Write-Host "Project: $projectName"
Write-Host "Phase: $($config.Name)"
Write-Host "Status: $Status"

# Create docs directory if needed
if (-not (Test-Path $DocsDir)) {
    New-Item -ItemType Directory -Path $DocsDir -Force | Out-Null
    Write-Host "Created: docs/"
}

# Initialize new handoff document
if ($Init -or -not (Test-Path $HandoffFile)) {
    Write-Host "`nCreating new handoff document..." -ForegroundColor Yellow

    $handoffContent = @"
# Project Handoff Document

**Project:** $projectName
**Last Updated:** $date
**Current Phase:** $($config.Name)
**Last Handoff By:** $($config.Agent)

---

## Phase History

### Phase 1: Analyst Discovery
**Status:** $(if ($Phase -eq "analyst") { $Status } else { "Not Started" })
**Agent:** Maya (Analyst)
**Dates:** $(if ($Phase -eq "analyst") { $date } else { "[Start]" }) - [End]

#### Work Summary
[Brief description of what was accomplished]

#### Documents Created
| DOC-ID | Title | Domain | Description |
|--------|-------|--------|-------------|
| | | | |

**Total Documents:** $($stats.Total)
**Domains Covered:** [List domains]

#### Key Decisions Made
1. [Decision with rationale]

#### Open Questions for Architect (REQUIRED)
> These are questions the analyst could not resolve alone and require architectural input.

1. **[Question Title]**
   - Context: [Why this is a question]
   - Options considered: [What analyst thought about]
   - Recommendation: [If any]

#### Entry Points for Next Phase
| Priority | DOC-ID | Title | Why Start Here |
|----------|--------|-------|----------------|
| 1 | | | |

---

### Phase 2: Architecture Refinement
**Status:** Not Started
**Agent:** Winston (Architect)
**Dates:** [Start] - [End]

#### Review Summary
[What was reviewed and key findings]

#### Documents Modified
| DOC-ID | Title | Changes Made | Rationale |
|--------|-------|--------------|-----------|

#### Documents Created
| DOC-ID | Title | Domain | Description |
|--------|-------|--------|-------------|

#### Questions Resolved
| From Phase | Question | Resolution |
|------------|----------|------------|

#### Open Questions for Developer (REQUIRED)
1. **[Question Title]**
   - Context: [Why this is a question]
   - Technical constraints: [What architect identified]
   - Recommendation: [If any]

#### Entry Points for Next Phase
| Priority | DOC-ID | Title | Why Start Here |
|----------|--------|-------|----------------|

---

### Phase 3: Implementation
**Status:** Not Started
**Agent:** Devon (Developer+QA)
**Dates:** [Start] - [End]

#### Implementation Notes
[Key implementation decisions and notes]

#### Stories Completed
| Story ID | Title | Status | Notes |
|----------|-------|--------|-------|

#### Test Coverage
| Component | Unit | Integration | Functional |
|-----------|------|-------------|------------|

#### Issues Discovered
1. [Issue with resolution]

---

## Document Statistics

**Total Documents:** $($stats.Total)
**By Domain:**
$(if ($stats.ByDomain.Count -gt 0) {
    ($stats.ByDomain.Keys | Sort-Object | ForEach-Object { "- " + $_ + ": [count]" }) -join "`n"
} else {
    "- [No domains yet]"
})

**Relationship Health:**
- Orphan documents: $($stats.Orphans)
- Broken links: [Run mlda-validate to check]
"@

    Set-Content $HandoffFile -Value $handoffContent
    Write-Host "Created: docs/handoff.md" -ForegroundColor Green
}
else {
    # Update existing handoff document
    Write-Host "`nUpdating existing handoff document..." -ForegroundColor Yellow

    $content = Get-Content $HandoffFile -Raw

    # Update last updated date
    $content = $content -replace "(?<=\*\*Last Updated:\*\*\s*).+", $date

    # Update current phase
    $content = $content -replace "(?<=\*\*Current Phase:\*\*\s*).+", $config.Name

    # Update last handoff by
    $content = $content -replace "(?<=\*\*Last Handoff By:\*\*\s*).+", $config.Agent

    # Update phase status
    $phasePattern = "(?<=### Phase $($config.Number):.+\n\*\*Status:\*\*\s*).+"
    $content = $content -replace $phasePattern, $Status

    # Update document statistics
    $content = $content -replace "(?<=\*\*Total Documents:\*\*\s*)\d+", $stats.Total
    $content = $content -replace "(?<=Orphan documents:\s*)\d+", $stats.Orphans

    Set-Content $HandoffFile -Value $content -NoNewline
    Write-Host "Updated: docs/handoff.md" -ForegroundColor Green
}

# Validation reminders
Write-Host "`n--- Reminders ---" -ForegroundColor Yellow

if ($Phase -eq "analyst" -and $Status -eq "completed") {
    Write-Host "REQUIRED: Ensure 'Open Questions for Architect' section is populated" -ForegroundColor Magenta
    Write-Host "  - At least one question, OR"
    Write-Host "  - Explicit 'None' with justification"
}

if ($Phase -eq "architect" -and $Status -eq "completed") {
    Write-Host "REQUIRED: Ensure 'Questions Resolved' section addresses analyst questions" -ForegroundColor Magenta
    Write-Host "REQUIRED: Ensure 'Open Questions for Developer' section is populated" -ForegroundColor Magenta
}

if ($Status -eq "completed") {
    Write-Host "`nNext step: Hand off to $($config.NextAgent)" -ForegroundColor Cyan
    if ($config.NextPhase) {
        Write-Host "Command for next phase: /modes:$($config.NextPhase)"
    }
}

Write-Host "`n=== Done ===" -ForegroundColor Cyan
Write-Host ""
