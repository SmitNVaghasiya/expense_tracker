// pipeline-data.jsx — shared shape for the 7-stage pipeline
const STAGES = [
  { id: 1, code: 'INGEST',   label: 'File ingestion',     desc: 'Receive chunked uploads from phone', tech: 'FastAPI · SHA-256' },
  { id: 2, code: 'EXTRACT',  label: 'Text extraction',    desc: 'Parse PDF / DOCX / PPTX / XLSX',     tech: 'PyMuPDF · python-docx · Tesseract' },
  { id: 3, code: 'DEDUP',    label: 'Dedup detection',    desc: 'MD5 exact + MinHash near-duplicate', tech: 'datasketch · hashlib' },
  { id: 4, code: 'EMBED',    label: 'Embeddings',         desc: 'Vectorise text into 768-dim space',  tech: 'nomic-embed-text · ChromaDB' },
  { id: 5, code: 'CLUSTER',  label: 'Clustering',         desc: 'HDBSCAN groups by semantic distance', tech: 'hdbscan · sklearn' },
  { id: 6, code: 'LABEL',    label: 'Cluster labelling',  desc: 'LLM names each cluster + flags PII', tech: 'qwen3:14b · keyword rules' },
  { id: 7, code: 'REVIEW',   label: 'Review & decide',    desc: 'You confirm, rename, or trash',      tech: 'Web UI · bulk actions' },
];

// Demo telemetry — what the phone polls from /pipeline/status
function deriveStatus(t /* 0..1 */) {
  const start = (offset) => Math.max(0, Math.min(1, (t - offset) * 4));
  return STAGES.map((s, i) => {
    const begin = i * 0.13;
    const p = start(begin);
    const status = p === 0 ? 'queued' : p >= 1 ? 'done' : 'running';
    return { ...s, progress: Math.round(p * 100), status };
  });
}

Object.assign(window, { STAGES, deriveStatus });
