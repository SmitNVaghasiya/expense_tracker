// screens-2.jsx — Files browser, Transfer, Clusters

const { useState: useState2, useEffect: useEffect2 } = React;

// ═══════════════════════════════════════════════════════════════════
// 4. FILES — browse what was found, filter, select
// ═══════════════════════════════════════════════════════════════════
const SAMPLE_FILES = [
  { n: 'bank_statement_jan_2026.pdf',    e: 'pdf',   sz: '2.3 MB',  s: 'verified', dir: '/Download' },
  { n: 'aadhaar_copy.pdf',               e: 'pdf',   sz: '0.8 MB',  s: 'flagged',  dir: '/Documents' },
  { n: 'marks_semester3.xlsx',           e: 'xlsx',  sz: '1.1 MB',  s: 'pending',  dir: '/Drive' },
  { n: 'thesis_draft_v7.docx',           e: 'docx',  sz: '4.2 MB',  s: 'pending',  dir: '/Documents' },
  { n: 'lecture_notes_dl.pdf',           e: 'pdf',   sz: '12.6 MB', s: 'verified', dir: '/Telegram' },
  { n: 'pitch_deck_q4.pptx',             e: 'pptx',  sz: '8.4 MB',  s: 'pending',  dir: '/WhatsApp' },
  { n: 'rent_agreement_2025.pdf',        e: 'pdf',   sz: '1.7 MB',  s: 'verified', dir: '/Download' },
  { n: 'expenses.csv',                   e: 'csv',   sz: '0.2 MB',  s: 'pending',  dir: '/Documents' },
  { n: 'atomic_habits.epub',             e: 'epub',  sz: '3.1 MB',  s: 'pending',  dir: '/Download' },
  { n: 'meeting_minutes.docx',           e: 'docx',  sz: '0.6 MB',  s: 'pending',  dir: '/Documents' },
];

const STATUS_STYLE = {
  verified: { fg: 'oklch(50% 0.11 155)', bg: 'oklch(96% 0.02 155)',  d: 'oklch(64% 0.11 155)' },
  pending:  { fg: '#857F77',             bg: '#F4F2EE',               d: '#B8B0A6' },
  flagged:  { fg: 'oklch(45% 0.16 25)',  bg: 'oklch(96% 0.025 25)',   d: 'oklch(60% 0.16 25)' },
  failed:   { fg: 'oklch(45% 0.16 25)',  bg: 'oklch(96% 0.025 25)',   d: 'oklch(60% 0.16 25)' },
};

