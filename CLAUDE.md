# RMS-BMAD Methodology

**RMS Framework: Rules Layer**

This file contains universal rules that apply across all projects using the RMS-BMAD methodology.

---

## RMS Framework

This configuration follows the **RMS (Rules - Modes - Skills)** methodology:

| Layer | Location | Purpose |
|-------|----------|---------|
| **Rules** | This file (CLAUDE.md) | Universal standards, always active |
| **Modes** | `.claude/commands/modes/` | Expert personas, activated via `/modes:{name}` |
| **Skills** | `.claude/commands/skills/` | Discrete workflows, invoked via `/skills:{name}` |

### Core Workflow (3 Roles)

The RMS-BMAD methodology uses three core roles:

```
Analyst → Architect → Developer+QA
(Maya)    (Winston)   (Devon)
```

| Phase | Role | Mode | Purpose |
|-------|------|------|---------|
| 1 | **Analyst** | `/modes:analyst` | Requirements, PRDs, epics, stories, user documentation |
| 2 | **Architect** | `/modes:architect` | Critical review, technical refinement, architecture docs |
| 3 | **Developer+QA** | `/modes:dev` | Implementation, test-first development, quality gates |

Each role hands off to the next using the **handoff document** (`docs/handoff.md`).

### Invoking Modes and Skills

- **Activate a Mode**: `/modes:analyst`, `/modes:architect`, `/modes:dev`
- **Run a Skill**: `/skills:qa-gate`, `/skills:handoff`, `/skills:create-doc`
- **Mode Commands**: Once in a mode, use `*help` to see available commands
- **Exit Mode**: Use `*exit` or `exit` to leave current mode
- **Onboarding**: `/modes:bmad-orchestrator` for new joiners needing methodology guidance

### Supporting Resources

| Resource | Location | Purpose |
|----------|----------|---------|
| Checklists | `.claude/commands/checklists/` | Quality validation checklists |
| Templates | `.claude/commands/templates/` | Document generation templates |
| Data | `.claude/commands/data/` | Reference data and knowledge bases |

---

## Universal Conventions

### File Naming
- Use kebab-case for all file names
- Suffix test files with `.test.{ext}` or `.spec.{ext}`
- Configuration files: `{name}.config.{ext}` or `.{name}rc`

### Code Style
- Prefer explicit over implicit
- Keep functions focused and single-purpose
- Use descriptive variable names

### Documentation
- Document the "why", not just the "what"
- Keep docs close to code
- Update docs when changing behavior

---

## Universal Protocols

### Communication
- Present options as numbered lists for easy selection
- Ask for clarification when requirements are ambiguous
- Summarize understanding before major actions

### Safety
- Never commit secrets, API keys, or credentials
- Validate user input at system boundaries
- Review destructive operations before executing

### Quality
- Run tests before considering work complete
- Check for linting errors
- Verify changes don't break existing functionality

---

## Issue Tracking with Beads

Use **Beads** (`bd`) for multi-session projects with complex dependencies. For simple tasks, use regular TODOs.

### Critical Setup

**ALWAYS run `bd init` first in new projects** - creates .beads/ folder for project-local isolation.

### Essential Commands

```bash
bd init                                    # Initialize (REQUIRED first step)
bd ready --json                            # Show unblocked tasks
bd create "Description" -t task -p 1       # Create issue (priority 0-4, lower=higher)
bd update <id> --status in_progress        # Claim task
bd close <id> --reason "Done"              # Complete task
bd dep add <id> --blocks <other-id>        # Add dependency
bd dep tree <id>                           # Visualize dependency graph
bd stats                                   # Project overview
```

### Workflow

1. Check `bd ready` for unblocked work
2. Claim with `bd update <id> --status in_progress`
3. File new issues as discovered: `bd create "Found bug" --deps discovered-from:<current-id>`
4. Complete with `bd close <id> --reason "Implemented"`

All commands support `--json` flag. Issues auto-sync via git-friendly JSONL files.

---

## MLDA Protocol - The Neocortex Model

**Modular Linked Documentation Architecture** - a knowledge graph that agents navigate.

### The Neocortex Paradigm

MLDA models documentation as a **neural network**:

| Brain Concept | MLDA Equivalent | Description |
|---------------|-----------------|-------------|
| **Neuron** | Document | A single unit storing specific knowledge |
| **Dendrites** | Relationships (`related` in sidecar) | Connections to other documents |
| **Axon** | DOC-ID | The unique identifier that enables connections |
| **Signal** | Agent reading a document | Activation that triggers exploration |
| **Signal Propagation** | Following relationships | Agent traversing from doc to doc |

