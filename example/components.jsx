// Shared components — polished

window.PALETTES = {
  paper: {
    bg:      '#F0EEE9',
    surface: '#FFFFFF',
    sub:     '#E8E4DA',
    border:  '#E0DAD0',
    ink:     '#14110F',
    ink2:    '#6A6259',
    ink3:    '#A39A8E',
    accent:  '#14110F',
    warn:    '#A8451D',
    ok:      '#3F6D3A',
    mono:    `'JetBrains Mono', ui-monospace, monospace`,
  },
};

const { useState, useEffect, useRef, useMemo, createContext, useContext } = React;
window.ThemeCtx = createContext(window.PALETTES.paper);
window.useTheme = () => useContext(window.ThemeCtx);

// ── Screen wrapper
function Screen({ children, pad = true, style }) {
  const t = useTheme();
  return (
    <div style={{
      width: '100%', height: '100%', overflow: 'hidden', background: t.bg, color: t.ink,
      fontFamily: `'Plus Jakarta Sans', system-ui, sans-serif`,
      paddingBottom: pad ? 110 : 0, display: 'flex', flexDirection: 'column',
      ...style,
    }}>
      {children}
    </div>
  );
}

// ── Big hero header
function HeroHeader({ eyebrow, title, subtitle, leading, trailing }) {
  const t = useTheme();
  return (
    <div style={{
      padding: '14px 22px 14px', display: 'flex', alignItems: 'flex-start',
      justifyContent: 'space-between', gap: 12,
    }}>
      <div style={{ display: 'flex', alignItems: 'flex-start', gap: 12, minWidth: 0, flex: 1 }}>
        {leading}
        <div style={{ minWidth: 0 }}>
          {eyebrow && (
            <div style={{
              fontSize: 10.5, fontWeight: 700, letterSpacing: '0.12em', textTransform: 'uppercase',
              color: t.ink2, fontFamily: t.mono, marginBottom: 6,
            }}>{eyebrow}</div>
          )}
          <div style={{
            fontSize: 30, fontWeight: 700, lineHeight: 1.05, letterSpacing: '-0.035em', color: t.ink,
          }}>{title}</div>
          {subtitle && (
            <div style={{ fontSize: 13.5, color: t.ink2, marginTop: 6, fontWeight: 500, letterSpacing: '-0.005em' }}>
              {subtitle}
            </div>
          )}
        </div>
      </div>
      {trailing && <div style={{ display: 'flex', gap: 8, alignItems: 'center', flexShrink: 0 }}>{trailing}</div>}
    </div>
  );
}

// ── Compact header (drill-in screens)
function CompactHeader({ title, subtitle, leading, trailing }) {
  const t = useTheme();
  return (
    <div style={{
      padding: '12px 16px 10px', display: 'flex', alignItems: 'center', gap: 10,
    }}>
      {leading}
      <div style={{ flex: 1, minWidth: 0 }}>
        <div style={{ fontSize: 16, fontWeight: 700, letterSpacing: '-0.01em', color: t.ink,
                      overflow: 'hidden', textOverflow: 'ellipsis', whiteSpace: 'nowrap' }}>{title}</div>
        {subtitle && (
          <div style={{ fontSize: 11.5, color: t.ink2, marginTop: 1 }}>{subtitle}</div>
        )}
      </div>
      {trailing && <div style={{ display: 'flex', gap: 6, alignItems: 'center' }}>{trailing}</div>}
    </div>
  );
}

// ── Icon button (circular)
function IconBtn({ icon, onClick, bg, color, size = 42, border = true }) {
  const t = useTheme();
  return (
    <button onClick={onClick} style={{
      width: size, height: size, borderRadius: 999,
      background: bg ?? t.surface, color: color ?? t.ink,
      border: border ? `1px solid ${t.border}` : 'none',
      display: 'inline-flex', alignItems: 'center', justifyContent: 'center',
      cursor: 'pointer', padding: 0, flexShrink: 0,
    }}>
      {icon}
    </button>
  );
}

