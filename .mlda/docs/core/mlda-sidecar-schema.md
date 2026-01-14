# MLDA Sidecar Schema

**DOC-CORE-003** | Metadata Sidecar Specification

---

## Purpose

Every MLDA topic document has a companion `.meta.yaml` sidecar file. This document defines the standardized schema for sidecars, ensuring consistent dendrite structure across the knowledge graph.

---

## File Naming Convention

```
{document-name}.md           # Topic document
{document-name}.meta.yaml    # Sidecar (same name, different extension)
```

Example:
```
.mlda/docs/api/
├── rest-endpoints.md
└── rest-endpoints.meta.yaml
```

---

## Schema Definition

```yaml
# ═══════════════════════════════════════════════════════════════════════════
# REQUIRED FIELDS
# ═══════════════════════════════════════════════════════════════════════════

id: DOC-{DOMAIN}-{NNN}           # Unique identifier (the axon)
title: "{Document Title}"         # Human-readable title
status: active                    # active | deprecated | draft

created:
  date: "{YYYY-MM-DD}"
  by: "{Agent/Author name}"

updated:
  date: "{YYYY-MM-DD}"
  by: "{Agent/Author name}"

tags:                             # For discovery and search
  - {tag1}
  - {tag2}

# ═══════════════════════════════════════════════════════════════════════════
# RELATIONSHIPS (DENDRITES) - Critical for navigation
# ═══════════════════════════════════════════════════════════════════════════

related:                          # Array of connections to other documents
  - id: DOC-XXX-NNN               # Target document ID
    type: depends-on              # Relationship type (see below)
    why: "{explanation}"          # Why this connection exists

# ═══════════════════════════════════════════════════════════════════════════
# OPTIONAL FIELDS
# ═══════════════════════════════════════════════════════════════════════════

summary: |                        # Brief description for quick context
  One paragraph summary of the document content.
  Used by agents during navigation to decide relevance.

source:                           # Traceability to origin
  research: "{research-id}"       # Research document this came from
  sections: ["1", "2.1"]          # Specific sections referenced

metrics:                          # Quantitative metadata
  {metric_name}: {value}

beads: "{Project-N}"              # Link to issue tracker

domain: {domain}                  # Explicit domain (usually inferred from path)

version: "1.0"                    # Document version

superseded_by: DOC-XXX-NNN        # If deprecated, what replaces this
```

---

## Relationship Types

The `type` field in relationships defines signal strength for navigation:

| Type | Signal Strength | Meaning | Agent Behavior |
|------|-----------------|---------|----------------|
| `depends-on` | **Strong** | Cannot understand this without target | Always follow |
| `extends` | **Medium** | Builds upon or adds detail to target | Follow if depth allows |
| `references` | **Weak** | Mentions or cites target | Follow if highly relevant |
| `supersedes` | **Redirect** | This document replaces target | Follow this, mark target obsolete |

### When to Use Each Type

**depends-on**
- Target provides essential context
- This document assumes knowledge from target
- Example: API endpoint doc depends on data model doc

**extends**
- This document adds detail to target
- Target is the overview, this is the deep-dive
- Example: Security audit extends security requirements

**references**
- Casual mention or citation
- Nice-to-know, not need-to-know
- Example: Requirements doc references market research

**supersedes**
- Target is outdated or replaced
- Agents should follow this, ignore target
- Example: API v2 supersedes API v1

---

## The `why` Field

The `why` field is **critical** for navigation. It tells agents:
- Why this relationship exists
- What context the target provides
- Whether to follow based on current task

### Good `why` Examples

```yaml
related:
  - id: DOC-AUTH-001
    type: depends-on
    why: "Authentication flow required for all API calls"

  - id: DOC-DATA-003
    type: references
    why: "Data model for invoice line items"

  - id: REQ-A5-T7
    type: extends
    why: "Detailed requirements for transaction tracking feature"
```

### Bad `why` Examples

```yaml
related:
  - id: DOC-AUTH-001
    why: "Related"           # Too vague - no context for agent

  - id: DOC-DATA-003
    why: "See also"          # Doesn't explain relevance

  - id: REQ-A5-T7
    # Missing why field      # Agent can't evaluate relevance
```

