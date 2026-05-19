// Screens — upload, settings, recycle, sheets (polished)

const { useState: useState3 } = React;

// ─────────────────────────────────────────────────────────────
// Upload chooser sheet
// ─────────────────────────────────────────────────────────────
function UploadChooserSheet({ open, onClose, onPickCamera, onPickFile }) {
  const t = useTheme();
  return (
    <Sheet open={open} onClose={onClose} maxHeight={520}>
      <div style={{ padding: '6px 22px 28px' }}>
        <div style={{
          fontSize: 10.5, fontWeight: 700, letterSpacing: '0.12em', textTransform: 'uppercase',
          color: t.ink2, marginBottom: 6, fontFamily: t.mono,
        }}>Add a document</div>
        <div style={{
          fontSize: 22, fontWeight: 700, letterSpacing: '-0.025em', color: t.ink, marginBottom: 18,
          lineHeight: 1.15,
        }}>How would you like<br/>to add it?</div>

        <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 10 }}>
          {[
            { icon: <IconCamera size={24}/>, label: 'Take photo', hint: 'Use camera', cb: onPickCamera },
            { icon: <IconFile   size={24}/>, label: 'Pick file',  hint: 'PDF or image', cb: onPickFile },
          ].map(o => (
            <button key={o.label} onClick={o.cb} style={{
              background: t.bg, border: `1px solid ${t.border}`, borderRadius: 18,
              padding: '18px 16px', display: 'flex', flexDirection: 'column', alignItems: 'flex-start',
              gap: 14, cursor: 'pointer', color: t.ink, fontFamily: 'inherit', textAlign: 'left',
            }}>
              <div style={{
                width: 42, height: 42, borderRadius: 12, background: t.ink, color: t.bg,
                display: 'inline-flex', alignItems: 'center', justifyContent: 'center',
              }}>{o.icon}</div>
              <div>
                <div style={{ fontWeight: 700, fontSize: 15, letterSpacing: '-0.015em' }}>{o.label}</div>
                <div style={{ fontSize: 11.5, color: t.ink2, marginTop: 3 }}>{o.hint}</div>
              </div>
            </button>
          ))}
        </div>

        <div style={{ marginTop: 12, display: 'flex', flexDirection: 'column', gap: 6 }}>
          {[
            { icon: <IconFolder size={16}/>, label: 'New collection', hint: 'Group related docs together' },
            { icon: <IconCloud  size={16}/>, label: 'Import from Drive', hint: 'Restore from backup' },
          ].map(r => (
            <button key={r.label} style={{
              background: 'transparent', border: `1px solid ${t.border}`, borderRadius: 14,
              padding: '12px 14px', display: 'flex', alignItems: 'center', gap: 12,
              cursor: 'pointer', color: t.ink, fontFamily: 'inherit', textAlign: 'left', width: '100%',
            }}>
              <div style={{
                width: 32, height: 32, borderRadius: 9, background: t.sub, color: t.ink,
                display: 'inline-flex', alignItems: 'center', justifyContent: 'center',
              }}>{r.icon}</div>
              <div style={{ flex: 1 }}>
                <div style={{ fontWeight: 700, fontSize: 13.5, letterSpacing: '-0.005em' }}>{r.label}</div>
                <div style={{ fontSize: 11, color: t.ink2, marginTop: 1 }}>{r.hint}</div>
              </div>
              <IconChevR size={15}/>
            </button>
          ))}
        </div>
      </div>
    </Sheet>
  );
}