// ── Section heading (numbered eyebrow, big label)
function SectionHeading({ num, label, count, hint, trailing }) {
  const t = useTheme();
  return (
    <div style={{
      display: 'flex', alignItems: 'flex-end', justifyContent: 'space-between',
      padding: '22px 22px 12px',
    }}>
      <div style={{ display: 'flex', alignItems: 'baseline', gap: 10, color: t.ink, minWidth: 0 }}>
        {num !== undefined && (
          <span style={{
            fontSize: 11, fontWeight: 600, letterSpacing: '0.06em', color: t.ink3,
            fontFamily: t.mono,
          }}>{String(num).padStart(2, '0')}</span>
        )}
        <span style={{
          fontSize: 18, fontWeight: 700, letterSpacing: '-0.02em',
        }}>{label}</span>
        {count !== undefined && (
          <span style={{ fontSize: 12, fontWeight: 500, color: t.ink3, fontFamily: t.mono }}>
            {count}
          </span>
        )}
      </div>
      {trailing || (hint && (
        <span style={{ fontSize: 11, color: t.ink3, fontWeight: 500, marginBottom: 2 }}>{hint}</span>
      ))}
    </div>
  );
}

// ── Format chip
function FormatChip({ type, dark = false }) {
  const t = useTheme();
  const colors = {
    pdf: { bg: '#F4DDD0', fg: '#8E3614' },
    jpg: { bg: '#E1E8DC', fg: '#3F6D3A' },
    png: { bg: '#DEE3F0', fg: '#2E4787' },
  };
  const c = dark
    ? { bg: 'rgba(255,255,255,0.14)', fg: '#fff' }
    : (colors[type] || { bg: t.sub, fg: t.ink2 });
  return (
    <span style={{
      display: 'inline-flex', alignItems: 'center', height: 19, padding: '0 7px',
      borderRadius: 4, background: c.bg, color: c.fg, fontWeight: 700,
      fontSize: 9.5, letterSpacing: '0.08em', fontFamily: t.mono,
    }}>{type.toUpperCase()}</span>
  );
}

// ── Expiry badge
function ExpiryBadge({ expiry, expired, dark = false }) {
  const t = useTheme();
  if (!expiry) return null;
  const bg = expired ? t.warn : (dark ? 'rgba(255,255,255,0.14)' : t.sub);
  const fg = expired ? '#fff' : (dark ? '#fff' : t.ink2);
  return (
    <span style={{
      display: 'inline-flex', alignItems: 'center', gap: 4, height: 19, padding: '0 8px',
      borderRadius: 999, background: bg, color: fg, fontSize: 10.5, fontWeight: 600,
    }}>
      <svg width="10" height="10" viewBox="0 0 24 24" fill="none" stroke="currentColor"
           strokeWidth="2.4" strokeLinecap="round" strokeLinejoin="round">
        <circle cx="12" cy="12" r="9"/><path d="M12 7v5l3 2"/>
      </svg>
      {expired ? 'Expired' : expiry}
    </span>
  );
}