---

## Status Values

| Status | Meaning | Agent Behavior |
|--------|---------|----------------|
| `active` | Current, authoritative | Normal navigation |
| `draft` | Work in progress | Read with caution, may be incomplete |
| `deprecated` | Outdated, replaced | Check `superseded_by`, don't rely on |

---

## Tags Best Practices

Tags enable discovery when DOC-IDs are unknown:

```yaml
tags:
  - {domain}           # api, auth, inv, data, etc.
  - {document-type}    # requirements, spec, design, research
  - {feature-area}     # transaction, user, invoice, payment
  - {status-marker}    # mvp, phase-2, tech-debt (if applicable)
```

### Tag Conventions

- Use lowercase
- Use hyphens for multi-word tags: `credit-limit` not `creditLimit`
- Be specific: `invoice-validation` better than `validation`
- Limit to 5-8 tags per document

---

## Summary Field

The `summary` field provides quick context without reading the full document:

```yaml
summary: |
  Defines the REST API endpoints for invoice management including
  create, read, update, delete operations. Covers authentication
  requirements, rate limiting, and error response formats.
```

**Best practices:**
- Keep to 2-3 sentences
- Mention key topics covered
- Include terms agents might search for

---

## Source Traceability

Link back to origin documents:

```yaml
source:
  research: A7                    # Research document ID
  sections: ["9", "9.1", "10"]    # Specific sections
```

This enables:
- Audit trail back to original research
- Context about which research findings led to this doc
- Verification of requirements origin

---

## Complete Example

```yaml
id: REQ-A7-T7
title: "Transaction & Balance Tracking"
status: active

created:
  date: "2026-01-14"
  by: "Mary (Analyst)"

updated:
  date: "2026-01-14"
  by: "Mary (Analyst)"

tags:
  - requirements
  - transaction-items
  - balance-tracking
  - credit-limit
  - audit-trail

summary: |
  Requirements for tracking transaction items and maintaining balance
  calculations. Covers credit limit enforcement, audit trail generation,
  and balance reconciliation rules.

source:
  research: A7
  sections: ["9", "9.1", "9.2", "9.3", "10", "10.1", "10.2", "10.3"]

metrics:
  total_requirements: 27
  must: 26
  should: 1
  could: 0

related:
  - id: DOC-INV-015
    type: depends-on
    why: "Source research document (A7 Cancel/Void Invoice)"
  - id: REQ-A5-T7
    type: references
    why: "Transaction item tracking from create process"
  - id: DOC-DATA-003
    type: depends-on
    why: "Data model for transaction and balance entities"

beads: "Invoice Module-31"
```

---

## Validation Rules

The `mlda-validate.ps1` script checks:

1. **Required fields present:** id, title, status, created, updated, tags
2. **ID format valid:** Matches `DOC-{DOMAIN}-{NNN}` or `{PREFIX}-{ID}` pattern
3. **Relationships valid:** All referenced DOC-IDs exist in registry
4. **Why field present:** Every relationship has a `why` explanation
5. **Type field valid:** If present, matches allowed types
6. **Status valid:** One of: active, draft, deprecated
7. **Deprecated has superseded_by:** If status is deprecated

---

## Migration Notes

For existing sidecars without `type` field:

```yaml
# Old format (still valid, type defaults to 'references')
related:
  - id: DOC-AUTH-001
    why: "Authentication requirements"

# New format (explicit type)
related:
  - id: DOC-AUTH-001
    type: depends-on
    why: "Authentication requirements"
```

**Backward compatibility:** Sidecars without `type` field are treated as `type: references` (weakest signal).

---

## Summary

The sidecar schema defines the dendrite structure that enables knowledge graph navigation. Key points:

- `related` field is the dendrite array
- `type` determines signal strength for navigation
- `why` explains relevance for agent decision-making
- `summary` enables quick context gathering
- Validation ensures graph integrity

---

*DOC-CORE-003 | MLDA Sidecar Schema | v1.0*
