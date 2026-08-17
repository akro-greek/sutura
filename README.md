# Sutura Scrolls

**Open-source textual reconstruction infrastructure by AKRO.**

Sutura connects a line on a virtually unwrapped scroll to its diplomatic
reading, normalized text, corpus parallels, review history, and scholarly
exports. The first vertical slice is built around PHerc. 1667 and is designed
to be evaluated as a guided public showcase before any Challenge submission.

> [!IMPORTANT]
> The repository ships a clearly labelled showcase using six excerpts from the
> published PHerc. 1667 transcription and the official remote complete-surface
> rendering. It is not a complete local redistribution. Comparison links are
> unreviewed product demonstrations and keep that status in the interface.

## What works in the foundation release

- public scroll, column, and line permalinks;
- synchronized line/image-region metadata;
- diplomatic, Unicode, search, and accent-folded text representations;
- explainable lexical and lemma candidate matching;
- invitation-only reviewer decisions with an append-only audit trail;
- read-only JSON API;
- deterministic EpiDoc XML, JSON-LD, and CSV exports;
- manifest and JSONL import contracts;
- PostgreSQL/pgvector-ready data model and background indexing jobs.

## Local setup

Requirements: Ruby 3.4.5, PostgreSQL 16+ with `pgvector`, and libvips.

```bash
bin/setup
bin/dev
```

Then open <http://localhost:3000> and choose **Start the 3-minute tour**. The development reviewer account is printed
by `db:seed` only when `SEED_REVIEWER_PASSWORD` is explicitly supplied.

Docker users can run:

```bash
docker compose up --build
```

## Data interchange

```bash
bin/sutura import data/manifests/pherc-1667/showcase.yml
bin/sutura import_epidoc path/to/document.xml --scroll=pherc-1667
bin/sutura import_jsonl path/to/passages.jsonl --scroll=pherc-1667
bin/sutura index
bin/sutura export pherc-1667
```

Schemas live in [`schemas/`](schemas/). See [`docs/rfc-001.md`](docs/rfc-001.md),
[`docs/architecture.md`](docs/architecture.md), and
[`docs/reproducibility.md`](docs/reproducibility.md) for the product,
architecture, and repeatable research workflow.

## Project status

The application is an independent Rails monolith. It does not depend on AKRO's
production application, accounts, database, or private APIs. The public
showcase is ready for colleague evaluation before importing the full published
transcription or preparing a Vesuvius Challenge submission.

## License

Code is licensed under Apache-2.0. Data and model artifacts retain their source
licenses; see each manifest's `data_license` and `citation` fields.
