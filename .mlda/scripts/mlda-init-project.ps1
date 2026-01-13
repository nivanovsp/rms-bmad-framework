<#
.SYNOPSIS
    Initializes MLDA (Modular Linked Documentation Architecture) in a project folder.

.DESCRIPTION
    Scaffolds the complete MLDA structure including:
    - docs/ folder with domain subfolders
    - scripts/ folder with MLDA utilities
    - templates/ folder with document templates
    - registry.yaml for document tracking
    - README.md with project-specific instructions

.PARAMETER ProjectPath
    Target path where .mlda/ will be created. Defaults to current directory.

.PARAMETER Domains
    Array of domain codes (API, AUTH, DATA, INV, SEC, UI, INFRA, INT, TEST, DOC)

.PARAMETER ProjectName
    Name of the project (used in registry). Defaults to folder name.

.PARAMETER SourcePath
    Path to source MLDA scripts/templates. Defaults to script's parent .mlda folder.

.PARAMETER Migrate
    If set, will create .meta.yaml sidecars for existing .md files.

.EXAMPLE
    .\mlda-init-project.ps1 -Domains API,DATA,SEC
    .\mlda-init-project.ps1 -ProjectPath "C:\Projects\MyProject" -Domains API,AUTH -Migrate
    .\mlda-init-project.ps1 -Domains INV -ProjectName "Invoice Module"
#>

param(
    [Parameter()]
    [string]$ProjectPath = (Get-Location).Path,

    [Parameter(Mandatory=$true)]
    [ValidateSet("API", "AUTH", "DATA", "INV", "SEC", "UI", "INFRA", "INT", "TEST", "DOC")]
    [string[]]$Domains,

    [Parameter()]
    [string]$ProjectName,

    [Parameter()]
    [string]$SourcePath,

    [switch]$Migrate
)

$ErrorActionPreference = "Stop"

# Resolve paths
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
if (-not $SourcePath) {
    $SourcePath = Split-Path -Parent $ScriptDir  # Parent of scripts/ = .mlda/
}

$TargetMlda = Join-Path $ProjectPath ".mlda"
$TargetDocs = Join-Path $TargetMlda "docs"
$TargetScripts = Join-Path $TargetMlda "scripts"
$TargetTemplates = Join-Path $TargetMlda "templates"

if (-not $ProjectName) {
    $ProjectName = Split-Path $ProjectPath -Leaf
}

$Date = Get-Date -Format "yyyy-MM-dd"

Write-Host "`n=== MLDA Project Initialization ===" -ForegroundColor Cyan
Write-Host "Project:  $ProjectName"
Write-Host "Target:   $TargetMlda"
Write-Host "Domains:  $($Domains -join ', ')"
Write-Host "Source:   $SourcePath"

# Check if .mlda already exists
if (Test-Path $TargetMlda) {
    Write-Host "`nWarning: .mlda/ already exists at target location!" -ForegroundColor Yellow
    $response = Read-Host "Overwrite (o), Merge (m), or Cancel (c)?"
    switch ($response.ToLower()) {
        "c" { Write-Host "Cancelled."; exit 0 }
        "o" { Remove-Item -Path $TargetMlda -Recurse -Force }
        "m" { Write-Host "Merging with existing structure..." }
        default { Write-Host "Invalid option. Cancelled."; exit 1 }
    }
}

# Create folder structure
Write-Host "`nCreating folder structure..." -ForegroundColor Yellow

# Main folders
New-Item -ItemType Directory -Path $TargetMlda -Force | Out-Null
New-Item -ItemType Directory -Path $TargetDocs -Force | Out-Null
New-Item -ItemType Directory -Path $TargetScripts -Force | Out-Null
New-Item -ItemType Directory -Path $TargetTemplates -Force | Out-Null

# Domain folders
foreach ($domain in $Domains) {
    $domainPath = Join-Path $TargetDocs $domain.ToLower()
    New-Item -ItemType Directory -Path $domainPath -Force | Out-Null
    Write-Host "  Created: docs/$($domain.ToLower())/" -ForegroundColor Green
}

# Copy scripts from source
Write-Host "`nCopying scripts..." -ForegroundColor Yellow
$sourceScripts = Join-Path $SourcePath "scripts"
if (Test-Path $sourceScripts) {
    $scriptFiles = @("mlda-create.ps1", "mlda-registry.ps1", "mlda-validate.ps1", "mlda-brief.ps1")
    foreach ($script in $scriptFiles) {
        $srcFile = Join-Path $sourceScripts $script
        if (Test-Path $srcFile) {
            Copy-Item -Path $srcFile -Destination $TargetScripts
            Write-Host "  Copied: scripts/$script" -ForegroundColor Green
        }
    }
} else {
    Write-Host "  Warning: Source scripts not found. Creating minimal versions." -ForegroundColor Yellow
}

