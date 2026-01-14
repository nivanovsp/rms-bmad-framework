# MLDA Usage Patterns

**DOC-CORE-004** | User guide on structuring documents for optimal agent navigation

---

## Overview

This guide explains how to structure your MLDA documents to enable effective agent navigation through the knowledge graph. Following these patterns ensures agents can discover context efficiently and make informed decisions.

---

## Core Principles

### 1. Documents Are Neurons, Not Monoliths

**Bad Pattern:**
```
project-overview.md (2000 lines covering everything)
```

**Good Pattern:**
```
project-brief.md          → High-level overview
api-design.md             → API specifications
auth-strategy.md          → Authentication approach
data-model.md             → Data structures
deployment-strategy.md    → Infrastructure decisions
```

**Why:** Smaller, focused documents allow agents to navigate precisely to needed information without processing irrelevant content.

### 2. Relationships Define the Signal Path

Every document should have explicit relationships in its `.meta.yaml` sidecar:

```yaml
related:
  - id: DOC-AUTH-001
    type: depends-on
    why: "Authentication patterns required for API security"
  - id: DOC-DATA-003
    type: references
    why: "Data model for request/response schemas"
```

**Key:** The `why` field is crucial - it helps agents decide whether to follow the relationship.

### 3. Stories Are Entry Points, Not Specs

Stories should reference DOC-IDs as entry points:

```markdown
## Documentation References (Entry Points)

**Primary Documents (must explore):**
- DOC-API-007: Core API endpoints for this feature
- REQ-A3-T2: User requirements being addressed

**Secondary Documents (explore if needed):**
- DOC-SEC-002: Security patterns if handling sensitive data
```

Agents will navigate from these entry points, following dendrites as needed.

---

## Document Organization Patterns

### Pattern 1: Domain Clustering

Organize documents by functional domain:

```
.mlda/docs/
├── api/
│   ├── endpoints.md
│   ├── authentication.md
│   └── versioning.md
├── data/
│   ├── user-model.md
│   ├── transaction-model.md
│   └── audit-trail.md
├── security/
│   ├── encryption.md
│   └── access-control.md
```

**Benefits:**
- Clear domain boundaries
- Intuitive DOC-ID prefixes (DOC-API-xxx, DOC-DATA-xxx)
- Agents can focus exploration within relevant domains

### Pattern 2: Hierarchical Depth

Structure documents with increasing specificity:

```
Level 1: project-brief.md          → Overview (entry point for new contexts)
Level 2: prd.md                    → Product requirements detail
Level 3: api-design.md             → Technical specifications
Level 4: api-endpoints-users.md    → Implementation details
```

**Benefits:**
- Agents can stop at appropriate depth
- High-level documents serve as navigation hubs
- Prevents over-exploration for simple queries

### Pattern 3: Cross-Domain Hubs

Create hub documents that connect multiple domains:

```yaml
# architecture.meta.yaml - Acts as a hub
related:
  - id: DOC-API-001
    type: references
    why: "API layer of architecture"
  - id: DOC-DATA-001
    type: references
    why: "Data layer of architecture"
  - id: DOC-SEC-001
    type: references
    why: "Security layer of architecture"
  - id: DOC-INFRA-001
    type: references
    why: "Infrastructure layer of architecture"
```

**Benefits:**
- Single entry point for broad context gathering
- Enables agents to quickly orient themselves
- Reduces navigation depth for cross-cutting concerns

---

## Relationship Types and When to Use Them

| Type | Signal Strength | When to Use | Agent Behavior |
|------|-----------------|-------------|----------------|
| `depends-on` | Strong | Document cannot be fully understood without the target | Agent will likely follow |
| `extends` | Medium | Document builds upon target concepts | Agent follows if exploring deeply |
| `references` | Weak | Document mentions target for context | Agent follows if specifically relevant |
| `supersedes` | Redirect | Target is outdated, this replaces it | Agent redirects to newer document |

### Examples

**depends-on** (Strong - Almost always follow):
```yaml
- id: DOC-AUTH-001
  type: depends-on
  why: "Must understand OAuth flow before implementing API auth"
```

**extends** (Medium - Follow for deep understanding):
```yaml
- id: DOC-API-001
  type: extends
  why: "Adds pagination to base API patterns"
```

**references** (Weak - Follow if specifically relevant):
```yaml
- id: DOC-DEPLOY-003
  type: references
  why: "Deployment notes mention this endpoint"
```

**supersedes** (Redirect - Follow to get current info):
```yaml
- id: DOC-AUTH-001-deprecated
  type: supersedes
  why: "OAuth2 replaces legacy session auth"
```

---

## Writing for Agent Navigation

### Include Clear Summaries

Every document should start with a summary that agents can use to decide relevance:

