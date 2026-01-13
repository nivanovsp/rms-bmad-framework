---
description: 'Initialize new project with optional MLDA documentation scaffolding'
---
# Initialize Project Skill

**RMS Skill** | Project initialization with MLDA (Modular Linked Documentation Architecture) setup

## Purpose

When starting a new project or folder that will contain significant documentation, this skill:

1. Assesses documentation scope
2. Scaffolds MLDA infrastructure if threshold is met
3. Sets up domain-specific folders
4. Initializes the document registry

## Execution Flow

### Step 1: Assess Documentation Scope

Ask the user:

```
What is the expected documentation volume for this project?

1. Documentation-heavy (15+ documents expected) - MLDA recommended
2. Code-focused (fewer than 15 documents) - Manual linking sufficient
3. Not sure yet - I'll help you assess

Select 1-3:
```

**If option 1:** Proceed to Step 2
**If option 2:** Inform user they can run this skill later if needs change. Exit.
**If option 3:** Ask clarifying questions about project scope, then recommend based on answers.

### Step 2: Select Documentation Domains

Present domain options:

```
Select documentation domains for this project (comma-separated numbers):

1. API - API specifications, endpoints, contracts
2. AUTH - Authentication, authorization, identity
3. DATA - Data models, schemas, migrations
4. INV - Invoicing, billing, payments
5. SEC - Security, compliance, auditing
6. UI - User interface, components, UX
7. INFRA - Infrastructure, DevOps, deployment
8. INT - Integrations, third-party services
9. TEST - Testing strategies, test plans
10. DOC - General documentation, guides
11. Custom domain (specify)

Example: 1,3,5 or 1-5,8

Select domains:
```

### Step 3: Confirm Target Location

```
MLDA will be initialized at: {current_directory}/.mlda/

Confirm location?
1. Yes, proceed
2. No, specify different path
3. Cancel

Select 1-3:
```

### Step 4: Execute Scaffolding

Run the scaffolding process:

1. **Create `.mlda/` folder structure:**
   ```
   .mlda/
   ├── docs/
   │   └── {selected-domains}/
   ├── scripts/
   │   ├── mlda-create.ps1
   │   ├── mlda-registry.ps1
   │   ├── mlda-validate.ps1
   │   └── mlda-brief.ps1
   ├── templates/
   │   ├── topic-doc.md
   │   └── topic-meta.yaml
   ├── registry.yaml
   └── README.md
   ```

2. **Copy scripts from methodology source** (if available) or create new ones

3. **Initialize registry.yaml:**
   ```yaml
   # MLDA Document Registry
   project: {project_name}
   created: {date}
   domains: [{selected_domains}]

   documents: []
   ```

4. **Create README.md** with project-specific instructions

### Step 5: Provide Next Steps

```
MLDA initialized successfully!

Created:
- .mlda/docs/{domains}/
- .mlda/scripts/ (4 scripts)
- .mlda/templates/ (2 templates)
- .mlda/registry.yaml
- .mlda/README.md

Next steps:
1. Create new documents: .mlda/scripts/mlda-create.ps1 -Title "Doc Name" -Domain API
2. Rebuild registry: .mlda/scripts/mlda-registry.ps1
3. Validate links: .mlda/scripts/mlda-validate.ps1

For existing documents, add .meta.yaml sidecars manually or use migration guidance.
```

## Domain Codes Reference

| Code | Domain | DOC-ID Format |
|------|--------|---------------|
| API | API specifications | DOC-API-NNN |
| AUTH | Authentication | DOC-AUTH-NNN |
| DATA | Data models | DOC-DATA-NNN |
| INV | Invoicing | DOC-INV-NNN |
| SEC | Security | DOC-SEC-NNN |
| UI | User Interface | DOC-UI-NNN |
| INFRA | Infrastructure | DOC-INFRA-NNN |
| INT | Integrations | DOC-INT-NNN |
| TEST | Testing | DOC-TEST-NNN |
| DOC | General docs | DOC-DOC-NNN |

Custom domains use format: DOC-{CUSTOM}-NNN

## Migration Mode

If existing documents are detected in the target folder, offer migration:

```
Detected {N} existing markdown files in this folder.

Would you like to:
1. Scaffold MLDA and migrate existing docs (add .meta.yaml sidecars)
2. Scaffold MLDA only (migrate manually later)
3. Cancel

Select 1-3:
```

**If option 1:**
- Create `.meta.yaml` sidecar for each existing `.md` file
- Assign DOC-IDs sequentially
- Add to registry.yaml
- Report: "Migrated {N} documents. Review .meta.yaml files to add relationships."

## Error Handling

| Situation | Response |
|-----------|----------|
| `.mlda/` already exists | Ask: Overwrite, merge, or cancel? |
| No write permission | Report error, suggest alternative location |
| Invalid domain code | Show valid options, ask again |
| Script copy fails | Create minimal scripts inline |

## Dependencies

```yaml
scripts:
  - mlda-init-project.ps1
  - mlda-create.ps1
  - mlda-registry.ps1
  - mlda-validate.ps1
  - mlda-brief.ps1
templates:
  - topic-doc.md
  - topic-meta.yaml
```

## Invocation

This skill can be invoked via:
- `/skills:init-project`
- `*init-project` (when in analyst mode)
- `*init-mlda` (alias)
