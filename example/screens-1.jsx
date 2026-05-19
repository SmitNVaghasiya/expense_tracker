// Screens — auth, profiles, home (polished)

const { useState: useState1 } = React;

// ─────────────────────────────────────────────────────────────
// Lock screen
// ─────────────────────────────────────────────────────────────
function LockScreen({ onUnlock }) {
  const t = useTheme();
  const [pin, setPin] = useState1('');
  const [shake, setShake] = useState1(false);

  const onKey = (d) => {
    if (d === 'del') return setPin(p => p.slice(0, -1));
    if (pin.length >= 4) return;
    const next = pin + d;
    setPin(next);
    if (next.length === 4) {
      setTimeout(() => {
        if (next === '1234') onUnlock?.();
        else { setShake(true); setTimeout(() => { setPin(''); setShake(false); }, 400); }
      }, 200);
    }
  };

  const keys = ['1','2','3','4','5','6','7','8','9','bio','0','del'];

  return (
    <div style={{
      width: '100%', height: '100%', background: t.bg, color: t.ink,
      padding: '20px 28px 28px', display: 'flex', flexDirection: 'column',
      fontFamily: `'Plus Jakarta Sans', system-ui, sans-serif`, boxSizing: 'border-box',
    }}>
      {/* Brand */}
      <div style={{ display: 'flex', alignItems: 'center', gap: 10 }}>
        <div style={{
          width: 34, height: 34, borderRadius: 10, background: t.ink, color: t.bg,
          display: 'inline-flex', alignItems: 'center', justifyContent: 'center',
          fontWeight: 800, fontSize: 16, letterSpacing: '-0.04em',
        }}>D</div>
        <div style={{ fontWeight: 700, fontSize: 15, letterSpacing: '-0.02em' }}>DocVault</div>
        <div style={{
          marginLeft: 'auto', fontSize: 10.5, fontWeight: 600, letterSpacing: '0.12em',
          color: t.ink2, fontFamily: t.mono,
        }}>v0.2 · MVP</div>
      </div>

      {/* Welcome */}
      <div style={{ marginTop: 56 }}>
        <div style={{
          fontSize: 11, fontWeight: 700, letterSpacing: '0.12em', textTransform: 'uppercase',
          color: t.ink2, fontFamily: t.mono,
        }}>Welcome back</div>
        <div style={{
          fontSize: 32, fontWeight: 700, lineHeight: 1.04, letterSpacing: '-0.035em', marginTop: 10,
        }}>Enter your PIN<br/>to open the vault.</div>
      </div>

      {/* PIN dots */}
      <div style={{
        display: 'flex', gap: 14, justifyContent: 'center', marginTop: 48, marginBottom: 36,
        animation: shake ? 'dvShake 0.4s' : 'none',
      }}>
        {[0,1,2,3].map(i => (
          <div key={i} style={{
            width: 13, height: 13, borderRadius: '50%',
            background: i < pin.length ? t.ink : 'transparent',
            border: `1.5px solid ${i < pin.length ? t.ink : t.border}`,
            transition: 'all 160ms ease',
          }}/>
        ))}
      </div>

      {/* Keypad */}
      <div style={{ display: 'grid', gridTemplateColumns: 'repeat(3, 1fr)', gap: 10, marginTop: 'auto' }}>
        {keys.map((k, i) => {
          if (k === 'bio') return (
            <button key={i} onClick={onUnlock} style={{
              height: 58, borderRadius: 999, background: 'transparent', border: 'none',
              cursor: 'pointer', color: t.ink, display: 'inline-flex', alignItems: 'center', justifyContent: 'center',
            }}><IconFingerprint size={26} stroke={1.4}/></button>
          );
          if (k === 'del') return (
            <button key={i} onClick={() => onKey('del')} style={{
              height: 58, borderRadius: 999, background: 'transparent', border: 'none',
              cursor: 'pointer', color: t.ink2, fontFamily: 'inherit', fontSize: 13, fontWeight: 600,
            }}>Delete</button>
          );
          return (
            <button key={i} onClick={() => onKey(k)} style={{
              height: 58, borderRadius: 999, background: t.surface, border: `1px solid ${t.border}`,
              cursor: 'pointer', color: t.ink, fontFamily: 'inherit', fontSize: 22, fontWeight: 600,
              letterSpacing: '-0.02em',
            }}>{k}</button>
          );
        })}
      </div>

      <div style={{ textAlign: 'center', fontSize: 11, color: t.ink3, marginTop: 16, fontFamily: t.mono }}>
        Demo PIN: 1234 · or tap fingerprint
      </div>
    </div>
  );
}

