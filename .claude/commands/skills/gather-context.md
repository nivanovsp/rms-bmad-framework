---
description: 'Gather context from MLDA knowledge graph before starting work'
---
# Gather Context Skill

**RMS Skill** | Standard workflow for agents to gather context from MLDA before work

This skill defines the standard context-gathering workflow that agents should follow before starting implementation, review, or other substantive work. It leverages the MLDA neocortex model to navigate the knowledge graph.

## When to Use

Use this workflow when:
- Starting work on a story or task with DOC-ID references
- Beginning a review that requires understanding requirements context
- Needing to understand how a feature fits into the broader system
- Exploring documentation before creating new content

## Prerequisites

- MLDA must be initialized (`.mlda/` folder exists)
- Registry must be current (`mlda-registry.ps1` has been run)
- Story/task should contain DOC-ID references as entry points

---

## Workflow Steps

### Phase 1: Identify Entry Points

```
1. Check if current task/story has DOC-ID references
   - Look for patterns: DOC-XXX-NNN, REQ-XXX-NNN
   - Check "Documentation References" section if present

2. If no DOC-IDs found:
   - Ask user for relevant DOC-IDs
   - OR search registry by tags/keywords
   - OR browse domains: *related --domains

3. Validate entry points exist in registry
```

### Phase 2: Navigate Knowledge Graph

```
1. Start navigation from primary entry points:
   *explore {DOC-ID} --depth 3

2. For each document visited:
   - Read summary/key points
   - Note decisions and constraints
   - Identify critical depends-on relationships

3. Follow dendrites based on task type:
   - Developer: Focus on API, DATA, implementation details
   - QA: Follow requirements → test documentation path
   - Architect: Broader exploration (depth 5)

4. Track visited documents and gathered context
```

### Phase 3: Synthesize Context

```
1. Summarize key information gathered:
   - Requirements and constraints
   - Technical decisions made
   - API contracts and data models
   - Testing expectations

2. Identify gaps:
   - Missing information for task completion
   - Documents that should exist but don't
   - Unclear relationships or decisions

3. Note open questions for user clarification
```

### Phase 4: Confirm Understanding

```
1. Present context summary to user:
   "Based on my navigation of the knowledge graph, here's what I understand:
   - [Key requirement 1]
   - [Technical constraint 1]
   - [Decision that affects this work]

   Documents explored: {list}
   Relationships followed: {count}

   Should I explore any area deeper before proceeding?"

2. Address any clarifying questions

3. Proceed with work once context is confirmed
```

---

## Context Summary Template

After navigation, present context in this format:

```markdown
## Context Gathered

**Entry Points:** DOC-API-001, REQ-A7-T7
**Documents Explored:** 8
**Depth Reached:** 3

### Key Requirements
- [Requirement 1 from REQ-XXX]
- [Requirement 2 from REQ-XXX]

### Technical Constraints
- [Constraint from architecture doc]
- [Pattern to follow from DOC-XXX]

### Relevant Decisions
- [Decision from DOC-XXX: reason and date]
- [Decision from DOC-XXX: reason and date]

### API/Data Context
- [Endpoint or model relevant to task]
- [Data validation rules]

### Testing Requirements
- [Test pattern from DOC-TEST-XXX]
- [Coverage expectations]

### Open Questions
- [Question needing clarification]

---
Ready to proceed with: [task description]
```

---

## Depth Guidelines by Agent Type

| Agent | Default Depth | Rationale |
|-------|---------------|-----------|
| Developer | 3 | Focused on immediate implementation needs |
| QA | 4 | Needs to understand full test surface |
| Architect | 5 | Requires broader system understanding |
| Analyst | 4 | Broad research context |
| PO/PM | 3 | Requirements-focused |
| SM | 3 | Story-scoped context |

---

## Error Handling

| Situation | Action |
|-----------|--------|
| No MLDA folder | Inform user, suggest `*init-project` |
| Entry point not found | Search registry for similar, suggest alternatives |
| Broken relationship | Log warning, continue with available paths |
| Insufficient context | Report gaps, ask user for additional entry points |
| Registry outdated | Suggest running `mlda-registry.ps1` |

---

## Integration with Agent Activation

When agents activate in MLDA-enabled projects:

1. **Auto-detect MLDA:** Check for `.mlda/` folder
2. **Load registry:** Read `registry.yaml` for graph overview
3. **Report status:** "MLDA active: N documents, ready for navigation"
4. **On task receipt:** Auto-run gather-context if DOC-IDs present

---

## Commands

This skill can be invoked via:
- `/skills:gather-context`
- `*gather-context` (when in agent mode)
- Automatically triggered when story with DOC-IDs is loaded

---

## Example Session

```
User: Implement story 3.2 (transaction tracking)

Agent: I see this story references:
- REQ-A7-T7 (Transaction & Balance Tracking)
- DOC-DATA-003 (Transaction Data Model)

Let me gather context from the knowledge graph...

*explore REQ-A7-T7 --depth 3

Navigation complete:
- Entry: REQ-A7-T7
- Followed: REQ-A5-T7 (transaction items), DOC-INV-015 (source research)
- DOC-DATA-003 → DOC-SEC-002 (data security)
- 6 documents explored, depth 3 reached

## Context Gathered

**Key Requirements:**
- 27 requirements for transaction tracking (26 MUST, 1 SHOULD)
- Balance calculations must be atomic
- Audit trail required for all balance changes

**Technical Constraints:**
- Use existing transaction item model from DOC-DATA-003
- Follow soft-delete pattern from architecture decisions

**Ready to proceed?**

User: Yes, go ahead

Agent: [Proceeds with implementation with full context]
```

---

*gather-context v1.0 | MLDA Neocortex Workflow*