// ─────────────────────────────────────────────────────────────
// Upload form
// ─────────────────────────────────────────────────────────────
function UploadFormScreen({ onClose, onSave }) {
  const t = useTheme();
  const [name, setName]       = useState3('GTU Sem 7 Result');
  const [cat, setCat]         = useState3('Education');
  const [coll, setColl]       = useState3('GTU Marksheets');
  const [expiry, setExpiry]   = useState3('');
  const [loved, setLoved]     = useState3(true);
  const [encrypt, setEncrypt] = useState3(true);

  const cats = ['Personal IDs','Education','Medical','Financial','Property','Receipts'];

  const inputStyle = {
    width: '100%', height: 48, padding: '0 14px', borderRadius: 12,
    background: t.surface, border: `1px solid ${t.border}`, color: t.ink,
    fontFamily: 'inherit', fontSize: 14, boxSizing: 'border-box', outline: 'none',
    fontWeight: 600,
  };

  return (
    <Screen pad={false}>
      <div style={{ overflow: 'auto', height: '100%' }}>
        <div style={{ padding: '12px 18px 4px', display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
          <IconBtn icon={<IconBack size={18}/>} onClick={onClose}/>
          <div style={{ fontWeight: 700, fontSize: 14, color: t.ink, letterSpacing: '-0.01em' }}>New document</div>
          <button onClick={onClose} style={{
            background: 'transparent', border: 'none', cursor: 'pointer',
            fontFamily: 'inherit', fontWeight: 600, fontSize: 13, color: t.ink2, padding: '0 4px',
          }}>Cancel</button>
        </div>

        {/* Preview */}
        <div style={{ padding: '14px 22px 0' }}>
          <div style={{
            width: '100%', aspectRatio: '1.6', borderRadius: 18, position: 'relative', overflow: 'hidden',
            background: `repeating-linear-gradient(45deg, ${t.sub} 0 12px, ${t.bg} 12px 24px)`,
            border: `1px solid ${t.border}`,
          }}>
            <div style={{
              position: 'absolute', inset: 0, display: 'flex', alignItems: 'center', justifyContent: 'center',
              flexDirection: 'column', gap: 8, color: t.ink2,
            }}>
              <IconFile size={26}/>
              <div style={{ fontSize: 10.5, fontWeight: 700, fontFamily: t.mono, letterSpacing: '0.1em' }}>
                CAPTURED SCAN
              </div>
            </div>
            <button style={{
              position: 'absolute', right: 12, top: 12, height: 30, padding: '0 12px',
              borderRadius: 999, background: t.surface, border: `1px solid ${t.border}`, cursor: 'pointer',
              fontFamily: 'inherit', fontWeight: 600, fontSize: 11.5, color: t.ink,
            }}>Edit</button>
          </div>
        </div>

        <div style={{ padding: '18px 22px 0', display: 'flex', flexDirection: 'column', gap: 14 }}>
          <Field label="Document name">
            <input value={name} onChange={e => setName(e.target.value)} style={inputStyle}/>
          </Field>

          <Field label="Category">
            <div style={{ display: 'flex', flexWrap: 'wrap', gap: 5 }}>
              {cats.map(c => {
                const active = cat === c;
                return (
                  <button key={c} onClick={() => setCat(c)} style={{
                    height: 32, padding: '0 11px', borderRadius: 999,
                    background: active ? t.ink : t.surface,
                    color: active ? t.bg : t.ink,
                    border: `1px solid ${active ? t.ink : t.border}`,
                    cursor: 'pointer', fontFamily: 'inherit', fontWeight: 600, fontSize: 12,
                  }}>{c}</button>
                );
              })}
            </div>
          </Field>

          <Field label="Add to collection">
            <div style={{
              ...inputStyle, display: 'flex', alignItems: 'center', justifyContent: 'space-between',
              color: coll ? t.ink : t.ink3, paddingRight: 12,
            }}>
              <span style={{ display: 'inline-flex', alignItems: 'center', gap: 8 }}>
                <IconFolder size={15}/> {coll || 'None'}
              </span>
              <IconChevR size={15}/>
            </div>
          </Field>

          <Field label="Expiry date" hint="Reminders start 1 month before">
            <div style={{
              ...inputStyle, display: 'flex', alignItems: 'center', gap: 10,
              color: expiry ? t.ink : t.ink3,
            }}>
              <IconCalendar size={16}/>
              <span style={{ flex: 1 }}>{expiry || 'No expiry set'}</span>
              <button onClick={() => setExpiry(expiry ? '' : 'Jun 12, 2027')} style={{
                fontFamily: 'inherit', background: t.sub, border: 'none', cursor: 'pointer',
                height: 28, padding: '0 12px', borderRadius: 999, fontSize: 11.5, fontWeight: 600, color: t.ink,
              }}>{expiry ? 'Clear' : 'Set date'}</button>
            </div>
          </Field>

          <Field label="Options">
            <div style={{ display: 'flex', flexDirection: 'column', gap: 6 }}>
              <Toggle on={loved}   onChange={setLoved}   label="Mark as Loved" hint="Show in Loved section"/>
              <Toggle on={encrypt} onChange={setEncrypt} label="Encrypt on device" hint="AES-256 — recommended"/>
            </div>
          </Field>
        </div>

        <div style={{ padding: '22px 22px 28px', display: 'flex', gap: 8 }}>
          <PillButton variant="outline" full onClick={onClose}>Discard</PillButton>
          <PillButton variant="primary" full onClick={onSave} icon={<IconCheck size={16} stroke={2.4}/>}>
            Save document
          </PillButton>
        </div>
      </div>
    </Screen>
  );
}

function Field({ label, hint, children }) {
  const t = useTheme();
  return (
    <div>
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'baseline', marginBottom: 7 }}>
        <div style={{
          fontSize: 10.5, fontWeight: 700, letterSpacing: '0.1em', textTransform: 'uppercase',
          color: t.ink2, fontFamily: t.mono,
        }}>{label}</div>
        {hint && <div style={{ fontSize: 10.5, color: t.ink3 }}>{hint}</div>}
      </div>
      {children}
    </div>
  );
}

