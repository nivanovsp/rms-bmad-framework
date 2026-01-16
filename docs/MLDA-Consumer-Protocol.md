# MLDA Consumer Protocol

**For External Agents Working with RMS-BMAD Documentation**

This document explains how any AI agent (Claude Code, Augment Code, Gemini, etc.) can effectively consume and navigate MLDA documentation without installing the full RMS-BMAD methodology.

---

## What is MLDA?

**MLDA (Modular Linked Documentation Architecture)** models project documentation as a **knowledge graph** using the neocortex paradigm:

| Brain Concept | MLDA Equivalent | Description |
|---------------|-----------------|-------------|
| **Neuron** | Document (.md file) | A single unit of knowledge |
| **Dendrites** | Relationships | Connections to other documents |
| **Axon** | DOC-ID | Unique identifier enabling connections |
| **Signal** | Agent reading | Activation triggers exploration |
| **Signal Propagation** | Following relationships | Agent traversing the graph |

**Key Principle:** Stories and tasks are **entry points** into the knowledge graph, not self-contained specifications. You must navigate the graph to gather full context.

---

## Quick Start for External Agents

### 1. Find Entry Points

Start with one of these entry points:
- **Handoff Document**: `docs/handoff.md` - Contains phase context and entry points
- **Story File**: Look for stories in `docs/stories/` with DOC-ID references
- **Registry**: `.mlda/registry.yaml` - Index of all documents

### 2. Parse DOC-IDs

DOC-IDs follow the format: `DOC-{DOMAIN}-{NNN}`

Examples:
- `DOC-AUTH-001` - Authentication document #1
- `DOC-API-003` - API document #3
- `DOC-DATA-002` - Data model document #2

### 3. Navigate the Graph

When you see a DOC-ID reference:
1. Look up the path in `.mlda/registry.yaml`
2. Read the document
3. Check its sidecar (`.meta.yaml`) for relationships
4. Follow relationships based on signal strength

---

## Understanding Relationship Types

Each document has a sidecar file (`{filename}.meta.yaml`) defining relationships:

```yaml
# Example: auth-flow.meta.yaml
id: DOC-AUTH-001
title: Authentication Flow
status: active

related:
  - id: DOC-AUTH-002
    type: depends-on
    why: "Session management is required for auth"
  - id: DOC-API-001
    type: references
    why: "Auth uses API endpoints"
```

### Signal Strength (When to Follow)

| Type | Signal | When to Follow |
|------|--------|----------------|
| `depends-on` | **Strong** | **ALWAYS** - Cannot understand without this |
| `supersedes` | **Redirect** | **ALWAYS** - This replaces the target |
| `extends` | **Medium** | Follow if you need more detail |
| `references` | **Weak** | Follow only if relevant to your task |

---

## Navigation Algorithm

```
function gatherContext(entry_doc_id, max_depth=3):
    context = []
    visited = set()
    queue = [(entry_doc_id, 0)]

    while queue:
        doc_id, depth = queue.pop(0)

        if doc_id in visited or depth > max_depth:
            continue

        visited.add(doc_id)
        doc = readDocument(doc_id)
        context.append(doc)

        for relationship in doc.sidecar.related:
            if relationship.type == "depends-on":
                # ALWAYS follow depends-on
                queue.append((relationship.id, depth + 1))
            elif relationship.type == "supersedes":
                # REDIRECT - follow this instead
                queue.append((relationship.id, depth))  # Same depth
            elif relationship.type == "extends" and depth < max_depth - 1:
                # Follow if depth allows
                queue.append((relationship.id, depth + 1))
            # Skip "references" unless specifically needed

    return context
```

---

## Working with the Registry

The registry (`.mlda/registry.yaml`) provides:

```yaml
# Registry structure
graph:
  total_documents: 45
  orphan_documents: 2

# Document index
documents:
  - id: DOC-AUTH-001
    title: "Authentication Flow"
    path: docs/auth-flow.md
    status: active
    relates_to:
      - id: DOC-AUTH-002
        type: depends-on
    referenced_by:
      - id: DOC-API-001
        type: references
```

### Registry Queries

**Find document path:**
```
doc = registry.documents.find(d => d.id == "DOC-AUTH-001")
path = doc.path  // "docs/auth-flow.md"
```

**Find what depends on a document:**
```
doc = registry.documents.find(d => d.id == "DOC-AUTH-001")
dependents = doc.referenced_by.filter(r => r.type == "depended-by")
```

---

## Practical Examples

### Example 1: Implementing a Story

Given story with:
```markdown
## Documentation References
- DOC-AUTH-001: Authentication Flow (depends-on)
- DOC-API-003: User Endpoints (extends)
```

**Steps:**
1. Read DOC-AUTH-001 (required context)
2. Read its `depends-on` relationships
3. Read DOC-API-003 if more detail needed
4. Proceed with implementation

### Example 2: Understanding a Module

Starting from `DOC-DATA-001`:
```
DOC-DATA-001 (Database Schema)
  └── depends-on: DOC-DATA-002 (Entity Relationships)
      └── depends-on: DOC-AUTH-001 (User entity)
  └── extends: DOC-DATA-003 (Migration Guide)
```

**Steps:**
1. Read DOC-DATA-001
2. Follow depends-on to DOC-DATA-002
3. Follow that depends-on to DOC-AUTH-001
4. Optionally read DOC-DATA-003 for migration details

---

## Handoff Document Structure

The handoff document (`docs/handoff.md`) tracks phase transitions:

```markdown
# Project Handoff Document

**Current Phase:** Architect | Developer+QA
**Last Handoff By:** Maya (Analyst) | Winston (Architect)

## Phase History

### Phase 1: Analyst Discovery
#### Entry Points for Next Phase
| Priority | DOC-ID | Title | Why Start Here |
|----------|--------|-------|----------------|
| 1 | DOC-AUTH-001 | Auth Flow | Core functionality |

#### Open Questions for Architect
1. **Question** - Context and options
```

**Use the Entry Points table** to know where to start reading.

---

## Best Practices for External Agents

### DO:
- Start from handoff document or story file
- Follow `depends-on` relationships always
- Check `supersedes` - don't read outdated docs
- Use the registry for quick lookups
- Read sidecars to understand relationships

### DON'T:
- Read documents in isolation (they're part of a graph)
- Ignore relationships (you'll miss context)
- Follow every `references` link (too much noise)
- Assume a story contains all needed information

### Context Depth Guidelines:

| Task Type | Recommended Depth |
|-----------|-------------------|
| Quick fix | 1-2 levels |
| Feature implementation | 2-3 levels |
| Architecture review | 3-4 levels |
| Full understanding | No limit |

---

## Troubleshooting

### "I can't find a document"
1. Check registry: `.mlda/registry.yaml`
2. Verify DOC-ID format is correct
3. Document may have been superseded - check for `superseded-by`

### "Relationships seem circular"
- `depends-on` should never be circular
- `references` can be bidirectional (that's OK)
- If you find circular depends-on, report it

### "Document seems outdated"
- Check `status` in sidecar
- Look for `superseded-by` relationships
- Check handoff document for latest phase

---

## Integration Templates

For specific agent integrations, see:
- `docs/integration/claude-code-integration.md`
- `docs/integration/augment-code-integration.md`
- `docs/integration/generic-agent-integration.md`

---

*MLDA Consumer Protocol v1.0 | For use with RMS-BMAD methodology*
