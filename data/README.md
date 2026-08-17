# Data policy

Git stores manifests, checksums, small synthetic fixtures, and reproducible
import definitions. It does not store full scroll imagery, restricted
transcriptions, corpus dumps, tile pyramids, or embedding weights.

Every real `artifact` entry must contain:

- a stable key and artifact kind;
- canonical source URL or documented local acquisition route;
- SHA-256 checksum;
- access date;
- exact data license;
- citation and attribution.

`manifests/pherc-1667/showcase.yml` is the colleague-preview dataset. It combines
six published transcription excerpts with the official remote complete-surface
rendering and a tiny public-domain comparison corpus. Candidate links are
unreviewed demonstrations, not scholarly assertions.

`manifests/pherc-1667/demo.yml` and `public/demo-scroll.svg` remain synthetic,
CC0 test fixtures. They are not loaded by `db:seed` and must not be cited as
readings of PHerc. 1667.
