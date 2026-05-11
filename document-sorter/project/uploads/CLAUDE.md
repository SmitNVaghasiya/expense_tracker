# Document Sorter — Project Context
> AI-powered document organizer: scans phone storage, transfers files to laptop, clusters by content, labels clusters with LLM.
> **Owner:** Smit | **Stack:** FastAPI + SQLite + ChromaDB + Ollama + Flutter

**Last Updated:** 2026-05-10
**Current Stage:** Stage 1 COMPLETE — moving to Flutter Phase 1A (file scanner)

---

## Read These Files First (Every Session)

| File | What It Covers |
|------|----------------|
| `PROJECT_DECISIONS.md` | Every architectural/code decision — READ THIS |
| `PROJECT_SESSIONS.md` | Important outcomes from past sessions — READ THIS |
| `Plan/Plan.md` | Full pipeline overview (Stages 1-7) |
| `Plan/Stage1.md` | Stage 1 detailed spec — chunked upload, SQLite schema, Flutter protocol |
| `python_server/Details.md` | Backend audit: what exists, what's missing, removed features |
| `python_server/README.md` | How to run backend + tests with exact commands |

---

## Mandatory: Use These Agents Before Every Task

Before starting ANY non-trivial task (new feature, refactor, bug fix), check these tools:

```bash
# Agent kit — multi-agent workflows
npx @vudovn/ag-kit init

# Get-shit-done — task automation
npx get-shit-done-cc@latest
```

**UI/UX Skill Pack** (for frontend work):
- Repo: https://github.com/nextlevelbuilder/ui-ux-pro-max-skill
- Use skills from this pack for any Flutter or web UI decisions

**Rule:** If there's a 1% chance a skill/agent applies → use it. Do NOT skip.

---

## Project Pipeline (All 7 Stages)

```
Stage 1: File Ingestion    — Flutter scans phone → chunked transfer → laptop ✅ BACKEND DONE
Stage 2: Text Extraction   — PDF/DOCX/PPTX/TXT → text (PyMuPDF + OCR)
Stage 3: Dedup Detection   — MD5 exact + MinHash near-duplicate grouping
Stage 4: Embedding         — nomic-embed-text via Ollama → ChromaDB
Stage 5: Clustering        — HDBSCAN on embeddings
Stage 6: Labeling          — qwen3:14b labels clusters, keyword sensitivity rules
Stage 7: Review UI         — HTML/React served by backend, bulk actions
```

---

## Current Folder Structure

```
document_sorter/
├── Plan/
│   ├── Plan.md                — Full pipeline plan
│   └── Stage1.md              — Stage 1 detailed spec
├── python_server/             — FastAPI backend (Stage 1 COMPLETE)
│   ├── main.py                — Entry point, lifespan, router registration
│   ├── app/config.py          — Config (Ollama + Stage 1 paths, Colab removed)
│   ├── database/
│   │   ├── db.py              — SQLite init + connection
│   │   └── models.py          — Pydantic request/response models
│   ├── routes/
│   │   ├── sync.py            — POST /sync/metadata, GET /sync/status
│   │   └── files.py           — init/chunk/complete/progress endpoints
│   ├── services/
│   │   ├── file_service.py    — Extension routing, folder creation, file moves
│   │   └── hash_service.py    — SHA-256 file hashing
│   ├── test/stage1/           — 39 tests, run: python test/stage1/run_tests.py
│   ├── data/                  — Received files: pdf/ word/ presentations/ etc.
│   ├── temp_uploads/          — Chunks land here pre-verification
│   ├── sorter.db              — SQLite transfer state
│   └── app/                   — Pipeline services (Stages 4-6, keep untouched)
├── CLAUDE.md                  — This file (read every session)
├── PROJECT_SESSIONS.md        — Session log
└── PROJECT_DECISIONS.md       — Decision log
```

---

## Stage 1 Backend — COMPLETE ✅

All endpoints live at `http://laptop-ip:8000`:

| Method | Endpoint | Status |
|--------|----------|--------|
| POST | /sync/metadata | ✅ done |
| GET | /sync/status | ✅ done |
| POST | /files/upload/init | ✅ done |
| POST | /files/upload/chunk | ✅ done |
| POST | /files/upload/complete | ✅ done |
| GET | /files/upload/progress/{file_id} | ✅ done |
| GET | /health | ✅ done |

