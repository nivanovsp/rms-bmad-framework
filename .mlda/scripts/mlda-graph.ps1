<#
.SYNOPSIS
    Visualizes MLDA document relationships as a graph.

.DESCRIPTION
    Generates text-based and Mermaid diagram visualizations of the
    MLDA knowledge graph. Shows document relationships (dendrites)
    and helps identify clusters, orphans, and hubs.

.PARAMETER DocId
    Focus on a specific document and show its local neighborhood

.PARAMETER Depth
    How many levels deep to show from the focused document (default: 2)

.PARAMETER Output
    Output format: text (default), mermaid, or both

.PARAMETER OutFile
    Write Mermaid diagram to file (default: graph.mmd)

.EXAMPLE
    .\mlda-graph.ps1                        # Show full graph as text
    .\mlda-graph.ps1 -DocId DOC-API-001     # Focus on specific document
    .\mlda-graph.ps1 -Output mermaid        # Generate Mermaid diagram
    .\mlda-graph.ps1 -DocId DOC-API-001 -Depth 3 -Output both
#>

param(
    [string]$DocId,
    [int]$Depth = 2,
    [ValidateSet("text", "mermaid", "both")]
    [string]$Output = "text",
    [string]$OutFile = "graph.mmd"
)

$ErrorActionPreference = "Stop"

# Paths
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$MldaRoot = Split-Path -Parent $ScriptDir
$DocsDir = Join-Path $MldaRoot "docs"
$RegistryFile = Join-Path $MldaRoot "registry.yaml"

