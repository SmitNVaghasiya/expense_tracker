// web-primitives.jsx — desktop console primitives
// Tokens
const W = {
  bg:    '#F4F2EE',
  panel: '#FFFFFF',
  panel2:'#FAF8F4',
  ink:   '#14110F',
  ink2:  '#3A3631',
  sub:   '#7A736B',
  sub2:  '#B8B0A4',
  hair:  '#EBE6DE',
  pill:  '#1E1A17',
  good:  'oklch(64% 0.11 155)',
  goodBg:'oklch(95% 0.04 155)',
  warn:  'oklch(70% 0.15 60)',
  warnBg:'oklch(96% 0.04 60)',
  bad:   'oklch(60% 0.18 25)',
  badBg: 'oklch(96% 0.04 25)',
  font:  "'Plus Jakarta Sans', system-ui, sans-serif",
  mono:  "'JetBrains Mono', ui-monospace, monospace",
};

// Sidebar
function Sidebar({ active, onPick, telemetry }) {
  const running = telemetry.filter(s => s.status === 'running').length;
  const items = [
    { id: 'dashboard',  label: 'Dashboard',   icon: <IconHome size={17}/> },
    { id: 'pipeline',   label: 'Pipeline',    icon: <IconLayers size={17}/>, badge: running > 0 ? running : null },
    { id: 'files',      label: 'Files',       icon: <IconFile size={17}/> },
    { id: 'duplicates', label: 'Duplicates',  icon: <IconList size={17}/>, badge: 217 },
    { id: 'clusters',   label: 'Clusters',    icon: <IconScan size={17}/>, dot: 'warn' },
    { id: 'settings',   label: 'Settings',    icon: <IconSettings size={17}/> },
  ];
  return (
    <aside style={{
      width: 240, background: '#FBF9F5', borderRight: `1px solid ${W.hair}`,
      padding: '20px 14px', display: 'flex', flexDirection: 'column', gap: 4,
    }}>
      {/* Logo block */}
      <div style={{ display: 'flex', alignItems: 'center', gap: 10, padding: '4px 8px 16px' }}>
        <div style={{
          width: 30, height: 30, borderRadius: 8, background: W.pill, color: '#fff',
          display: 'flex', alignItems: 'center', justifyContent: 'center',
          fontFamily: W.mono, fontSize: 13, fontWeight: 700,
        }}>DS</div>
        <div>
          <div style={{ fontSize: 13.5, fontWeight: 700, letterSpacing: -0.2 }}>Document Sorter</div>
          <div style={{ fontSize: 10.5, color: W.sub, fontFamily: W.mono }}>v0.4 · localhost</div>
        </div>
      </div>

      {items.map(it => {
        const on = active === it.id;
        return (
          <button key={it.id} onClick={() => onPick(it.id)} style={{
            display: 'flex', alignItems: 'center', gap: 12, padding: '10px 12px',
            border: 0, cursor: 'pointer', textAlign: 'left', borderRadius: 10,
            background: on ? '#fff' : 'transparent',
            color: on ? W.ink : W.ink2,
            fontWeight: on ? 600 : 500, fontSize: 13.5,
            boxShadow: on ? `inset 0 0 0 1px ${W.hair}` : 'none',
            fontFamily: W.font,
          }}>
            <span style={{ color: on ? W.ink : W.sub }}>{it.icon}</span>
            <span style={{ flex: 1 }}>{it.label}</span>
            {it.badge != null && (
              <span style={{
                fontSize: 10.5, fontFamily: W.mono, fontWeight: 700,
                background: on ? W.bg : W.hair, color: W.ink2,
                padding: '2px 7px', borderRadius: 999,
              }}>{it.badge}</span>
            )}
            {it.dot && <span style={{ width: 6, height: 6, borderRadius: '50%', background: W.warn }}/>}
          </button>
        );
      })}

      <div style={{ marginTop: 'auto', padding: '14px 10px 4px', borderTop: `1px solid ${W.hair}` }}>
        <div style={{ display: 'flex', alignItems: 'center', gap: 8, fontSize: 11, color: W.sub, fontFamily: W.mono }}>
          <span style={{ width: 7, height: 7, borderRadius: '50%', background: W.good,
            boxShadow: `0 0 0 3px ${W.goodBg}` }}/>
          phone connected
        </div>
        <div style={{ fontSize: 11, color: W.sub, fontFamily: W.mono, marginTop: 4 }}>
          Pixel 7a · 192.168.1.42
        </div>
      </div>
    </aside>
  );
}