function ScreenFiles({ accent }) {
  const [filter, setFilter] = useState2('All');
  const filters = ['All', 'PDF', 'DOCX', 'XLSX', 'PPTX', 'Pending', 'Flagged'];
  const list = filter === 'All' ? SAMPLE_FILES
    : filter === 'Pending' ? SAMPLE_FILES.filter(f => f.s === 'pending')
    : filter === 'Flagged' ? SAMPLE_FILES.filter(f => f.s === 'flagged')
    : SAMPLE_FILES.filter(f => f.e === filter.toLowerCase());

  return (
    <div style={{ flex: 1, display: 'flex', flexDirection: 'column', overflow: 'hidden' }}>
      <div style={{ flex: 1, overflow: 'auto', padding: '8px 20px 20px', display: 'flex', flexDirection: 'column', gap: 14 }}>
        {/* header */}
        <div>
          <div style={{ fontSize: 28, fontWeight: 700, letterSpacing: -0.6, lineHeight: 1.1 }}>All files</div>
          <div style={{ fontSize: 14, color: DS.sub, marginTop: 4 }}>
            <span style={{ fontFamily: DS.mono }}>{list.length}</span> shown · <span style={{ fontFamily: DS.mono }}>2,653</span> total
          </div>
        </div>

        {/* search bar */}
        <div style={{ display: 'flex', gap: 10 }}>
          <div style={{
            flex: 1, height: 56, borderRadius: 999, background: '#fff',
            display: 'flex', alignItems: 'center', padding: '0 22px', gap: 12,
            boxShadow: '0 1px 0 rgba(20,17,15,.04), 0 8px 22px rgba(20,17,15,.05)',
          }}>
            <IconSearch size={18} color={DS.sub}/>
            <span style={{ fontSize: 15, color: DS.sub }}>Search by name or content…</span>
          </div>
          <button style={{
            width: 56, height: 56, borderRadius: '50%', background: DS.pillBg, border: 0, cursor: 'pointer',
            color: '#fff', display: 'flex', alignItems: 'center', justifyContent: 'center',
            boxShadow: '0 8px 22px rgba(20,17,15,.22)',
          }}><IconSliders size={20}/></button>
        </div>

        {/* filter chips — horizontal scroll */}
        <div style={{
          display: 'flex', gap: 8, overflow: 'auto', paddingBottom: 4,
          marginLeft: -20, marginRight: -20, padding: '4px 20px',
          scrollbarWidth: 'none',
        }}>
          {filters.map(f => <Chip key={f} active={filter === f} onClick={() => setFilter(f)}>{f}</Chip>)}
        </div>

        {/* grouped list */}
        <Card pad={0}>
          {list.map((f, i) => (
            <div key={f.n} style={{
              display: 'flex', alignItems: 'center', gap: 14, padding: '12px 14px',
              borderBottom: i < list.length - 1 ? `1px solid ${DS.hairline}` : 'none',
            }}>
              <FileTag ext={f.e}/>
              <div style={{ flex: 1, minWidth: 0 }}>
                <div style={{
                  fontSize: 14, fontWeight: 600, color: DS.ink, lineHeight: 1.3,
                  overflow: 'hidden', textOverflow: 'ellipsis', whiteSpace: 'nowrap',
                }}>{f.n}</div>
                <div style={{ fontSize: 12, color: DS.sub, marginTop: 2, display: 'flex', gap: 8, fontFamily: DS.mono }}>
                  <span>{f.sz}</span><span>·</span><span>{f.dir}</span>
                </div>
              </div>
              <StatusDot s={f.s}/>
            </div>
          ))}
        </Card>
      </div>
      <BottomNav active="files"/>
    </div>
  );
}

function StatusDot({ s }) {
  const st = STATUS_STYLE[s] || STATUS_STYLE.pending;
  return (
    <div style={{
      display: 'flex', alignItems: 'center', gap: 6, padding: '4px 10px 4px 8px',
      borderRadius: 999, background: st.bg, color: st.fg,
      fontSize: 11, fontWeight: 600, textTransform: 'capitalize',
    }}>
      <span style={{ width: 6, height: 6, borderRadius: '50%', background: st.d }}/>
      {s}
    </div>
  );
}

