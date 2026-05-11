// web-views.jsx — main views for desktop web app
const { useState: uS, useEffect: uE } = React;

// ═══════════════════════════════════════════════════════════════════
// DASHBOARD
// ═══════════════════════════════════════════════════════════════════
function ViewDashboard({ accent, telemetry }) {
  const overall = Math.round(telemetry.reduce((s, x) => s + x.progress, 0) / telemetry.length);
  return (
    <div>
      <WHeader eyebrow="Overview" title="Library" sub="2,653 documents · 10.1 GB · last sync 2 minutes ago"
        right={
          <div style={{ display: 'flex', gap: 8 }}>
            <WPill icon={<IconRefresh size={14}/>}>Resync phone</WPill>
            <WPill dark icon={<IconArrowRight size={14} color="#fff"/>}>Run pipeline</WPill>
          </div>
        }/>

      {/* stat row */}
      <div style={{ display: 'grid', gridTemplateColumns: 'repeat(4, 1fr)', gap: 12, marginBottom: 18 }}>
        <WStat label="Documents"   value="2,653" mono hint="from 5 source folders"/>
        <WStat label="Duplicates"  value="217"   mono hint="exact + 84 near-dup" accent={W.warn}/>
        <WStat label="Embeddings"  value="2,436" mono hint="768-dim · ChromaDB"/>
        <WStat label="Clusters"    value="14"    mono hint="2 flagged sensitive" accent={accent}/>
      </div>

      {/* main row */}
      <div style={{ display: 'grid', gridTemplateColumns: '1.5fr 1fr', gap: 12, marginBottom: 18 }}>
        {/* pipeline summary */}
        <WPanel pad={22}>
          <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginBottom: 16 }}>
            <div>
              <div style={{ fontSize: 11, color: W.sub, fontWeight: 600, letterSpacing: 0.3, textTransform: 'uppercase' }}>Pipeline</div>
              <div style={{ fontSize: 20, fontWeight: 700, letterSpacing: -0.4, marginTop: 4 }}>
                {overall}% complete <span style={{ fontSize: 13, color: W.sub, fontWeight: 500 }}>· stages 2 → 6 running</span>
              </div>
            </div>
            <WPill>Open</WPill>
          </div>
          <WBar value={overall} color={accent}/>
          <div style={{ marginTop: 18, display: 'flex', gap: 8 }}>
            {telemetry.map(s => (
              <div key={s.id} style={{ flex: 1 }}>
                <div style={{
                  fontSize: 10, color: W.sub, fontFamily: W.mono, letterSpacing: 0.3,
                  display: 'flex', justifyContent: 'space-between', marginBottom: 4,
                }}>
                  <span>S{s.id}</span><span>{s.progress}%</span>
                </div>
                <div style={{
                  height: 4, borderRadius: 4, background: W.hair, overflow: 'hidden',
                }}>
                  <div style={{
                    width: `${s.progress}%`, height: '100%', borderRadius: 4,
                    background: s.status === 'done' ? accent : s.status === 'running' ? W.ink : W.sub2,
                  }}/>
                </div>
                <div style={{ fontSize: 10.5, color: W.ink2, marginTop: 6, fontWeight: 500, lineHeight: 1.2, height: 24 }}>
                  {s.label}
                </div>
              </div>
            ))}
          </div>
        </WPanel>

        {/* type breakdown */}
        <WPanel pad={22}>
          <div style={{ fontSize: 11, color: W.sub, fontWeight: 600, letterSpacing: 0.3, textTransform: 'uppercase' }}>By type</div>
          <div style={{ marginTop: 12, display: 'flex', flexDirection: 'column', gap: 12 }}>
            {[
              { l: 'PDF',   n: 1008, v: 38, c: '#9C3D26' },
              { l: 'DOCX',  n: 583,  v: 22, c: '#26469C' },
              { l: 'XLSX',  n: 425,  v: 16, c: '#256B3F' },
              { l: 'PPTX',  n: 372,  v: 14, c: '#9C6B26' },
              { l: 'Other', n: 265,  v: 10, c: W.sub },
            ].map(t => (
              <div key={t.l}>
                <div style={{ display: 'flex', justifyContent: 'space-between', fontSize: 12, marginBottom: 5 }}>
                  <span style={{ fontWeight: 600 }}>{t.l}</span>
                  <span style={{ fontFamily: W.mono, color: W.sub }}>{t.n.toLocaleString()} · {t.v}%</span>
                </div>
                <div style={{ height: 4, borderRadius: 4, background: W.hair, overflow: 'hidden' }}>
                  <div style={{ width: `${t.v}%`, height: '100%', background: t.c, borderRadius: 4 }}/>
                </div>
              </div>
            ))}
          </div>
        </WPanel>
      </div>

      {/* recent activity + flagged */}
      <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 12 }}>
        <WPanel pad={0}>
          <div style={{ padding: '18px 22px 12px' }}>
            <div style={{ fontSize: 11, color: W.sub, fontWeight: 600, letterSpacing: 0.3, textTransform: 'uppercase' }}>Recent runs</div>
          </div>
          {[
            { i: <IconCheck size={16}/>, t: 'Stage 4 · embed batch 12/47', s: '256 docs · 12.3s · ollama'  },
            { i: <IconCheck size={16}/>, t: 'Stage 3 · MinHash dedup',     s: '84 near-duplicates grouped' },
            { i: <IconCheck size={16}/>, t: 'Stage 2 · text extraction',   s: '2,653 / 2,653 · 47 OCR'    },
            { i: <IconUpload size={16}/>, t: 'Stage 1 · phone transfer',   s: '2,653 verified · 0 failed' },
          ].map((row, i, arr) => (
            <div key={i} style={{
              display: 'flex', alignItems: 'center', gap: 14, padding: '12px 22px',
              borderTop: `1px solid ${W.hair}`,
            }}>
              <div style={{ width: 32, height: 32, borderRadius: 9, background: W.bg, color: accent,
                display: 'flex', alignItems: 'center', justifyContent: 'center' }}>{row.i}</div>
              <div style={{ flex: 1 }}>
                <div style={{ fontSize: 13, fontWeight: 600 }}>{row.t}</div>
                <div style={{ fontSize: 11.5, color: W.sub, marginTop: 2, fontFamily: W.mono }}>{row.s}</div>
              </div>
            </div>
          ))}
        </WPanel>

        <WPanel pad={22} style={{ background: W.warnBg, border: '1px solid oklch(88% 0.06 60)' }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: 10 }}>
            <div style={{ width: 32, height: 32, borderRadius: 9, background: '#fff',
              display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
              <IconAlert size={16} color="oklch(50% 0.13 60)"/>
            </div>
            <div style={{ fontSize: 13.5, fontWeight: 700, color: 'oklch(35% 0.1 60)' }}>2 sensitive clusters detected</div>
          </div>
          <div style={{ fontSize: 12.5, color: 'oklch(45% 0.08 60)', marginTop: 10, lineHeight: 1.5 }}>
            Documents containing <span style={{ fontFamily: W.mono, fontWeight: 600 }}>aadhaar</span>,
            <span style={{ fontFamily: W.mono, fontWeight: 600 }}> account number</span>,
            <span style={{ fontFamily: W.mono, fontWeight: 600 }}> pan</span> were grouped automatically. Review before running deletes.
          </div>
          <div style={{ display: 'flex', gap: 8, marginTop: 16 }}>
            <WPill style={{ background: '#fff' }}>Review now</WPill>
            <WPill>Adjust keywords</WPill>
          </div>
        </WPanel>
      </div>
    </div>
  );
}

