// web-views-2.jsx — Duplicates, Clusters, Files, Settings
const { useState: uS2 } = React;

// ═══════════════════════════════════════════════════════════════════
// DUPLICATES
// ═══════════════════════════════════════════════════════════════════
const DUP_GROUPS = [
  { kind: 'exact', score: 100, files: [
    { n: 'rent_agreement_2025.pdf', sz: '1.7 MB', dir: '/Download', date: '2025-04-12', keep: true },
    { n: 'rent_agreement_2025 (1).pdf', sz: '1.7 MB', dir: '/Documents', date: '2025-04-12', keep: false },
    { n: 'rent_agreement_2025_copy.pdf', sz: '1.7 MB', dir: '/WhatsApp', date: '2025-04-15', keep: false },
  ]},
  { kind: 'near',  score: 94,  files: [
    { n: 'thesis_draft_v6.docx', sz: '4.1 MB', dir: '/Documents', date: '2025-09-02', keep: false },
    { n: 'thesis_draft_v7.docx', sz: '4.2 MB', dir: '/Documents', date: '2025-09-08', keep: true },
  ]},
  { kind: 'near', score: 88, files: [
    { n: 'invoice_aug.pdf', sz: '0.4 MB', dir: '/Download', date: '2025-08-31', keep: true },
    { n: 'invoice_august_signed.pdf', sz: '0.5 MB', dir: '/Telegram', date: '2025-09-01', keep: false },
  ]},
];

function ViewDuplicates({ accent }) {
  return (
    <div>
      <WHeader eyebrow="Stage 3" title="Duplicates" sub="217 exact (md5) · 84 near-duplicate (MinHash) · pick which copy to keep"
        right={<div style={{ display: 'flex', gap: 8 }}>
          <WPill>Auto-select newest</WPill>
          <WPill dark icon={<IconTrash size={14} color="#fff"/>}>Move 217 to trash</WPill>
        </div>}/>

      <div style={{ display: 'flex', gap: 8, marginBottom: 16 }}>
        <WChip active>All groups (84)</WChip>
        <WChip>Exact (217)</WChip>
        <WChip>Near (84)</WChip>
        <WChip>Unresolved</WChip>
      </div>

      <div style={{ display: 'flex', flexDirection: 'column', gap: 12 }}>
        {DUP_GROUPS.map((g, i) => <DupGroup key={i} g={g} accent={accent}/>)}
      </div>
    </div>
  );
}

