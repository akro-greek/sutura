# Reproducibility guide

## Development fixture

The repository includes a synthetic PHerc. 1667-shaped fixture so every UI and
contract can be tested without redistributing source data.

```bash
bin/setup --skip-server
bin/sutura import data/manifests/pherc-1667/demo.yml
bin/sutura import data/manifests/pherc-1667/demo.yml
bin/sutura export pherc-1667
bundle exec rspec
```

The second import must report the same counts and create no duplicate domain
records. Generated files appear under `tmp/exports/pherc-1667`.

## Real sources

Create a new manifest instead of editing the demo fixture. For every artifact,
record its canonical URL, access date, cryptographic checksum, license, and
scholarly citation. Large source files, tiles, and model weights are excluded
from Git. Never infer a permissive data license from the Apache license on the
application code.

## Search runs

Record corpus release identifiers and the embedding model in an `IndexRun`.
Candidate matches retain the algorithm version, per-channel ranks, combined
score, and detailed evidence. This allows a ranking to be reconstructed even
after the active index changes.
