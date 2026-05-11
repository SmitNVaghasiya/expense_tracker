// screens.jsx — Document Sorter screens (Android, hi-fi)

const { useState, useEffect, useRef } = React;

// ═══════════════════════════════════════════════════════════════════
// 1. CONNECT — pair phone with laptop server
// ═══════════════════════════════════════════════════════════════════
function ScreenConnect({ accent }) {
  const [ip, setIp] = useState('192.168.1.42');
  const [status, setStatus] = useState('connected'); // idle | connecting | connected | failed
  const dot = { connected: accent, connecting: DS.warn, idle: DS.sub, failed: DS.bad }[status];
  const label = { connected: 'Connected', connecting: 'Pairing…', idle: 'Not paired', failed: 'Unreachable' }[status];

  return (
    <div style={{ flex: 1, padding: '8px 20px 20px', display: 'flex', flexDirection: 'column', gap: 16 }}>
      <button style={{
        width: 44, height: 44, borderRadius: '50%', background: '#fff', border: 0, cursor: 'pointer',
        display: 'flex', alignItems: 'center', justifyContent: 'center', alignSelf: 'flex-start',
        boxShadow: '0 1px 0 rgba(20,17,15,.04), 0 8px 22px rgba(20,17,15,.05)',
      }}><IconChevronLeft size={20}/></button>

      <div style={{ marginTop: 8 }}>
        <div style={{ fontSize: 13, color: DS.sub, fontWeight: 500 }}>Step 1 of 3</div>
        <div style={{ fontSize: 30, fontWeight: 700, letterSpacing: -0.8, lineHeight: 1.1, marginTop: 6 }}>
          Pair with your<br/>laptop
        </div>
        <div style={{ fontSize: 14.5, color: DS.sub, marginTop: 10, lineHeight: 1.5 }}>
          Both devices must be on the same Wi-Fi.<br/>Open the desktop app to find your IP.
        </div>
      </div>

      {/* connection card */}
      <Card pad={18}>
        <div style={{ display: 'flex', alignItems: 'center', gap: 14, marginBottom: 14 }}>
          <div style={{ width: 44, height: 44, borderRadius: 12, background: DS.bg,
            display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
            <IconLaptop size={22}/>
          </div>
          <div style={{ flex: 1 }}>
            <div style={{ fontSize: 15, fontWeight: 600 }}>Smit's MacBook</div>
            <div style={{ fontSize: 12.5, color: DS.sub, fontFamily: DS.mono, marginTop: 2 }}>
              Document Sorter · v0.1
            </div>
          </div>
          <div style={{
            display: 'flex', alignItems: 'center', gap: 6, padding: '6px 10px',
            borderRadius: 999, background: DS.bg, fontSize: 12, fontWeight: 600,
          }}>
            <span style={{ width: 6, height: 6, borderRadius: '50%', background: dot }}/>
            {label}
          </div>
        </div>

        <div style={{ borderTop: `1px solid ${DS.hairline}`, paddingTop: 14 }}>
          <div style={{ fontSize: 12, color: DS.sub, fontWeight: 500, marginBottom: 6 }}>SERVER ADDRESS</div>
          <div style={{ display: 'flex', alignItems: 'center', gap: 10 }}>
            <input value={ip} onChange={e => setIp(e.target.value)} style={{
              flex: 1, height: 44, border: `1px solid ${DS.hairline}`, borderRadius: 12,
              padding: '0 14px', fontFamily: DS.mono, fontSize: 14, color: DS.ink,
              background: '#fff', outline: 'none',
            }}/>
            <span style={{ fontFamily: DS.mono, fontSize: 14, color: DS.sub }}>:8000</span>
          </div>
        </div>

        <div style={{ borderTop: `1px solid ${DS.hairline}`, marginTop: 14, paddingTop: 14,
          display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
          <div>
            <div style={{ fontSize: 13, fontWeight: 600 }}>Auto-discover</div>
            <div style={{ fontSize: 12, color: DS.sub }}>Find by mDNS broadcast</div>
          </div>
          <Toggle on={true}/>
        </div>
      </Card>

      <div style={{ display: 'flex', gap: 10, marginTop: 'auto' }}>
        <Pill style={{ flex: 1, justifyContent: 'center' }}>Test ping</Pill>
        <Pill dark style={{ flex: 1.4, justifyContent: 'center' }} icon={<IconArrowRight size={18} color="#fff"/>}>
          Continue
        </Pill>
      </div>
    </div>
  );
}

function Toggle({ on }) {
  return (
    <div style={{
      width: 44, height: 26, borderRadius: 999, padding: 3, boxSizing: 'border-box',
      background: on ? DS.pillBg : DS.hairline, transition: 'background .2s',
      display: 'flex', justifyContent: on ? 'flex-end' : 'flex-start',
    }}>
      <div style={{ width: 20, height: 20, borderRadius: '50%', background: '#fff' }}/>
    </div>
  );
}

// ═══════════════════════════════════════════════════════════════════
// 2. HOME — dashboard with stats + actions
// ═══════════════════════════════════════════════════════════════════
function ScreenHome({ accent, demo }) {
  return (
    <div style={{ flex: 1, display: 'flex', flexDirection: 'column', overflow: 'hidden' }}>
      <div style={{ flex: 1, overflow: 'auto', padding: '8px 20px 20px', display: 'flex', flexDirection: 'column', gap: 18 }}>

        {/* greeting */}
        <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
          <div>
            <div style={{ fontSize: 28, fontWeight: 700, letterSpacing: -0.6, lineHeight: 1.1 }}>
              Hello, Smit
            </div>
            <div style={{ fontSize: 14, color: DS.sub, marginTop: 4 }}>2,653 docs across 5 folders</div>
          </div>
          <div style={{
            width: 44, height: 44, borderRadius: '50%', background: '#fff',
            display: 'flex', alignItems: 'center', justifyContent: 'center',
            boxShadow: '0 1px 0 rgba(20,17,15,.04), 0 8px 22px rgba(20,17,15,.05)',
            position: 'relative',
          }}>
            <IconWifi size={20}/>
            <span style={{
              position: 'absolute', top: 6, right: 6, width: 8, height: 8,
              borderRadius: '50%', background: accent, border: '2px solid #fff',
            }}/>
          </div>
        </div>

        {/* hero stat card — large rounded, image-like */}
        <Card pad={0} style={{ overflow: 'hidden' }}>
          <div style={{
            background: DS.pillBg, color: '#fff', padding: '20px 22px 22px',
            position: 'relative', overflow: 'hidden',
          }}>
            <PaperPattern accent={accent}/>
            <div style={{ position: 'relative', zIndex: 1 }}>
              <div style={{ fontSize: 12, opacity: .6, fontWeight: 500, letterSpacing: 0.4, textTransform: 'uppercase' }}>
                Library
              </div>
              <div style={{ fontSize: 44, fontWeight: 700, letterSpacing: -1.4, marginTop: 6, lineHeight: 1 }}>
                2,653<span style={{ fontSize: 16, opacity: .55, marginLeft: 8, fontWeight: 500 }}>docs</span>
              </div>
              <div style={{ fontSize: 14, opacity: .7, marginTop: 6, fontFamily: DS.mono }}>
                10.1 GB · 5 sources
              </div>

              <div style={{
                marginTop: 18, display: 'flex', gap: 6, alignItems: 'center',
              }}>
                <SegBar segs={[
                  { v: 38, c: '#FCE9E4', l: 'PDF' },
                  { v: 22, c: '#E4ECFC', l: 'DOCX' },
                  { v: 14, c: '#FCEFD6', l: 'PPTX' },
                  { v: 16, c: '#E1F2E5', l: 'XLSX' },
                  { v: 10, c: 'rgba(255,255,255,.3)', l: 'Other' },
                ]}/>
              </div>
              <div style={{ display: 'flex', gap: 14, marginTop: 10, fontSize: 11.5, opacity: .8, flexWrap: 'wrap' }}>
                {['PDF 1,008','DOCX 583','PPTX 372','XLSX 425','Other 265'].map(s => (
                  <span key={s} style={{ fontFamily: DS.mono }}>{s}</span>
                ))}
              </div>
            </div>
          </div>
        </Card>

        {/* action grid */}
        <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 12 }}>
          <ActionCard title="Scan phone" sub="Find new docs" icon={<IconScan size={22}/>} accent={accent}/>
          <ActionCard title="Transfer" sub={demo ? 'In progress · 41%' : 'Send to laptop'} icon={<IconUpload size={22}/>}
            badge={demo ? '41%' : null} accent={accent}/>
          <ActionCard title="Browse files" sub="2,653 found" icon={<IconList size={22}/>}/>
          <ActionCard title="Clusters" sub="14 groups · 2 flagged" icon={<IconLayers size={22}/>}/>
        </div>

        {/* recent activity */}
        <div>
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'baseline', marginBottom: 10 }}>
            <div style={{ fontSize: 16, fontWeight: 700 }}>Recent activity</div>
            <span style={{ fontSize: 13, color: DS.sub, textDecoration: 'underline' }}>See all</span>
          </div>
          <Card pad={0}>
            {[
              { i: <IconCheck size={18}/>,    t: 'Transferred 187 files',  s: '2 min ago · 412 MB',     c: accent },
              { i: <IconScan size={18}/>,     t: 'Scan complete',           s: '08:21 · 2,653 found',    c: DS.ink },
              { i: <IconShield size={18}/>,   t: 'Storage permission',      s: 'Granted yesterday',      c: DS.ink },
            ].map((row, i, arr) => (
              <div key={i} style={{
                display: 'flex', alignItems: 'center', gap: 14, padding: '14px 18px',
                borderBottom: i < arr.length - 1 ? `1px solid ${DS.hairline}` : 'none',
              }}>
                <div style={{ width: 36, height: 36, borderRadius: 10, background: DS.bg,
                  display: 'flex', alignItems: 'center', justifyContent: 'center', color: row.c }}>
                  {row.i}
                </div>
                <div style={{ flex: 1 }}>
                  <div style={{ fontSize: 14, fontWeight: 600 }}>{row.t}</div>
                  <div style={{ fontSize: 12, color: DS.sub, marginTop: 2 }}>{row.s}</div>
                </div>
                <IconChevronRight size={16} color={DS.sub}/>
              </div>
            ))}
          </Card>
        </div>
      </div>
      <BottomNav active="home"/>
    </div>
  );
}

