// PhoneShell — clean rounded phone chrome (no Android bezel)
// Used for the print-style design pack

function PhoneStatusBar({ dark = false }) {
  const c = dark ? '#fff' : '#15140F';
  return (
    <div style={{
      height: 44, padding: '0 24px', display: 'flex', alignItems: 'center',
      justifyContent: 'space-between',
      fontFamily: `'Plus Jakarta Sans', system-ui, sans-serif`,
      fontSize: 15, fontWeight: 600, color: c, letterSpacing: '-0.01em',
    }}>
      <span>9:41</span>
      <div style={{ display: 'flex', gap: 6, alignItems: 'center' }}>
        {/* signal */}
        <svg width="17" height="11" viewBox="0 0 17 11"><g fill={c}>
          <rect x="0"  y="7" width="3" height="4" rx="0.6"/>
          <rect x="4"  y="5" width="3" height="6" rx="0.6"/>
          <rect x="8"  y="2.5" width="3" height="8.5" rx="0.6"/>
          <rect x="12" y="0" width="3" height="11" rx="0.6"/>
        </g></svg>
        {/* wifi */}
        <svg width="15" height="11" viewBox="0 0 15 11" fill={c}>
          <path d="M7.5 0C4.5 0 1.8 1 0 2.7l1.4 1.4A8.5 8.5 0 017.5 1.9 8.5 8.5 0 0113.6 4.1L15 2.7C13.2 1 10.5 0 7.5 0zm0 3.8a6 6 0 00-4.3 1.7L4.6 6.9A4 4 0 017.5 5.8c1.1 0 2.2.4 3 1.1l1.3-1.4a6 6 0 00-4.3-1.7zM7.5 7.6a2 2 0 00-1.4.6L7.5 9.6 8.9 8.2a2 2 0 00-1.4-.6z"/>
        </svg>
        {/* battery */}
        <svg width="26" height="12" viewBox="0 0 26 12">
          <rect x="0.5" y="0.5" width="22" height="11" rx="3" fill="none" stroke={c} strokeOpacity="0.4"/>
          <rect x="2"   y="2"   width="18" height="8" rx="1.4" fill={c}/>
          <rect x="23"  y="4"   width="2"  height="4" rx="0.6" fill={c} fillOpacity="0.4"/>
        </svg>
      </div>
    </div>
  );
}

function PhoneShell({ children, dark = false, bg }) {
  const t = useTheme?.();
  return (
    <div style={{
      width: 390, height: 800, background: bg || t?.bg || '#F4F2EC',
      display: 'flex', flexDirection: 'column', overflow: 'hidden',
      fontFamily: `'Plus Jakarta Sans', system-ui, sans-serif`,
      color: dark ? '#fff' : '#15140F',
    }}>
      <PhoneStatusBar dark={dark}/>
      <div style={{ flex: 1, overflow: 'hidden', position: 'relative' }}>
        {children}
      </div>
    </div>
  );
}

Object.assign(window, { PhoneShell, PhoneStatusBar });
