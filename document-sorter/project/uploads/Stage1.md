## Stage 1 Complete Plan

### What to Build First

Build in this exact order:
1. FastAPI backend (laptop) — so you have something to test against
2. Flutter app Phase 1A — file scanning and metadata
3. Metadata sync to laptop
4. Flutter app Phase 1B — file transfer

---

## FastAPI Backend (Build First)

**Why first:** You can't test Flutter networking without a server running. Build and test backend endpoints with Postman or curl before touching Flutter.

**Endpoints needed for Stage 1:**

```
POST /sync/metadata          — receives full metadata list from phone
GET  /sync/status            — returns transfer summary (total, pending, verified, failed)
POST /files/upload/init      — phone announces it's starting a file upload
POST /files/upload/chunk     — receives one chunk of a file
POST /files/upload/complete  — phone signals file is fully sent, triggers hash verification
GET  /files/upload/progress/{file_id} — laptop tells phone how many bytes it has received
GET  /health                 — simple ping so Flutter can check if laptop is reachable
```

**Folder structure for backend:**

```
document_sorter_backend/
├── main.py
├── config.py              # ports, folder paths, chunk size settings
├── database/
│   ├── db.py              # SQLite connection
│   └── models.py          # file record schema
├── routes/
│   ├── sync.py            # metadata sync endpoints
│   └── files.py           # upload endpoints
├── services/
│   ├── file_service.py    # folder creation, file moving logic
│   └── hash_service.py    # SHA-256 verification
├── data/                  # where received files go
│   ├── pdf/
│   ├── word/
│   ├── presentations/
│   ├── spreadsheets/
│   ├── text/
│   ├── ebooks/
│   └── failed/
└── requirements.txt
```

**Laptop SQLite schema:**

```sql
CREATE TABLE files (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    phone_file_id TEXT UNIQUE,    -- matches phone SQLite id
    file_name TEXT,
    extension TEXT,
    file_size INTEGER,
    file_hash TEXT,
    date_modified TEXT,
    date_created TEXT,
    status TEXT DEFAULT 'pending', -- pending/receiving/verified/failed
    bytes_received INTEGER DEFAULT 0,
    retry_count INTEGER DEFAULT 0,
    error_message TEXT,
    received_at TEXT,
    storage_path TEXT              -- where file is stored on laptop
);
```

---

## Phase 1A: Flutter App — Metadata Extraction

**Flutter folder structure:**

```
document_sorter_app/
├── lib/
│   ├── main.dart
│   ├── config/
│   │   └── app_config.dart        # laptop IP, port, chunk size
│   ├── database/
│   │   └── local_db.dart          # SQLite setup and queries
│   ├── models/
│   │   └── file_model.dart        # file data structure
│   ├── services/
│   │   ├── scanner_service.dart   # file system scanning
│   │   ├── hash_service.dart      # SHA-256 calculation
│   │   └── transfer_service.dart  # chunked upload logic
│   ├── screens/
│   │   ├── home_screen.dart       # main screen with buttons
│   │   ├── scan_screen.dart       # scanning progress
│   │   ├── files_screen.dart      # browse all found files
│   │   └── transfer_screen.dart   # transfer progress
│   └── widgets/
│       └── progress_card.dart     # reusable progress UI
```

**Phone SQLite schema:**

```sql
CREATE TABLE files (
    id TEXT PRIMARY KEY,           -- UUID generated on phone
    file_path TEXT,
    file_name TEXT,
    extension TEXT,
    file_size INTEGER,
    file_hash TEXT,                -- calculated during Phase 1A
    date_modified TEXT,
    date_created TEXT,
    status TEXT DEFAULT 'pending', -- pending/sending/verified/failed
    bytes_sent INTEGER DEFAULT 0,
    retry_count INTEGER DEFAULT 0,
    error_message TEXT,
    last_attempt TEXT
);
```

**Folders to scan on Android:**

```dart
final foldersToScan = [
  '/storage/emulated/0/Download',
  '/storage/emulated/0/Documents',
  '/storage/emulated/0/WhatsApp/Media/WhatsApp Documents',
  '/storage/emulated/0/Telegram',
  '/storage/emulated/0/Drive',
  '/storage/emulated/0/DCIM',     // sometimes PDFs saved here
];

final extensionsToFind = [
  // Documents
  'pdf', 'docx', 'doc', 'odt', 'rtf', 'txt', 'md',
  // Presentations
  'pptx', 'ppt', 'odp',
  // Spreadsheets
  'xlsx', 'xls', 'csv', 'tsv', 'ods',
  // Ebooks
  'epub',
];
```

**Phase 1A flow in detail:**

```
Step 1: Permission check
→ Request MANAGE_EXTERNAL_STORAGE permission
→ If denied, show instructions to enable manually
→ Do not proceed without it

Step 2: Folder scan (fast — no hashing yet)
→ Walk each folder recursively
→ For each file matching extension list:
   → Extract path, name, extension, size, date modified
   → Insert into SQLite with status = 'discovered'
→ Update UI: "Found X files"
→ This should take seconds, not minutes

Step 3: Hash calculation (slow — run in background isolate)
→ For each 'discovered' file, calculate SHA-256
→ Update SQLite: set hash, change status to 'pending'
→ Show progress bar: "Calculating checksums: X of Y files"
→ Allow user to pause and resume this step
→ On completion: show summary screen
   → Total files found: X
   → Total size: Y GB
   → Files by type breakdown
   → "Ready to transfer" button

Step 4: Show user what was found
→ List all files grouped by type
→ Show file name, size, location
→ User reviews before transfer starts
→ Optional: let user deselect specific files or folders
```