function PaperPattern({ accent }) {
  return (
    <svg style={{ position: 'absolute', right: -30, top: -20, opacity: .14 }}
      width="220" height="220" viewBox="0 0 220 220" fill="none">
      <rect x="40" y="20" width="120" height="160" rx="8" stroke={accent} strokeWidth="1.5"/>
      <rect x="60" y="40" width="120" height="160" rx="8" stroke={accent} strokeWidth="1.5"/>
      <rect x="80" y="60" width="120" height="160" rx="8" stroke="#fff" strokeWidth="1.5"/>
      <path d="M95 90h90M95 110h90M95 130h60M95 150h75" stroke="#fff" strokeWidth="1" opacity="0.6"/>
    </svg>
  );
}

function ActionCard({ title, sub, icon, accent, badge }) {
  return (
    <Card pad={16} style={{ minHeight: 124, display: 'flex', flexDirection: 'column', justifyContent: 'space-between', position: 'relative' }}>
      <div style={{
        width: 38, height: 38, borderRadius: 12, background: DS.bg,
        display: 'flex', alignItems: 'center', justifyContent: 'center',
      }}>{icon}</div>
      <div>
        <div style={{ fontSize: 15, fontWeight: 700, letterSpacing: -0.2 }}>{title}</div>
        <div style={{ fontSize: 12.5, color: DS.sub, marginTop: 2 }}>{sub}</div>
      </div>
      {badge && (
        <div style={{
          position: 'absolute', top: 14, right: 14,
          fontSize: 11, fontWeight: 700, padding: '4px 8px', borderRadius: 999,
          background: accent, color: '#fff', fontFamily: DS.mono,
        }}>{badge}</div>
      )}
    </Card>
  );
}

