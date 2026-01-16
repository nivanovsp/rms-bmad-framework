---
description: 'Critical review of analyst documentation for technical accuracy'
---
# Review Docs Skill

**RMS Skill** | Discrete workflow for architectural review of analyst documentation

Perform critical review of analyst documentation to ensure technical accuracy before development begins.

## Purpose

The architect MUST critically review analyst documentation, not accept it at face value. This skill provides a structured workflow for:
1. Identifying technical inaccuracies
2. Finding monolithic designs that should be modular
3. Validating MLDA structure and relationships
4. Ensuring documentation is correct for agent consumption

## Prerequisites

- MLDA must be initialized (`.mlda/` folder exists)
- Handoff document exists (`docs/handoff.md`) with analyst phase completed
- Registry is current (`.mlda/registry.yaml`)

## Workflow

### Step 1: Read Handoff Document

**START HERE** - Read `docs/handoff.md` to understand:
- What the analyst created
- Entry points for review
- Open questions requiring architectural input
- Key decisions already made

### Step 2: Navigate Knowledge Graph

Starting from entry points in the handoff:

1. Run `*explore {DOC-ID}` for each entry point
2. Follow `depends-on` relationships (strong signal)
3. Note any broken or missing relationships
4. Build mental model of the documentation structure

### Step 3: Critical Review Protocol

For EACH document, evaluate:

| Review Aspect | Questions to Ask |
|---------------|------------------|
| **Technical Feasibility** | Can this be implemented as described? What's missing? |
| **Modularity** | Should this be one system or multiple modules? |
| **Scalability** | Will this design scale? What are the limits? |
| **Security** | Are there security implications not addressed? |
| **Integration** | How does this connect to other systems? |
| **Dependencies** | Are all dependencies identified? |

### Step 4: Document Findings

Create a review findings section in the handoff document:

```markdown
## Architect Review Findings

### Documents Reviewed
| DOC-ID | Title | Status | Issues Found |
|--------|-------|--------|--------------|
| DOC-XXX-001 | ... | APPROVED | None |
| DOC-XXX-002 | ... | NEEDS CHANGES | 2 issues |
| DOC-XXX-003 | ... | SPLIT REQUIRED | Monolithic design |

### Critical Issues

#### Issue 1: [Title]
- **Document:** DOC-XXX-002
- **Finding:** [What's wrong]
- **Impact:** [Why it matters]
- **Recommendation:** [What to do]

### Monolithic Designs Identified

#### [Document Title] (DOC-XXX-003)
- **Current State:** Single document covering [X, Y, Z]
- **Recommendation:** Split into [n] modules
- **Proposed Structure:**
  - DOC-XXX-003a: [Module 1 scope]
  - DOC-XXX-003b: [Module 2 scope]
  - DOC-XXX-003c: [Module 3 scope]

### Open Questions Resolved

| Question | Resolution |
|----------|------------|
| [From analyst] | [Architect's decision] |

### New Open Questions for Developer

1. **[Question]** - [Context]
```

## Review Status Definitions

| Status | Meaning |
|--------|---------|
| **APPROVED** | Document is technically sound, proceed to development |
| **NEEDS CHANGES** | Issues found, must be fixed before development |
| **SPLIT REQUIRED** | Monolithic design, run `/skills:split-document` |
| **BLOCKED** | Cannot review, missing dependencies or context |

## Output

1. Update `docs/handoff.md` with architect review section
2. Create list of documents needing changes
3. Identify documents requiring splitting
4. Resolve analyst's open questions
5. Add new open questions for developer

## Next Steps

After review:
- For documents with NEEDS CHANGES: Edit directly or request analyst revision
- For documents with SPLIT REQUIRED: Run `/skills:split-document`
- When all documents are APPROVED: Run `/skills:handoff` to update phase

## Key Principles

- QUESTION everything - do not accept at face value
- Technical accuracy is paramount - agents read docs literally
- Identify what should be modular early - fixing later is expensive
- Preserve business intent while correcting technical details
- Document all changes and rationale