// ═══════════════════════════════════════════════════════════════════
// 5. TRANSFER — chunked upload progress
// ═══════════════════════════════════════════════════════════════════
function ScreenTransfer({ accent, transferProgress }) {
  const total = 2653;
  const sent = Math.round(total * transferProgress / 100);
  const failed = transferProgress > 20 ? 5 : 0;
  const inflight = transferProgress > 5 && transferProgress < 100 ? 3 : 0;

  return (
    <div style={{ flex: 1, display: 'flex', flexDirection: 'column', overflow: 'hidden' }}>
      <div style={{ flex: 1, overflow: 'auto', padding: '8px 20px 20px', display: 'flex', flexDirection: 'column', gap: 16 }}>
        {/* header */}
        <div style={{ display: 'flex', alignItems: 'center', gap: 12 }}>
          <button style={{
            width: 40, height: 40, borderRadius: '50%', background: '#fff', border: 0, cursor: 'pointer',
            display: 'flex', alignItems: 'center', justifyContent: 'center',
            boxShadow: '0 1px 0 rgba(20,17,15,.04), 0 8px 22px rgba(20,17,15,.05)',
          }}><IconChevronLeft size={18}/></button>
          <div style={{ flex: 1 }}>
            <div style={{ fontSize: 12, color: DS.sub, fontWeight: 500 }}>Phase 1B</div>
            <div style={{ fontSize: 18, fontWeight: 700, letterSpacing: -0.3 }}>Transfer</div>
          </div>
          <div style={{
            display: 'flex', alignItems: 'center', gap: 6, padding: '8px 12px',
            borderRadius: 999, background: '#fff', fontSize: 12, fontWeight: 600,
            boxShadow: '0 1px 0 rgba(20,17,15,.04), 0 8px 22px rgba(20,17,15,.05)',
          }}>
            <span style={{ width: 6, height: 6, borderRadius: '50%', background: accent }}/>
            <span style={{ fontFamily: DS.mono }}>192.168.1.42</span>
          </div>
        </div>

        {/* hero ring */}
        <Card pad={26} style={{ display: 'flex', alignItems: 'center', gap: 22 }}>
          <Ring value={transferProgress} accent={accent}/>
          <div style={{ flex: 1 }}>
            <div style={{ fontSize: 12, color: DS.sub, fontWeight: 500, letterSpacing: 0.3, textTransform: 'uppercase' }}>
              Sending
            </div>
            <div style={{ fontSize: 26, fontWeight: 700, letterSpacing: -0.6, marginTop: 4, lineHeight: 1.1 }}>
              {sent.toLocaleString()} / {total.toLocaleString()}
            </div>
            <div style={{ fontSize: 13, color: DS.sub, marginTop: 6, fontFamily: DS.mono }}>
              {(10.1 * transferProgress / 100).toFixed(1)} GB / 10.1 GB
            </div>
          </div>
        </Card>

        {/* tally row */}
        <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr 1fr', gap: 10 }}>
          <TallyCard label="Verified"  value={Math.max(sent - inflight - failed, 0)} dot={accent}/>
          <TallyCard label="Sending"   value={inflight} dot={DS.warn} mono/>
          <TallyCard label="Failed"    value={failed}   dot={failed ? DS.bad : DS.sub}/>
        </div>

        {/* in-flight files */}
        <div>
          <div style={{ fontSize: 13, fontWeight: 700, color: DS.ink, marginBottom: 8 }}>Currently sending</div>
          <Card pad={0}>
            {[
              { n: 'report_final_v3.pdf',   e: 'pdf',   p: 78, sz: '2.1 MB' },
              { n: 'bookkeeping_q3.xlsx',   e: 'xlsx',  p: 34, sz: '0.9 MB' },
              { n: 'photos_metadata.docx',  e: 'docx',  p: 12, sz: '1.4 MB' },
            ].map((f, i, arr) => (
              <div key={f.n} style={{
                display: 'flex', alignItems: 'center', gap: 12, padding: '12px 14px',
                borderBottom: i < arr.length - 1 ? `1px solid ${DS.hairline}` : 'none',
              }}>
                <FileTag ext={f.e}/>
                <div style={{ flex: 1, minWidth: 0 }}>
                  <div style={{
                    fontSize: 13.5, fontWeight: 600, overflow: 'hidden',
                    textOverflow: 'ellipsis', whiteSpace: 'nowrap',
                  }}>{f.n}</div>
                  <div style={{ marginTop: 6 }}>
                    <Progress value={f.p} color={accent} height={4}/>
                  </div>
                  <div style={{ fontSize: 11, color: DS.sub, marginTop: 4, display: 'flex', justifyContent: 'space-between', fontFamily: DS.mono }}>
                    <span>chunk {Math.round(f.p / 100 * (parseFloat(f.sz) / 2))}/{Math.round(parseFloat(f.sz) / 2)}</span>
                    <span>{f.p}%</span>
                  </div>
                </div>
              </div>
            ))}
          </Card>
        </div>

        {/* control row */}
        <div style={{ display: 'flex', gap: 10, marginTop: 4 }}>
          <Pill style={{ flex: 1, justifyContent: 'center' }} icon={<IconPause size={16}/>}>Pause</Pill>
          <Pill dark style={{ flex: 1.4, justifyContent: 'center' }} icon={<IconAlert size={16} color="#fff"/>}>
            View failed ({failed})
          </Pill>
        </div>
      </div>
    </div>
  );
}