**Key Principle:** Stories and tasks are **entry points** into the knowledge graph, not self-contained specs. Agents navigate the graph by following relationships (dendrites) to gather context.

### Navigation Commands

All agents support these navigation commands:
- `*explore {DOC-ID}` - Navigate from a specific document
- `*related` - Show documents related to current context
- `*context` - Display gathered context summary
- `*gather-context` - Run full context-gathering workflow

### Project Initialization

For documentation-heavy projects (15+ expected documents), initialize MLDA:

```bash
# Via skill (recommended)
/skills:init-project

# Or via analyst mode
/modes:analyst then *init-project

# Or via PowerShell directly
.\.mlda\scripts\mlda-init-project.ps1 -Domains API,DATA,SEC
```

### Document Creation
- Create topic documents, not monolithic documents
- Use `.mlda/scripts/mlda-create.ps1` to scaffold new topic docs
- Each topic doc needs a companion `.meta.yaml` sidecar
- **CRITICAL:** Define relationships in sidecars - documents without relationships are "dead neurons"

### Relationships (Dendrites)

Relationship types and their signal strength:

| Type | Signal | Meaning |
|------|--------|---------|
| `depends-on` | **Strong** | Cannot understand without target - always follow |
| `extends` | **Medium** | Adds detail to target - follow if depth allows |
| `references` | **Weak** | Mentions target - follow if relevant |
| `supersedes` | **Redirect** | Replaces target - follow this, ignore target |

The `why` field explains the reason for the connection, helping agents decide whether to follow.

### Registry Management
- Run `mlda-registry.ps1` after creating new topic docs
- Run `mlda-registry.ps1 -Graph` to see connectivity analysis
- Run `mlda-validate.ps1` to check link integrity
- Run `mlda-graph.ps1` to visualize document relationships

### Stories as Entry Points

Stories reference DOC-IDs in their "Documentation References" section. When a developer receives a story:
1. Parse DOC-ID references from the story
2. Run `*explore` to navigate the knowledge graph
3. Gather context from related documents
4. Proceed with implementation

This replaces the old model where stories had to contain all necessary information.

---

## Handoff Document Protocol

The **handoff document** (`docs/handoff.md`) maintains context across phase transitions.

### Purpose
- Single evolving document (never replace, always update)
- Tracks phase history and decisions
- Contains entry points for next phase
- **REQUIRED:** Open questions section for each handoff

### Key Sections

| Phase | Required Section |
|-------|------------------|
| Analyst → Architect | "Open Questions for Architect" |
| Architect → Developer | "Open Questions for Developer" |
| Developer (completion) | "Implementation Notes" |

### Generation

```bash
# Via skill
/skills:handoff

# Via mode command
*handoff

# Via PowerShell
.\.mlda\scripts\mlda-handoff.ps1 -Phase analyst -Status completed
```

### Workflow

1. **Analyst completes work** → Runs `*handoff` → Populates open questions
2. **Architect reviews** → Reads handoff first → Resolves questions → Runs `*handoff`
3. **Developer implements** → Reads handoff for context → Updates with implementation notes

---

## Git Conventions

### Commit Messages
- Keep commit messages clean and concise
- Focus on the "why" not just the "what"

### Branch Safety
- Never force push to main/master
- Always verify before destructive operations
- Create feature branches for significant changes

---

## Development Servers

Never start dev servers - assume they are already running.

---

## Universal Commands

All modes support these commands:
- `*help` - Show available commands for current mode
- `*exit` - Leave current mode
- `*yolo` - Toggle autonomous mode (when supported)

---

## External Agent Integration

For team members using other AI agents (Claude Code standalone, Augment Code, Gemini, etc.):

- **Consumer Protocol**: See `docs/MLDA-Consumer-Protocol.md`
- **Integration Templates**: See `docs/integration/`
  - `claude-code-integration.md`
  - `augment-code-integration.md`
  - `generic-agent-integration.md`

External agents can navigate MLDA documentation by:
1. Starting from `docs/handoff.md` or story files
2. Using `.mlda/registry.yaml` for DOC-ID lookups
3. Following relationship types (depends-on → always, extends → if needed)

---

## Deprecated Modes

The following modes are deprecated (January 2026) and will be removed in February 2026:
- `/modes:pm` → Use `/modes:analyst`
- `/modes:po` → Use `/modes:analyst`
- `/modes:sm` → Use `/modes:analyst`
- `/modes:qa` → Use `/modes:dev`

These roles have been consolidated into the 3-role workflow to reduce handoffs and improve context preservation.

---

*RMS-BMAD Methodology v1.1 | Rules Layer*