# Copy templates from source
Write-Host "`nCopying templates..." -ForegroundColor Yellow
$sourceTemplates = Join-Path $SourcePath "templates"
if (Test-Path $sourceTemplates) {
    Copy-Item -Path "$sourceTemplates\*" -Destination $TargetTemplates -Force
    Write-Host "  Copied: templates/*" -ForegroundColor Green
} else {
    # Create minimal templates
    $topicDocTemplate = @"
# {Title}

**DOC-ID:** {DOC-ID}

---

## Summary

{Overview of this topic}

---

## Content

{Main content}

---

## Change Log

| Date | Author | Change |
|------|--------|--------|
| {date} | {author} | Initial creation |
"@
    Set-Content -Path (Join-Path $TargetTemplates "topic-doc.md") -Value $topicDocTemplate

    $topicMetaTemplate = @"
id: {DOC-ID}
title: "{Title}"
status: active

created:
  date: "{date}"
  by: "{author}"

updated:
  date: "{date}"
  by: "{author}"

tags: []
related: []
"@
    Set-Content -Path (Join-Path $TargetTemplates "topic-meta.yaml") -Value $topicMetaTemplate
    Write-Host "  Created: templates/topic-doc.md" -ForegroundColor Green
    Write-Host "  Created: templates/topic-meta.yaml" -ForegroundColor Green
}

# Create registry.yaml
Write-Host "`nCreating registry..." -ForegroundColor Yellow
$domainsYaml = ($Domains | ForEach-Object { $_.ToLower() }) -join ", "
$registryContent = @"
# MLDA Document Registry
# Project: $ProjectName
# Initialized: $Date

project: "$ProjectName"
created: "$Date"
domains: [$domainsYaml]

# Document entries are added automatically by mlda-create.ps1
# or manually following this format:
#
# documents:
#   - id: DOC-API-001
#     title: "Document Title"
#     path: docs/api/document-slug.md
#     status: active

documents: []
"@
Set-Content -Path (Join-Path $TargetMlda "registry.yaml") -Value $registryContent
Write-Host "  Created: registry.yaml" -ForegroundColor Green

# Create README.md
Write-Host "`nCreating README..." -ForegroundColor Yellow

# Build domain list for README
$domainList = ($Domains | ForEach-Object { "  - $($_.ToLower())/" }) -join "`n"
$domainExamples = ($Domains | ForEach-Object { "- $_ -> DOC-$_-001" }) -join "`n"

$readmeContent = @"
# MLDA - $ProjectName

**Modular Linked Documentation Architecture**

Initialized: $Date

---

## Structure

.mlda/
  docs/              # Topic documents organized by domain
$domainList
  scripts/           # MLDA utilities
    - mlda-create.ps1
    - mlda-registry.ps1
    - mlda-validate.ps1
    - mlda-brief.ps1
  templates/         # Document templates
  registry.yaml      # Document index
  README.md          # This file

---

## Quick Start

### Create a New Document

.mlda/scripts/mlda-create.ps1 -Title "My Document" -Domain $($Domains[0])

### Rebuild Registry

.mlda/scripts/mlda-registry.ps1

### Validate Links

.mlda/scripts/mlda-validate.ps1

---

## DOC-ID Convention

Format: DOC-{DOMAIN}-{NNN}

Examples:
$domainExamples

---

## Adding Relationships

In .meta.yaml files, use the related field:

related:
  - id: DOC-API-001
    type: references
    why: "Uses patterns defined here"

Relationship types: references, extends, depends-on, supersedes
"@
Set-Content -Path (Join-Path $TargetMlda "README.md") -Value $readmeContent
Write-Host "  Created: README.md" -ForegroundColor Green

# Migration mode - create .meta.yaml for existing .md files
if ($Migrate) {
    Write-Host "`nMigrating existing documents..." -ForegroundColor Yellow

    $existingDocs = Get-ChildItem -Path $ProjectPath -Filter "*.md" -File |
                    Where-Object { $_.Name -ne "README.md" }

    if ($existingDocs.Count -gt 0) {
        $counter = @{}
        foreach ($domain in $Domains) {
            $counter[$domain] = 1
        }

        # Default domain for migration
        $defaultDomain = $Domains[0]

        foreach ($doc in $existingDocs) {
            $docId = "DOC-$defaultDomain-{0:D3}" -f $counter[$defaultDomain]
            $counter[$defaultDomain]++

            $metaFile = $doc.FullName -replace '\.md$', '.meta.yaml'

            if (-not (Test-Path $metaFile)) {
                $metaContent = @"
id: $docId
title: "$($doc.BaseName)"
status: active

created:
  date: "$Date"
  by: "migration"

updated:
  date: "$Date"
  by: "migration"

tags:
  - migrated
  - $($defaultDomain.ToLower())

related: []

# NOTE: This sidecar was auto-generated during MLDA migration.
# Review and update:
# - Correct the domain if needed
# - Add related document references
# - Update tags
"@
                Set-Content -Path $metaFile -Value $metaContent
                Write-Host "  Created: $($doc.Name -replace '\.md$', '.meta.yaml')" -ForegroundColor Green
            }
        }

        Write-Host "`n  Migrated $($existingDocs.Count) documents" -ForegroundColor Cyan
        Write-Host "  Review .meta.yaml files to correct domains and add relationships" -ForegroundColor Yellow
    } else {
        Write-Host "  No existing .md files found to migrate" -ForegroundColor Gray
    }
}

# Summary
Write-Host "`n=== Initialization Complete ===" -ForegroundColor Cyan
Write-Host @"

MLDA has been initialized at: $TargetMlda

Next steps:
1. Create new documents:
   .\.mlda\scripts\mlda-create.ps1 -Title "Doc Name" -Domain $($Domains[0])

2. Rebuild registry after changes:
   .\.mlda\scripts\mlda-registry.ps1

3. Validate link integrity:
   .\.mlda\scripts\mlda-validate.ps1

"@