// ── Document card — typographic, distinct variants
function DocCard({ doc, onClick, onMore, variant = 'default' }) {
  const t = useTheme();
  const isPinned = variant === 'pinned';

  const surface = isPinned ? t.ink : t.surface;
  const ink     = isPinned ? '#FFFFFF' : t.ink;
  const ink2    = isPinned ? 'rgba(255,255,255,0.6)' : t.ink2;
  const ink3    = isPinned ? 'rgba(255,255,255,0.4)' : t.ink3;
  const subBg   = isPinned ? 'rgba(255,255,255,0.08)' : t.sub;

  return (
    <button onClick={onClick} style={{
      width: '100%', textAlign: 'left', cursor: 'pointer',
      background: surface, border: `1px solid ${isPinned ? 'transparent' : t.border}`, borderRadius: 18,
      padding: 14, display: 'flex', alignItems: 'center', gap: 12,
      color: 'inherit', fontFamily: 'inherit',
    }}>
      {/* Leading */}
      <div style={{
        width: 46, height: 46, borderRadius: 13, flexShrink: 0,
        background: isPinned ? 'rgba(255,255,255,0.12)' : t.sub,
        color: isPinned ? '#fff' : t.ink2,
        display: 'flex', alignItems: 'center', justifyContent: 'center',
      }}>
        {isPinned ? (
          <span style={{
            fontWeight: 700, fontSize: 17, fontFamily: t.mono, letterSpacing: '-0.02em',
          }}>0{doc.pinOrder}</span>
        ) : (
          <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor"
               strokeWidth="1.6" strokeLinecap="round" strokeLinejoin="round">
            <path d="M7 3h7l5 5v12a2 2 0 01-2 2H7a2 2 0 01-2-2V5a2 2 0 012-2z"/>
            <path d="M14 3v5h5"/>
          </svg>
        )}
      </div>

      {/* Body */}
      <div style={{ flex: 1, minWidth: 0 }}>
        <div style={{
          fontSize: 15.5, fontWeight: 700, color: ink, letterSpacing: '-0.015em',
          overflow: 'hidden', textOverflow: 'ellipsis', whiteSpace: 'nowrap',
        }}>{doc.name}</div>
        <div style={{ display: 'flex', alignItems: 'center', gap: 8, marginTop: 6, flexWrap: 'wrap' }}>
          <FormatChip type={doc.type} dark={isPinned}/>
          <span style={{ fontSize: 11.5, color: ink2, fontWeight: 500 }}>{doc.category}</span>
          <span style={{ fontSize: 11.5, color: ink3, fontFamily: t.mono }}>·</span>
          <span style={{ fontSize: 11.5, color: ink3, fontFamily: t.mono }}>{doc.size}</span>
        </div>
        {(doc.expiry || doc.collection) && (
          <div style={{ display: 'flex', alignItems: 'center', gap: 6, marginTop: 8, flexWrap: 'wrap' }}>
            {doc.expiry && <ExpiryBadge expiry={doc.expiry} expired={doc.expired} dark={isPinned}/>}
            {doc.collection && !doc.expiry && (
              <span style={{
                display: 'inline-flex', alignItems: 'center', gap: 4, height: 19,
                padding: '0 8px', borderRadius: 999, background: subBg, color: ink2,
                fontSize: 10.5, fontWeight: 600,
              }}>
                <svg width="9" height="9" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.4">
                  <path d="M3 7a2 2 0 012-2h4l2 2h8a2 2 0 012 2v9a2 2 0 01-2 2H5a2 2 0 01-2-2V7z"/>
                </svg>
                {doc.collection}
              </span>
            )}
          </div>
        )}
      </div>

      {/* Trailing */}
      <span onClick={(e) => { e.stopPropagation(); onMore?.(doc); }} style={{
        width: 30, height: 30, borderRadius: 999, background: 'transparent',
        cursor: 'pointer', color: ink2,
        display: 'inline-flex', alignItems: 'center', justifyContent: 'center',
        flexShrink: 0,
      }}>
        <IconMore size={16}/>
      </span>
    </button>
  );
}

// ── Bottom sheet
function Sheet({ open, onClose, children, maxHeight = 620 }) {
  const t = useTheme();
  if (!open) return null;
  return (
    <div style={{ position: 'absolute', inset: 0, zIndex: 100 }}>
      <div onClick={onClose} style={{
        position: 'absolute', inset: 0, background: 'rgba(20,17,15,0.42)',
        animation: 'dvFade 220ms ease',
      }}/>
      <div style={{
        position: 'absolute', left: 0, right: 0, bottom: 0,
        background: t.surface, borderTopLeftRadius: 28, borderTopRightRadius: 28,
        maxHeight, overflow: 'auto', animation: 'dvSlide 280ms cubic-bezier(.2,.8,.2,1)',
        boxShadow: '0 -10px 40px rgba(0,0,0,0.18)',
      }}>
        <div style={{ display: 'flex', justifyContent: 'center', padding: '10px 0 4px' }}>
          <div style={{ width: 36, height: 4, borderRadius: 2, background: t.border }}/>
        </div>
        {children}
      </div>
    </div>
  );
}