function DupGroup({ g, accent }) {
  const isExact = g.kind === 'exact';
  return (
    <WPanel pad={0}>
      <div style={{
        padding: '14px 20px', display: 'flex', alignItems: 'center', gap: 12,
        borderBottom: `1px solid ${W.hair}`,
      }}>
        <div style={{
          fontSize: 10, fontWeight: 700, padding: '3px 9px', borderRadius: 999,
          background: isExact ? W.badBg : W.warnBg,
          color: isExact ? 'oklch(45% 0.16 25)' : 'oklch(45% 0.13 60)',
          letterSpacing: 0.4, textTransform: 'uppercase', fontFamily: W.mono,
        }}>{isExact ? 'EXACT · md5' : `NEAR · ${g.score}% sim`}</div>
        <span style={{ fontSize: 13, fontWeight: 600 }}>{g.files.length} copies</span>
        <span style={{ fontFamily: W.mono, fontSize: 12, color: W.sub, marginLeft: 'auto' }}>
          saves {g.files.length - 1} × {g.files[0].sz}
        </span>
      </div>
      <table style={{ width: '100%', borderCollapse: 'collapse', fontSize: 12.5 }}>
        <thead>
          <tr style={{ background: W.panel2 }}>
            {['Keep', 'Filename', 'Source', 'Size', 'Modified'].map(h => (
              <th key={h} style={{
                textAlign: 'left', padding: '10px 20px', fontSize: 10.5, fontWeight: 600,
                color: W.sub, letterSpacing: 0.3, textTransform: 'uppercase',
                borderBottom: `1px solid ${W.hair}`,
              }}>{h}</th>
            ))}
          </tr>
        </thead>
        <tbody>
          {g.files.map((f, i) => (
            <tr key={i} style={{ borderBottom: i < g.files.length - 1 ? `1px solid ${W.hair}` : 'none' }}>
              <td style={{ padding: '12px 20px' }}>
                <div style={{
                  width: 18, height: 18, borderRadius: '50%',
                  border: `1.5px solid ${f.keep ? accent : W.sub2}`,
                  background: f.keep ? accent : 'transparent',
                  display: 'flex', alignItems: 'center', justifyContent: 'center',
                }}>
                  {f.keep && <IconCheck size={11} color="#fff" stroke={3}/>}
                </div>
              </td>
              <td style={{ padding: '12px 20px', fontWeight: f.keep ? 600 : 500, color: f.keep ? W.ink : W.ink2 }}>
                {f.n}
              </td>
              <td style={{ padding: '12px 20px', fontFamily: W.mono, color: W.sub }}>{f.dir}</td>
              <td style={{ padding: '12px 20px', fontFamily: W.mono, color: W.sub }}>{f.sz}</td>
              <td style={{ padding: '12px 20px', fontFamily: W.mono, color: W.sub }}>{f.date}</td>
            </tr>
          ))}
        </tbody>
      </table>
    </WPanel>
  );
}

// ═══════════════════════════════════════════════════════════════════
// CLUSTERS — Stage 5-7 review
// ═══════════════════════════════════════════════════════════════════
const W_CLUSTERS = [
  { id: 1,  l: 'Bank statements',           n: 142, conf: 0.94, flag: true,  e: 'pdf',
    sample: ['hdfc_jan.pdf', 'sbi_feb.pdf', 'axis_mar.pdf', 'icici_q4.pdf'] },
  { id: 2,  l: 'College notes — Physics',   n: 318, conf: 0.91, flag: false, e: 'pdf',
    sample: ['mechanics_l1.pdf', 'thermo_l5.pdf', 'quantum_l3.docx'] },
  { id: 3,  l: 'Aadhaar & ID copies',       n: 11,  conf: 0.97, flag: true,  e: 'pdf',
    sample: ['aadhaar_copy.pdf', 'pan_copy.pdf', 'voter_id.pdf'] },
  { id: 4,  l: 'Lecture slides',            n: 234, conf: 0.88, flag: false, e: 'pptx',
    sample: ['ml_lecture_4.pptx', 'dl_w3.pptx'] },
  { id: 5,  l: 'Tax & receipts 2024-25',    n: 87,  conf: 0.86, flag: false, e: 'pdf',
    sample: ['16a_form.pdf', 'itr_ack.pdf', 'rent_recpt.pdf'] },
  { id: 6,  l: 'Project reports',           n: 56,  conf: 0.82, flag: false, e: 'docx',
    sample: ['btp_final.docx', 'intern_report.pdf'] },
  { id: 7,  l: 'Books & ebooks',            n: 43,  conf: 0.79, flag: false, e: 'epub',
    sample: ['atomic_habits.epub', 'thinking_fast.pdf'] },
  { id: 8,  l: 'Resumes (own + reference)', n: 18,  conf: 0.74, flag: false, e: 'pdf',
    sample: ['smit_resume_v4.pdf', 'cv_template.docx'] },
];

