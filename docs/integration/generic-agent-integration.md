# Generic Agent Integration Guide

**Working with MLDA Documentation from Any AI Agent**

This guide provides a universal protocol for any AI agent to consume MLDA documentation effectively.

---

## Core Concepts

### Document Structure

```
project/
├── docs/
│   ├── handoff.md              # Phase handoff document (START HERE)
│   └── stories/                # Story files with DOC-ID references
├── .mlda/
│   ├── registry.yaml           # Document index (DOC-ID → path mapping)
│   └── docs/
│       └── domain/
│           ├── document.md      # Content
│           └── document.meta.yaml  # Relationships (sidecar)
```

### DOC-ID Format

```
DOC-{DOMAIN}-{NNN}

Examples:
- DOC-AUTH-001  (Authentication domain, document 1)
- DOC-API-003   (API domain, document 3)
- DOC-DATA-002  (Data domain, document 2)
```

### Relationship Types

| Type | Signal Strength | Action |
|------|-----------------|--------|
| `depends-on` | Strong | **ALWAYS** follow |
| `supersedes` | Redirect | **ALWAYS** follow (this replaces target) |
| `extends` | Medium | Follow if more detail needed |
| `references` | Weak | Follow only if directly relevant |

---

## Protocol Steps

### Step 1: Initialize

```pseudo
function initialize():
    # Read handoff for current project state
    handoff = read("docs/handoff.md")
    current_phase = extract_phase(handoff)
    entry_points = extract_entry_points(handoff)

    # Load registry for document lookups
    registry = parse_yaml(".mlda/registry.yaml")

    return {handoff, registry, entry_points}
```

### Step 2: Resolve DOC-ID to Path

```pseudo
function resolve_doc_id(registry, doc_id):
    for doc in registry.documents:
        if doc.id == doc_id:
            return doc.path  # Path relative to .mlda/
    return null  # Not found
```

### Step 3: Read Document with Sidecar

```pseudo
function read_document(doc_id):
    path = resolve_doc_id(registry, doc_id)
    if not path:
        return null

    # Content is in the .md file
    content = read(".mlda/" + path)

    # Relationships are in the .meta.yaml sidecar
    sidecar_path = path.replace(".md", ".meta.yaml")
    sidecar = parse_yaml(".mlda/" + sidecar_path)

    return {content, sidecar}
```

### Step 4: Navigate Graph

```pseudo
function gather_context(entry_doc_id, max_depth=3):
    visited = set()
    context = []
    queue = [(entry_doc_id, 0)]  # (doc_id, depth)

    while queue not empty:
        (doc_id, depth) = queue.pop_front()

        if doc_id in visited or depth > max_depth:
            continue

        visited.add(doc_id)
        doc = read_document(doc_id)

        if doc is null:
            continue

        context.append(doc)

        # Process relationships
        for rel in doc.sidecar.related:
            if rel.type == "depends-on":
                # ALWAYS follow
                queue.append((rel.id, depth + 1))

            elif rel.type == "supersedes":
                # REDIRECT - same depth (replacement)
                queue.append((rel.id, depth))

            elif rel.type == "extends" and depth < max_depth - 1:
                # Follow if depth allows
                queue.append((rel.id, depth + 1))

            # Skip "references" by default

    return context
```

---

## Implementation Template

### For Story Implementation

```pseudo
function implement_story(story_path):
    # 1. Read the story
    story = read(story_path)

    # 2. Extract DOC-ID references
    doc_refs = extract_doc_references(story)

    # 3. Gather context from each reference
    full_context = []
    for ref in doc_refs:
        if ref.type == "depends-on":
            context = gather_context(ref.id, max_depth=3)
            full_context.extend(context)

    # 4. Now implement with full context
    return full_context
```

### For Architecture Review

```pseudo
function review_architecture(entry_point):
    # Use deeper traversal for architecture review
    context = gather_context(entry_point, max_depth=5)

    # Include referenced documents too
    for doc in context:
        for rel in doc.sidecar.related:
            if rel.type == "references":
                ref_doc = read_document(rel.id)
                if ref_doc not in context:
                    context.append(ref_doc)

    return context
```

---

## Sidecar Schema

```yaml
# document.meta.yaml
id: DOC-AUTH-001
title: "Authentication Flow"
status: active | draft | deprecated | superseded

created:
  date: "2026-01-15"
  by: "Maya (Analyst)"

related:
  - id: DOC-AUTH-002
    type: depends-on | extends | references | supersedes
    why: "Explanation of relationship"

tags:
  - authentication
  - security

summary: "Brief description of document content"
```

---

## Registry Schema

```yaml
# .mlda/registry.yaml
last_updated: "2026-01-15"

graph:
  total_documents: 45
  orphan_documents: 2

documents:
  - id: DOC-AUTH-001
    title: "Authentication Flow"
    path: docs/auth/auth-flow.md
    status: active
    tags: [authentication, security]
    relates_to:
      - id: DOC-AUTH-002
        type: depends-on
    referenced_by:
      - id: DOC-API-001
        type: references
```

---

## Error Handling

```pseudo
function handle_navigation_errors():
    # Document not found
    if resolve_doc_id returns null:
        log("Warning: DOC-ID not found in registry")
        # May have been deleted or renamed

    # Circular dependency detection
    if doc_id already in visited at same depth:
        log("Error: Circular depends-on detected")
        # This is a graph integrity issue - report it

    # Missing sidecar
    if sidecar file not found:
        log("Warning: No sidecar for document")
        # Treat as orphan document
```

---

## Best Practices

### DO:
- Always start from handoff document or story
- Always follow `depends-on` relationships
- Check `supersedes` to avoid reading outdated docs
- Use the registry for efficient lookups
- Respect the signal strength hierarchy

### DON'T:
- Read documents in isolation
- Ignore relationships
- Follow every `references` link (noise)
- Assume stories are self-contained
- Skip the handoff document

### Depth Guidelines:

| Task | Recommended Depth |
|------|-------------------|
| Bug fix | 1-2 |
| Feature implementation | 2-3 |
| Module understanding | 3-4 |
| Full architecture review | No limit |

---

*Generic Agent Integration Guide v1.0*
