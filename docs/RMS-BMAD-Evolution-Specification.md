# RMS-BMAD Evolution Specification

**Version:** 1.0 (Draft for Review)
**Date:** 2026-01-16
**Status:** Pending Approval

---

## Executive Summary

This document specifies the evolution of RMS-BMAD methodology to optimize for **agentic development**. The changes consolidate roles, formalize critical review phases, introduce a handoff mechanism, and ensure MLDA (Modular Linked Documentation Architecture) is enforced throughout the entire workflow.

### Key Changes

1. **Role Consolidation:** 8 roles → 3 core roles (Analyst, Architect, Developer+QA)
2. **Architecture Refinement Phase:** Architect can now question and modify analyst work
3. **Handoff Document:** Single evolving document that maintains context across phases
4. **MLDA Enforcement:** All roles MUST use MLDA for document creation and navigation
5. **External Agent Protocol:** Documentation consumable by any AI agent, not just RMS-BMAD

---

## Table of Contents

1. [Current State Analysis](#1-current-state-analysis)
2. [Problems Identified](#2-problems-identified)
3. [The New Three-Role Model](#3-the-new-three-role-model)
4. [Detailed Role Specifications](#4-detailed-role-specifications)
5. [The Handoff Document](#5-the-handoff-document)
6. [MLDA Enforcement Protocol](#6-mlda-enforcement-protocol)
7. [New Skills and Commands](#7-new-skills-and-commands)
8. [External Agent Consumer Protocol](#8-external-agent-consumer-protocol)
9. [File Changes Required](#9-file-changes-required)
10. [Migration Plan](#10-migration-plan)

---

## 1. Current State Analysis

### 1.1 Current Role Structure

RMS-BMAD currently defines 8+ roles:

| Role | Current Responsibility | Mode File |
|------|------------------------|-----------|
| Analyst | Requirements, business docs | `modes/analyst.md` |
| Architect | System design, architecture docs | `modes/architect.md` |
| PM | PRDs, product strategy | `modes/pm.md` |
| PO | Backlog, story refinement | `modes/po.md` |
| SM | Story creation, epic management | `modes/sm.md` |
| Developer | Code implementation | `modes/dev.md` |
| QA | Test strategy, quality gates | `modes/qa.md` |
| UX Expert | UI/UX design | `modes/ux-expert.md` |

### 1.2 Current Workflow

```
Analyst → PM → PO → SM → Developer → QA → Analyst
            ↑    ↑    ↑              ↑
         Multiple handoffs = context loss
```

### 1.3 Current MLDA Integration

- MLDA exists and is documented (DOC-CORE-001 through DOC-CORE-004)
- Modes have `mlda_protocol` section but enforcement is inconsistent
- Navigation commands exist (`*explore`, `*related`, `*context`)
- Document creation can use MLDA but isn't mandatory

### 1.4 Current Gaps

1. **No critical review phase:** Architect creates docs but doesn't formally review analyst work
2. **Permission restrictions:** Architect "cannot_edit: business requirements"
3. **No handoff mechanism:** No formal document passing between phases
4. **Role fragmentation:** Too many handoffs for agentic efficiency
5. **External agent support:** No protocol for non-RMS-BMAD agents to consume MLDA

---

## 2. Problems Identified

### 2.1 Documentation Drift

Each handoff between roles creates opportunity for context loss:

```
Analyst writes: "User Management System"
PM interprets: "User module with auth"
PO refines: "Login and profile features"
SM creates story: "Implement user login"
Developer reads story: Misses original system context
```

**Impact:** Agents work from incomplete or misinterpreted context.

### 2.2 Architect Cannot Challenge Analyst Work

Current architect mode says:
```yaml
cannot_edit:
  - business requirements
```

But architecturally, the analyst might describe one monolithic system that should be three microservices. The architect currently cannot:
- Split analyst documents
- Modify technical structure
- Add architectural refinements to existing docs

**Impact:** Technical inaccuracies persist into development, confusing agents.

### 2.3 Agents Take Documentation Literally

A human developer can think: "I know this doc says one system, but experience tells me it should be split."

An AI agent cannot. It reads the documentation and follows it precisely.

**Impact:** Wrong documentation = wrong implementation.

### 2.4 Too Many Roles for Agentic Flow

Traditional role separation addresses human limitations:
- Different expertise areas
- Accountability checkpoints
- Cognitive load distribution

In agentic development:
- Agents don't have cognitive load limits
- Each handoff loses context
- The creating agent understands context best

**Impact:** Efficiency loss and context fragmentation.

### 2.5 No Formal Handoff Mechanism

When analyst completes 200 documents, how does the architect know:
- Where to start?
- What needs review?
- What questions are open?
- What the analyst couldn't decide alone?

**Impact:** Architect must rediscover context that analyst already had.

---

## 3. The New Three-Role Model

### 3.1 Role Overview

```
┌─────────────────────────────────────────────────────────────────┐
│ ANALYST                                                         │
│ "The Business Owner"                                            │
├─────────────────────────────────────────────────────────────────┤
│ Responsibilities:                                               │
│ • Requirements gathering and documentation                      │
│ • Business documentation with technical topics                  │
│ • PRDs, project briefs, concept documents                       │
│ • Epics, stories, tasks with acceptance criteria                │
│ • User documentation (guides, help content)                     │
│                                                                 │
│ MLDA Role: Primary document creator, knowledge graph builder    │
│ Handoff: Creates handoff document for Architect                 │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│ ARCHITECT                                                       │
│ "The Technical Authority"                                       │
├─────────────────────────────────────────────────────────────────┤
│ Responsibilities:                                               │
│ • Critical review of analyst documentation                      │
│ • CAN question, modify, and split analyst documents             │
│ • Architecture documentation                                    │
│ • Technology selection (modern, non-legacy)                     │
│ • Ensure technical accuracy for agent consumption               │
│                                                                 │
│ MLDA Role: Refiner and validator of knowledge graph             │
│ Handoff: Updates handoff document for Developer+QA              │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│ DEVELOPER+QA                                                    │
│ "The Implementation Owner"                                      │
├─────────────────────────────────────────────────────────────────┤
│ Responsibilities:                                               │
│ • Review stories before implementing                            │
│ • Create test cases (think about edge cases BEFORE coding)      │
│ • Develop the solution                                          │
│ • Write unit & integration tests                                │
│ • Execute all tests (functional, unit, integration)             │
│                                                                 │
│ MLDA Role: Consumer and navigator of knowledge graph            │
│ Handoff: Updates handoff document with implementation notes     │
└─────────────────────────────────────────────────────────────────┘
```

### 3.2 Role Consolidation Mapping

| Old Role | New Assignment | Rationale |
|----------|---------------|-----------|
| Analyst | **Analyst** | Core role retained |
| PM | **Analyst** | PRD creation is requirements work |
| PO | **Analyst** | Backlog is extension of requirements |
| SM | **Analyst** | Story creation belongs with requirements author |
| Architect | **Architect** | Core role retained + enhanced |
| Developer | **Developer+QA** | Core role retained |
| QA | **Developer+QA** | Shift-left testing, TDD alignment |
| UX Expert | **Specialist** | Available when needed, not core flow |

### 3.3 Support and Specialist Roles

In addition to the 3 core roles, the following support roles remain available:

| Role | Type | Purpose |
|------|------|---------|
| **Orchestrator** | Support | Onboarding guide for new joiners unfamiliar with SDLC |
| **UX Expert** | Specialist | UI/UX design, called when needed (unchanged) |

These roles are **not part of the core workflow** but provide specialized capabilities when required.

### 3.4 Workflow Comparison

**Before (8 roles, 7 handoffs):**
```
Analyst → PM → PO → SM → Developer → QA → Analyst
```

**After (3 core roles, 2 handoffs):**
```
Analyst → Architect → Developer+QA
             ↑              ↑
      Critical review   Full ownership
      Single point      No separate QA handoff

Support: Orchestrator (onboarding)
Specialist: UX Expert (when needed)
```

---

## 4. Detailed Role Specifications

### 4.1 Analyst Role (Expanded)

#### Identity
```yaml
agent:
  name: Maya
  id: analyst
  title: Business Analyst & Documentation Owner
  icon: 📋

persona:
  role: Business Analyst, Requirements Engineer & Documentation Owner
  style: Thorough, inquisitive, user-focused, documentation-obsessed
  identity: Master of understanding stakeholder needs and translating them into comprehensive, agent-consumable documentation
  focus: Requirements, business documentation, stories, user guides
```

#### Core Principles
1. **User-Centric Discovery** - Start with user needs, work backward
2. **Comprehensive Documentation** - Document thoroughly for agent consumption
3. **MLDA-Native Thinking** - Every document is a neuron in the knowledge graph
4. **Story Ownership** - Write stories with full context, not just titles
5. **Handoff Responsibility** - Prepare clear handoff for architect

#### Responsibilities (Expanded from Current)

| Responsibility | Status | Notes |
|---------------|--------|-------|
| Requirements gathering | Existing | Core capability |
| Business documentation | Existing | Core capability |
| PRD creation | **NEW** | From PM role |
| Project briefs | Existing | Core capability |
| Epic creation | **NEW** | From SM role |
| Story creation with AC | **NEW** | From PO/SM roles |
| Task breakdown | **NEW** | From SM role |
| User documentation | **NEW** | Guides, help content |
| Handoff document creation | **NEW** | For architect |

#### Commands

| Command | Description | Status |
|---------|-------------|--------|
| `*help` | Show available commands | Existing |
| `*create-prd` | Create PRD document | **NEW** (from PM) |
| `*create-project-brief` | Create project brief | Existing |
| `*create-epic` | Create epic with stories | **NEW** (from SM) |
| `*create-story` | Create user story with AC | **NEW** (from PO/SM) |
| `*create-user-guide` | Create user documentation | **NEW** |
| `*brainstorm` | Facilitate brainstorming | Existing |
| `*research` | Deep research prompt | Existing |
| `*handoff` | Generate handoff document | **NEW** |
| `*explore` | Navigate MLDA graph | Existing |
| `*related` | Show related documents | Existing |
| `*context` | Display gathered context | Existing |
| `*exit` | Leave analyst mode | Existing |

#### File Permissions
```yaml
file_permissions:
  can_create:
    - requirements documents
    - business documentation
    - PRDs
    - project briefs
    - epics
    - stories
    - user guides
    - handoff document
  can_edit:
    - all documents they created
    - handoff document
  cannot_edit:
    - architecture documents (architect owns)
    - code files (developer owns)
```

#### MLDA Enforcement
```yaml
mlda_protocol:
  mandatory: true
  on_document_creation:
    - MUST assign DOC-ID from appropriate domain
    - MUST create .meta.yaml sidecar
    - MUST define at least one relationship
    - MUST update registry after creation
  on_handoff:
    - MUST generate handoff document
    - MUST list all created documents
    - MUST specify open questions for architect
```

---

### 4.2 Architect Role (Enhanced)

#### Identity
```yaml
agent:
  name: Winston
  id: architect
  title: System Architect & Technical Authority
  icon: 🏗️

persona:
  role: Holistic System Architect & Technical Reviewer
  style: Critical, thorough, pragmatic, technically rigorous
  identity: Technical authority who validates, refines, and ensures documentation accuracy for agent consumption
  focus: Architecture, technical review, documentation refinement
```

#### Core Principles
1. **Critical Review Mandate** - Question and validate analyst work
2. **Technical Accuracy** - Ensure docs reflect correct architecture
3. **Agent-Ready Documentation** - Agents will read this literally
4. **Modern Technology Selection** - No legacy patterns without justification
5. **Documentation Ownership** - Can modify any document for technical accuracy

#### Responsibilities (Enhanced)

| Responsibility | Status | Notes |
|---------------|--------|-------|
| Architecture documentation | Existing | Core capability |
| Technology selection | Existing | Core capability |
| **Critical review of analyst docs** | **NEW** | Can question and challenge |
| **Modify analyst documents** | **NEW** | For technical accuracy |
| **Split monolithic docs** | **NEW** | When architecture requires |
| **Validate MLDA structure** | **NEW** | Ensure graph integrity |
| Update handoff document | **NEW** | For developer |

#### Commands

| Command | Description | Status |
|---------|-------------|--------|
| `*help` | Show available commands | Existing |
| `*review-docs` | Critical review of analyst documentation | **NEW** |
| `*create-architecture` | Create architecture document | Existing (renamed) |
| `*split-document` | Split monolithic doc into modules | **NEW** |
| `*validate-mlda` | Validate MLDA graph integrity | **NEW** |
| `*execute-checklist` | Run architect checklist | Existing |
| `*research` | Deep research prompt | Existing |
| `*handoff` | Update handoff for developer | **NEW** |
| `*explore` | Navigate MLDA graph | Existing |
| `*related` | Show related documents | Existing |
| `*context` | Display gathered context | Existing |
| `*exit` | Leave architect mode | Existing |

#### File Permissions (CHANGED)
```yaml
file_permissions:
  can_create:
    - architecture documents
    - technical specifications
    - API designs
    - infrastructure documents
  can_edit:
    - architecture documents
    - technical specifications
    - analyst documents (for technical accuracy)  # CHANGED
    - any document (for technical structure)      # CHANGED
    - handoff document
  cannot_edit:
    - code files (developer owns)
  special_permissions:
    - CAN split analyst documents into multiple docs
    - CAN add technical sections to analyst docs
    - CAN modify document structure for accuracy
    - MUST preserve business intent when modifying
```

#### Critical Review Protocol (NEW)
```yaml
review_protocol:
  when_reviewing_analyst_docs:
    - Read handoff document first (entry point)
    - Navigate MLDA graph from entry points
    - For each document, evaluate:
        - Technical feasibility
        - Should this be split into multiple modules?
        - Are there missing technical considerations?
        - Will an agent understand this correctly?
    - Document all findings
    - Propose modifications before making them
    - Update sidecars when relationships change

  critical_thinking_mandate:
    - DO NOT accept analyst docs at face value
    - Question architectural assumptions
    - Identify monolithic designs that should be modular
    - Flag missing non-functional requirements
    - Ensure technology choices are justified
```

#### MLDA Enforcement
```yaml
mlda_protocol:
  mandatory: true
  on_document_modification:
    - MUST update .meta.yaml sidecar
    - MUST maintain relationship integrity
    - MUST run mlda-validate after changes
  on_document_split:
    - MUST create new DOC-IDs for new documents
    - MUST use 'supersedes' relationship for replaced docs
    - MUST update all references to split document
    - MUST update registry
  on_handoff:
    - MUST update handoff document
    - MUST mark resolved questions from analyst
    - MUST add new questions for developer if any
```

---

### 4.3 Developer+QA Role (Merged)

#### Identity
```yaml
agent:
  name: Devon
  id: developer
  title: Implementation Owner (Dev + QA)
  icon: 💻

persona:
  role: Full-Stack Developer & Quality Engineer
  style: Pragmatic, test-driven, thorough, quality-focused
  identity: Implementation owner who develops AND ensures quality through comprehensive testing
  focus: Implementation, testing, quality assurance
```

#### Core Principles
1. **Test-First Thinking** - Consider test cases before writing code
2. **Quality Ownership** - Dev owns quality, no "throw over wall"
3. **MLDA Navigation** - Gather full context before implementing
4. **Story Validation** - Review stories critically before starting
5. **Comprehensive Testing** - Unit, integration, and functional tests

#### Responsibilities (Merged)

| Responsibility | Source | Notes |
|---------------|--------|-------|
| Code implementation | Developer | Core capability |
| Debugging & refactoring | Developer | Core capability |
| Review stories before implementing | **NEW** | Critical validation |
| Create test cases | QA | Before coding |
| Write unit tests | Developer | TDD approach |
| Write integration tests | Developer/QA | Merged |
| Execute functional tests | QA | Merged |
| Quality gate decisions | QA | Merged |
| Update handoff with impl notes | **NEW** | For documentation |

#### Commands

| Command | Description | Status |
|---------|-------------|--------|
| `*help` | Show available commands | Existing |
| `*review-story` | Review story before implementing | **NEW** (from QA) |
| `*create-test-cases` | Create test cases for story | **NEW** (from QA) |
| `*implement` | Start implementation of story | Existing |
| `*write-tests` | Write unit/integration tests | **NEW** |
| `*run-tests` | Execute all tests | **NEW** |
| `*qa-gate` | Quality gate decision | Existing (from QA) |
| `*explore` | Navigate MLDA graph | Existing |
| `*related` | Show related documents | Existing |
| `*context` | Display gathered context | Existing |
| `*handoff` | Update handoff with impl notes | **NEW** |
| `*exit` | Leave developer mode | Existing |

#### File Permissions
```yaml
file_permissions:
  can_create:
    - source code files
    - test files
    - configuration files
    - implementation documentation
  can_edit:
    - source code files
    - test files
    - configuration files
    - handoff document (implementation notes section)
  cannot_edit:
    - requirements documents (analyst owns)
    - architecture documents (architect owns)
    - business documentation
```

#### Test-First Protocol (NEW)
```yaml
test_first_protocol:
  before_implementing:
    - Read story and acceptance criteria
    - Navigate MLDA to gather context
    - Create test cases covering:
        - Happy path scenarios
        - Edge cases
        - Error conditions
        - Acceptance criteria validation
    - Review test cases mentally before coding

  during_implementation:
    - Write unit tests alongside code (TDD)
    - Ensure tests cover acceptance criteria
    - Write integration tests for component boundaries

  after_implementation:
    - Run all tests (unit, integration, functional)
    - Validate against acceptance criteria
    - Document any deviations or discoveries
    - Update handoff with implementation notes
```

#### MLDA Enforcement
```yaml
mlda_protocol:
  mandatory: true
  before_implementation:
    - MUST read handoff document
    - MUST navigate from story's DOC-ID references
    - MUST gather context before writing code
  on_implementation_complete:
    - MUST update handoff with implementation notes
    - MAY create implementation documentation with DOC-ID
    - MUST link implementation docs to relevant requirements
```

---

### 4.4 Orchestrator Role (Minimal - Onboarding Only)

#### Purpose

The Orchestrator is retained as a **minimal onboarding mode** for new team members who are unfamiliar with SDLC or the RMS-BMAD methodology. It provides guidance and education, not workflow coordination.

#### Identity
```yaml
agent:
  name: Oscar
  id: orchestrator
  title: Onboarding Guide
  icon: 🎓

persona:
  role: Methodology Guide & Onboarding Assistant
  style: Educational, patient, explanatory
  identity: Guide who helps new joiners understand the RMS-BMAD methodology and SDLC basics
  focus: Education, guidance, methodology explanation
```

#### When to Use

- First time using RMS-BMAD
- Confused about which role to use
- Need to understand the overall methodology
- Want to learn about MLDA and the neocortex model
- New to software development lifecycle concepts

#### Commands (Simplified)

| Command | Description |
|---------|-------------|
| `*help` | Show available commands |
| `*getting-started` | First-time onboarding walkthrough |
| `*explain-workflow` | Explain the 3-role workflow (Analyst → Architect → Developer+QA) |
| `*explain-mlda` | Explain MLDA and knowledge graph concepts |
| `*which-role` | Guide to correct role based on task description |
| `*exit` | Leave orchestrator mode |

#### Removed Commands (From Old Orchestrator)

| Old Command | Status | Reason |
|-------------|--------|--------|
| `*handoff` | REMOVED | Each role now has its own `*handoff` command |
| `*status` | REMOVED | Handoff document tracks phase status |
| `*next-step` | REMOVED | Trivial with 3 roles, handoff document provides this |
| `*recommend-mode` | REPLACED | Now `*which-role` with educational focus |
| `*show-workflow` | REPLACED | Now `*explain-workflow` with educational focus |

#### Example Interactions

**`*getting-started` output:**
```
Welcome to RMS-BMAD! Here's how the methodology works:

1. ANALYST creates business documentation, requirements, and stories
2. ARCHITECT reviews and refines for technical accuracy
3. DEVELOPER+QA implements and tests

Each role hands off to the next using a handoff document (docs/handoff.md).

All documentation follows MLDA (Modular Linked Documentation Architecture),
which means documents link to each other like neurons in a brain.

To get started:
- If you're defining requirements → /modes:analyst
- If you're reviewing architecture → /modes:architect
- If you're implementing code → /modes:dev

Type *explain-mlda to learn about the documentation structure.
Type *which-role to get help choosing the right mode.
```

**`*which-role` interaction:**
```
User: I need to create user stories for our new feature

Oscar: Based on your task, you should use the **Analyst** role.

The Analyst is responsible for:
- Requirements gathering
- Business documentation
- Creating epics, stories, and tasks with acceptance criteria

To activate: /modes:analyst

Once in Analyst mode, use *create-story to create a new user story.
```

---

## 5. The Handoff Document

### 5.1 Purpose

The handoff document is a **single, evolving document** that:
1. Maintains context across all phases
2. Serves as the entry point for each receiving agent
3. Tracks open questions and their resolutions
4. Provides audit trail of decisions

### 5.2 Location

```
docs/handoff.md
```

### 5.3 Structure

```markdown
# Project Handoff Document

**Project:** [Project Name]
**Last Updated:** [Date]
**Current Phase:** [Analyst | Architect | Developer+QA]
**Last Handoff By:** [Role]

---

## Phase History

### Phase 1: Analyst Discovery
**Status:** [In Progress | Completed | Handed Off]
**Agent:** Maya (Analyst)
**Dates:** [Start] - [End]

#### Work Summary
Brief description of what was accomplished.

#### Documents Created
| DOC-ID | Title | Domain | Description |
|--------|-------|--------|-------------|
| DOC-PRD-001 | Core Platform PRD | PRD | Main product requirements |
| DOC-AUTH-001 | Authentication Concepts | AUTH | Auth flow definitions |
| ... | ... | ... | ... |

**Total Documents:** [Count]
**Domains Covered:** [List]

#### Key Decisions Made
1. [Decision 1 with rationale]
2. [Decision 2 with rationale]

#### Open Questions for Architect (REQUIRED)
> These are questions the analyst could not resolve alone and require architectural input.

1. **[Question Title]**
   - Context: [Why this is a question]
   - Options considered: [What analyst thought about]
   - Recommendation: [If any]

2. **[Question Title]**
   ...

#### Entry Points for Next Phase
| Priority | DOC-ID | Title | Why Start Here |
|----------|--------|-------|----------------|
| 1 | DOC-BRIEF-001 | Project Brief | Overall context |
| 2 | DOC-PRD-001 | Core PRD | Requirements scope |
| 3 | DOC-AUTH-001 | Auth Concepts | Critical security |

---

### Phase 2: Architecture Refinement
**Status:** [Not Started | In Progress | Completed | Handed Off]
**Agent:** Winston (Architect)
**Dates:** [Start] - [End]

#### Review Summary
What was reviewed and key findings.

#### Documents Modified
| DOC-ID | Title | Changes Made | Rationale |
|--------|-------|--------------|-----------|
| DOC-AUTH-001 | Auth Concepts | Split into 3 docs | Microservices arch |

#### Documents Created
| DOC-ID | Title | Domain | Description |
|--------|-------|--------|-------------|
| DOC-ARCH-001 | System Architecture | ARCH | Overall architecture |

#### Questions Resolved
| From Phase | Question | Resolution |
|------------|----------|------------|
| 1 | Should user mgmt be one service? | Split into 3: auth, profile, permissions |

#### Open Questions for Developer+QA (REQUIRED)
1. **[Question Title]**
   ...

#### Entry Points for Next Phase
| Priority | DOC-ID | Title | Why Start Here |
|----------|--------|-------|----------------|
| 1 | DOC-ARCH-001 | System Architecture | Technical overview |
| 2 | STORY-001 | First implementation story | Start here |

---

### Phase 3: Implementation
**Status:** [Not Started | In Progress | Completed]
**Agent:** Devon (Developer+QA)
**Dates:** [Start] - [End]

#### Implementation Notes
Key implementation decisions and notes.

#### Stories Completed
| Story ID | Title | Status | Notes |
|----------|-------|--------|-------|
| STORY-001 | Implement auth service | Done | Used JWT |

#### Test Coverage
| Component | Unit | Integration | Functional |
|-----------|------|-------------|------------|
| auth-service | 95% | 80% | 100% |

#### Issues Discovered
1. [Issue with resolution]

---

## Document Statistics

**Total Documents:** [Auto-calculated]
**By Domain:**
- AUTH: [count]
- API: [count]
- DATA: [count]
- ...

**Relationship Health:**
- Orphan documents: [count]
- Broken links: [count]

---

## Appendix: Full Document Index

[Auto-generated from registry.yaml]
```

### 5.4 Auto-Generation

The handoff document will be auto-generated via:

1. **New Skill:** `*handoff` command in each role
2. **Script:** `.mlda/scripts/mlda-handoff.ps1`
3. **Data Sources:**
   - `.mlda/registry.yaml` for document lists
   - Session context for work summary
   - User input for open questions (REQUIRED prompt)

#### Generation Flow

```
Analyst runs *handoff
       │
       ▼
┌─────────────────────────────────────────┐
│ 1. Read registry.yaml                   │
│ 2. Identify documents created this phase│
│ 3. Prompt user for:                     │
│    - Work summary                       │
│    - Key decisions                      │
│    - Open questions (REQUIRED)          │
│    - Recommended entry points           │
│ 4. Generate/update docs/handoff.md      │
│ 5. Validate MLDA integrity              │
└─────────────────────────────────────────┘
       │
       ▼
Architect reads handoff.md as first action
```

### 5.5 Enforcement Rules

1. **Analyst MUST run `*handoff` before phase completion**
2. **"Open Questions" section is REQUIRED** - skill will prompt until at least one is provided (or explicit "none" with justification)
3. **Architect MUST read handoff.md first** - mode activation checks for this
4. **Each phase updates the SAME document** - append, don't replace

---

## 6. MLDA Enforcement Protocol

### 6.1 Why MLDA is Mandatory

MLDA is not optional in the new structure because:

1. **Agents navigate via DOC-IDs** - No DOC-ID = invisible document
2. **Relationships enable context gathering** - No relationships = orphan neuron
3. **Registry enables discovery** - Unregistered docs are lost
4. **Handoff depends on MLDA data** - Auto-generation reads registry

### 6.2 Enforcement by Role

#### Analyst Enforcement
```yaml
mlda_enforcement:
  on_activation:
    - Check if .mlda/ exists
    - If not, prompt to initialize with mlda-init-project.ps1
    - Load registry.yaml
    - Report MLDA status

  on_document_creation:
    - BLOCK creation without DOC-ID assignment
    - BLOCK creation without .meta.yaml sidecar
    - REQUIRE at least one relationship
    - AUTO-UPDATE registry after creation

  on_handoff:
    - REQUIRE handoff document generation
    - VALIDATE all documents have relationships
    - REPORT orphan documents as warnings
```

#### Architect Enforcement
```yaml
mlda_enforcement:
  on_activation:
    - REQUIRE reading docs/handoff.md first
    - Load registry.yaml
    - Navigate from handoff entry points

  on_document_modification:
    - REQUIRE sidecar update
    - MAINTAIN relationship integrity
    - RUN mlda-validate after changes

  on_document_split:
    - REQUIRE new DOC-IDs for all new docs
    - REQUIRE 'supersedes' relationship
    - UPDATE all incoming references
    - REBUILD registry

  on_handoff:
    - REQUIRE handoff document update
    - RESOLVE open questions from analyst
    - ADD new questions if any
```

#### Developer+QA Enforcement
```yaml
mlda_enforcement:
  on_activation:
    - REQUIRE reading docs/handoff.md first
    - Navigate from story DOC-ID references
    - Gather context before implementation

  on_implementation:
    - NAVIGATE to understand full context
    - REFERENCE DOC-IDs in code comments where relevant

  on_completion:
    - UPDATE handoff with implementation notes
    - OPTIONALLY create implementation docs with DOC-IDs
```

### 6.3 Validation Checks

Each role runs validation:

| Check | Analyst | Architect | Developer |
|-------|---------|-----------|-----------|
| All docs have DOC-ID | ✓ | ✓ | - |
| All docs have sidecar | ✓ | ✓ | - |
| All docs have relationships | ✓ | ✓ | - |
| No orphan documents | ✓ | ✓ | - |
| No broken links | ✓ | ✓ | - |
| Registry is current | ✓ | ✓ | - |
| Handoff document exists | ✓ | ✓ | ✓ |
| Handoff has open questions | ✓ | - | - |

---

## 7. New Skills and Commands

### 7.1 New Skills to Create

| Skill | File | Used By | Purpose |
|-------|------|---------|---------|
| `handoff` | `skills/handoff.md` | All roles | Generate/update handoff document |
| `review-docs` | `skills/review-docs.md` | Architect | Critical review of documentation |
| `split-document` | `skills/split-document.md` | Architect | Split monolithic docs |
| `create-test-cases` | `skills/create-test-cases.md` | Developer+QA | Generate test cases from story |
| `validate-mlda` | `skills/validate-mlda.md` | All roles | Validate MLDA integrity |

### 7.2 Skills to Move Between Roles

| Skill | Current Owner | New Owner | Notes |
|-------|---------------|-----------|-------|
| `create-doc` (PRD template) | PM | Analyst | PRD creation moves to analyst |
| `create-next-story` | SM/PO | Analyst | Story creation moves to analyst |
| `create-brownfield-story` | SM | Analyst | Story creation moves to analyst |
| `review-story` | QA | Developer+QA | Story review moves to dev |
| `qa-gate` | QA | Developer+QA | Quality gates move to dev |
| `test-design` | QA | Developer+QA | Test design moves to dev |

### 7.3 New Script to Create

| Script | Location | Purpose |
|--------|----------|---------|
| `mlda-handoff.ps1` | `.mlda/scripts/` | Auto-generate handoff document |

---

## 8. External Agent Consumer Protocol

### 8.1 Purpose

Teams not using RMS-BMAD should still be able to consume MLDA documentation effectively. This protocol teaches any AI agent how to navigate the knowledge graph.

### 8.2 Consumer Protocol Document

Create: `.mlda/CONSUMER-PROTOCOL.md`

This document will contain:

1. **What is MLDA** (2 paragraphs)
2. **Folder Structure** (where to find docs)
3. **DOC-ID Format** (how to identify documents)
4. **Sidecar Files** (what .meta.yaml contains)
5. **Relationship Types** (signal strength for navigation)
6. **Navigation Algorithm** (how to traverse)
7. **Entry Points** (how to find starting documents)
8. **The Handoff Document** (always start here)

### 8.3 Integration Templates

Create templates for different agent systems:

| Template | Location | Purpose |
|----------|----------|---------|
| `CLAUDE.md` snippet | `.mlda/integrations/claude-snippet.md` | Add to Claude Code projects |
| `.augment` snippet | `.mlda/integrations/augment-snippet.md` | Add to Augment Code projects |
| Generic prompt | `.mlda/integrations/generic-prompt.md` | Paste into any agent |

### 8.4 Consumer Protocol Content

```markdown
# MLDA Consumer Protocol

## For AI Agents Not Using RMS-BMAD

This document teaches you how to navigate MLDA documentation.

### Quick Start

1. **Start with the handoff document:** `docs/handoff.md`
2. **Navigate to entry points** listed in handoff
3. **Follow relationships** in .meta.yaml sidecars
4. **Gather context** before implementing

### Document Structure

Documents live in `.mlda/docs/{domain}/`:
- Each document has a `.md` file and `.meta.yaml` sidecar
- DOC-IDs follow pattern: `DOC-{DOMAIN}-{NNN}`
- Registry at `.mlda/registry.yaml` indexes all documents

### Relationship Signal Strength

| Type | Strength | Action |
|------|----------|--------|
| `depends-on` | Strong | ALWAYS follow |
| `supersedes` | Redirect | Follow this, ignore target |
| `extends` | Medium | Follow if depth allows |
| `references` | Weak | Follow if relevant to task |

### Navigation Algorithm

1. Read current document
2. Read its .meta.yaml sidecar
3. For each relationship:
   - If `depends-on`: follow immediately
   - If `supersedes`: follow, mark target obsolete
   - If `extends`: follow if depth < 3
   - If `references`: follow if `why` matches your task
4. Track visited documents to avoid cycles
5. Stop when sufficient context gathered

### The "Why" Field

Every relationship has a `why` field explaining the connection.
Use this to decide if the relationship is relevant to your task.

Example:
```yaml
related:
  - id: DOC-AUTH-001
    type: depends-on
    why: "Authentication flow required for all API calls"
```

If your task involves API calls, this relationship is critical.
If your task is UI-only, you might skip it.
```

---

## 9. File Changes Required

### 9.1 Mode Files to Update

| File | Action | Changes |
|------|--------|---------|
| `.claude/commands/modes/analyst.md` | UPDATE | Expand responsibilities, add commands |
| `.claude/commands/modes/architect.md` | UPDATE | Add review capabilities, change permissions |
| `.claude/commands/modes/dev.md` | UPDATE | Merge QA capabilities |
| `.claude/commands/modes/bmad-orchestrator.md` | UPDATE | Convert to minimal onboarding mode |
| `.claude/commands/bmad-agents/analyst.md` | UPDATE | Mirror mode changes |
| `.claude/commands/bmad-agents/architect.md` | UPDATE | Mirror mode changes |
| `.claude/commands/bmad-agents/dev.md` | UPDATE | Mirror mode changes |
| `.claude/commands/bmad-agents/bmad-orchestrator.md` | UPDATE | Mirror mode changes |

### 9.2 Mode Files to Deprecate

| File | Action | Rationale |
|------|--------|-----------|
| `.claude/commands/modes/pm.md` | DEPRECATE | Merged into Analyst |
| `.claude/commands/modes/po.md` | DEPRECATE | Merged into Analyst |
| `.claude/commands/modes/sm.md` | DEPRECATE | Merged into Analyst |
| `.claude/commands/modes/qa.md` | DEPRECATE | Merged into Developer+QA |
| `.claude/commands/bmad-agents/pm.md` | DEPRECATE | Merged into Analyst |
| `.claude/commands/bmad-agents/po.md` | DEPRECATE | Merged into Analyst |
| `.claude/commands/bmad-agents/sm.md` | DEPRECATE | Merged into Analyst |
| `.claude/commands/bmad-agents/qa.md` | DEPRECATE | Merged into Developer+QA |

### 9.3 Skills to Create

| File | Purpose |
|------|---------|
| `.claude/commands/skills/handoff.md` | Handoff document generation |
| `.claude/commands/skills/review-docs.md` | Critical documentation review |
| `.claude/commands/skills/split-document.md` | Document splitting |
| `.claude/commands/skills/create-test-cases.md` | Test case generation |
| `.claude/commands/skills/validate-mlda.md` | MLDA validation |

### 9.4 Scripts to Create

| File | Purpose |
|------|---------|
| `.mlda/scripts/mlda-handoff.ps1` | Auto-generate handoff document |

### 9.5 Documentation to Create

| File | Purpose |
|------|---------|
| `.mlda/CONSUMER-PROTOCOL.md` | External agent protocol |
| `.mlda/integrations/claude-snippet.md` | Claude Code integration |
| `.mlda/integrations/augment-snippet.md` | Augment Code integration |
| `.mlda/integrations/generic-prompt.md` | Generic agent prompt |

### 9.6 Templates to Update

| File | Changes |
|------|---------|
| Story template | Add "Entry Points" section |
| All doc templates | Ensure MLDA sidecar guidance |

---

## 10. Migration Plan

### 10.1 Phase 1: Documentation
1. ✓ Create this specification document
2. [ ] Review and approve specification
3. [ ] Create CONSUMER-PROTOCOL.md

### 10.2 Phase 2: Core Role Updates
1. [ ] Update Analyst mode with expanded capabilities
2. [ ] Update Architect mode with review capabilities
3. [ ] Update Developer mode with QA merge
4. [ ] Update corresponding bmad-agents files

### 10.3 Phase 3: New Skills
1. [ ] Create handoff skill
2. [ ] Create review-docs skill
3. [ ] Create split-document skill
4. [ ] Create create-test-cases skill
5. [ ] Create validate-mlda skill

### 10.4 Phase 4: Scripts
1. [ ] Create mlda-handoff.ps1
2. [ ] Test handoff generation

### 10.5 Phase 5: Deprecation
1. [ ] Mark PM, PO, SM, QA modes as deprecated
2. [ ] Add deprecation notices pointing to new roles
3. [ ] Keep files for backward compatibility (1 month)
4. [ ] Deprecated modes only available if explicitly requested

### 10.6 Phase 6: Integration Templates
1. [ ] Create Claude Code snippet
2. [ ] Create Augment Code snippet
3. [ ] Create generic prompt

### 10.7 Phase 7: Testing
1. [ ] Test full workflow: Analyst → Architect → Developer+QA
2. [ ] Test handoff document evolution
3. [ ] Test MLDA enforcement
4. [ ] Test external agent consumption

---

## Appendix A: Decision Log

| Date | Decision | Rationale | Made By |
|------|----------|-----------|---------|
| 2026-01-16 | Consolidate 8 roles to 3 | Reduce handoffs, maintain context | User + Claude |
| 2026-01-16 | Architect can modify analyst docs | Technical accuracy for agents | User + Claude |
| 2026-01-16 | Single evolving handoff document | Context preservation | User |
| 2026-01-16 | Open Questions section required | Force analyst to think about arch needs | User |
| 2026-01-16 | Handoff in docs/ folder | Main documentation location | User |
| 2026-01-16 | Auto-generate handoff | Reduce manual work, ensure consistency | User + Claude |
| 2026-01-16 | UX Expert unchanged | Specialist role for UI design only, no updates needed | User |
| 2026-01-16 | Orchestrator becomes minimal onboarding mode | New joiners unfamiliar with SDLC need guidance | User |
| 2026-01-16 | 1 month deprecation period | Short period, modes not in use unless explicitly requested | User |
| 2026-01-16 | No migration needed | Only one active project, not finalized yet | User |
| 2026-01-16 | Implement in both global and project-level | Testing with current project, want for all future projects | User |

---

## Appendix C: Implementation Scope

Changes will be implemented in **both locations**:

| Location | Path | Purpose |
|----------|------|---------|
| **Global (User-level)** | `C:\Users\User\.claude\commands\` | All future projects |
| **Project-level** | `D:\BA Projects\...\Ways of Development\.claude\commands\` | Current project testing |

Both locations will be kept in sync during implementation.

---

## Appendix B: Resolved Questions

| Question | Resolution | Date |
|----------|------------|------|
| UX Expert Role | Keep as optional specialist, no changes needed | 2026-01-16 |
| BMAD Orchestrator | Convert to minimal onboarding mode for new joiners | 2026-01-16 |
| Backward Compatibility | 1 month deprecation period, modes marked deprecated but available if explicitly requested | 2026-01-16 |
| Existing Projects | No migration needed, current project not finalized | 2026-01-16 |

---

*Document generated: 2026-01-16*
*Status: Pending Review*