function ViewClusters({ accent }) {
  const [sel, setSel] = uS2(W_CLUSTERS[0].id);
  const cluster = W_CLUSTERS.find(c => c.id === sel);
  return (
    <div>
      <WHeader eyebrow="Stage 5–7" title="Clusters"
        sub="HDBSCAN groups · labelled by qwen3:14b · keyword-based PII flags"
        right={<div style={{ display: 'flex', gap: 8 }}>
          <WPill icon={<IconRefresh size={14}/>}>Re-cluster</WPill>
          <WPill dark icon={<IconArrowRight size={14} color="#fff"/>}>Export decisions</WPill>
        </div>}/>

      <div style={{ display: 'grid', gridTemplateColumns: '1fr 1.4fr', gap: 12, height: 580 }}>
        {/* cluster list */}
        <WPanel pad={0} style={{ display: 'flex', flexDirection: 'column', overflow: 'hidden' }}>
          <div style={{ padding: '14px 18px', borderBottom: `1px solid ${W.hair}`, display: 'flex',
            alignItems: 'center', justifyContent: 'space-between' }}>
            <span style={{ fontSize: 12, color: W.sub, fontWeight: 600, letterSpacing: 0.3, textTransform: 'uppercase' }}>
              All clusters · 14
            </span>
            <span style={{ fontSize: 12, color: W.sub, fontFamily: W.mono }}>conf ↓</span>
          </div>
          <div style={{ flex: 1, overflow: 'auto' }}>
            {W_CLUSTERS.map(c => (
              <button key={c.id} onClick={() => setSel(c.id)} style={{
                display: 'flex', alignItems: 'center', gap: 12, padding: '12px 18px',
                width: '100%', border: 0, cursor: 'pointer', textAlign: 'left',
                background: sel === c.id ? W.bg : '#fff',
                borderBottom: `1px solid ${W.hair}`, borderLeft: sel === c.id ? `3px solid ${W.ink}` : '3px solid transparent',
              }}>
                <div style={{
                  width: 32, height: 32, borderRadius: 9, background: W.bg,
                  display: 'flex', alignItems: 'center', justifyContent: 'center',
                  fontFamily: W.mono, fontSize: 12, fontWeight: 700,
                }}>{String(c.id).padStart(2, '0')}</div>
                <div style={{ flex: 1, minWidth: 0 }}>
                  <div style={{ fontSize: 13, fontWeight: 600, display: 'flex', alignItems: 'center', gap: 6 }}>
                    {c.l}
                    {c.flag && <span style={{ width: 6, height: 6, borderRadius: '50%', background: W.warn }}/>}
                  </div>
                  <div style={{ fontSize: 11, color: W.sub, marginTop: 2, fontFamily: W.mono }}>
                    {c.n} files · {(c.conf * 100).toFixed(0)}%
                  </div>
                </div>
                <IconChevronRight size={14} color={W.sub2}/>
              </button>
            ))}
          </div>
        </WPanel>

        {/* cluster detail */}
        <WPanel pad={0} style={{ overflow: 'hidden', display: 'flex', flexDirection: 'column' }}>
          <div style={{ padding: '20px 24px 18px', borderBottom: `1px solid ${W.hair}` }}>
            <div style={{ display: 'flex', alignItems: 'center', gap: 10 }}>
              <div style={{ fontSize: 11, fontWeight: 700, padding: '2px 9px', borderRadius: 999,
                background: cluster.flag ? W.warnBg : W.goodBg,
                color: cluster.flag ? 'oklch(45% 0.13 60)' : 'oklch(45% 0.11 155)',
                letterSpacing: 0.3, textTransform: 'uppercase', fontFamily: W.mono,
              }}>{cluster.flag ? 'sensitive' : 'normal'}</div>
              <div style={{ fontFamily: W.mono, fontSize: 11.5, color: W.sub }}>
                cluster_id={String(cluster.id).padStart(3, '0')}
              </div>
            </div>
            <div style={{ fontSize: 22, fontWeight: 700, letterSpacing: -0.5, marginTop: 8 }}>{cluster.l}</div>
            <div style={{ fontSize: 13, color: W.sub, marginTop: 4 }}>
              {cluster.n} files · confidence {(cluster.conf * 100).toFixed(1)}% · primary type {cluster.e.toUpperCase()}
            </div>
          </div>

          {/* member files */}
          <div style={{ flex: 1, overflow: 'auto', padding: 14 }}>
            {cluster.sample.concat(Array.from({ length: Math.min(8, cluster.n - cluster.sample.length) }, (_, i) => `member_${(i+1).toString().padStart(3,'0')}.${cluster.e}`)).map((fn, i) => (
              <div key={i} style={{
                display: 'flex', alignItems: 'center', gap: 12, padding: '8px 10px', borderRadius: 8,
                background: i % 2 ? W.panel2 : 'transparent',
              }}>
                <FileTag ext={cluster.e}/>
                <div style={{ flex: 1, minWidth: 0 }}>
                  <div style={{ fontSize: 12.5, fontWeight: 600 }}>{fn}</div>
                  <div style={{ fontSize: 10.5, color: W.sub, fontFamily: W.mono, marginTop: 2 }}>
                    /data/{cluster.e === 'pptx' ? 'presentations' : cluster.e === 'xlsx' ? 'spreadsheets' : cluster.e === 'docx' ? 'word' : 'pdf'}/{fn}
                  </div>
                </div>
                <span style={{ fontFamily: W.mono, fontSize: 11, color: W.sub }}>
                  d={(0.05 + Math.random() * 0.2).toFixed(3)}
                </span>
              </div>
            ))}
          </div>

          {/* actions */}
          <div style={{ borderTop: `1px solid ${W.hair}`, padding: 16, display: 'flex', gap: 8 }}>
            <WPill icon={<IconCheck size={14}/>}>Keep cluster</WPill>
            <WPill>Rename…</WPill>
            <WPill>Split</WPill>
            <WPill style={{ marginLeft: 'auto', color: W.bad, borderColor: 'oklch(85% 0.06 25)' }}
              icon={<IconTrash size={14} color={W.bad}/>}>Move {cluster.n} to trash</WPill>
          </div>
        </WPanel>
      </div>
    </div>
  );
}