// ═══════════════════════════════════════════════════════════════════
// PIPELINE MONITOR
// ═══════════════════════════════════════════════════════════════════
function ViewPipeline({ accent, telemetry }) {
  return (
    <div>
      <WHeader eyebrow="Backend" title="Pipeline monitor" sub="Live telemetry from FastAPI · stages 2 → 7"
        right={<div style={{ display: 'flex', gap: 8 }}>
          <WPill icon={<IconPause size={14}/>}>Pause</WPill>
          <WPill dark icon={<IconRefresh size={14} color="#fff"/>}>Re-run failed</WPill>
        </div>}/>

      <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 12 }}>
        {telemetry.map(s => <PipelineCard key={s.id} s={s} accent={accent}/>)}
      </div>

      <WPanel pad={0} style={{ marginTop: 18, background: W.pill, color: '#fff', border: 0 }}>
        <div style={{ padding: '14px 20px', display: 'flex', justifyContent: 'space-between', borderBottom: '1px solid rgba(255,255,255,.08)' }}>
          <div style={{ fontSize: 11, opacity: .6, fontWeight: 600, letterSpacing: 0.4, textTransform: 'uppercase' }}>Server log</div>
          <div style={{ fontSize: 11, opacity: .6, fontFamily: W.mono }}>uvicorn · stdout</div>
        </div>
        <div style={{ padding: 20, fontFamily: W.mono, fontSize: 12, lineHeight: 1.7, opacity: .9 }}>
          {[
            ['09:41:02', 'INFO',  'extract: thesis_draft_v7.docx → 8,214 chars'],
            ['09:41:02', 'INFO',  'dedup:  exact match (md5) → trash/dup_217.pdf'],
            ['09:41:03', 'INFO',  'embed:  batch 12/47 (256 docs)'],
            ['09:41:03', 'INFO',  'ollama: nomic-embed-text · 2.1s · 256 vec'],
            ['09:41:04', 'INFO',  'chroma: persist · 30,624 vectors'],
            ['09:41:05', 'WARN',  'extract: scanned_pdf_017.pdf < 50 chars · queued for OCR'],
            ['09:41:06', 'INFO',  'ocr:    tesseract eng+hin · 12.3s'],
            ['09:41:07', 'INFO',  'embed:  batch 13/47 (256 docs)'],
          ].map((l, i) => (
            <div key={i}>
              <span style={{ opacity: .5 }}>{l[0]}</span>{' '}
              <span style={{ color: l[1] === 'WARN' ? 'oklch(80% 0.14 70)' : accent, fontWeight: 600 }}>{l[1].padEnd(5)}</span>{' '}
              <span>{l[2]}</span>
            </div>
          ))}
        </div>
      </WPanel>
    </div>
  );
}

