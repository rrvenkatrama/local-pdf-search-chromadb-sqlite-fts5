# Project Context — v1 (Chroma + SQLite FTS5)

_Last updated: 2026-07-15_

## What this is
v1 of a fully-local hybrid PDF search engine over `~/Documents`.
Repo: https://github.com/rrvenkatrama/local-pdf-search-chromadb-sqlite-fts5
(private; renamed from `local-pdf-search-kb` — this FOLDER kept its original
name, so folder and repo names differ).
Successor: https://github.com/rrvenkatrama/local-pdf-search-qdrant
(`/Users/rajeshramani/ai/local-pdf-search-qdrant`) — built because v1 results
felt more keyword- than semantic-driven (MiniLM 384-dim was the limiter).
Both editions run side by side.

## Current deployed state (this Mac)
- UI: http://localhost:8130/ — launchd agent `com.rajesh.pdfkb.server`
  (always on, KeepAlive)
- Daily indexer 08:00 — `com.rajesh.pdfkb.indexer`
- Index: 1,347 PDFs / ~278K chunks; 240 scanned PDFs skipped (no text layer),
  9 encrypted skipped, 8 genuinely-corrupt files fail on every run (expected)
- All generated data in `data/` (gitignored): `chroma/`, `kb.db`, `index.log`

## Architecture in one line
indexer.py (crawl → sentence-chunk → MiniLM embed → Chroma + FTS5) ⇢
server.py (query both engines → RRF merge in Python → snippets) ⇢
static/index.html. Full design + decisions: `plan.txt`, README.

## Known quirks
- Embedded-Chroma staleness: server refreshes its Chroma client when it sees
  a new completed run id (server.py `_refresh_vectors_if_new_run`).
- Chroma `add()` capped at ~5,461 points → batched in kb/vectors.py.
- Owner's own name ("Rajesh Ramani") has LOW IDF in his own corpus, so
  name queries rank counterintuitively — by design, not a bug.
- `PDF Search KB.code-workspace` is a multi-root workspace including v2.