function Toggle({ on, onChange, label, hint }) {
  const t = useTheme();
  return (
    <button onClick={() => onChange(!on)} style={{
      display: 'flex', alignItems: 'center', gap: 10, padding: '12px 14px',
      background: t.surface, border: `1px solid ${t.border}`, borderRadius: 12,
      cursor: 'pointer', fontFamily: 'inherit', color: t.ink, textAlign: 'left', width: '100%',
    }}>
      <div style={{ flex: 1 }}>
        <div style={{ fontSize: 13.5, fontWeight: 700, letterSpacing: '-0.005em' }}>{label}</div>
        {hint && <div style={{ fontSize: 11, color: t.ink2, marginTop: 1 }}>{hint}</div>}
      </div>
      <div style={{
        width: 40, height: 24, borderRadius: 999, padding: 2, boxSizing: 'border-box',
        background: on ? t.ink : t.border, transition: 'background 200ms ease',
        display: 'flex', alignItems: 'center',
      }}>
        <div style={{
          width: 20, height: 20, borderRadius: '50%', background: '#fff',
          transform: on ? 'translateX(16px)' : 'translateX(0)', transition: 'transform 200ms ease',
          boxShadow: '0 1px 4px rgba(0,0,0,0.15)',
        }}/>
      </div>
    </button>
  );
}

