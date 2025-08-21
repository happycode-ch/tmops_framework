# TeamOps v7 Documentation

This directory contains the documentation for TeamOps Framework v7, which introduces automated orchestration using Claude Code's subagents and hooks capabilities.

## Key Features
- Single-command orchestration
- Automated TDD workflow
- Role-based context isolation
- Zero manual coordination

## Documentation Structure
- `README.md` - This overview document
- `architecture.md` - Technical architecture and design
- `setup_guide.md` - Installation and configuration
- `migration_guide.md` - Migrating from v6 to v7
- `troubleshooting.md` - Common issues and solutions
- `examples/` - Example workflows and use cases

## Quick Start with hello-v7

Test TeamOps v7 with the included hello-v7 example:

```bash
# Validate setup
./tmops_tools/v7/test/validate_hello_v7.sh

# Run the automated workflow
TMOPS_V7_ACTIVE=1 claude "Build hello-v7 feature using TeamOps v7"
```

The hello-v7 feature demonstrates a complete TDD workflow in ~5 minutes with zero manual intervention. See `examples/hello-v7-walkthrough.md` for details.