function TallyCard({ label, value, dot, mono }) {
  return (
    <Card pad={14}>
      <div style={{ display: 'flex', alignItems: 'center', gap: 6 }}>
        <span style={{ width: 6, height: 6, borderRadius: '50%', background: dot }}/>
        <span style={{ fontSize: 11, color: DS.sub, fontWeight: 600, letterSpacing: 0.3, textTransform: 'uppercase' }}>{label}</span>
      </div>
      <div style={{
        fontSize: 24, fontWeight: 700, letterSpacing: -0.5, marginTop: 4,
        fontFamily: mono ? DS.mono : DS.font,
      }}>{value.toLocaleString()}</div>
    </Card>
  );
}

function Ring({ value, accent }) {
  const size = 96, r = 40, c = 2 * Math.PI * r;
  const off = c - (value / 100) * c;
  return (
    <div style={{ position: 'relative', width: size, height: size, flexShrink: 0 }}>
      <svg width={size} height={size} style={{ transform: 'rotate(-90deg)' }}>
        <circle cx={size/2} cy={size/2} r={r} stroke={DS.hairline} strokeWidth="6" fill="none"/>
        <circle cx={size/2} cy={size/2} r={r} stroke={accent} strokeWidth="6" fill="none"
          strokeDasharray={c} strokeDashoffset={off} strokeLinecap="round"
          style={{ transition: 'stroke-dashoffset .4s ease' }}/>
      </svg>
      <div style={{
        position: 'absolute', inset: 0, display: 'flex',
        alignItems: 'center', justifyContent: 'center',
        fontSize: 22, fontWeight: 700, letterSpacing: -0.4, fontFamily: DS.font,
      }}>{value}<span style={{ fontSize: 11, color: DS.sub, marginLeft: 1 }}>%</span></div>
    </div>
  );
}

// ═══════════════════════════════════════════════════════════════════
// 6. CLUSTERS — Stage 5-7 review UI on phone
// ═══════════════════════════════════════════════════════════════════
const CLUSTERS = [
  { l: 'Bank statements',         n: 142, sample: ['hdfc_jan.pdf','sbi_feb.pdf','axis_mar.pdf'], e: 'pdf',  flag: true,  conf: 0.94 },
  { l: 'College notes — Physics', n: 318, sample: ['mechanics_l1.pdf','quantum_l3.docx'],         e: 'pdf',  flag: false, conf: 0.91 },
  { l: 'Aadhaar & ID copies',     n: 11,  sample: ['aadhaar_copy.pdf','pan_copy.pdf'],            e: 'pdf',  flag: true,  conf: 0.97 },
  { l: 'Lecture slides',          n: 234, sample: ['ml_lecture_4.pptx','dl_w3.pptx'],             e: 'pptx', flag: false, conf: 0.88 },
  { l: 'Tax & receipts 2024-25',  n: 87,  sample: ['16a_form.pdf','itr_ack.pdf'],                 e: 'pdf',  flag: false, conf: 0.86 },
  { l: 'Project reports',         n: 56,  sample: ['btp_final.docx','intern_report.pdf'],         e: 'docx', flag: false, conf: 0.82 },
];