// Page header
function WHeader({ eyebrow, title, sub, right }) {
  return (
    <div style={{ display: 'flex', alignItems: 'flex-end', justifyContent: 'space-between',
      marginBottom: 22, gap: 16 }}>
      <div>
        <div style={{ fontSize: 11, color: W.sub, fontWeight: 600, letterSpacing: 0.4, textTransform: 'uppercase' }}>
          {eyebrow}
        </div>
        <div style={{ fontSize: 28, fontWeight: 700, letterSpacing: -0.7, marginTop: 4 }}>{title}</div>
        {sub && <div style={{ fontSize: 13.5, color: W.sub, marginTop: 4 }}>{sub}</div>}
      </div>
      {right}
    </div>
  );
}

function WPanel({ children, pad = 18, style }) {
  return (
    <div style={{
      background: W.panel, border: `1px solid ${W.hair}`, borderRadius: 18,
      padding: pad, ...style,
    }}>{children}</div>
  );
}

function WStat({ label, value, hint, mono, accent }) {
  return (
    <WPanel pad={18}>
      <div style={{ fontSize: 11, color: W.sub, fontWeight: 600, letterSpacing: 0.3, textTransform: 'uppercase' }}>{label}</div>
      <div style={{
        fontSize: 30, fontWeight: 700, letterSpacing: -1, marginTop: 6,
        fontFamily: mono ? W.mono : W.font,
        color: accent || W.ink,
      }}>{value}</div>
      {hint && <div style={{ fontSize: 12, color: W.sub, marginTop: 4 }}>{hint}</div>}
    </WPanel>
  );
}

function WPill({ children, icon, dark, style, ...rest }) {
  return (
    <button {...rest} style={{
      display: 'inline-flex', alignItems: 'center', gap: 8, height: 36,
      padding: '0 14px', borderRadius: 999, fontSize: 12.5, fontWeight: 600,
      background: dark ? W.pill : '#fff',
      color: dark ? '#fff' : W.ink,
      border: dark ? '0' : `1px solid ${W.hair}`,
      cursor: 'pointer', fontFamily: W.font,
      ...style,
    }}>{icon}<span>{children}</span></button>
  );
}

function WChip({ children, active }) {
  return (
    <button style={{
      height: 32, padding: '0 14px', borderRadius: 999, fontSize: 12, fontWeight: 600,
      background: active ? W.pill : '#fff',
      color: active ? '#fff' : W.ink2,
      border: active ? '0' : `1px solid ${W.hair}`,
      cursor: 'pointer', fontFamily: W.font,
    }}>{children}</button>
  );
}

function WBar({ value, color, height = 6 }) {
  return (
    <div style={{ height, borderRadius: height, background: W.hair, overflow: 'hidden' }}>
      <div style={{ width: `${value}%`, height: '100%', background: color || W.ink, borderRadius: height,
        transition: 'width 200ms linear' }}/>
    </div>
  );
}

function FileTag({ ext }) {
  const palette = {
    pdf:  { bg: '#FCE9E1', c: '#9C3D26' },
    docx: { bg: '#E1E8FC', c: '#26469C' },
    xlsx: { bg: '#DEF1E5', c: '#256B3F' },
    pptx: { bg: '#FCEEDA', c: '#9C6B26' },
    csv:  { bg: '#EAEAEA', c: '#3A3631' },
    epub: { bg: '#EFE1FC', c: '#5B269C' },
  };
  const p = palette[ext] || palette.csv;
  return (
    <span style={{
      display: 'inline-block', padding: '3px 8px', borderRadius: 6,
      background: p.bg, color: p.c, fontSize: 10.5, fontWeight: 700,
      letterSpacing: 0.3, textTransform: 'uppercase', fontFamily: W.mono,
    }}>{ext}</span>
  );
}

Object.assign(window, { W, Sidebar, WHeader, WPanel, WStat, WPill, WChip, WBar, FileTag });