**Tests:** 39 passing, 0 warnings. Run from `python_server/`:
```powershell
python test/stage1/run_tests.py
```

---

## Flutter Phase 1A — NEXT TO BUILD

Build order:
1. Permission check (`MANAGE_EXTERNAL_STORAGE`)
2. Folder scan → phone-local SQLite (status=`discovered`, no hashing yet)
3. SHA-256 hash each file in background isolate (status=`pending`)
4. Show user file list (grouped by type, size, location) before transfer starts

Flutter target folders to scan:
```
/storage/emulated/0/Download
/storage/emulated/0/Documents
/storage/emulated/0/WhatsApp/Media/WhatsApp Documents
/storage/emulated/0/Telegram
/storage/emulated/0/Drive
```

Extensions to find: pdf, docx, doc, odt, rtf, txt, md, pptx, ppt, odp, xlsx, xls, csv, tsv, ods, epub

**Ollama NOT needed for Phase 1A or 1B.** Only needed from Stage 4 onward.

---

## What Exists (Pipeline Services — Keep These, Don't Touch)

| File | Status | Notes |
|------|--------|-------|
| app/services/clustering_service.py | KEEP | Solid HDBSCAN |
| app/services/labeling_service.py | KEEP | Indian doc prompts, good quality |
| app/services/ollama_service.py | KEEP | nomic-embed-text, needs batching later |
| app/services/ingestion.py | KEEP | Needs PyMuPDF swap + OCR in Stage 2 |
| app/services/chromadb_service.py | KEEP | Needs API update (deprecated Settings()) |
| app/routers/process.py | KEEP | Stage 4 processing |
| app/routers/clusters.py | KEEP | Stage 5-6 review |

---

## Critical Rules (Never Violate)

| Rule | Why |
|------|-----|
| NEVER delete files from phone/laptop automatically | Move to trash/ only; user confirms |
| NEVER skip hash verification on upload complete | One corrupt file poisons the dataset |
| NEVER use in-memory storage for file state | Server restart = data loss; SQLite required |
| NEVER embed before dedup | Wastes Ollama time on duplicate vectors |
| Backup before any processing | Non-negotiable for v1 |
| UTF-8 explicit everywhere | Indian language filenames + mixed content |

---

## Tech Stack

**Backend:** Python 3.11+, FastAPI, stdlib sqlite3, ChromaDB, Ollama
**Models:** nomic-embed-text (embedding), qwen3:14b (labeling — upgraded from qwen2.5:7b)
**Flutter:** Dart, local SQLite, chunked upload, SHA-256 hashing in isolate
**Text extraction:** pypdf (→ PyMuPDF in Stage 2), python-docx, python-pptx, Tesseract OCR (Stage 2)

---

## Code Style Rules

**Python:** Type hints everywhere, sync routes (stdlib sqlite3), snake_case functions, PascalCase classes. Comments explain WHY not what.
**No print() statements** — use Python `logging` module.
**No automatic deletions** — always move to trash/failed folder.
**No Colab code** — dropped for v1 (see python_server/Details.md for re-add instructions).

---

## Session / Decision Hygiene (MANDATORY — No Reminders Needed)

**After fixing any bug, making any architectural decision, or when Smit says something like "always X" or "never Y":**
→ Add entry to `PROJECT_DECISIONS.md` immediately. Do NOT wait to be asked.

**After each session ends:**
→ Add session summary to `PROJECT_SESSIONS.md` immediately. Do NOT wait to be asked.

**Never delete entries.** Mark outdated decisions as `[SUPERSEDED]`.

---

## Commands

```powershell
# Backend — run from python_server/ with venv active
uvicorn main:app --reload --host 0.0.0.0 --port 8000
# Docs: http://localhost:8000/docs

# Tests
python test/stage1/run_tests.py        # all 39 tests
python test/stage1/run_tests.py -v     # verbose

# Health check
curl http://localhost:8000/health
```

---

## How to Update This File

**CLAUDE.md stays lean — never grows beyond ~200 lines of prose.**
- Architectural or code decisions → add to `PROJECT_DECISIONS.md`
- Session outcomes → add to `PROJECT_SESSIONS.md`
- New permanent rules or stack changes → update relevant section here

*Last updated: 2026-05-10*