// ─────────────────────────────────────────────────────────────
// Doc actions sheet
// ─────────────────────────────────────────────────────────────
function DocActionsSheet({ open, onClose, doc }) {
  const t = useTheme();
  if (!doc) return null;
  const rows = [
    { icon: <IconPin     size={16}/>, label: 'Pin to top',          hint: 'Always show first' },
    { icon: <IconHeart   size={16}/>, label: 'Mark as Loved' },
    { icon: <IconFile    size={16}/>, label: 'Rename' },
    { icon: <IconFolder  size={16}/>, label: 'Move to collection' },
    { icon: <IconClock   size={16}/>, label: 'Version history',     hint: '3 versions kept' },
    { icon: <IconShare   size={16}/>, label: 'Share' },
    { icon: <IconDownload size={16}/>, label: 'Save copy to Drive' },
  ];
  return (
    <Sheet open={open} onClose={onClose} maxHeight={620}>
      <div style={{ padding: '4px 14px 18px' }}>
        <div style={{
          display: 'flex', alignItems: 'center', gap: 12, padding: '10px 8px 14px',
          borderBottom: `1px solid ${t.border}`,
        }}>
          <div style={{
            width: 42, height: 42, borderRadius: 12, background: t.sub, color: t.ink2,
            display: 'inline-flex', alignItems: 'center', justifyContent: 'center',
          }}><IconFile size={18}/></div>
          <div style={{ minWidth: 0, flex: 1 }}>
            <div style={{ fontWeight: 700, fontSize: 14.5, color: t.ink, letterSpacing: '-0.01em',
                          overflow: 'hidden', textOverflow: 'ellipsis', whiteSpace: 'nowrap' }}>
              {doc.name}
            </div>
            <div style={{ fontSize: 11.5, color: t.ink2, marginTop: 2 }}>
              {doc.category} · <span style={{ fontFamily: t.mono }}>{doc.size}</span>
            </div>
          </div>
        </div>

        <div style={{ display: 'flex', flexDirection: 'column', padding: '6px 0' }}>
          {rows.map(r => (
            <button key={r.label} onClick={onClose} style={{
              background: 'transparent', border: 'none', cursor: 'pointer',
              padding: '11px 8px', display: 'flex', alignItems: 'center', gap: 12,
              color: t.ink, fontFamily: 'inherit', textAlign: 'left', width: '100%',
            }}>
              <div style={{
                width: 34, height: 34, borderRadius: 10, background: t.sub, color: t.ink,
                display: 'inline-flex', alignItems: 'center', justifyContent: 'center',
              }}>{r.icon}</div>
              <div style={{ flex: 1 }}>
                <div style={{ fontWeight: 600, fontSize: 13.5 }}>{r.label}</div>
                {r.hint && <div style={{ fontSize: 11, color: t.ink2, marginTop: 1 }}>{r.hint}</div>}
              </div>
              <IconChevR size={14}/>
            </button>
          ))}

          <div style={{ height: 1, background: t.border, margin: '8px 0' }}/>

          <button onClick={onClose} style={{
            background: 'transparent', border: 'none', cursor: 'pointer',
            padding: '11px 8px', display: 'flex', alignItems: 'center', gap: 12,
            color: t.warn, fontFamily: 'inherit', textAlign: 'left', width: '100%',
          }}>
            <div style={{
              width: 34, height: 34, borderRadius: 10, background: 'rgba(168,69,29,0.12)',
              color: t.warn, display: 'inline-flex', alignItems: 'center', justifyContent: 'center',
            }}><IconTrash size={16}/></div>
            <div style={{ flex: 1 }}>
              <div style={{ fontWeight: 600, fontSize: 13.5 }}>Move to Recycle Bin</div>
              <div style={{ fontSize: 11, color: t.ink2, marginTop: 1 }}>Kept for 7 days</div>
            </div>
          </button>
        </div>
      </div>
    </Sheet>
  );
}

// ─────────────────────────────────────────────────────────────
// Unlock-collection sheet
// ─────────────────────────────────────────────────────────────
function UnlockSheet({ open, onClose, coll, onUnlock }) {
  const t = useTheme();
  const [pin, setPin] = useState3('');
  if (!coll) return null;

  return (
    <Sheet open={open} onClose={onClose} maxHeight={560}>
      <div style={{ padding: '4px 22px 24px' }}>
        <div style={{ display: 'flex', alignItems: 'center', gap: 12, marginTop: 6, marginBottom: 16 }}>
          <div style={{
            width: 48, height: 48, borderRadius: 14, background: t.ink, color: t.bg,
            display: 'inline-flex', alignItems: 'center', justifyContent: 'center',
          }}><IconLock size={20}/></div>
          <div>
            <div style={{
              fontSize: 10.5, fontWeight: 700, letterSpacing: '0.12em', textTransform: 'uppercase',
              color: t.ink2, fontFamily: t.mono,
            }}>Locked collection</div>
            <div style={{ fontSize: 18, fontWeight: 700, letterSpacing: '-0.02em', color: t.ink, marginTop: 2 }}>
              {coll.name}
            </div>
          </div>
        </div>

        <div style={{ fontSize: 13, color: t.ink2, lineHeight: 1.5, marginBottom: 16 }}>
          Holds <strong style={{ color: t.ink }}>{coll.count} files</strong>. Unlocks for 5 min, then auto-relocks.
        </div>

        <div style={{ display: 'flex', gap: 8, marginBottom: 12 }}>
          {[0,1,2,3].map(i => (
            <div key={i} style={{
              flex: 1, height: 52, borderRadius: 14, background: t.bg,
              border: `1.5px solid ${i < pin.length ? t.ink : t.border}`,
              display: 'inline-flex', alignItems: 'center', justifyContent: 'center',
              fontSize: 24, fontWeight: 700, color: t.ink,
            }}>{i < pin.length ? '●' : ''}</div>
          ))}
        </div>

        <div style={{ display: 'grid', gridTemplateColumns: 'repeat(3, 1fr)', gap: 6, marginBottom: 10 }}>
          {['1','2','3','4','5','6','7','8','9','bio','0','del'].map((k, i) => {
            if (k === 'bio') return (
              <button key={i} onClick={() => onUnlock?.(coll)} style={{
                height: 48, borderRadius: 14, background: t.surface, border: `1px solid ${t.border}`,
                cursor: 'pointer', color: t.ink,
                display: 'inline-flex', alignItems: 'center', justifyContent: 'center',
              }}><IconFingerprint size={20}/></button>
            );
            if (k === 'del') return (
              <button key={i} onClick={() => setPin(p => p.slice(0, -1))} style={{
                height: 48, borderRadius: 14, background: t.surface, border: `1px solid ${t.border}`,
                cursor: 'pointer', color: t.ink2, fontFamily: 'inherit', fontSize: 11.5, fontWeight: 600,
              }}>Delete</button>
            );
            return (
              <button key={i} onClick={() => {
                const n = (pin + k).slice(0, 4); setPin(n);
                if (n.length === 4) setTimeout(() => onUnlock?.(coll), 200);
              }} style={{
                height: 48, borderRadius: 14, background: t.surface, border: `1px solid ${t.border}`,
                cursor: 'pointer', color: t.ink, fontFamily: 'inherit', fontSize: 18, fontWeight: 600,
              }}>{k}</button>
            );
          })}
        </div>

        <div style={{ textAlign: 'center', fontSize: 11, color: t.ink3, fontFamily: t.mono, letterSpacing: '0.04em' }}>
          Use device fingerprint for faster unlock
        </div>
      </div>
    </Sheet>
  );
}