// ═══════════════════════════════════════════════════════════════════
// FILES — table view
// ═══════════════════════════════════════════════════════════════════
function ViewFiles({ accent }) {
  const rows = [
    { n: 'bank_statement_jan_2026.pdf',  e: 'pdf',  sz: '2.3 MB',  st: 'verified', cl: 'Bank statements',         hash: 'a3f2…b417' },
    { n: 'thesis_draft_v7.docx',         e: 'docx', sz: '4.2 MB',  st: 'verified', cl: 'Project reports',         hash: '7e1c…9d22' },
    { n: 'aadhaar_copy.pdf',             e: 'pdf',  sz: '0.8 MB',  st: 'flagged',  cl: 'Aadhaar & ID copies',     hash: '0b89…fc40' },
    { n: 'pitch_deck_q4.pptx',           e: 'pptx', sz: '8.4 MB',  st: 'verified', cl: 'Lecture slides',          hash: '5d6e…1a08' },
    { n: 'lecture_notes_dl.pdf',         e: 'pdf',  sz: '12.6 MB', st: 'verified', cl: 'College notes — Physics', hash: '3c44…aa11' },
    { n: 'rent_agreement_2025 (1).pdf',  e: 'pdf',  sz: '1.7 MB',  st: 'duplicate', cl: '—',                       hash: '9f12…cd55' },
    { n: 'expenses.csv',                 e: 'csv',  sz: '0.2 MB',  st: 'pending',  cl: '—',                       hash: '—' },
    { n: 'atomic_habits.epub',           e: 'epub', sz: '3.1 MB',  st: 'verified', cl: 'Books & ebooks',          hash: '6a7b…02ee' },
    { n: 'meeting_minutes.docx',         e: 'docx', sz: '0.6 MB',  st: 'verified', cl: 'Project reports',         hash: '4e88…b1c3' },
    { n: 'marks_semester3.xlsx',         e: 'xlsx', sz: '1.1 MB',  st: 'verified', cl: 'Tax & receipts 2024-25',  hash: '2d33…f9a7' },
  ];
  return (
    <div>
      <WHeader eyebrow="All files" title="Files" sub="2,653 documents · indexed and ready for review"
        right={<div style={{ display: 'flex', gap: 8 }}>
          <WPill>Export CSV</WPill>
          <WPill dark>Bulk action</WPill>
        </div>}/>

      <div style={{ display: 'flex', alignItems: 'center', gap: 10, marginBottom: 14 }}>
        <div style={{
          flex: 1, height: 38, borderRadius: 999, background: W.panel,
          border: `1px solid ${W.hair}`, padding: '0 16px', display: 'flex',
          alignItems: 'center', gap: 10,
        }}>
          <IconSearch size={15} color={W.sub}/>
          <span style={{ fontSize: 13, color: W.sub }}>Search by name, content, or hash…</span>
        </div>
        <WChip active>All</WChip>
        <WChip>Verified</WChip>
        <WChip>Flagged</WChip>
        <WChip>Duplicate</WChip>
        <WChip>Pending</WChip>
      </div>

      <WPanel pad={0}>
        <table style={{ width: '100%', borderCollapse: 'collapse', fontSize: 13 }}>
          <thead>
            <tr style={{ background: W.panel2 }}>
              {['', 'Name', 'Type', 'Size', 'Status', 'Cluster', 'SHA-256'].map((h, i) => (
                <th key={i} style={{
                  textAlign: 'left', padding: '12px 16px', fontSize: 10.5, fontWeight: 600,
                  color: W.sub, letterSpacing: 0.3, textTransform: 'uppercase',
                  borderBottom: `1px solid ${W.hair}`,
                }}>{h}</th>
              ))}
            </tr>
          </thead>
          <tbody>
            {rows.map((r, i) => (
              <tr key={i} style={{ borderBottom: i < rows.length - 1 ? `1px solid ${W.hair}` : 'none' }}>
                <td style={{ padding: '10px 16px', width: 36 }}>
                  <div style={{ width: 16, height: 16, borderRadius: 4, border: `1.5px solid ${W.sub2}` }}/>
                </td>
                <td style={{ padding: '10px 16px', fontWeight: 600 }}>{r.n}</td>
                <td style={{ padding: '10px 16px' }}><FileTag ext={r.e}/></td>
                <td style={{ padding: '10px 16px', fontFamily: W.mono, color: W.sub }}>{r.sz}</td>
                <td style={{ padding: '10px 16px' }}><WStatus s={r.st}/></td>
                <td style={{ padding: '10px 16px', color: W.ink2 }}>{r.cl}</td>
                <td style={{ padding: '10px 16px', fontFamily: W.mono, color: W.sub, fontSize: 11.5 }}>{r.hash}</td>
              </tr>
            ))}
          </tbody>
        </table>
      </WPanel>
    </div>
  );
}

