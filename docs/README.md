# BLKWDS Manager Documentation

This directory contains the documentation for the BLKWDS Manager application.

## Single Source of Truth

The **[Project Status](project_status.md)** document is the definitive source of truth for the BLKWDS Manager project. It contains:

- Current version and project phase
- Feature status and completion percentages
- Known issues and their status
- Detailed next steps and implementation plans
- Recent changes and version history

All other documentation should be considered supplementary to this document.

## Development Journal

The **[Development Journal](development_journal.md)** provides a chronological record of development activities, including:

- Daily development activities and decisions
- Implementation details and rationale
- Challenges encountered and solutions applied
- Progress tracking over time

## Implementation Plans

Detailed implementation plans for specific features and improvements are stored in the [implementation_plans](implementation_plans/) directory:

- **[Database Service Wrapper Refactoring](implementation_plans/database_service_wrapper_refactoring.md)** - Plan for refactoring database operations to use the wrapper consistently

## Technical Documentation

### Database

- **[Database Migration System](database_migration_system.md)** - Framework for database schema migrations
- **[Database Error Handling](database_error_handling.md)** - Error handling system for database operations
- **[Database Integrity Checks](database_integrity_checks.md)** - Integrity check system for database operations

### Architecture

- **[Architecture and Tech Stack](architecture/architecture_and_tech_stack.md)** - Overview of the application architecture

## Testing Documentation

- **[Testing Strategy](testing_strategy.md)** - Overall testing approach and methodology
- **[Studio System Testing Checklist](testing/studio_system_checklist.md)** - Testing plan for the studio management system

## Documentation Guidelines

1. **Single Source of Truth**: The project_status.md file is the definitive source of truth. All other documentation should be consistent with it.

2. **Keep Documentation Current**: Update documentation as code changes. Documentation that becomes outdated should be updated or removed.

3. **Clear Structure**: Use consistent formatting and organization across all documentation files.

4. **Implementation Plans**: All implementation plans should be stored in the implementation_plans directory with clear, descriptive filenames.

5. **Cross-Reference**: Link related documents to provide a cohesive documentation experience.

6. **Code Examples**: Include relevant code examples where appropriate to illustrate concepts.

7. **Avoid Duplication**: Information should not be duplicated across multiple documents. Instead, reference the authoritative source.

**Last Updated**: 2025-06-28