function ScreenClusters({ accent }) {
  return (
    <div style={{ flex: 1, display: 'flex', flexDirection: 'column', overflow: 'hidden' }}>
      <div style={{ flex: 1, overflow: 'auto', padding: '8px 20px 20px', display: 'flex', flexDirection: 'column', gap: 14 }}>
        <div>
          <div style={{ fontSize: 28, fontWeight: 700, letterSpacing: -0.6, lineHeight: 1.1 }}>Clusters</div>
          <div style={{ fontSize: 14, color: DS.sub, marginTop: 4 }}>
            <span style={{ fontFamily: DS.mono }}>14</span> groups · labelled by <span style={{ fontFamily: DS.mono }}>qwen3:14b</span>
          </div>
        </div>

        {/* sensitive callout */}
        <Card pad={16} style={{ background: 'oklch(96% 0.025 60)', boxShadow: 'none', border: '1px solid oklch(88% 0.06 60)' }}>
          <div style={{ display: 'flex', gap: 12, alignItems: 'flex-start' }}>
            <div style={{
              width: 36, height: 36, borderRadius: 10, background: '#fff',
              display: 'flex', alignItems: 'center', justifyContent: 'center', flexShrink: 0,
            }}><IconAlert size={18} color="oklch(50% 0.13 60)"/></div>
            <div style={{ flex: 1 }}>
              <div style={{ fontSize: 14, fontWeight: 700, color: 'oklch(35% 0.1 60)' }}>2 sensitive clusters flagged</div>
              <div style={{ fontSize: 12.5, color: 'oklch(45% 0.08 60)', marginTop: 2, lineHeight: 1.45 }}>
                Matched keyword rules: <span style={{ fontFamily: DS.mono }}>aadhaar</span>, <span style={{ fontFamily: DS.mono }}>account number</span>, <span style={{ fontFamily: DS.mono }}>pan</span>.
              </div>
            </div>
          </div>
        </Card>

        {CLUSTERS.map((c, i) => (
          <Card key={c.l} pad={18}>
            <div style={{ display: 'flex', alignItems: 'flex-start', gap: 12 }}>
              <div style={{
                width: 44, height: 44, borderRadius: 14, background: DS.bg,
                display: 'flex', alignItems: 'center', justifyContent: 'center', flexShrink: 0,
              }}>
                <span style={{ fontSize: 18, fontWeight: 700 }}>{String(i + 1).padStart(2, '0')}</span>
              </div>
              <div style={{ flex: 1, minWidth: 0 }}>
                <div style={{ display: 'flex', alignItems: 'center', gap: 8 }}>
                  <span style={{ fontSize: 16, fontWeight: 700, letterSpacing: -0.2 }}>{c.l}</span>
                  {c.flag && (
                    <span style={{
                      fontSize: 10, fontWeight: 700, padding: '2px 8px', borderRadius: 999,
                      background: 'oklch(94% 0.04 60)', color: 'oklch(45% 0.13 60)',
                      letterSpacing: 0.4, textTransform: 'uppercase',
                    }}>flagged</span>
                  )}
                </div>
                <div style={{ fontSize: 12.5, color: DS.sub, marginTop: 4, fontFamily: DS.mono }}>
                  {c.n} files · confidence {(c.conf * 100).toFixed(0)}%
                </div>
              </div>
              <IconChevronRight size={18} color={DS.sub}/>
            </div>

            {/* sample chips */}
            <div style={{ display: 'flex', gap: 6, marginTop: 14, flexWrap: 'wrap' }}>
              {c.sample.map(s => (
                <span key={s} style={{
                  fontSize: 11.5, padding: '5px 10px', borderRadius: 999,
                  background: DS.bg, color: DS.ink2, fontFamily: DS.mono,
                  overflow: 'hidden', textOverflow: 'ellipsis', maxWidth: 140, whiteSpace: 'nowrap',
                }}>{s}</span>
              ))}
              {c.n > c.sample.length && (
                <span style={{
                  fontSize: 11.5, padding: '5px 10px', borderRadius: 999, color: DS.sub,
                }}>+{c.n - c.sample.length} more</span>
              )}
            </div>

            <div style={{ display: 'flex', gap: 8, marginTop: 14 }}>
              <button style={btn(false)}>Keep</button>
              <button style={btn(false)}>Rename</button>
              <button style={{ ...btn(false), color: DS.bad }}>Trash</button>
            </div>
          </Card>
        ))}
      </div>
      <BottomNav active="review"/>
    </div>
  );
}