function WStatus({ s }) {
  const map = {
    verified: { c: 'oklch(45% 0.11 155)', bg: W.goodBg, d: W.good },
    pending:  { c: W.sub, bg: W.bg, d: W.sub2 },
    flagged:  { c: 'oklch(45% 0.13 60)', bg: W.warnBg, d: W.warn },
    duplicate:{ c: 'oklch(45% 0.16 25)', bg: W.badBg,  d: W.bad },
  };
  const st = map[s] || map.pending;
  return (
    <div style={{ display: 'inline-flex', alignItems: 'center', gap: 6, padding: '3px 10px',
      borderRadius: 999, background: st.bg, color: st.c, fontSize: 11, fontWeight: 600,
      textTransform: 'capitalize' }}>
      <span style={{ width: 5, height: 5, borderRadius: '50%', background: st.d }}/>
      {s}
    </div>
  );
}

// ═══════════════════════════════════════════════════════════════════
// SETTINGS
// ═══════════════════════════════════════════════════════════════════
function ViewSettings({ accent }) {
  return (
    <div style={{ maxWidth: 760 }}>
      <WHeader eyebrow="Configuration" title="Settings" sub="Backend wiring · models · safety rules"/>

      <SettingGroup title="Server">
        <SetRow label="Host" mono value="0.0.0.0"/>
        <SetRow label="Port" mono value="8000"/>
        <SetRow label="Data directory" mono value="~/document_sorter/data"/>
        <SetRow label="Trash directory" mono value="~/document_sorter/trash"/>
      </SettingGroup>

      <SettingGroup title="Models (Ollama)">
        <SetRow label="Embeddings"
          right={<WPill style={{ height: 30 }}>nomic-embed-text · 768 dim</WPill>}/>
        <SetRow label="Cluster labelling"
          right={<WPill style={{ height: 30 }}>qwen3:14b</WPill>}/>
        <SetRow label="OCR engine"
          right={<WPill style={{ height: 30 }}>Tesseract · eng + hin</WPill>}/>
      </SettingGroup>

      <SettingGroup title="Safety">
        <SetRow label="Auto-delete duplicates" sub="Move to trash/ instead of permanent delete"
          right={<WToggle on={false}/>}/>
        <SetRow label="Flag PII keywords" sub="aadhaar, pan, account number, password, otp"
          right={<WToggle on={true}/>}/>
        <SetRow label="Backup before processing" sub="Mirror data/ → backup/ before any pipeline run"
          right={<WToggle on={true}/>}/>
        <SetRow label="Dry-run mode" sub="Run pipeline without writing decisions"
          right={<WToggle on={false}/>}/>
      </SettingGroup>

      <SettingGroup title="Storage">
        <SetRow label="ChromaDB path" mono value="~/document_sorter/chroma"
          right={<WPill style={{ height: 30 }}>persist</WPill>}/>
        <SetRow label="SQLite database" mono value="~/document_sorter/sorter.db"/>
        <SetRow label="Log file" mono value="~/document_sorter/sorter.log"/>
      </SettingGroup>
    </div>
  );
}

