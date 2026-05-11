// primitives.jsx — shared building blocks for Document Sorter screens

const DS = {
  bg: '#F4F2EE',
  card: '#FFFFFF',
  ink: '#14110F',
  ink2: '#3A352F',
  sub: '#857F77',
  hairline: '#ECE7E0',
  chip: '#F4F2EE',
  pillBg: '#14110F',
  good: 'oklch(64% 0.11 155)',
  goodBg: 'oklch(96% 0.02 155)',
  warn: 'oklch(67% 0.13 60)',
  warnBg: 'oklch(96% 0.025 60)',
  bad: 'oklch(60% 0.16 25)',
  font: '"Plus Jakarta Sans", -apple-system, system-ui, sans-serif',
  mono: '"JetBrains Mono", ui-monospace, "SF Mono", monospace',
};

// ─── Phone status bar (matches reference style — minimal, dark text)
function PhoneStatus({ time = '9:41' }) {
  return (
    <div style={{
      height: 44, padding: '0 24px', display: 'flex', alignItems: 'center',
      justifyContent: 'space-between', fontFamily: DS.font, color: DS.ink,
      fontWeight: 600, fontSize: 15, letterSpacing: 0.2, flexShrink: 0,
    }}>
      <span>{time}</span>
      <div style={{ display: 'flex', alignItems: 'center', gap: 6 }}>
        <svg width="16" height="11" viewBox="0 0 16 11"><path d="M0 8h2v3H0zM4 6h2v5H4zM8 4h2v7H8zM12 1h2v10h-2z" fill={DS.ink}/></svg>
        <svg width="15" height="11" viewBox="0 0 15 11"><path d="M7.5 2c2 0 3.8.7 5.2 2L14 2.7C12.3 1 10 0 7.5 0S2.7 1 1 2.7L2.3 4C3.7 2.7 5.5 2 7.5 2zm0 3.2c1.2 0 2.3.4 3.2 1.2L12 5.1C10.8 4 9.2 3.4 7.5 3.4S4.2 4 3 5.1l1.3 1.3c.9-.8 2-1.2 3.2-1.2zM7.5 8a1.5 1.5 0 1 0 0 3 1.5 1.5 0 0 0 0-3z" fill={DS.ink}/></svg>
        <svg width="24" height="11" viewBox="0 0 24 11">
          <rect x="0.5" y="0.5" width="20" height="10" rx="2.5" fill="none" stroke={DS.ink} strokeOpacity="0.4"/>
          <rect x="2" y="2" width="17" height="7" rx="1.2" fill={DS.ink}/>
          <path d="M22 4v3c.6-.2 1-.7 1-1.5S22.6 4.2 22 4z" fill={DS.ink} fillOpacity="0.5"/>
        </svg>
      </div>
    </div>
  );
}

// ─── Bottom pill nav (4 icons, dark)
function BottomNav({ active = 'home', onTap = () => {} }) {
  const items = [
    { k: 'home',    icon: <IconHome size={22}/> },
    { k: 'files',   icon: <IconList size={22}/> },
    { k: 'review',  icon: <IconLayers size={22}/> },
    { k: 'more',    icon: (
      <svg width="22" height="22" viewBox="0 0 24 24" fill="currentColor">
        <circle cx="6" cy="6" r="2"/><circle cx="18" cy="6" r="2"/>
        <circle cx="6" cy="18" r="2"/><circle cx="18" cy="18" r="2"/>
      </svg>
    )},
  ];
  return (
    <div style={{
      margin: '0 16px 14px', height: 64, borderRadius: 999,
      background: DS.pillBg, display: 'flex', alignItems: 'center',
      justifyContent: 'space-around', padding: '0 8px', flexShrink: 0,
      boxShadow: '0 8px 24px rgba(20,17,15,.18)',
    }}>
      {items.map(it => (
        <button key={it.k} onClick={() => onTap(it.k)} style={{
          width: 48, height: 48, borderRadius: '50%', border: 0, cursor: 'pointer',
          background: active === it.k ? '#fff' : 'transparent',
          color: active === it.k ? DS.ink : 'rgba(255,255,255,.7)',
          display: 'flex', alignItems: 'center', justifyContent: 'center',
          transition: 'background .2s, color .2s',
        }}>{it.icon}</button>
      ))}
    </div>
  );
}