// ── Pill button
function PillButton({ children, onClick, variant = 'primary', size = 'md', icon, full, trailingIcon }) {
  const t = useTheme();
  const variants = {
    primary:   { bg: t.ink,                fg: t.bg,    bd: 'transparent' },
    secondary: { bg: t.sub,                fg: t.ink,   bd: 'transparent' },
    outline:   { bg: 'transparent',        fg: t.ink,   bd: t.border },
    danger:    { bg: t.warn,               fg: '#FFF',  bd: 'transparent' },
  };
  const s = variants[variant];
  const sizes = {
    sm: { h: 34, px: 14, fs: 12.5 },
    md: { h: 46, px: 20, fs: 14 },
    lg: { h: 54, px: 22, fs: 15 },
  };
  const sz = sizes[size];
  return (
    <button onClick={onClick} style={{
      height: sz.h, padding: `0 ${sz.px}px`, borderRadius: 999,
      background: s.bg, color: s.fg, border: `1px solid ${s.bd}`,
      fontFamily: 'inherit', fontWeight: 600, fontSize: sz.fs,
      display: 'inline-flex', alignItems: 'center', justifyContent: trailingIcon ? 'space-between' : 'center',
      gap: 8, cursor: 'pointer', width: full ? '100%' : 'auto', letterSpacing: '-0.005em',
    }}>
      {icon}
      <span style={{ flex: trailingIcon ? 1 : 'initial' }}>{children}</span>
      {trailingIcon}
    </button>
  );
}

// ── Bottom nav — slim dark pill, icon + dot
function BottomNav({ tab = 'home', onTab, onAdd }) {
  const t = useTheme();
  const items = [
    { id: 'home', icon: <IconHome  size={20}/>, label: 'Home' },
    { id: 'coll', icon: <IconStack size={20}/>, label: 'Collections' },
    { id: 'add',  isAdd: true },
    { id: 'fam',  icon: <IconUsers size={20}/>, label: 'Family' },
    { id: 'set',  icon: <IconSettings size={20}/>, label: 'Settings' },
  ];
  return (
    <div style={{
      position: 'absolute', left: 16, right: 16, bottom: 18, zIndex: 50,
    }}>
      <div style={{
        background: t.ink, borderRadius: 999, height: 58,
        display: 'flex', alignItems: 'center', justifyContent: 'space-between',
        padding: '0 8px',
        boxShadow: '0 16px 32px rgba(20,17,15,0.18), 0 4px 10px rgba(20,17,15,0.10)',
      }}>
        {items.map((it) => {
          if (it.isAdd) {
            return (
              <button key="add" onClick={onAdd} style={{
                width: 46, height: 46, borderRadius: 999, border: 'none', cursor: 'pointer',
                background: t.bg, color: t.ink,
                display: 'inline-flex', alignItems: 'center', justifyContent: 'center',
              }}>
                <IconPlus size={20} stroke={2.2}/>
              </button>
            );
          }
          const active = tab === it.id;
          return (
            <button key={it.id} onClick={() => onTab?.(it.id)} style={{
              flex: 1, height: 46, borderRadius: 999, border: 'none', cursor: 'pointer',
              background: 'transparent',
              color: active ? '#fff' : 'rgba(255,255,255,0.45)',
              display: 'inline-flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center',
              gap: 2, position: 'relative',
            }}>
              {it.icon}
              {active && (
                <div style={{ width: 4, height: 4, borderRadius: '50%', background: '#fff' }}/>
              )}
            </button>
          );
        })}
      </div>
    </div>
  );
}