function SettingGroup({ title, children }) {
  return (
    <WPanel pad={0} style={{ marginBottom: 14 }}>
      <div style={{ padding: '14px 22px', borderBottom: `1px solid ${W.hair}`,
        fontSize: 11, color: W.sub, fontWeight: 600, letterSpacing: 0.3, textTransform: 'uppercase' }}>
        {title}
      </div>
      <div>{children}</div>
    </WPanel>
  );
}

function SetRow({ label, sub, value, mono, right }) {
  return (
    <div style={{ padding: '14px 22px', display: 'flex', alignItems: 'center', gap: 16,
      borderBottom: `1px solid ${W.hair}` }}>
      <div style={{ flex: 1, minWidth: 0 }}>
        <div style={{ fontSize: 13.5, fontWeight: 600 }}>{label}</div>
        {sub && <div style={{ fontSize: 12, color: W.sub, marginTop: 2 }}>{sub}</div>}
      </div>
      {value && (
        <span style={{ fontFamily: mono ? W.mono : W.font, fontSize: 12.5, color: W.ink2,
          padding: '6px 12px', borderRadius: 8, background: W.panel2, border: `1px solid ${W.hair}` }}>{value}</span>
      )}
      {right}
    </div>
  );
}

function WToggle({ on }) {
  return (
    <div style={{
      width: 38, height: 22, borderRadius: 999, padding: 2, boxSizing: 'border-box',
      background: on ? W.pill : W.hair, display: 'flex',
      justifyContent: on ? 'flex-end' : 'flex-start',
    }}>
      <div style={{ width: 18, height: 18, borderRadius: '50%', background: '#fff' }}/>
    </div>
  );
}

Object.assign(window, { ViewDuplicates, ViewClusters, ViewFiles, ViewSettings });