function btn(dark) {
  return {
    flex: 1, height: 38, borderRadius: 999, border: `1px solid ${DS.hairline}`,
    background: dark ? DS.pillBg : '#fff', color: dark ? '#fff' : DS.ink,
    fontFamily: DS.font, fontWeight: 600, fontSize: 13, cursor: 'pointer',
  };
}

// ═══════════════════════════════════════════════════════════════════
// 7. PERMISSION — onboarding gate
// ═══════════════════════════════════════════════════════════════════
function ScreenPermission({ accent }) {
  return (
    <div style={{ flex: 1, padding: '8px 24px 24px', display: 'flex', flexDirection: 'column' }}>
      <button style={{
        width: 44, height: 44, borderRadius: '50%', background: '#fff', border: 0, cursor: 'pointer',
        display: 'flex', alignItems: 'center', justifyContent: 'center', alignSelf: 'flex-start',
        boxShadow: '0 1px 0 rgba(20,17,15,.04), 0 8px 22px rgba(20,17,15,.05)',
      }}><IconChevronLeft size={20}/></button>

      <div style={{ marginTop: 18 }}>
        <div style={{ fontSize: 13, color: DS.sub, fontWeight: 500 }}>Step 2 of 3</div>
        <div style={{ fontSize: 32, fontWeight: 700, letterSpacing: -0.8, lineHeight: 1.05, marginTop: 6 }}>
          Storage<br/>access
        </div>
        <div style={{ fontSize: 14.5, color: DS.sub, marginTop: 12, lineHeight: 1.55 }}>
          We need <span style={{ fontFamily: DS.mono, color: DS.ink }}>MANAGE_EXTERNAL_STORAGE</span> to read documents from
          Downloads, WhatsApp, Telegram and Drive.
        </div>
      </div>

      <Card pad={20} style={{ marginTop: 24 }}>
        <div style={{ display: 'flex', flexDirection: 'column', gap: 16 }}>
          {[
            { i: <IconShield size={18}/>,  t: 'Read-only',          s: 'Files are never deleted from your phone' },
            { i: <IconWifi size={18}/>,    t: 'Local network only', s: 'Nothing leaves your Wi-Fi' },
            { i: <IconCheck size={18}/>,   t: 'You stay in control', s: 'Review before transfer, deselect anything' },
          ].map(row => (
            <div key={row.t} style={{ display: 'flex', gap: 14, alignItems: 'flex-start' }}>
              <div style={{
                width: 38, height: 38, borderRadius: 12, background: DS.bg, color: accent,
                display: 'flex', alignItems: 'center', justifyContent: 'center', flexShrink: 0,
              }}>{row.i}</div>
              <div style={{ flex: 1 }}>
                <div style={{ fontSize: 14.5, fontWeight: 700 }}>{row.t}</div>
                <div style={{ fontSize: 13, color: DS.sub, marginTop: 2, lineHeight: 1.45 }}>{row.s}</div>
              </div>
            </div>
          ))}
        </div>
      </Card>

      {/* visual mock of the OS prompt */}
      <Card pad={18} style={{ marginTop: 16, background: '#FAF9F6' }}>
        <div style={{ fontSize: 11, color: DS.sub, fontWeight: 600, letterSpacing: 0.4, textTransform: 'uppercase', marginBottom: 8 }}>
          Android will ask
        </div>
        <div style={{ fontSize: 14, fontWeight: 600, lineHeight: 1.4 }}>
          Allow Document Sorter to access photos, media and files on this device?
        </div>
        <div style={{ display: 'flex', gap: 8, marginTop: 14, justifyContent: 'flex-end' }}>
          <span style={{ fontSize: 13, fontWeight: 600, color: DS.sub }}>DENY</span>
          <span style={{ fontSize: 13, fontWeight: 700, color: accent }}>ALLOW</span>
        </div>
      </Card>

      <Pill dark style={{ marginTop: 'auto', justifyContent: 'center' }} icon={<IconShield size={18} color="#fff"/>}>
        Grant storage access
      </Pill>
    </div>
  );
}

Object.assign(window, { ScreenFiles, ScreenTransfer, ScreenClusters, ScreenPermission });
