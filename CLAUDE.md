# CLAUDE.md - AI Assistant Guide

> **Last Updated:** 2026-01-11
> **Repository:** Nlabrakis/Claude
> **Purpose:** Comprehensive guide for AI assistants working with this codebase

---

## 📋 Table of Contents

1. [Repository Overview](#repository-overview)
2. [Codebase Structure](#codebase-structure)
3. [Development Workflows](#development-workflows)
4. [Key Conventions](#key-conventions)
5. [Architecture & Design Patterns](#architecture--design-patterns)
6. [Common Tasks](#common-tasks)
7. [Testing Strategy](#testing-strategy)
8. [Deployment & CI/CD](#deployment--cicd)
9. [AI Assistant Best Practices](#ai-assistant-best-practices)
10. [Troubleshooting](#troubleshooting)

---

## Repository Overview

### Project Description
<!-- TODO: Add project description -->
This repository is currently being initialized. Update this section with:
- Project purpose and goals
- Target audience/users
- Key features and functionality
- Technology stack overview

### Technology Stack
<!-- TODO: Add technology stack details -->
- **Language(s):** TBD
- **Framework(s):** TBD
- **Database:** TBD
- **Build Tools:** TBD
- **Testing:** TBD
- **CI/CD:** TBD

### Quick Start
```bash
# Clone the repository
git clone <repository-url>
cd Claude

# TODO: Add setup commands
# Example:
# npm install
# cp .env.example .env
# npm run dev
```

---

## Codebase Structure

### Directory Layout
```
.
├── CLAUDE.md           # This file - AI assistant guide
├── README.md           # User-facing documentation (TODO)
├── .gitignore          # Git ignore patterns (TODO)
└── [Project directories will be documented here as they're added]
```

### Key Directories
<!-- Update as directories are added -->
- **`/src`** - Source code (if applicable)
- **`/tests`** - Test files
- **`/docs`** - Additional documentation
- **`/scripts`** - Build and utility scripts
- **`/config`** - Configuration files

### Important Files
<!-- Update as files are added -->
- **Configuration:** TBD
- **Entry Points:** TBD
- **Core Modules:** TBD

---

## Development Workflows

### Branch Strategy

**Branch Naming Convention:**
- Feature branches: `claude/feature-description-{sessionId}`
- Bug fixes: `claude/fix-description-{sessionId}`
- Hotfixes: `claude/hotfix-description-{sessionId}`

**Current Branch:** `claude/add-claude-documentation-KDx4s`

### Git Workflow

1. **Always develop on designated feature branches**
   ```bash
   git checkout -b claude/feature-name-{sessionId}
   ```

2. **Commit frequently with clear messages**
   ```bash
   git add .
   git commit -m "type: clear description of changes"
   ```

3. **Push to remote when ready**
   ```bash
   git push -u origin claude/feature-name-{sessionId}
   ```

### Commit Message Format
```
type: Brief description (50 chars or less)

More detailed explanation if needed (wrap at 72 chars).
Explain the problem this solves and why this approach.

- Bullet points are acceptable
- Use imperative mood: "Add feature" not "Added feature"
```

**Commit Types:**
- `feat` - New feature
- `fix` - Bug fix
- `docs` - Documentation changes
- `style` - Code style/formatting (no logic change)
- `refactor` - Code refactoring
- `test` - Adding or updating tests
- `chore` - Maintenance tasks
- `perf` - Performance improvements

---

## Key Conventions

### Code Style
<!-- Update based on project's code style -->
- **Formatting:** TBD (Prettier, Black, gofmt, etc.)
- **Linting:** TBD (ESLint, pylint, etc.)
- **Line Length:** TBD (80, 100, 120 chars)
- **Indentation:** TBD (spaces vs tabs, size)

### Naming Conventions
<!-- Update based on project's naming conventions -->
- **Variables:** TBD (camelCase, snake_case, etc.)
- **Functions:** TBD
- **Classes:** TBD (PascalCase typical)
- **Constants:** TBD (UPPER_SNAKE_CASE typical)
- **Files:** TBD (kebab-case, snake_case, etc.)

### File Organization
- Keep files focused and single-purpose
- Maximum file length: TBD (500-1000 lines typical)
- Group related functionality together
- Use index files for clean exports (if applicable)

### Documentation Standards
- **Inline Comments:** Explain "why", not "what"
- **Function Docs:** Document public APIs, parameters, returns, errors
- **README Files:** Each major directory should have context
- **Architecture Decisions:** Document in ADRs or design docs

---

## Architecture & Design Patterns

### System Architecture
<!-- TODO: Add architecture diagram or description -->
```
[Architecture diagram or description will go here]
```

### Design Patterns Used
<!-- Update as patterns are adopted -->
- TBD

### Data Flow
<!-- Update as architecture is defined -->
```
User → [Component] → [Service] → [Database]
```

### API Structure
<!-- If applicable -->
- **REST API:** TBD
- **GraphQL:** TBD
- **Authentication:** TBD
- **Rate Limiting:** TBD

---

## Common Tasks

### Running the Project
```bash
# TODO: Add run commands
# npm start / python main.py / go run main.go / etc.
```

### Building
```bash
# TODO: Add build commands
# npm run build / make build / etc.
```

### Testing
```bash
# Run all tests
# TODO: Add test command

# Run specific test file
# TODO: Add specific test command

# Run with coverage
# TODO: Add coverage command
```

### Linting & Formatting
```bash
# Check code style
# TODO: Add lint command

# Auto-fix formatting
# TODO: Add format command
```

### Database Operations
```bash
# Run migrations
# TODO: Add migration command

# Seed database
# TODO: Add seed command

# Reset database
# TODO: Add reset command
```

---

## Testing Strategy

### Test Types
<!-- Update based on testing approach -->
- **Unit Tests:** Test individual functions/methods
- **Integration Tests:** Test component interactions
- **End-to-End Tests:** Test complete user flows
- **Performance Tests:** Test system under load

### Test Coverage Goals
- Target: TBD% coverage
- Critical paths must have 100% coverage
- New features require tests before merge

### Writing Tests
```
# TODO: Add test example for this project
```

### Running Tests Locally
```bash
# TODO: Add local test commands
```

---

## Deployment & CI/CD

### Environments
<!-- Update as environments are configured -->
- **Development:** TBD
- **Staging:** TBD
- **Production:** TBD

### CI/CD Pipeline
<!-- Update as CI/CD is configured -->
- **CI Tool:** TBD (GitHub Actions, GitLab CI, etc.)
- **Build Steps:** TBD
- **Test Steps:** TBD
- **Deploy Steps:** TBD

### Deployment Process
```bash
# TODO: Add deployment commands/process
```

---

## AI Assistant Best Practices

### Before Making Changes

1. **Read Existing Code First**
   - NEVER propose changes to code you haven't read
   - Use `Read` tool to examine files before modification
   - Understand context and existing patterns

2. **Explore the Codebase**
   - Use `Glob` to find relevant files
   - Use `Grep` to search for patterns
   - Use `Task` tool with `Explore` agent for comprehensive searches

3. **Check for Tests**
   - Look for existing test files
   - Understand test patterns before writing new tests

### While Making Changes

1. **Follow Existing Patterns**
   - Match the style of surrounding code
   - Use same naming conventions
   - Follow established architectural patterns

2. **Keep Changes Focused**
   - Don't refactor unrelated code
   - Don't add unnecessary features
   - Avoid over-engineering solutions

3. **Write Secure Code**
   - Avoid SQL injection vulnerabilities
   - Prevent XSS attacks
   - Validate user input
   - Use parameterized queries
   - Sanitize outputs

4. **Track Your Work**
   - Use `TodoWrite` tool for multi-step tasks
   - Mark tasks as in_progress before starting
   - Mark completed immediately after finishing

### After Making Changes

1. **Test Your Changes**
   - Run existing tests to ensure nothing broke
   - Add tests for new functionality
   - Verify in development environment if possible

2. **Commit Properly**
   - Use clear, descriptive commit messages
   - Follow commit message format
   - Group related changes in single commits

3. **Update Documentation**
   - Update CLAUDE.md if patterns change
   - Update README.md if user-facing changes
   - Add inline comments for complex logic

### Code Review Checklist

Before committing, verify:
- [ ] Code follows project conventions
- [ ] No security vulnerabilities introduced
- [ ] Tests pass (or added if new feature)
- [ ] No unintended side effects
- [ ] Documentation updated if needed
- [ ] No debugging code left behind
- [ ] Error handling is appropriate
- [ ] Performance is acceptable

---

## Troubleshooting

### Common Issues

#### Build Failures
<!-- TODO: Add common build issues and solutions -->

#### Test Failures
<!-- TODO: Add common test issues and solutions -->

#### Runtime Errors
<!-- TODO: Add common runtime issues and solutions -->

### Getting Help

1. **Check Documentation**
   - README.md for user-facing docs
   - This file (CLAUDE.md) for development guidance
   - Inline code comments for specific implementations

2. **Search Codebase**
   - Use Grep to find similar implementations
   - Look for related test files
   - Check git history for context

3. **Verify Environment**
   - Check that dependencies are installed
   - Verify environment variables are set
   - Ensure correct versions of tools

---

## Maintenance Notes

### Updating This Document

This CLAUDE.md file should be updated when:
- New directories or major files are added
- Development workflows change
- New conventions are adopted
- Architecture evolves
- Common issues are discovered

### Document Status

**Current Status:** 🟡 Template - Needs population as project develops

**Next Updates Needed:**
- [ ] Add actual technology stack details
- [ ] Document directory structure as it's created
- [ ] Add specific setup and run commands
- [ ] Document code style and conventions
- [ ] Add architecture diagrams
- [ ] Include actual test examples
- [ ] Document CI/CD pipeline
- [ ] Add troubleshooting guides

---

## Additional Resources

### External Documentation
<!-- Add links to relevant external docs -->
- [Project Wiki](TBD)
- [API Documentation](TBD)
- [Design Documents](TBD)

### Related Repositories
<!-- Add links to related repositories -->
- TBD

### Tools & Services
<!-- Add links to tools and services used -->
- TBD

---

**Note for AI Assistants:** This is a living document. As you work with this codebase, please update this file to reflect the actual state of the project. Your future self (and other AI assistants) will thank you!
