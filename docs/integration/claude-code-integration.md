# Claude Code Integration Guide

**Using Claude Code (standalone) with MLDA Documentation**

This guide explains how to work with MLDA documentation when using Claude Code without the full RMS-BMAD methodology installed.

---

## Setup

No installation required. Claude Code can work with MLDA documentation directly by following the navigation protocol.

### Recommended Workflow

1. **Start each session** by reading the handoff document:
   ```
   Read docs/handoff.md
   ```

2. **For implementation tasks**, identify DOC-IDs from your story and navigate:
   ```
   Read .mlda/registry.yaml to find document paths
   Read each depends-on document
   ```

---

## Navigation Commands (Manual)

Since you don't have RMS-BMAD skills, perform navigation manually:

### Find a Document by DOC-ID

```
# Step 1: Look up in registry
Read .mlda/registry.yaml

# Find entry like:
#   - id: DOC-AUTH-001
#     path: docs/auth/auth-flow.md

# Step 2: Read the document
Read docs/auth/auth-flow.md

# Step 3: Read its sidecar for relationships
Read docs/auth/auth-flow.meta.yaml
```

### Gather Context for Implementation

```
# Given a story with DOC-IDs:
# - DOC-AUTH-001 (depends-on)
# - DOC-API-003 (extends)

# Read each document and follow depends-on chains:
Read docs/auth/auth-flow.md
Read docs/auth/auth-flow.meta.yaml
# Follow any depends-on relationships found

Read docs/api/user-endpoints.md  # Only if more detail needed
```

---

## Practical Example

**Task:** Implement user authentication

**Step 1: Read handoff**
```
Read docs/handoff.md
```
Look for "Entry Points" section, find relevant DOC-IDs.

**Step 2: Navigate from entry point**
```
# From handoff, you see: DOC-AUTH-001 is entry point
# Look up in registry
Read .mlda/registry.yaml

# Read the document
Read docs/auth/auth-flow.md

# Read relationships
Read docs/auth/auth-flow.meta.yaml
# Found: depends-on DOC-AUTH-002 (session management)

# Follow the dependency
Read docs/auth/session-management.md
```

**Step 3: Implement with context**
Now you have the full context to implement correctly.

---

## Tips for Claude Code Users

### Session Start Prompt

Add this to your session when working with MLDA projects:

```
This project uses MLDA (Modular Linked Documentation Architecture).

When I give you a task:
1. First read docs/handoff.md to understand current project phase
2. Identify DOC-IDs relevant to the task
3. Look up document paths in .mlda/registry.yaml
4. Read documents and their .meta.yaml sidecars
5. Follow "depends-on" relationships to gather full context
6. Only then proceed with implementation

Relationship types:
- depends-on: ALWAYS read (required context)
- supersedes: Follow this, ignore the target
- extends: Read if more detail needed
- references: Read only if relevant
```

### Useful Glob Patterns

```bash
# Find all MLDA documents
docs/**/*.md

# Find all sidecars
.mlda/docs/**/*.meta.yaml

# Find story files
docs/stories/*.md
```

### Registry Quick Reference

The registry at `.mlda/registry.yaml` contains:
- `documents[].id` - DOC-ID
- `documents[].path` - File path relative to .mlda/
- `documents[].relates_to[]` - Outgoing relationships
- `documents[].referenced_by[]` - Incoming relationships (reverse lookup)

---

## Common Patterns

### "I need to understand the auth system"
```
1. Read .mlda/registry.yaml
2. Find documents with domain "AUTH"
3. Start with the one that has most "referenced_by" (it's the hub)
4. Follow its depends-on chain
```

### "I need to implement a specific story"
```
1. Read the story file
2. Find "Documentation References" section
3. Read each DOC-ID marked "depends-on"
4. Follow their depends-on chains
5. Implement
```

### "I'm not sure where to start"
```
1. Read docs/handoff.md
2. Look at "Entry Points for Next Phase"
3. Start with Priority 1 entry point
```

---

## Limitations Without RMS-BMAD

Without the full methodology, you won't have:
- Automated navigation commands (`*explore`, `*related`)
- Automatic context gathering
- Phase-aware workflows
- Handoff document auto-generation

**Workaround:** Follow the manual navigation steps above. The documentation structure works the same way - you just navigate it manually.

---

*Claude Code Integration Guide v1.0*