function PipelineCard({ s, accent }) {
  const isRunning = s.status === 'running';
  const c = s.status === 'done' ? accent : isRunning ? W.ink : W.sub;
  const pillBg = s.status === 'done' ? W.goodBg : isRunning ? W.bg : W.bg;
  return (
    <WPanel pad={20}>
      <div style={{ display: 'flex', alignItems: 'flex-start', gap: 14 }}>
        <div style={{
          width: 40, height: 40, borderRadius: 10, flexShrink: 0,
          background: s.status === 'done' ? accent : isRunning ? W.ink : W.bg,
          color: s.status === 'queued' ? W.sub : '#fff',
          display: 'flex', alignItems: 'center', justifyContent: 'center',
          fontFamily: W.mono, fontSize: 14, fontWeight: 700,
        }}>
          {s.status === 'done' ? <IconCheck size={18} color="#fff" stroke={2.5}/> : s.id}
        </div>
        <div style={{ flex: 1, minWidth: 0 }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: 8 }}>
            <span style={{ fontSize: 14.5, fontWeight: 700, letterSpacing: -0.2 }}>{s.label}</span>
            <span style={{
              fontSize: 10, fontWeight: 700, padding: '2px 7px', borderRadius: 999,
              background: pillBg, color: c, letterSpacing: 0.3, textTransform: 'uppercase', fontFamily: W.mono,
            }}>{s.status}</span>
          </div>
          <div style={{ fontSize: 12.5, color: W.sub, marginTop: 3 }}>{s.desc}</div>
          <div style={{ fontSize: 11, color: W.sub, marginTop: 6, fontFamily: W.mono }}>{s.tech}</div>
        </div>
        <div style={{ fontFamily: W.mono, fontSize: 14, fontWeight: 700, color: c }}>{s.progress}%</div>
      </div>
      {s.status !== 'queued' && (
        <div style={{ marginTop: 12 }}>
          <WBar value={s.progress} color={c} height={4}/>
        </div>
      )}
    </WPanel>
  );
}

Object.assign(window, { ViewDashboard, ViewPipeline });
