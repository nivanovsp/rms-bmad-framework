---
description: 'Generate test cases from story before implementation (test-first)'
---
# Create Test Cases Skill

**RMS Skill** | Discrete workflow for test-first development

Generate comprehensive test cases from a story BEFORE implementation begins.

## Purpose

The Developer+QA role follows test-first methodology. This skill:
1. Analyzes story and acceptance criteria
2. Navigates MLDA to gather full context
3. Generates test cases for all scenarios
4. Creates test file structure ready for implementation

## Prerequisites

- Story exists with acceptance criteria
- MLDA context gathered (run `*explore` on story DOC-IDs first)
- Understanding of project test framework

## Workflow

### Step 1: Read Story and Acceptance Criteria

Parse the story for:
- **Given/When/Then** acceptance criteria
- **DOC-ID references** for context navigation
- **Edge cases** mentioned or implied
- **Error conditions** to handle

### Step 2: Navigate MLDA for Context

For each DOC-ID in the story:
1. Run `*explore {DOC-ID}` to gather context
2. Follow `depends-on` relationships
3. Note validation rules, constraints, business rules
4. Identify integration points

### Step 3: Categorize Test Scenarios

Organize tests into categories:

| Category | Description | Priority |
|----------|-------------|----------|
| **Happy Path** | Normal successful flow | Must have |
| **Edge Cases** | Boundary conditions | Must have |
| **Error Handling** | Invalid inputs, failures | Must have |
| **Integration** | Cross-component behavior | Should have |
| **Performance** | Load, response time | Could have |
| **Security** | Auth, injection, XSS | Must have (if applicable) |

### Step 4: Generate Test Cases

For each acceptance criterion, create test cases:

```markdown
## Test Cases for Story {epic}.{story}

### Story: {Title}

### Acceptance Criterion 1: {Description}

#### TC-001: Happy Path - {Scenario}
- **Given:** {Preconditions}
- **When:** {Action}
- **Then:** {Expected result}
- **Priority:** High
- **Type:** Unit/Integration/Functional

#### TC-002: Edge Case - {Scenario}
- **Given:** {Preconditions}
- **When:** {Action with boundary value}
- **Then:** {Expected result}
- **Priority:** High
- **Type:** Unit

#### TC-003: Error - {Scenario}
- **Given:** {Preconditions}
- **When:** {Invalid action}
- **Then:** {Error handling behavior}
- **Priority:** High
- **Type:** Unit

### Acceptance Criterion 2: {Description}
...
```

### Step 5: Create Test File Structure

Based on project conventions, create test file(s):

**For TypeScript/JavaScript:**
```typescript
// tests/{feature}/{story-slug}.test.ts

describe('Story {epic}.{story}: {Title}', () => {
  describe('AC1: {Acceptance Criterion}', () => {
    it('TC-001: should {expected behavior} when {action}', () => {
      // Arrange
      // Act
      // Assert
    });

    it('TC-002: should handle edge case when {condition}', () => {
      // Arrange
      // Act
      // Assert
    });

    it('TC-003: should return error when {invalid condition}', () => {
      // Arrange
      // Act
      // Assert - expect error
    });
  });

  describe('AC2: {Acceptance Criterion}', () => {
    // ...
  });
});
```

**For Python:**
```python
# tests/{feature}/test_{story_slug}.py

class TestStory{Epic}{Story}:
    """Story {epic}.{story}: {Title}"""

    class TestAC1:
        """AC1: {Acceptance Criterion}"""

        def test_tc001_happy_path(self):
            """TC-001: should {expected behavior} when {action}"""
            # Arrange
            # Act
            # Assert

        def test_tc002_edge_case(self):
            """TC-002: should handle edge case when {condition}"""
            pass

        def test_tc003_error_handling(self):
            """TC-003: should return error when {invalid condition}"""
            pass
```

## Test Case ID Convention

`TC-{NNN}` where:
- NNN is sequential within the story
- Group by acceptance criterion
- Prefix with category for clarity in reports

Examples:
- `TC-001` - First test case
- `TC-HP-001` - Happy path test 1
- `TC-EC-001` - Edge case test 1
- `TC-ERR-001` - Error handling test 1

## Coverage Requirements

Minimum coverage for each story:

| Acceptance Criterion | Required Tests |
|---------------------|----------------|
| Each AC | At least 1 happy path |
| Each AC | At least 1 edge case |
| Each AC | At least 1 error case |
| Integration points | At least 1 integration test |

## Output

1. **Test case document** in `docs/test-cases/{epic}.{story}-test-cases.md`
2. **Test file skeleton** in appropriate test directory
3. **Update story** with test case reference
4. **Update handoff** with test coverage summary

### Story Update

Add to story file:
```markdown
## Test Cases

Test cases: [docs/test-cases/{epic}.{story}-test-cases.md](../test-cases/{epic}.{story}-test-cases.md)

| Category | Count |
|----------|-------|
| Happy Path | 5 |
| Edge Cases | 8 |
| Error Handling | 4 |
| Integration | 2 |
| **Total** | **19** |
```

### Handoff Update

Add to `docs/handoff.md` Phase 3 section:
```markdown
#### Test Cases Created

| Story | Test Cases | Coverage |
|-------|------------|----------|
| 1.1 | 19 | Unit: 15, Integration: 4 |
```

## Key Principles

- Write tests BEFORE implementation
- Cover happy path, edge cases, and errors
- Navigate MLDA for full context
- Test files are ready for implementation to fill in
- Update story and handoff with test references
- Tests document expected behavior