**Important:** Between Step 2 and Step 3, show the user what was found. Don't start hashing invisibly. Let them see the list early.

---

## Phase 1B: Metadata Sync Then File Transfer

**First action when user taps "Start Transfer":**

Before sending any file, send the complete metadata list to the laptop. This is a single API call with all file records as JSON.

```
Phone → POST /sync/metadata → Laptop
Payload: list of all file records from phone SQLite
Laptop: inserts all records with status = 'pending'
Response: confirmation + any files laptop already has (by hash)
Phone: marks already-existing files as 'verified' — skip them
```

This last point matters — if a file with the same hash already exists on the laptop from a previous run, don't re-send it. Check by hash, not filename.

**Transfer flow per file:**

```
Step 1: Phone picks next 'pending' file (smallest first)
Step 2: POST /files/upload/init
   → sends: file_id, file_name, file_size, file_hash, extension
   → laptop creates empty temp file, returns: ok
Step 3: Split file into chunks (2MB each)
Step 4: For each chunk:
   → POST /files/upload/chunk
   → sends: file_id, chunk_number, chunk_data
   → laptop appends to temp file
   → laptop returns: bytes_received so far
   → phone updates bytes_sent in SQLite
Step 5: POST /files/upload/complete
   → sends: file_id, expected_hash
   → laptop calculates SHA-256 of received file
   → if hash matches:
      → move from temp to correct type folder
      → update laptop SQLite: status = 'verified'
      → return: success
   → if hash mismatch:
      → delete temp file
      → return: failed, reason = hash_mismatch
Step 6: Phone updates SQLite based on response
   → success: status = 'verified'
   → failed: increment retry_count
      → if retry_count < 3: re-queue (status stays 'pending')
      → if retry_count >= 3: status = 'failed'
```

**Concurrency:** Send 3 files simultaneously, not 1 and not 10. Use Flutter's isolates or async queue for this.

**Resume logic:**

```
If app closes mid-transfer:
→ On restart, query phone SQLite:
   SELECT * FROM files 
   WHERE status IN ('pending', 'sending', 'failed') 
   AND retry_count < 3
   ORDER BY file_size ASC
→ For files with status 'sending':
   → Call GET /files/upload/progress/{file_id}
   → Laptop returns bytes_received
   → Phone resumes from that byte offset
→ Continue queue normally
```

---

## UI Screens

**Home Screen:**
```
[ Scan Documents ]     ← starts Phase 1A
[ View Files ]         ← browse already scanned files
[ Transfer to Laptop ] ← starts Phase 1B (only active after scan complete)
[ Settings ]           ← laptop IP, port
```

**Scan Screen:**
```
Scanning folders...
━━━━━━━━━━━━━━━━━━━━━━━  65%
Found 1,847 files so far

Calculating checksums...
━━━━━━━━━━━━━━━━━━━━━━━  32%
847 / 2,653 files processed
```

**Transfer Screen:**
```
Transferring files to laptop
━━━━━━━━━━━━━━━━━━━━━━━  41%
1,087 / 2,653 files sent
4.2 GB / 10.1 GB

Currently sending: report_final_v3.pdf (2.1 MB)
✓ Verified: 1,082 files
✗ Failed: 5 files
⟳ Pending: 1,566 files

[ Pause ]  [ View Failed Files ]
```

**Files Browser Screen:**
```
All Files (2,653)
[PDF] [Word] [Sheets] [PPT] [Text] [All]

📄 bank_statement_jan.pdf    2.3 MB  ● pending
📄 aadhaar_copy.pdf          0.8 MB  ● pending
📊 marks_semester3.xlsx      1.1 MB  ● pending
```

---

## Permissions Needed in AndroidManifest.xml

```xml
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
<uses-permission android:name="android.permission.MANAGE_EXTERNAL_STORAGE"/>
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE"/>
<uses-permission android:name="android.permission.ACCESS_WIFI_STATE"/>
```

---

## Build Order Summary

| Order | What | Why |
|-------|------|-----|
| 1 | FastAPI backend skeleton + SQLite setup | Need server running to test anything |
| 2 | `/health` endpoint + Flutter ping test | Confirm phone-laptop connection works |
| 3 | Flutter file scanner (no hashing) | Verify you can actually read files on your phone |
| 4 | SQLite on Flutter | Store what scanner finds |
| 5 | SHA-256 hashing in Flutter isolate | Slow step — test on 50 files first |
| 6 | `/sync/metadata` endpoint + Flutter call | Get metadata onto laptop |
| 7 | Chunked upload endpoints + Flutter upload | Core transfer logic |
| 8 | Resume logic | Test by killing app mid-transfer |
| 9 | UI polish | Progress bars, file browser |

Say the word and I'll start with the FastAPI backend.