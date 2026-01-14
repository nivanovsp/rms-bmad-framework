# MLDA Navigation Protocol

**DOC-CORE-002** | Agent Traversal Rules

---

## Purpose

This document defines how agents navigate the MLDA knowledge graph. It specifies entry points, traversal strategies, depth limits, termination conditions, and reporting requirements.

---

## Navigation Lifecycle

```
┌─────────────────┐
│ 1. INITIALIZE   │  Read registry, understand graph structure
└────────┬────────┘
         ▼
┌─────────────────┐
│ 2. IDENTIFY     │  Find entry points from task/story
│    ENTRY POINTS │
└────────┬────────┘
         ▼
┌─────────────────┐
│ 3. TRAVERSE     │  Follow dendrites, gather context
└────────┬────────┘
         ▼
┌─────────────────┐
│ 4. TERMINATE    │  Stop when conditions met
└────────┬────────┘
         ▼
┌─────────────────┐
│ 5. REPORT       │  Document navigation path
└─────────────────┘
```

---

## Phase 1: Initialize

### On Agent Activation

When an agent activates (enters a mode), it MUST:

1. **Check for MLDA presence**
   ```
   IF .mlda/ folder exists:
     → MLDA is active
     → Read registry.yaml
   ELSE:
     → Standard mode (no graph navigation)
   ```

2. **Load registry into context**
   - Document count and domains
   - High-connectivity nodes (documents with many relationships)
   - Recent documents (last modified)

3. **Announce MLDA status**
   ```
   "MLDA active: {N} documents across {domains}.
    Knowledge graph navigation enabled."
   ```

---

## Phase 2: Identify Entry Points

### Entry Point Sources

| Source | How to Extract | Priority |
|--------|----------------|----------|
| Story/Epic | DOC-IDs in references section | Highest |
| User request | DOC-IDs mentioned explicitly | High |
| Task context | Keywords matched to registry tags | Medium |
| Domain inference | Task type → likely domains | Low |

### Entry Point Validation

Before traversing, verify entry points exist:

```
FOR each entry_point:
  IF exists in registry:
    → Add to traversal queue
  ELSE:
    → Warn user: "DOC-ID {X} not found in registry"
```

---

## Phase 3: Traverse

### Traversal Algorithm

```
FUNCTION traverse(entry_points, task_context, max_depth):
  visited = []
  queue = entry_points
  context_gathered = []

  WHILE queue NOT empty AND depth < max_depth:
    current = queue.pop()

    IF current IN visited:
      CONTINUE  // Avoid cycles

    visited.add(current)
    doc = read_document(current)
    sidecar = read_sidecar(current)
    context_gathered.add(doc.summary)

    FOR each relationship IN sidecar.related:
      IF should_follow(relationship, task_context):
        queue.add(relationship.id)

  RETURN context_gathered, visited
```

### Decision: Should Follow?

Evaluate each dendrite before following:

```
FUNCTION should_follow(relationship, task_context):
  // Always follow dependencies
  IF relationship.type == "depends-on":
    RETURN true

  // Check relevance via 'why' field
  IF relationship.why MATCHES task_context.keywords:
    RETURN true

  // Check relationship type priority
  IF relationship.type == "extends" AND depth < max_depth - 1:
    RETURN true

  // References are optional - follow if highly relevant
  IF relationship.type == "references":
    RETURN relevance_score(relationship.why, task_context) > 0.7

  // Supersedes: follow the new, skip the old
  IF relationship.type == "supersedes":
    RETURN true  // And mark target as "do not follow"

  RETURN false
```

### Depth Limits

| Agent Type | Default Max Depth | Rationale |
|------------|-------------------|-----------|
| Developer | 3 | Focused on immediate requirements |
| Architect | 5 | Needs broader system understanding |
| Analyst | 4 | Balance of depth and breadth |
| QA | 4 | Needs to understand test surface |
| PO | 3 | Focused on requirements, not deep tech |

Depth can be overridden per-task with `*explore --depth N`.

### Breadth Limits

To prevent explosion in highly connected graphs:

- **Max siblings per node:** 5 (follow top 5 by relevance)
- **Max total documents:** 20 per navigation session
- **Override:** `*explore --max-docs N`

---

## Phase 4: Terminate

### Termination Conditions

Navigation stops when ANY condition is met:

| Condition | Description |
|-----------|-------------|
| **Sufficient context** | Agent determines enough information gathered |
| **Max depth reached** | Configured depth limit hit |
| **Max documents reached** | Breadth limit hit |
| **No relevant dendrites** | All remaining relationships are low-relevance |
| **Cycle detected** | Would revisit already-processed document |
| **User interrupt** | User says "stop exploring" or similar |

### Sufficiency Heuristics

Agent determines "sufficient context" when:

1. All entry point documents have been read
2. All `depends-on` relationships have been followed
3. Task keywords are covered by gathered context
4. No critical gaps identified

---

## Phase 5: Report

### Navigation Summary

After traversal, agent MUST report:

```
Navigation complete:
- Entry points: DOC-INV-015, REQ-A7-T7
- Documents explored: 8
- Path: DOC-INV-015 → REQ-A7-T7 → REQ-A5-T7 → DOC-DATA-003 → ...
- Depth reached: 3
- Termination: Sufficient context gathered

Key context gathered:
- Transaction tracking requirements (REQ-A7-T7)
- Data model for transactions (DOC-DATA-003)
- API contract (DOC-API-007)
```

### Context Handoff

The gathered context is retained for the session:

- Summaries from each visited document
- Key decisions and constraints found
- Open questions identified
- Related documents NOT visited (for potential later exploration)

---

## Navigation Commands

Agents expose these commands for user-controlled navigation:

| Command | Description | Example |
|---------|-------------|---------|
| `*explore {DOC-ID}` | Start navigation from specific document | `*explore DOC-API-001` |
| `*explore --entry {IDs}` | Multiple entry points | `*explore --entry DOC-API-001,DOC-AUTH-002` |
| `*explore --depth N` | Override depth limit | `*explore DOC-API-001 --depth 5` |
| `*related` | Show related docs for current context | `*related` |
| `*context` | Show gathered context summary | `*context` |
| `*graph` | Visualize local graph around current docs | `*graph` |

---

## Error Handling

| Situation | Response |
|-----------|----------|
| DOC-ID not found | Warn user, continue with other entry points |
| Sidecar missing | Read document without relationships, warn |
| Registry outdated | Suggest running `mlda-registry.ps1` |
| Circular dependency | Log cycle, skip revisit, continue |
| Permission denied | Report inaccessible document, continue |

---

## Performance Considerations

### Caching

- Cache registry in memory for session duration
- Cache document summaries (first paragraph or `summary` from sidecar)
- Don't re-read documents already in visited set

### Lazy Loading

- Read full document content only when needed
- For relationship decisions, sidecar `why` field is usually sufficient
- Load full content when agent needs to extract specific information

---

## Integration with Agent Activation

### Activation Sequence Update

```yaml
activation-instructions:
  - STEP 1: Read agent configuration
  - STEP 2: Adopt persona
  - STEP 3: Load core-config.yaml
  - STEP 4: Check for .mlda/ folder              # NEW
  - STEP 5: If MLDA present, read registry.yaml  # NEW
  - STEP 6: Greet user, run *help
  - STEP 7: Await instructions
```

### Story/Task Reception

When receiving a story or task:

```
1. Parse for DOC-ID references
2. If found, auto-navigate from those entry points
3. Present gathered context to user
4. Confirm understanding before proceeding
```

---

## Summary

The navigation protocol transforms agents from passive document readers into active knowledge explorers. By following dendrites through the knowledge graph, agents gather the context they need to perform their tasks effectively.

Key rules:
- Always check for MLDA on activation
- Respect depth and breadth limits
- Follow `depends-on` relationships always
- Use `why` field to evaluate relevance
- Report navigation path to user
- Cache for performance

---

*DOC-CORE-002 | MLDA Navigation Protocol | v1.0*