// ─────────────────────────────────────────────────────────────
// Profile picker
// ─────────────────────────────────────────────────────────────
function ProfilesScreen({ onPick, current, embedded = false }) {
  const t = useTheme();
  const profiles = window.SAMPLE_PROFILES;
  const labels = { p1: 'You',   p2: 'Father', p3: 'Mother', p4: 'Sister' };

  return (
    <div style={{
      width: '100%', height: '100%', background: t.bg, color: t.ink,
      padding: '20px 22px 32px', display: 'flex', flexDirection: 'column',
      fontFamily: `'Plus Jakarta Sans', system-ui, sans-serif`, boxSizing: 'border-box',
    }}>
      <div>
        <div style={{
          fontSize: 11, fontWeight: 700, letterSpacing: '0.12em', textTransform: 'uppercase',
          color: t.ink2, fontFamily: t.mono,
        }}>Family vault</div>
        <div style={{
          fontSize: 32, fontWeight: 700, lineHeight: 1.04, letterSpacing: '-0.035em', marginTop: 10,
        }}>Who's using<br/>DocVault?</div>
        <div style={{ fontSize: 13, color: t.ink2, marginTop: 12, fontWeight: 500, lineHeight: 1.5 }}>
          Each profile keeps its own documents.<br/>Shared collections are visible to everyone.
        </div>
      </div>

      <div style={{
        marginTop: 36, display: 'grid', gridTemplateColumns: 'repeat(2, 1fr)', gap: 12,
      }}>
        {profiles.map(p => {
          const active = current === p.id;
          return (
            <button key={p.id} onClick={() => onPick?.(p.id)} style={{
              background: t.surface, border: `1.5px solid ${active ? t.ink : t.border}`,
              borderRadius: 20, padding: '20px 14px',
              display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 10,
              cursor: 'pointer', fontFamily: 'inherit', color: t.ink, position: 'relative',
            }}>
              {active && (
                <div style={{
                  position: 'absolute', top: 10, right: 10, width: 20, height: 20, borderRadius: 999,
                  background: t.ink, color: t.bg, display: 'inline-flex',
                  alignItems: 'center', justifyContent: 'center',
                }}><IconCheck size={13} stroke={2.4}/></div>
              )}
              <Avatar profile={p} size={68}/>
              <div style={{ fontWeight: 700, fontSize: 14.5, letterSpacing: '-0.01em' }}>{p.name}</div>
              <div style={{
                fontSize: 9.5, color: t.ink3, fontFamily: t.mono, letterSpacing: '0.1em',
              }}>{labels[p.id]?.toUpperCase()}</div>
            </button>
          );
        })}
        <button style={{
          background: 'transparent', border: `1.5px dashed ${t.border}`, borderRadius: 20,
          padding: '20px 14px', display: 'flex', flexDirection: 'column', alignItems: 'center',
          gap: 10, cursor: 'pointer', color: t.ink2,
        }}>
          <div style={{
            width: 68, height: 68, borderRadius: '50%', background: t.sub,
            display: 'inline-flex', alignItems: 'center', justifyContent: 'center',
          }}><IconPlus size={24}/></div>
          <div style={{ fontWeight: 600, fontSize: 13.5 }}>Add profile</div>
          <div style={{ fontSize: 9.5, color: t.ink3, fontFamily: t.mono, letterSpacing: '0.1em' }}>NEW</div>
        </button>
      </div>

      <div style={{
        marginTop: 'auto', textAlign: 'center', fontSize: 11, color: t.ink3, lineHeight: 1.5,
        fontFamily: t.mono, letterSpacing: '0.04em',
      }}>
        Profiles are on-device only · not synced
      </div>
    </div>
  );
}