// ─────────────────────────────────────────────────────────────
// Settings
// ─────────────────────────────────────────────────────────────
function SettingsScreen({ onRecycle, onProfiles }) {
  const t = useTheme();
  const sections = [
    { num: 1, title: 'Account', rows: [
      { icon: <IconUsers size={16}/>, label: 'Family profiles',       hint: '4 active',                cb: onProfiles },
      { icon: <IconCloud size={16}/>, label: 'Google Drive backup',   hint: 'Connected · synced 2h ago' },
    ]},
    { num: 2, title: 'Security', rows: [
      { icon: <IconLock size={16}/>,        label: 'App lock & PIN',     hint: 'PIN + fingerprint' },
      { icon: <IconFingerprint size={16}/>, label: 'Biometric unlock',   toggle: true, on: true },
      { icon: <IconClock size={16}/>,       label: 'Auto-lock timer',    hint: 'After 5 minutes' },
    ]},
    { num: 3, title: 'Storage', rows: [
      { icon: <IconTrash size={16}/>,       label: 'Recycle Bin',        hint: '3 items · 7-day retention', cb: onRecycle },
      { icon: <IconClock size={16}/>,       label: 'Version history',    hint: 'Keep last 5 versions' },
      { icon: <IconFolder size={16}/>,      label: 'Export to folders',  hint: 'Local manual backup' },
    ]},
    { num: 4, title: 'Notifications', rows: [
      { icon: <IconBell size={16}/>,        label: 'Expiry reminders',   hint: '30 / 15 / 7 days before' },
      { icon: <IconClock size={16}/>,       label: 'Quiet hours',        hint: '10 PM – 8 AM' },
    ]},
  ];

  return (
    <Screen>
      <div style={{ overflow: 'auto', height: '100%', paddingBottom: 110 }}>
        <HeroHeader
          eyebrow="Account & preferences"
          title="Settings"
          subtitle="DocVault v0.2 · MVP build"
        />

        {/* Storage card */}
        <div style={{ padding: '4px 22px 4px' }}>
          <div style={{
            background: t.ink, color: t.bg, borderRadius: 20, padding: 20,
          }}>
            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'baseline' }}>
              <div>
                <div style={{
                  fontSize: 10.5, fontWeight: 700, letterSpacing: '0.12em', textTransform: 'uppercase',
                  color: 'rgba(255,255,255,0.5)', fontFamily: t.mono,
                }}>Vault size</div>
                <div style={{ fontSize: 30, fontWeight: 700, letterSpacing: '-0.04em', marginTop: 6, lineHeight: 1 }}>
                  <span style={{ fontFamily: t.mono }}>182</span>
                  <span style={{ fontSize: 14, color: 'rgba(255,255,255,0.55)', marginLeft: 5 }}>MB</span>
                </div>
                <div style={{ fontSize: 11.5, color: 'rgba(255,255,255,0.55)', marginTop: 6 }}>
                  47 documents · 7 collections
                </div>
              </div>
              <div style={{ textAlign: 'right' }}>
                <div style={{
                  fontSize: 9.5, color: 'rgba(255,255,255,0.5)', fontFamily: t.mono, letterSpacing: '0.1em',
                  fontWeight: 700,
                }}>ENCRYPTED</div>
                <div style={{
                  fontSize: 11.5, color: '#fff', marginTop: 4, fontWeight: 700, fontFamily: t.mono,
                }}>AES-256</div>
              </div>
            </div>
            <div style={{
              marginTop: 16, height: 6, borderRadius: 999, background: 'rgba(255,255,255,0.12)',
              overflow: 'hidden', display: 'flex',
            }}>
              <div style={{ width: '32%', background: '#fff' }}/>
              <div style={{ width: '24%', background: 'rgba(255,255,255,0.7)', marginLeft: 1 }}/>
              <div style={{ width: '14%', background: 'rgba(255,255,255,0.5)', marginLeft: 1 }}/>
              <div style={{ width: '10%', background: 'rgba(255,255,255,0.3)', marginLeft: 1 }}/>
            </div>
            <div style={{
              display: 'flex', gap: 12, marginTop: 10, flexWrap: 'wrap',
            }}>
              {[
                ['IDs', '#fff'], ['Education', 'rgba(255,255,255,0.7)'],
                ['Medical', 'rgba(255,255,255,0.5)'], ['Other', 'rgba(255,255,255,0.3)'],
              ].map(([k, c]) => (
                <div key={k} style={{
                  display: 'inline-flex', alignItems: 'center', gap: 5, fontSize: 10.5,
                  color: 'rgba(255,255,255,0.7)',
                }}>
                  <div style={{ width: 7, height: 7, borderRadius: 2, background: c }}/>
                  {k}
                </div>
              ))}
            </div>
          </div>
        </div>

        {sections.map(s => (
          <div key={s.title}>
            <SectionHeading num={s.num} label={s.title}/>
            <div style={{ padding: '0 22px' }}>
              <div style={{
                background: t.surface, border: `1px solid ${t.border}`, borderRadius: 16, overflow: 'hidden',
              }}>
                {s.rows.map((r, i, arr) => (
                  <button key={r.label} onClick={r.cb} style={{
                    background: 'transparent', border: 'none', cursor: r.cb ? 'pointer' : 'default',
                    padding: '13px 16px', display: 'flex', alignItems: 'center', gap: 12,
                    color: t.ink, fontFamily: 'inherit', textAlign: 'left', width: '100%',
                    borderBottom: i < arr.length - 1 ? `1px solid ${t.border}` : 'none',
                  }}>
                    <div style={{
                      width: 30, height: 30, borderRadius: 9, background: t.sub, color: t.ink,
                      display: 'inline-flex', alignItems: 'center', justifyContent: 'center',
                    }}>{r.icon}</div>
                    <div style={{ flex: 1 }}>
                      <div style={{ fontWeight: 600, fontSize: 13.5, letterSpacing: '-0.005em' }}>{r.label}</div>
                      {r.hint && <div style={{ fontSize: 11, color: t.ink2, marginTop: 1 }}>{r.hint}</div>}
                    </div>
                    {r.toggle ? (
                      <div style={{
                        width: 36, height: 22, borderRadius: 999, padding: 2, boxSizing: 'border-box',
                        background: r.on ? t.ink : t.border,
                      }}>
                        <div style={{
                          width: 18, height: 18, borderRadius: '50%', background: '#fff',
                          transform: r.on ? 'translateX(14px)' : 'translateX(0)',
                          transition: 'transform 200ms ease', boxShadow: '0 1px 4px rgba(0,0,0,0.15)',
                        }}/>
                      </div>
                    ) : <IconChevR size={14}/>}
                  </button>
                ))}
              </div>
            </div>
          </div>
        ))}

        <div style={{ height: 30 }}/>
      </div>
    </Screen>
  );
}

