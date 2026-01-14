# MLDA Neocortex Paradigm

**DOC-CORE-001** | Architectural Foundation

---

## The Knowledge Graph Model

MLDA is not just a documentation system - it is a **knowledge graph** that agents navigate to gather context. Think of it as a neocortex: a network of interconnected knowledge that agents traverse by following signals through relationships.

---

## The Neocortex Analogy

| Brain Concept | MLDA Equivalent | Description |
|---------------|-----------------|-------------|
| **Neuron** | Document | A single unit storing specific knowledge |
| **Dendrites** | Relationships (`related` in sidecar) | Connections to other documents |
| **Axon** | DOC-ID | The unique identifier that enables connections |
| **Signal** | Agent reading a document | Activation that triggers exploration |
| **Signal Propagation** | Following relationships | Agent traversing from doc to doc |
| **Activation Pattern** | Navigation path | The specific route through the knowledge graph |

---

## How It Works

### 1. Signal Initiation

An agent receives a task (story, epic, or direct request). The task contains **entry points** - DOC-IDs that serve as starting neurons.

```
User: "Implement the transaction tracking feature"
Story references: DOC-INV-015, REQ-A7-T7
                  ↑
                  Entry points (initial signal)
```

### 2. Signal Propagation

The agent reads the entry document. The sidecar's `related` field contains dendrites pointing to connected knowledge:

```yaml
# REQ-A7-T7.meta.yaml
related:
  - id: DOC-INV-015
    why: "Source research document"
  - id: REQ-A5-T7
    why: "Transaction item tracking from create process"
```

The agent decides: "I need to understand the create process first" and follows the dendrite to `REQ-A5-T7`.

### 3. Recursive Exploration

At `REQ-A5-T7`, the agent finds more dendrites:

```yaml
related:
  - id: DOC-DATA-003
    why: "Data model for transaction items"
  - id: DOC-API-007
    why: "API endpoints for transactions"
```

The signal continues propagating until the agent has sufficient context.

### 4. Traversal Termination

The agent stops exploring when:
- Sufficient context is gathered for the task
- Maximum depth is reached (configurable)
- No relevant dendrites remain
- Circular reference detected (already visited)

---

## Key Principles

### Documents Are Not Self-Contained

**Old model:** Stories contain all information needed. Agents should not explore.

**Neocortex model:** Stories are **entry points** into the knowledge graph. Agents must navigate to gather context. No single document contains everything.

### Relationships Are First-Class Citizens

The `related` field in sidecars is not optional metadata - it is the **connective tissue** of the knowledge graph. Without relationships, documents are isolated neurons that cannot participate in signal propagation.

### Agents Are Active Navigators

Agents don't passively receive information - they actively explore the knowledge graph, making decisions about which dendrites to follow based on their task requirements.

### The Registry Is the Index

The registry (`registry.yaml`) provides:
- **Forward lookup:** What does document X relate to?
- **Reverse lookup:** What documents reference X? (computed)
- **Graph overview:** All documents and their connection density

---

## Relationship Types

Dendrites (relationships) have semantic meaning:

| Type | Meaning | Signal Direction |
|------|---------|------------------|
| `depends-on` | Cannot be understood without the target | Strong signal to follow |
| `extends` | Builds upon or adds to target | Follow for deeper detail |
| `references` | Mentions or cites target | Optional exploration |
| `supersedes` | Replaces target (target is outdated) | Follow this, ignore target |

The `why` field explains the reason for the connection, helping agents decide whether to follow.

---

## Navigation Strategies

### Depth-First

Follow one dendrite chain deeply before exploring siblings. Good for understanding a specific aspect thoroughly.

```
A → B → C → D (deep understanding of one path)
    ↓
    E (then explore alternatives)
```

### Breadth-First

Explore all immediate dendrites before going deeper. Good for getting a broad overview.

```
A → B, C, D (understand all immediate connections)
    ↓
B → E, F (then go deeper)
```

### Task-Driven

Follow dendrites that match the task context. Use the `why` field and relationship types to prioritize.

```
Task: "Implement API endpoint"
A → B (why: "API contract") ✓ Follow
A → C (why: "UI mockup") ✗ Skip for now
```

---

## Implications for Document Creation

When creating documents:

1. **Always define relationships** - Documents without dendrites are dead neurons
2. **Use meaningful `why` fields** - Help agents decide whether to follow
3. **Choose appropriate relationship types** - Signal strength varies by type
4. **Consider bidirectionality** - If A depends on B, B might want to know

---

## Implications for Agent Design

Agents must:

1. **Read the registry on activation** - Understand the knowledge landscape
2. **Have navigation commands** - `*explore`, `*related`, `*context`
3. **Track visited documents** - Avoid circular traversal
4. **Respect depth limits** - Don't explore infinitely
5. **Report their path** - Let users see what was explored

---

## Visual Representation

```
                    ┌──────────────┐
                    │  DOC-API-001 │
                    │   (neuron)   │
                    └──────┬───────┘
                           │ dendrite
              ┌────────────┼────────────┐
              ▼            ▼            ▼
        ┌──────────┐ ┌──────────┐ ┌──────────┐
        │DOC-AUTH  │ │DOC-DATA  │ │DOC-SEC   │
        │  -001    │ │  -003    │ │  -002    │
        └────┬─────┘ └────┬─────┘ └──────────┘
             │            │
             ▼            ▼
        ┌──────────┐ ┌──────────┐
        │DOC-AUTH  │ │DOC-DATA  │
        │  -005    │ │  -007    │
        └──────────┘ └──────────┘

Agent signal propagates through the network,
following dendrites based on task requirements.
```

---

## Summary

MLDA transforms documentation from a static reference system into a **living knowledge graph** that agents actively navigate. By modeling documents as neurons and relationships as dendrites, we enable intelligent context gathering that mirrors how information flows through a biological neural network.

The methodology's power comes not from any single document, but from the **emergent understanding** that arises when agents traverse the connections between many focused topic documents.

---

*DOC-CORE-001 | MLDA Neocortex Paradigm | v1.0*