// ─────────────────────────────────────────────────────────────
// Home — polished
// ─────────────────────────────────────────────────────────────
function HomeScreen({ profile, onSearch, onDoc, onMore, onProfile, category = 'all', setCategory }) {
  const t = useTheme();
  const [_cat, _setCat] = useState1(category);
  const cat = setCategory ? category : _cat;
  const setCat = setCategory || _setCat;
  const docs = window.SAMPLE_DOCS;
  const cats = window.SAMPLE_CATEGORIES;

  const filter = (d) => cat === 'all' || d.category === cats.find(c => c.id === cat)?.name;
  const pinned = docs.filter(d => d.tier === 'pinned' && filter(d)).sort((a,b) => a.pinOrder - b.pinOrder);
  const loved  = docs.filter(d => d.tier === 'loved'  && filter(d));
  const other  = docs.filter(d => d.tier === 'other'  && filter(d));

  return (
    <Screen>
      <div style={{ overflow: 'auto', height: '100%', paddingBottom: 110 }}>
        {/* Hero */}
        <HeroHeader
          eyebrow={`Sun 18 May · ${profile.name}'s vault`}
          title={`Hello, ${profile.name}.`}
          subtitle="47 documents kept safe on this device"
          trailing={
            <button onClick={onProfile} style={{
              background: 'transparent', border: 'none', padding: 0, cursor: 'pointer',
              position: 'relative',
            }}>
              <Avatar profile={profile} size={44}/>
              <span style={{
                position: 'absolute', top: -2, right: -2, width: 12, height: 12,
                background: t.warn, border: `2px solid ${t.bg}`, borderRadius: '50%',
              }}/>
            </button>
          }
        />

        {/* Stat strip */}
        <div style={{
          margin: '4px 22px 0', padding: '14px 16px', borderRadius: 18,
          background: t.surface, border: `1px solid ${t.border}`,
          display: 'flex', alignItems: 'center', justifyContent: 'space-between', gap: 10,
        }}>
          <StatCell value="47" label="Total"/>
          <div style={{ width: 1, height: 28, background: t.border }}/>
          <StatCell value="3" label="Pinned"/>
          <div style={{ width: 1, height: 28, background: t.border }}/>
          <StatCell value="1" label="Expired" accent={t.warn}/>
          <div style={{ width: 1, height: 28, background: t.border }}/>
          <StatCell value="2h" label="Synced"/>
        </div>

        {/* Search */}
        <div style={{ padding: '18px 22px 6px' }}>
          <SearchBar onClick={onSearch} placeholder="Search 47 documents…"/>
        </div>

        {/* Category chips */}
        <div style={{ marginTop: 10 }}>
          <ChipRow items={cats} value={cat} onChange={setCat}/>
        </div>

        {/* PINNED */}
        {pinned.length > 0 && (
          <>
            <SectionHeading num={1} label="Pinned" count={`${pinned.length} items`} hint="Always on top"/>
            <div style={{ display: 'flex', flexDirection: 'column', gap: 8, padding: '0 22px' }}>
              {pinned.map(d => (
                <DocCard key={d.id} doc={d} variant="pinned" onClick={() => onDoc?.(d)} onMore={onMore}/>
              ))}
            </div>
          </>
        )}

        {/* LOVED */}
        {loved.length > 0 && (
          <>
            <SectionHeading num={2} label="Loved" count={`${loved.length} items`} trailing={<SortChip/>}/>
            <div style={{ display: 'flex', flexDirection: 'column', gap: 8, padding: '0 22px' }}>
              {loved.map(d => <DocCard key={d.id} doc={d} onClick={() => onDoc?.(d)} onMore={onMore}/>)}
            </div>
          </>
        )}

        {/* ALL */}
        {other.length > 0 && (
          <>
            <SectionHeading num={3} label="All documents" count={`${other.length} items`} trailing={<SortChip value="newest"/>}/>
            <div style={{ display: 'flex', flexDirection: 'column', gap: 8, padding: '0 22px' }}>
              {other.map(d => <DocCard key={d.id} doc={d} onClick={() => onDoc?.(d)} onMore={onMore}/>)}
            </div>
          </>
        )}

        <div style={{ height: 30 }}/>
      </div>
    </Screen>
  );
}

function SortChip({ value = 'newest' }) {
  const t = useTheme();
  const labels = { newest: 'Newest', oldest: 'Oldest', az: 'A–Z' };
  return (
    <span style={{
      height: 26, padding: '0 10px 0 12px', borderRadius: 999,
      background: t.sub, color: t.ink, fontFamily: 'inherit', fontWeight: 600, fontSize: 11.5,
      display: 'inline-flex', alignItems: 'center', gap: 4,
    }}>
      {labels[value]}<IconChevD size={12}/>
    </span>
  );
}

Object.assign(window, { LockScreen, ProfilesScreen, HomeScreen });