// ─────────────────────────────────────────────────────────────
// Recycle bin
// ─────────────────────────────────────────────────────────────
function RecycleBinScreen({ onBack }) {
  const t = useTheme();
  const items = window.RECYCLE_BIN;
  return (
    <Screen>
      <div style={{ overflow: 'auto', height: '100%', paddingBottom: 110 }}>
        <CompactHeader
          title="Recycle Bin"
          subtitle="Auto-delete after 7 days"
          leading={<IconBtn icon={<IconBack size={18}/>} onClick={onBack}/>}
          trailing={<IconBtn icon={<IconMore size={16}/>}/>}
        />

        <div style={{ padding: '4px 22px 12px' }}>
          <div style={{
            background: 'rgba(168,69,29,0.06)', border: `1px solid rgba(168,69,29,0.2)`, borderRadius: 16,
            padding: '12px 14px', display: 'flex', alignItems: 'center', gap: 10,
          }}>
            <div style={{
              width: 32, height: 32, borderRadius: 10, background: t.warn, color: '#fff',
              display: 'inline-flex', alignItems: 'center', justifyContent: 'center',
            }}><IconWarning size={16}/></div>
            <div style={{ flex: 1 }}>
              <div style={{ fontSize: 12.5, fontWeight: 700, color: t.ink, letterSpacing: '-0.005em' }}>
                Items here will be permanently deleted
              </div>
              <div style={{ fontSize: 11, color: t.ink2, marginTop: 1 }}>
                Change retention in Settings → Storage
              </div>
            </div>
          </div>
        </div>

        <div style={{ display: 'flex', flexDirection: 'column', gap: 8, padding: '0 22px' }}>
          {items.map(it => (
            <div key={it.id} style={{
              background: t.surface, border: `1px solid ${t.border}`, borderRadius: 16, padding: 14,
              display: 'flex', alignItems: 'center', gap: 12,
            }}>
              <div style={{
                width: 42, height: 42, borderRadius: 12, background: t.sub, color: t.ink3,
                display: 'inline-flex', alignItems: 'center', justifyContent: 'center',
              }}><IconFile size={16}/></div>
              <div style={{ flex: 1, minWidth: 0 }}>
                <div style={{
                  fontWeight: 700, fontSize: 14, color: t.ink, letterSpacing: '-0.01em',
                  overflow: 'hidden', textOverflow: 'ellipsis', whiteSpace: 'nowrap',
                }}>{it.name}</div>
                <div style={{ display: 'flex', alignItems: 'center', gap: 7, marginTop: 4 }}>
                  <FormatChip type={it.type}/>
                  <span style={{ fontSize: 11, color: t.ink2 }}>Deleted {it.deleted}</span>
                </div>
                <div style={{
                  fontSize: 10, color: t.warn, fontWeight: 700, marginTop: 6,
                  letterSpacing: '0.06em', fontFamily: t.mono,
                }}>{it.expiresIn.toUpperCase()}</div>
              </div>
              <div style={{ display: 'flex', flexDirection: 'column', gap: 6 }}>
                <button style={{
                  width: 32, height: 32, borderRadius: 10, background: t.sub, border: 'none', cursor: 'pointer',
                  color: t.ink, display: 'inline-flex', alignItems: 'center', justifyContent: 'center',
                }}><IconRestore size={14}/></button>
                <button style={{
                  width: 32, height: 32, borderRadius: 10, background: 'transparent', border: 'none', cursor: 'pointer',
                  color: t.warn, display: 'inline-flex', alignItems: 'center', justifyContent: 'center',
                }}><IconTrash size={14}/></button>
              </div>
            </div>
          ))}
        </div>

        <div style={{ padding: '18px 22px 24px', display: 'flex', gap: 8 }}>
          <PillButton variant="outline" full>Restore all</PillButton>
          <PillButton variant="secondary" full>Empty bin</PillButton>
        </div>
      </div>
    </Screen>
  );
}

Object.assign(window, {
  UploadChooserSheet, UploadFormScreen, DocActionsSheet,
  UnlockSheet, SettingsScreen, RecycleBinScreen,
});
