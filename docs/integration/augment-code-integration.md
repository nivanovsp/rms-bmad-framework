# Augment Code Integration Guide

**Using Augment Code with MLDA Documentation**

This guide explains how to work with MLDA documentation when using Augment Code.

---

## Setup

Augment Code can work with MLDA documentation through its file reading capabilities. Add context awareness to your workspace.

### Workspace Configuration

Add these patterns to your Augment Code workspace settings for better MLDA awareness:

```json
{
  "context": {
    "include": [
      "docs/**/*.md",
      ".mlda/**/*.yaml",
      ".mlda/**/*.md"
    ],
    "priority": [
      "docs/handoff.md",
      ".mlda/registry.yaml"
    ]
  }
}
```

---

## Navigation Protocol

### Starting a Session

1. **Load project context** - Augment should index the docs/ and .mlda/ directories
2. **Read handoff first** - `docs/handoff.md` contains current phase and entry points
3. **Use registry for lookups** - `.mlda/registry.yaml` maps DOC-IDs to file paths

### Following Relationships

When you see a DOC-ID (e.g., `DOC-AUTH-001`):

1. **Query the registry** for the file path
2. **Read the document** and its sidecar (`.meta.yaml`)
3. **Follow relationships** based on type:
   - `depends-on` → Always read
   - `supersedes` → Follow to replacement
   - `extends` → Read if more detail needed
   - `references` → Skip unless specifically relevant

---

## Augment-Specific Tips

### Chat Commands

Use these patterns when chatting with Augment:

**To understand a module:**
```
Look up DOC-AUTH-001 in .mlda/registry.yaml and read the document.
Then read its .meta.yaml sidecar and follow any depends-on relationships.
Summarize what I need to know about authentication.
```

**To implement from a story:**
```
Read the story at docs/stories/1.1-user-login.md.
Find all DOC-ID references and gather context by reading those documents.
Focus on depends-on relationships - always follow those.
Then help me implement the story.
```

**To check current project phase:**
```
Read docs/handoff.md and tell me:
1. What phase is the project in?
2. Who did the last handoff?
3. What are the entry points for my work?
```

### Indexing Recommendations

Ensure Augment indexes these directories:
- `docs/` - All project documentation
- `.mlda/docs/` - MLDA-structured documents
- `.mlda/registry.yaml` - Document registry

### Context Window Optimization

MLDA documents are designed to be modular. If hitting context limits:
1. Start with just the story and its `depends-on` docs
2. Add `extends` documents only if needed
3. Skip `references` unless specifically relevant

---

## Example Workflow

**Task:** Implement password reset feature

**Step 1: Get context**
```
Read docs/handoff.md for entry points.
The handoff shows DOC-AUTH-004 (Password Reset) as entry point.
```

**Step 2: Navigate**
```
Look up DOC-AUTH-004 in .mlda/registry.yaml → docs/auth/password-reset.md
Read docs/auth/password-reset.md
Read docs/auth/password-reset.meta.yaml

Sidecar shows:
- depends-on: DOC-AUTH-001 (core auth flow)
- depends-on: DOC-API-002 (email service)
- extends: DOC-SEC-001 (security guidelines)
```

**Step 3: Gather required context**
```
Read DOC-AUTH-001 (required)
Read DOC-API-002 (required)
Optionally read DOC-SEC-001 for security guidance
```

**Step 4: Implement**
Now you have full context for password reset implementation.

---

## Registry Quick Reference

The registry structure:

```yaml
documents:
  - id: DOC-AUTH-001
    title: "Authentication Flow"
    path: docs/auth/auth-flow.md    # Path relative to .mlda/
    status: active
    relates_to:                      # Outgoing relationships
      - id: DOC-AUTH-002
        type: depends-on
    referenced_by:                   # Incoming relationships
      - id: DOC-API-001
        type: references
```

---

## Integration with Augment Features

### Code Actions
When Augment suggests code actions, ensure it has read relevant MLDA docs first.

### Chat References
Reference MLDA docs directly in chat:
```
@docs/auth/auth-flow.md explain this authentication approach
```

### Codebase Search
Use Augment's search to find DOC-IDs:
```
Search for "DOC-AUTH" to find all auth-related documentation references
```

---

*Augment Code Integration Guide v1.0*