```markdown
# API Authentication

**DOC-API-002** | OAuth2 implementation for REST API

## Summary

This document defines the OAuth2 implementation for API authentication,
including token lifecycle, refresh mechanisms, and error handling.
Required for any endpoint requiring user authentication.

## Key Decisions

- Using authorization code flow with PKCE
- Tokens expire after 1 hour, refresh tokens after 30 days
- Rate limiting: 100 requests per minute per user
```

### Use Consistent Structure

Agents can navigate faster when documents follow consistent patterns:

```markdown
# [Title]

**[DOC-ID]** | [One-line description]

## Summary
[2-3 sentences on what this document covers]

## Key Decisions
[Bullet list of important decisions with rationale]

## [Domain-Specific Sections]
[Technical content organized by topic]

## Open Questions
[Unresolved items that may need future decisions]
```

### Embed DOC-IDs in Content

When referencing other documents inline, use DOC-IDs:

```markdown
The authentication flow follows the patterns defined in [DOC-AUTH-001].
Data models are based on the user schema from [DOC-DATA-002].
```

This allows agents to recognize and potentially navigate to related documents.

---

## Anti-Patterns to Avoid

### 1. Orphan Documents

Documents with no relationships become invisible to navigation:

```yaml
# BAD - No relationships
related: []
```

**Fix:** Always add at least one relationship to the document hierarchy.

### 2. Circular Dependencies Without Purpose

```yaml
# doc-a.meta.yaml
related:
  - id: DOC-B
    type: depends-on

# doc-b.meta.yaml
related:
  - id: DOC-A
    type: depends-on
```

**Fix:** Use appropriate relationship types. If A extends B, the relationship is one-directional.

### 3. Missing "Why" Fields

```yaml
# BAD
related:
  - id: DOC-AUTH-001
    type: references
```

**Fix:** Always include a `why` to help agents decide relevance:

```yaml
# GOOD
related:
  - id: DOC-AUTH-001
    type: references
    why: "Auth error codes referenced in error handling section"
```

### 4. Over-Linking

Every document linking to every other document creates noise:

```yaml
# BAD - Everything links to everything
related:
  - id: DOC-A
  - id: DOC-B
  - id: DOC-C
  - id: DOC-D
  - id: DOC-E
  # ... 20 more
```

**Fix:** Only link to documents with meaningful relationships. Use hubs for broad connections.

### 5. Stale Relationships

Links to moved, renamed, or deleted documents break navigation:

**Fix:** Run `mlda-validate.ps1` regularly to detect broken links.

---

## Optimizing for Different Agent Types

### Developer Agent

Developers need implementation details quickly:

- Link directly to API specs, data models, code examples
- Include "Dev Notes" sections with practical guidance
- Reference specific file paths and function names

### QA Agent

QA needs requirement traceability:

- Link to requirements documents (REQ-xxx)
- Include test expectations in summaries
- Document edge cases and error scenarios

### Architect Agent

Architects need broad system understanding:

- Create architectural overview hub documents
- Link to cross-cutting concerns (security, performance, scalability)
- Document decision rationale with ADR patterns

### Analyst Agent

Analysts need research context:

- Link to source research, market analysis
- Include elicitation history and stakeholder decisions
- Reference business constraints and drivers

---

## Maintenance Best Practices

### Regular Validation

```powershell
# Weekly: Check for broken links
.\.mlda\scripts\mlda-validate.ps1

# After major changes: Rebuild registry
.\.mlda\scripts\mlda-registry.ps1

# Visualize graph health
.\.mlda\scripts\mlda-graph.ps1 -Output both
```

### Graph Health Indicators

| Indicator | Healthy | Warning |
|-----------|---------|---------|
| Orphan documents | 0-2 | 5+ |
| Max hub connections | 10-15 | 25+ |
| Average depth | 2-4 | 6+ |
| Broken links | 0 | Any |

### Pruning Old Documents

When documents become obsolete:

1. Create new document with `supersedes` relationship
2. Update old document status to `deprecated`
3. Run registry rebuild
4. Consider archiving after migration period

---

## Quick Reference Card

### Document Creation Checklist

- [ ] Focused on single topic
- [ ] DOC-ID assigned from appropriate domain
- [ ] `.meta.yaml` sidecar created
- [ ] Summary and key decisions included
- [ ] Relationships added with `why` fields
- [ ] Added to registry

### Relationship Decision Tree

```
Is target document required to understand this one?
├── Yes → depends-on
└── No
    ├── Does this extend/build on target? → extends
    ├── Is target outdated? → supersedes
    └── Just mentioned for context? → references
```

### Navigation Commands

```
*explore DOC-XXX-NNN [--depth N]  # Navigate from entry point
*related                          # Show current doc relationships
*context                          # Gather context for current task
```

---

*DOC-CORE-004 | MLDA Usage Patterns v1.0*