function SegBar({ segs }) {
  return (
    <div style={{ display: 'flex', gap: 4, width: '100%', height: 8 }}>
      {segs.map((s, i) => (
        <div key={i} style={{ flex: s.v, height: '100%', borderRadius: 4, background: s.c }}/>
      ))}
    </div>
  );
}

// ═══════════════════════════════════════════════════════════════════
// 3. SCAN — folder scan + checksum progress
// ═══════════════════════════════════════════════════════════════════
function ScreenScan({ accent, demo, scanProgress, hashProgress }) {
  const folders = [
    { p: '/Download',                              n: 412, done: true  },
    { p: '/Documents',                             n: 1124, done: true  },
    { p: '/WhatsApp/Media/WhatsApp Documents',     n: 687, done: scanProgress > 60 },
    { p: '/Telegram',                              n: 318, done: scanProgress > 80 },
    { p: '/Drive',                                 n: 112, done: scanProgress >= 100 },
  ];
  return (
    <div style={{ flex: 1, display: 'flex', flexDirection: 'column', overflow: 'hidden' }}>
      <div style={{ flex: 1, overflow: 'auto', padding: '8px 20px 20px', display: 'flex', flexDirection: 'column', gap: 16 }}>
        <div style={{ display: 'flex', alignItems: 'center', gap: 12 }}>
          <button style={{
            width: 40, height: 40, borderRadius: '50%', background: '#fff', border: 0, cursor: 'pointer',
            display: 'flex', alignItems: 'center', justifyContent: 'center',
            boxShadow: '0 1px 0 rgba(20,17,15,.04), 0 8px 22px rgba(20,17,15,.05)',
          }}><IconChevronLeft size={18}/></button>
          <div style={{ flex: 1 }}>
            <div style={{ fontSize: 12, color: DS.sub, fontWeight: 500 }}>Phase 1A</div>
            <div style={{ fontSize: 18, fontWeight: 700, letterSpacing: -0.3 }}>Scanning storage</div>
          </div>
          <button style={{
            width: 40, height: 40, borderRadius: '50%', background: '#fff', border: 0, cursor: 'pointer',
            display: 'flex', alignItems: 'center', justifyContent: 'center',
            boxShadow: '0 1px 0 rgba(20,17,15,.04), 0 8px 22px rgba(20,17,15,.05)',
          }}><IconPause size={16}/></button>
        </div>

        {/* big stat */}
        <Card pad={22}>
          <div style={{ fontSize: 12, color: DS.sub, fontWeight: 500, letterSpacing: 0.3, textTransform: 'uppercase' }}>Files found</div>
          <div style={{ display: 'flex', alignItems: 'baseline', gap: 12, marginTop: 6 }}>
            <span style={{ fontSize: 56, fontWeight: 700, letterSpacing: -2, lineHeight: 1, fontFamily: DS.font }}>
              {Math.round(2653 * scanProgress / 100).toLocaleString()}
            </span>
            <span style={{ fontSize: 18, color: DS.sub, fontFamily: DS.mono }}>/ 2,653</span>
          </div>
          <div style={{ marginTop: 16 }}>
            <Progress value={scanProgress} color={DS.ink}/>
          </div>
          <div style={{ display: 'flex', justifyContent: 'space-between', marginTop: 8, fontSize: 12, color: DS.sub }}>
            <span style={{ fontFamily: DS.mono }}>Step 1 · Walking folders</span>
            <span style={{ fontFamily: DS.mono }}>{scanProgress}%</span>
          </div>
        </Card>

        {/* hash card */}
        <Card pad={22} style={{ background: scanProgress >= 100 ? DS.card : '#FAF9F6', opacity: scanProgress >= 100 ? 1 : 0.7 }}>
          <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
            <div>
              <div style={{ fontSize: 12, color: DS.sub, fontWeight: 500, letterSpacing: 0.3, textTransform: 'uppercase' }}>
                Checksums
              </div>
              <div style={{ fontSize: 22, fontWeight: 700, marginTop: 4, fontFamily: DS.mono, letterSpacing: -0.6 }}>
                {Math.round(2653 * hashProgress / 100).toLocaleString()}<span style={{ color: DS.sub, fontWeight: 500 }}> / 2,653</span>
              </div>
            </div>
            <div style={{
              width: 56, height: 56, borderRadius: 16, background: DS.bg,
              display: 'flex', alignItems: 'center', justifyContent: 'center',
            }}>
              <IconShield size={26} color={hashProgress > 0 ? accent : DS.sub}/>
            </div>
          </div>
          <div style={{ marginTop: 14 }}>
            <Progress value={hashProgress} color={accent}/>
          </div>
          <div style={{ fontSize: 12, color: DS.sub, marginTop: 8, fontFamily: DS.mono }}>
            SHA-256 · background isolate · {hashProgress < 100 ? 'running' : 'complete'}
          </div>
        </Card>

        {/* folders */}
        <div>
          <div style={{ fontSize: 13, fontWeight: 700, color: DS.ink, marginBottom: 8, letterSpacing: -0.1 }}>
            Source folders
          </div>
          <Card pad={0}>
            {folders.map((f, i) => (
              <div key={f.p} style={{
                display: 'flex', alignItems: 'center', gap: 12, padding: '12px 16px',
                borderBottom: i < folders.length - 1 ? `1px solid ${DS.hairline}` : 'none',
              }}>
                <IconFolder size={18} color={f.done ? DS.ink : DS.sub}/>
                <div style={{ flex: 1, minWidth: 0 }}>
                  <div style={{
                    fontSize: 13, fontFamily: DS.mono, color: f.done ? DS.ink : DS.sub,
                    overflow: 'hidden', textOverflow: 'ellipsis', whiteSpace: 'nowrap',
                  }}>{f.p}</div>
                </div>
                <span style={{ fontSize: 12, color: DS.sub, fontFamily: DS.mono }}>{f.n}</span>
                {f.done
                  ? <IconCheck size={16} color={accent}/>
                  : <Spinner accent={accent}/>}
              </div>
            ))}
          </Card>
        </div>
      </div>
    </div>
  );
}

function Spinner({ accent }) {
  return (
    <svg width="16" height="16" viewBox="0 0 16 16" style={{ animation: 'spin 1s linear infinite' }}>
      <circle cx="8" cy="8" r="6" stroke={DS.hairline} strokeWidth="2" fill="none"/>
      <path d="M14 8a6 6 0 0 0-6-6" stroke={accent} strokeWidth="2" fill="none" strokeLinecap="round"/>
    </svg>
  );
}

Object.assign(window, { ScreenConnect, ScreenHome, ScreenScan, Toggle });
