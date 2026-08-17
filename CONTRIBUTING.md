# Contributing

Thank you for helping make ancient-text reconstruction more reproducible.

## Before opening a pull request

1. Discuss scholarly model changes in an issue or RFC first.
2. Never replace diplomatic readings with automated output.
3. Include provenance, license, and checksum metadata for imported artifacts.
4. Add a regression fixture for changes to normalization, EpiDoc, or ranking.
5. Run `bin/ci` locally.

## Development

Use `bin/setup` for the initial environment and `bin/dev` for the application.
Tests use RSpec. Keep service objects deterministic and avoid network access in
models, controllers, tests, and exports.

## Data contributions

Large or restrictively licensed files do not belong in Git. Submit a manifest
that points to the canonical source and records its checksum, citation,
attribution, and license. Test fixtures must be original, public domain, or
small transformations whose redistribution is explicitly permitted.

