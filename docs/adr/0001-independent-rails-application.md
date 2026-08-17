# ADR 0001: Independent Rails application

Status: accepted

Sutura Scrolls is a standalone Rails application, not an AKRO module or Rails
Engine. This keeps installation, licensing, review governance, and scientific
reproducibility independent from AKRO's product infrastructure. AKRO may consume
the read-only API later. An engine will be considered only after a second host
application demonstrates a stable shared boundary.

Rails owns presentation, persistence, review, import orchestration, and export.
External research pipelines communicate through versioned EpiDoc/JSONL schemas;
Python is not a required runtime.