// ─── Phone shell — replaces android frame default for our look
function PhoneShell({ children, time = '9:41', bg = DS.bg }) {
  return (
    <div style={{
      width: 390, height: 800, borderRadius: 44, overflow: 'hidden',
      background: bg, fontFamily: DS.font, color: DS.ink,
      display: 'flex', flexDirection: 'column',
      boxShadow: 'inset 0 0 0 8px #1a1a1a, 0 30px 60px rgba(20,17,15,.18)',
      border: '2px solid #2a2a2a', position: 'relative',
    }}>
      {/* dynamic island */}
      <div style={{
        position: 'absolute', top: 11, left: '50%', transform: 'translateX(-50%)',
        width: 110, height: 32, borderRadius: 999, background: '#000', zIndex: 5,
      }}/>
      <PhoneStatus time={time}/>
      <div style={{ flex: 1, overflow: 'hidden', display: 'flex', flexDirection: 'column' }}>
        {children}
      </div>
      {/* home indicator */}
      <div style={{ display: 'flex', justifyContent: 'center', padding: '6px 0 8px', flexShrink: 0 }}>
        <div style={{ width: 134, height: 5, borderRadius: 3, background: DS.ink, opacity: .9 }}/>
      </div>
    </div>
  );
}

// ─── Card
function Card({ children, style = {}, pad = 20 }) {
  return (
    <div style={{
      background: DS.card, borderRadius: 24, padding: pad,
      boxShadow: '0 1px 0 rgba(20,17,15,.04), 0 12px 28px rgba(20,17,15,.05)',
      ...style,
    }}>{children}</div>
  );
}

// ─── Pill button
function Pill({ children, dark = false, onClick, style = {}, icon = null }) {
  return (
    <button onClick={onClick} style={{
      height: 52, padding: '0 24px', border: 0, borderRadius: 999, cursor: 'pointer',
      background: dark ? DS.pillBg : DS.card, color: dark ? '#fff' : DS.ink,
      fontFamily: DS.font, fontWeight: 600, fontSize: 15.5,
      display: 'inline-flex', alignItems: 'center', gap: 10,
      boxShadow: dark
        ? '0 8px 22px rgba(20,17,15,.22)'
        : '0 1px 0 rgba(20,17,15,.04), 0 8px 22px rgba(20,17,15,.05)',
      ...style,
    }}>{icon}{children}</button>
  );
}

// ─── Chip
function Chip({ children, active = false, onClick }) {
  return (
    <button onClick={onClick} style={{
      height: 36, padding: '0 16px', border: 0, borderRadius: 999, cursor: 'pointer',
      background: active ? DS.pillBg : DS.card, color: active ? '#fff' : DS.ink,
      fontFamily: DS.font, fontWeight: 500, fontSize: 14,
      whiteSpace: 'nowrap', flexShrink: 0,
      boxShadow: active ? 'none' : '0 1px 0 rgba(20,17,15,.03)',
    }}>{children}</button>
  );
}

// ─── Stat tile
function Stat({ label, value, mono = false, suffix = null, accent }) {
  return (
    <div style={{ display: 'flex', flexDirection: 'column', gap: 4 }}>
      <span style={{ fontSize: 12, color: DS.sub, fontWeight: 500, letterSpacing: 0.2 }}>{label}</span>
      <span style={{
        fontFamily: mono ? DS.mono : DS.font, fontWeight: 600, fontSize: 22,
        color: accent || DS.ink, letterSpacing: -0.5, lineHeight: 1.05,
      }}>{value}<span style={{ fontSize: 13, color: DS.sub, marginLeft: 4, fontWeight: 500 }}>{suffix}</span></span>
    </div>
  );
}

// ─── Progress bar
function Progress({ value, color = null, height = 6 }) {
  const c = color || DS.ink;
  return (
    <div style={{
      width: '100%', height, borderRadius: height, background: DS.hairline, overflow: 'hidden',
    }}>
      <div style={{
        width: `${Math.max(0, Math.min(100, value))}%`, height: '100%',
        background: c, borderRadius: height, transition: 'width .4s ease',
      }}/>
    </div>
  );
}

// ─── File-type tag
const TYPE_COLORS = {
  pdf:   { bg: '#FCE9E4', fg: '#9C3D26' },
  docx:  { bg: '#E4ECFC', fg: '#26469C' },
  pptx:  { bg: '#FCEFD6', fg: '#9C6B26' },
  xlsx:  { bg: '#E1F2E5', fg: '#256B3F' },
  txt:   { bg: '#EDEAE6', fg: '#3A352F' },
  csv:   { bg: '#E1F2E5', fg: '#256B3F' },
  epub:  { bg: '#EFE4FC', fg: '#5B269C' },
  md:    { bg: '#EDEAE6', fg: '#3A352F' },
};
function FileTag({ ext }) {
  const c = TYPE_COLORS[ext] || TYPE_COLORS.txt;
  return (
    <div style={{
      width: 44, height: 44, borderRadius: 12, background: c.bg, color: c.fg,
      display: 'flex', alignItems: 'center', justifyContent: 'center',
      fontFamily: DS.mono, fontWeight: 600, fontSize: 11,
      letterSpacing: 0.4, textTransform: 'uppercase', flexShrink: 0,
    }}>{ext}</div>
  );
}

Object.assign(window, {
  DS, PhoneStatus, BottomNav, PhoneShell, Card, Pill, Chip, Stat, Progress, FileTag, TYPE_COLORS,
});