// ── Chip row (horizontal)
function ChipRow({ items, value, onChange, scroll = true, pad = 22 }) {
  const t = useTheme();
  return (
    <div style={{
      display: 'flex', gap: 7, padding: `0 ${pad}px`,
      overflowX: scroll ? 'auto' : 'visible', scrollbarWidth: 'none',
    }}>
      {items.map((it) => {
        const active = value === it.id;
        return (
          <button key={it.id} onClick={() => onChange(it.id)} style={{
            height: 32, padding: '0 12px', borderRadius: 999,
            background: active ? t.ink : 'transparent',
            color: active ? t.bg : t.ink,
            border: `1px solid ${active ? t.ink : t.border}`,
            fontSize: 12.5, fontWeight: 600, cursor: 'pointer',
            whiteSpace: 'nowrap', fontFamily: 'inherit', letterSpacing: '-0.005em',
            display: 'inline-flex', alignItems: 'center', gap: 6,
          }}>
            {it.name}
            {it.count !== undefined && (
              <span style={{
                fontSize: 10.5, fontWeight: 700, opacity: 0.65,
                fontFamily: t.mono,
              }}>{it.count}</span>
            )}
          </button>
        );
      })}
    </div>
  );
}

// ── Avatar
function Avatar({ profile, size = 42, ring = false }) {
  const t = useTheme();
  return (
    <div style={{
      width: size, height: size, borderRadius: '50%',
      background: profile.color, color: '#fff',
      display: 'inline-flex', alignItems: 'center', justifyContent: 'center',
      fontWeight: 700, fontSize: size * 0.42, letterSpacing: '-0.02em',
      border: ring ? `2px solid ${t.bg}` : 'none',
      outline: ring ? `2px solid ${t.ink}` : 'none',
      flexShrink: 0,
    }}>{profile.initials}</div>
  );
}

// ── Search bar (resting)
function SearchBar({ placeholder = 'Search documents…', onClick, dark = false }) {
  const t = useTheme();
  return (
    <button onClick={onClick} style={{
      width: '100%', height: 50, borderRadius: 999,
      background: dark ? 'rgba(255,255,255,0.06)' : t.surface,
      border: `1px solid ${dark ? 'rgba(255,255,255,0.10)' : t.border}`,
      padding: '0 6px 0 18px',
      display: 'flex', alignItems: 'center', justifyContent: 'space-between',
      cursor: 'pointer', color: dark ? 'rgba(255,255,255,0.7)' : t.ink3,
      fontFamily: 'inherit', fontSize: 14,
    }}>
      <span style={{ display: 'inline-flex', alignItems: 'center', gap: 10 }}>
        <IconSearch size={17}/>
        <span style={{ fontWeight: 500 }}>{placeholder}</span>
      </span>
      <span style={{
        width: 38, height: 38, borderRadius: 999, background: dark ? '#fff' : t.ink, color: dark ? t.ink : t.bg,
        display: 'inline-flex', alignItems: 'center', justifyContent: 'center',
      }}>
        <IconFilter size={16}/>
      </span>
    </button>
  );
}

// ── Stat cell
function StatCell({ value, label, accent, mono = true }) {
  const t = useTheme();
  return (
    <div style={{ minWidth: 0 }}>
      <div style={{
        fontSize: 26, fontWeight: 700, letterSpacing: '-0.04em', lineHeight: 1,
        fontFamily: mono ? t.mono : 'inherit', color: accent || t.ink,
      }}>{value}</div>
      <div style={{
        fontSize: 10.5, fontWeight: 600, letterSpacing: '0.08em', textTransform: 'uppercase',
        color: t.ink2, marginTop: 6, fontFamily: t.mono,
      }}>{label}</div>
    </div>
  );
}

Object.assign(window, {
  Screen, HeroHeader, CompactHeader, IconBtn, SectionHeading,
  FormatChip, ExpiryBadge, DocCard, Sheet, PillButton, BottomNav,
  ChipRow, Avatar, SearchBar, StatCell,
});
