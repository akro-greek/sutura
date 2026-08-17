# ADR 0002: Explainable hybrid search

- Status: accepted
- Date: 2026-08-13

## Decision

Exact/trigram, lemma sequence, and vector retrieval remain independent search
channels. Reciprocal Rank Fusion combines candidate rankings, while each
channel stores its own `MatchEvidence`. Embeddings are secondary evidence.

## Consequences

Reviewers can inspect matched forms, lemmas, frequencies and ranks. A candidate
can be suggested by vectors but is never exported as accepted without a human
decision. The architecture permits replacing an embedding model without
changing the scholarly record or public contracts.