# Simple YAML parser for meta files
function Read-MetaYaml {
    param([string]$Path)

    $meta = @{
        id = ""
        title = ""
        status = "active"
        related = @()
    }

    $content = Get-Content $Path -ErrorAction SilentlyContinue
    if (-not $content) { return $null }

    $inRelated = $false
    $inRelatedItem = $false
    $currentRelated = @{}

    foreach ($line in $content) {
        if ($line -match "^\w") {
            if ($inRelatedItem -and $currentRelated.id) {
                $meta.related += [PSCustomObject]$currentRelated
            }
            $inRelated = $false
            $inRelatedItem = $false
            $currentRelated = @{}
        }

        if ($line -match "^id:\s*(.+)") {
            $meta.id = $Matches[1].Trim()
        }
        elseif ($line -match "^title:\s*[`"']?([^`"']+)[`"']?") {
            $meta.title = $Matches[1].Trim()
        }
        elseif ($line -match "^status:\s*(\w+)") {
            $meta.status = $Matches[1].Trim()
        }
        elseif ($line -match "^related:") {
            $inRelated = $true
        }
        elseif ($inRelated -and $line -match "^\s+-\s*id:\s*(.+)") {
            if ($inRelatedItem -and $currentRelated.id) {
                $meta.related += [PSCustomObject]$currentRelated
            }
            $inRelatedItem = $true
            $currentRelated = @{
                id = $Matches[1].Trim()
                type = "references"
            }
        }
        elseif ($inRelatedItem -and $line -match "^\s+type:\s*(.+)") {
            $currentRelated.type = $Matches[1].Trim()
        }
    }

    if ($inRelatedItem -and $currentRelated.id) {
        $meta.related += [PSCustomObject]$currentRelated
    }

    return $meta
}

# Load all documents
Write-Host "`n=== MLDA Graph Visualization ===" -ForegroundColor Cyan

if (-not (Test-Path $DocsDir)) {
    Write-Host "No docs directory found." -ForegroundColor Red
    exit 1
}

$metaFiles = Get-ChildItem -Path $DocsDir -Filter "*.meta.yaml" -Recurse -ErrorAction SilentlyContinue
$documents = @{}
$edges = @()

foreach ($metaFile in $metaFiles) {
    $meta = Read-MetaYaml $metaFile.FullName
    if ($meta -and $meta.id) {
        $documents[$meta.id] = @{
            Id = $meta.id
            Title = $meta.title
            Status = $meta.status
            Related = $meta.related
            ReferencedBy = @()
        }
    }
}

# Build edges and reverse references
foreach ($docId in $documents.Keys) {
    $doc = $documents[$docId]
    foreach ($rel in $doc.Related) {
        $edges += @{
            From = $docId
            To = $rel.id
            Type = $rel.type
        }
        if ($documents.ContainsKey($rel.id)) {
            $documents[$rel.id].ReferencedBy += $docId
        }
    }
}

Write-Host "Loaded: $($documents.Count) documents, $($edges.Count) relationships"

# Text visualization
function Show-TextGraph {
    param(
        [string]$FocusId,
        [int]$MaxDepth
    )

    if ($FocusId) {
        if (-not $documents.ContainsKey($FocusId)) {
            Write-Host "Document not found: $FocusId" -ForegroundColor Red
            return
        }

        Write-Host "`n--- Local Graph: $FocusId ---" -ForegroundColor Yellow

        $visited = @{}
        $queue = @(@{ Id = $FocusId; Depth = 0; Direction = "center" })

        while ($queue.Count -gt 0) {
            $current = $queue[0]
            $queue = $queue[1..($queue.Count - 1)]

            if ($visited.ContainsKey($current.Id)) { continue }
            $visited[$current.Id] = $true

            $doc = $documents[$current.Id]
            $indent = "  " * $current.Depth
            $marker = switch ($current.Direction) {
                "center" { "[*]" }
                "outgoing" { "-->" }
                "incoming" { "<--" }
                default { "   " }
            }

            $shortTitle = if ($doc.Title.Length -gt 30) {
                $doc.Title.Substring(0, 27) + "..."
            } else {
                $doc.Title
            }

            Write-Host "$indent$marker $($current.Id)" -ForegroundColor Cyan -NoNewline
            Write-Host " - $shortTitle"

            if ($current.Depth -lt $MaxDepth) {
                # Add outgoing relationships
                foreach ($rel in $doc.Related) {
                    if (-not $visited.ContainsKey($rel.id)) {
                        $queue += @{ Id = $rel.id; Depth = $current.Depth + 1; Direction = "outgoing" }
                    }
                }
                # Add incoming relationships
                foreach ($refId in $doc.ReferencedBy) {
                    if (-not $visited.ContainsKey($refId)) {
                        $queue += @{ Id = $refId; Depth = $current.Depth + 1; Direction = "incoming" }
                    }
                }
            }
        }
    }
    else {
        Write-Host "`n--- Full Graph Overview ---" -ForegroundColor Yellow

        # Group by domain
        $byDomain = @{}
        foreach ($docId in $documents.Keys) {
            if ($docId -match "^(?:DOC-)?(\w+)-") {
                $domain = $Matches[1]
                if (-not $byDomain[$domain]) {
                    $byDomain[$domain] = @()
                }
                $byDomain[$domain] += $docId
            }
        }

        foreach ($domain in $byDomain.Keys | Sort-Object) {
            Write-Host "`n[$domain]" -ForegroundColor Green
            foreach ($docId in $byDomain[$domain] | Sort-Object) {
                $doc = $documents[$docId]
                $outCount = $doc.Related.Count
                $inCount = $doc.ReferencedBy.Count

                $connStr = ""
                if ($outCount -gt 0 -or $inCount -gt 0) {
                    $connStr = " ($outCount out, $inCount in)"
                }

                $shortTitle = if ($doc.Title.Length -gt 35) {
                    $doc.Title.Substring(0, 32) + "..."
                } else {
                    $doc.Title
                }

                Write-Host "  $docId" -ForegroundColor Cyan -NoNewline
                Write-Host " - $shortTitle" -NoNewline
                if ($connStr) {
                    Write-Host $connStr -ForegroundColor DarkGray
                } else {
                    Write-Host ""
                }

                # Show outgoing relationships
                foreach ($rel in $doc.Related) {
                    $arrow = switch ($rel.type) {
                        "depends-on" { "==>" }
                        "extends" { "-->" }
                        "supersedes" { ">>>" }
                        default { "---" }
                    }
                    Write-Host "    $arrow $($rel.id)" -ForegroundColor DarkYellow
                }
            }
        }

        # Show orphans
        $orphans = $documents.Values | Where-Object {
            $_.Related.Count -eq 0 -and $_.ReferencedBy.Count -eq 0
        }
        if ($orphans.Count -gt 0) {
            Write-Host "`n[ORPHANS - No connections]" -ForegroundColor Red
            foreach ($orphan in $orphans) {
                Write-Host "  $($orphan.Id) - $($orphan.Title)"
            }
        }
    }
}

# Mermaid visualization
function Get-MermaidGraph {
    param(
        [string]$FocusId,
        [int]$MaxDepth
    )

    $mermaid = @("graph TD")
    $mermaid += "    %% MLDA Knowledge Graph"
    $mermaid += "    %% Generated by mlda-graph.ps1"
    $mermaid += ""

    $includedDocs = @{}

    if ($FocusId) {
        # BFS to collect local neighborhood
        $visited = @{}
        $queue = @(@{ Id = $FocusId; Depth = 0 })

        while ($queue.Count -gt 0) {
            $current = $queue[0]
            $queue = $queue[1..($queue.Count - 1)]

            if ($visited.ContainsKey($current.Id)) { continue }
            $visited[$current.Id] = $true
            $includedDocs[$current.Id] = $true

            if ($current.Depth -lt $MaxDepth -and $documents.ContainsKey($current.Id)) {
                $doc = $documents[$current.Id]
                foreach ($rel in $doc.Related) {
                    if (-not $visited.ContainsKey($rel.id)) {
                        $queue += @{ Id = $rel.id; Depth = $current.Depth + 1 }
                    }
                    $includedDocs[$rel.id] = $true
                }
                foreach ($refId in $doc.ReferencedBy) {
                    if (-not $visited.ContainsKey($refId)) {
                        $queue += @{ Id = $refId; Depth = $current.Depth + 1 }
                    }
                    $includedDocs[$refId] = $true
                }
            }
        }
    }
    else {
        foreach ($docId in $documents.Keys) {
            $includedDocs[$docId] = $true
        }
    }

    # Add nodes
    $mermaid += "    %% Nodes"
    foreach ($docId in $includedDocs.Keys | Sort-Object) {
        if ($documents.ContainsKey($docId)) {
            $doc = $documents[$docId]
            $safeId = $docId -replace "-", "_"
            $shortTitle = if ($doc.Title.Length -gt 25) {
                $doc.Title.Substring(0, 22) + "..."
            } else {
                $doc.Title
            }
            $shortTitle = $shortTitle -replace '"', "'"

            if ($docId -eq $FocusId) {
                $mermaid += "    ${safeId}[`"**$docId**<br/>$shortTitle`"]"
            } else {
                $mermaid += "    ${safeId}[`"$docId<br/>$shortTitle`"]"
            }
        }
    }

    $mermaid += ""
    $mermaid += "    %% Relationships"

    # Add edges
    foreach ($edge in $edges) {
        if ($includedDocs.ContainsKey($edge.From) -and $includedDocs.ContainsKey($edge.To)) {
            $fromSafe = $edge.From -replace "-", "_"
            $toSafe = $edge.To -replace "-", "_"

            $arrow = switch ($edge.Type) {
                "depends-on" { "==>" }
                "extends" { "-->" }
                "supersedes" { "-.->" }
                default { "---" }
            }

            $mermaid += "    $fromSafe $arrow $toSafe"
        }
    }

    # Style the focus node
    if ($FocusId) {
        $focusSafe = $FocusId -replace "-", "_"
        $mermaid += ""
        $mermaid += "    %% Styling"
        $mermaid += "    style $focusSafe fill:#f9f,stroke:#333,stroke-width:4px"
    }

    return $mermaid -join "`n"
}

# Execute based on output format
switch ($Output) {
    "text" {
        Show-TextGraph -FocusId $DocId -MaxDepth $Depth
    }
    "mermaid" {
        $mermaidContent = Get-MermaidGraph -FocusId $DocId -MaxDepth $Depth
        $outPath = Join-Path $MldaRoot $OutFile
        Set-Content $outPath -Value $mermaidContent
        Write-Host "`nMermaid diagram written to: $outPath" -ForegroundColor Green
        Write-Host "View at: https://mermaid.live/ or in VS Code with Mermaid extension"
    }
    "both" {
        Show-TextGraph -FocusId $DocId -MaxDepth $Depth
        Write-Host ""
        $mermaidContent = Get-MermaidGraph -FocusId $DocId -MaxDepth $Depth
        $outPath = Join-Path $MldaRoot $OutFile
        Set-Content $outPath -Value $mermaidContent
        Write-Host "Mermaid diagram written to: $outPath" -ForegroundColor Green
    }
}

Write-Host "`n=== Done ===" -ForegroundColor Cyan
Write-Host ""
