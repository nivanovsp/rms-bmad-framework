---
description: 'Split monolithic documents into properly modular MLDA documents'
---
# Split Document Skill

**RMS Skill** | Discrete workflow for splitting monolithic documents into modules

Split a monolithic document into multiple focused MLDA documents with proper relationships.

## Purpose

When the architect identifies a document that describes multiple systems/modules that should be separate, this skill provides a structured workflow to:
1. Analyze the document for natural split points
2. Create new focused documents with DOC-IDs
3. Establish proper MLDA relationships
4. Update references in other documents
5. Deprecate (supersede) the original

## Prerequisites

- MLDA must be initialized (`.mlda/` folder exists)
- Document to split has been reviewed and marked SPLIT REQUIRED
- Understanding of what modules should result from the split

## Workflow

### Step 1: Analyze Document Structure

Read the monolithic document and identify:
- Distinct concepts/modules that should be separate
- Natural boundaries (different domains, different responsibilities)
- Shared content that needs duplication or extraction

Example analysis:
```
DOC-AUTH-001 (Authentication System Design)
├── User Registration      → Should be: DOC-AUTH-002
├── Login/Logout           → Should be: DOC-AUTH-003
├── Password Reset         → Should be: DOC-AUTH-004
├── Session Management     → Should be: DOC-AUTH-005
└── OAuth Integration      → Should be: DOC-AUTH-006
```

### Step 2: Plan New Documents

Create a split plan:

| New DOC-ID | Title | Content from Original | Domain |
|------------|-------|----------------------|--------|
| DOC-AUTH-002 | User Registration | Sections 2.1-2.3 | AUTH |
| DOC-AUTH-003 | Login Flow | Sections 3.1-3.5 | AUTH |
| ... | ... | ... | ... |

### Step 3: Create New Documents

For each new document:

1. **Create the document** using MLDA protocol:
   ```bash
   .\.mlda\scripts\mlda-create.ps1 -Title "User Registration" -Domain AUTH
   ```

2. **Copy relevant content** from original document

3. **Create sidecar** with relationships:
   ```yaml
   doc_id: DOC-AUTH-002
   title: User Registration
   domain: AUTH
   status: draft
   created: 2026-01-16
   modified: 2026-01-16
   author: Winston (Architect)

   related:
     - doc_id: DOC-AUTH-003
       type: references
       why: "Login depends on registered users"
     - doc_id: DOC-AUTH-001
       type: supersedes
       why: "This document replaces the registration section of the original"

   tags:
     - authentication
     - registration
   ```

### Step 4: Update Original Document

Transform the original into a **summary document** that:
1. Provides overview of the authentication system
2. References all the new detailed documents
3. Acts as an entry point/index

Update original sidecar:
```yaml
doc_id: DOC-AUTH-001
title: Authentication System Overview
status: superseded-partial
note: "Detailed content split into DOC-AUTH-002 through DOC-AUTH-006"

related:
  - doc_id: DOC-AUTH-002
    type: references
    why: "User registration details"
  - doc_id: DOC-AUTH-003
    type: references
    why: "Login flow details"
  # ... etc
```

### Step 5: Update Referencing Documents

Find all documents that reference the original:
1. Search for `DOC-AUTH-001` across all documents
2. Update references to point to appropriate new document(s)
3. Update sidecars with new relationships

### Step 6: Update Registry

Run registry update:
```bash
.\.mlda\scripts\mlda-registry.ps1
```

### Step 7: Validate

Run validation:
```bash
.\.mlda\scripts\mlda-validate.ps1
```

Check for:
- No orphan documents
- No broken links
- All new documents properly registered

## Split Decision Criteria

When to split:
| Indicator | Action |
|-----------|--------|
| Document > 500 lines | Consider splitting |
| Multiple distinct responsibilities | Split by responsibility |
| Different teams would own parts | Split by ownership |
| Different deployment units | Split by deployment |
| Mixed domains (AUTH + API) | Split by domain |

When NOT to split:
| Indicator | Action |
|-----------|--------|
| Cohesive single concept | Keep together |
| Would create circular dependencies | Reconsider structure |
| Content is inherently sequential | Keep as one |

## Output

1. Create N new focused documents with DOC-IDs
2. Create sidecars for each new document
3. Update original to summary/index role
4. Update all referencing documents
5. Update registry
6. Validate MLDA integrity

## Document Handoff Update

After splitting, update `docs/handoff.md`:

```markdown
### Documents Split

| Original | New Documents | Rationale |
|----------|---------------|-----------|
| DOC-AUTH-001 | DOC-AUTH-002, 003, 004, 005, 006 | Monolithic auth design split into focused modules |

#### Split Details: DOC-AUTH-001

**Before:** Single 800-line document covering all auth functionality
**After:**
- DOC-AUTH-001: Overview (50 lines, entry point)
- DOC-AUTH-002: User Registration (150 lines)
- DOC-AUTH-003: Login Flow (200 lines)
- DOC-AUTH-004: Password Reset (100 lines)
- DOC-AUTH-005: Session Management (180 lines)
- DOC-AUTH-006: OAuth Integration (220 lines)

**Benefits:**
- Each module can be developed independently
- Clear ownership boundaries
- Easier to navigate and update
```

## Key Principles

- Split by responsibility, not by size alone
- Maintain MLDA relationship integrity
- Update ALL references to original
- Original becomes summary/index, not deleted
- Run validation after splitting
- Document the split in handoff
