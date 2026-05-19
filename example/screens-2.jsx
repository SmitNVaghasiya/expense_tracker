// Screens — search, doc detail, collections, collection detail (polished)

const { useState: useState2 } = React;

// ─────────────────────────────────────────────────────────────
// Search overlay
// ─────────────────────────────────────────────────────────────
function SearchScreen({ initialQuery = '', onClose, onDoc }) {
  const t = useTheme();
  const [q, setQ] = useState2(initialQuery);
  const [filter, setFilter] = useState2('all');

  const filters = [
    { id: 'all',     name: 'All'     },
    { id: 'newest',  name: 'Newest'  },
    { id: 'oldest',  name: 'Oldest'  },
    { id: 'az',      name: 'A–Z'     },
    { id: 'loved',   name: 'Loved'   },
    { id: 'expired', name: 'Expired' },
  ];

  const results = q
    ? window.SAMPLE_DOCS
        .filter(d => d.name.toLowerCase().includes(q.toLowerCase())
                  || d.category.toLowerCase().includes(q.toLowerCase()))
        .slice(0, 6)
    : [];

  const recent = ['Aadhaar', 'GTU result', 'Electricity bill', 'Insurance'];

  return (
    <Screen pad={false}>
      <div style={{ overflow: 'auto', height: '100%' }}>
        {/* Search header */}
        <div style={{ padding: '14px 18px 8px', display: 'flex', alignItems: 'center', gap: 10 }}>
          <IconBtn icon={<IconBack size={18}/>} onClick={onClose}/>
          <div style={{
            flex: 1, height: 46, borderRadius: 999, background: t.surface,
            border: `1px solid ${t.border}`, padding: '0 14px 0 16px',
            display: 'flex', alignItems: 'center', gap: 10,
          }}>
            <IconSearch size={17}/>
            <input autoFocus value={q} onChange={e => setQ(e.target.value)}
                   placeholder="Search documents, categories…"
                   style={{
                     flex: 1, border: 'none', outline: 'none', background: 'transparent',
                     fontFamily: 'inherit', fontSize: 14, color: t.ink, minWidth: 0,
                   }}/>
            {q && (
              <button onClick={() => setQ('')} style={{
                background: 'transparent', border: 'none', cursor: 'pointer', color: t.ink2, padding: 0,
              }}><IconClose size={16}/></button>
            )}
          </div>
        </div>

        <div style={{ marginTop: 10 }}>
          <ChipRow items={filters} value={filter} onChange={setFilter} pad={18}/>
        </div>

        {q ? (
          <>
            <div style={{
              padding: '22px 22px 10px', display: 'flex', alignItems: 'baseline', justifyContent: 'space-between',
            }}>
              <span style={{ fontSize: 11, fontWeight: 700, letterSpacing: '0.12em', textTransform: 'uppercase',
                             color: t.ink2, fontFamily: t.mono }}>
                {results.length} matches
              </span>
              <span style={{ fontSize: 11, color: t.ink3, fontFamily: t.mono }}>"{q}"</span>
            </div>
            <div style={{ display: 'flex', flexDirection: 'column', gap: 8, padding: '0 22px' }}>
              {results.map(d => <DocCard key={d.id} doc={d} onClick={() => onDoc?.(d)}/>)}
              {results.length === 0 && (
                <div style={{
                  padding: '32px 20px', textAlign: 'center', color: t.ink2, fontSize: 13.5,
                  background: t.surface, border: `1px solid ${t.border}`, borderRadius: 16, lineHeight: 1.5,
                }}>
                  No matches for <strong style={{ color: t.ink }}>"{q}"</strong>
                  <div style={{ fontSize: 11.5, color: t.ink3, marginTop: 8 }}>
                    Try a category or part of the name
                  </div>
                </div>
              )}
            </div>
          </>
        ) : (
          <>
            <SectionHeading num={1} label="Recent" hint="Last 4 searches"/>
            <div style={{ padding: '0 12px' }}>
              {recent.map(r => (
                <button key={r} onClick={() => setQ(r)} style={{
                  background: 'transparent', border: 'none', cursor: 'pointer', width: '100%',
                  padding: '12px 10px', display: 'flex', alignItems: 'center', gap: 12,
                  color: t.ink, fontFamily: 'inherit',
                }}>
                  <div style={{
                    width: 34, height: 34, borderRadius: 999, background: t.sub, color: t.ink2,
                    display: 'inline-flex', alignItems: 'center', justifyContent: 'center',
                  }}><IconClock size={15}/></div>
                  <span style={{ fontSize: 14, fontWeight: 500, flex: 1, textAlign: 'left' }}>{r}</span>
                  <IconArrowR size={15}/>
                </button>
              ))}
            </div>

            <SectionHeading num={2} label="Suggested"/>
            <div style={{ display: 'flex', flexWrap: 'wrap', gap: 6, padding: '0 22px' }}>
              {['Aadhaar', 'PAN', 'Marksheet', 'Insurance', 'Receipt', 'Rent', 'Vaccine', 'License'].map(s => (
                <button key={s} onClick={() => setQ(s)} style={{
                  height: 32, padding: '0 12px', borderRadius: 999,
                  background: t.surface, border: `1px solid ${t.border}`,
                  fontSize: 12.5, fontWeight: 500, color: t.ink, fontFamily: 'inherit', cursor: 'pointer',
                }}>{s}</button>
              ))}
            </div>
          </>
        )}
      </div>
    </Screen>
  );
}

// ─────────────────────────────────────────────────────────────
// Doc detail
// ─────────────────────────────────────────────────────────────
function DocDetailScreen({ doc, onClose, onMore }) {
  const t = useTheme();
  const [favorite, setFavorite] = useState2(doc.tier === 'loved' || doc.tier === 'pinned');

  return (
    <Screen pad={false}>
      <div style={{ overflow: 'auto', height: '100%' }}>
        <CompactHeader
          title="Document"
          subtitle={doc.category}
          leading={<IconBtn icon={<IconBack size={18}/>} onClick={onClose}/>}
          trailing={<>
            <IconBtn icon={favorite ? <IconHeartF size={16}/> : <IconHeart size={16}/>}
                     onClick={() => setFavorite(f => !f)}
                     color={favorite ? t.warn : t.ink}/>
            <IconBtn icon={<IconMore size={16}/>} onClick={() => onMore?.(doc)}/>
          </>}
        />

        {/* Preview */}
        <div style={{ padding: '6px 22px 0' }}>
          <div style={{
            width: '100%', aspectRatio: '0.78', borderRadius: 20,
            background: t.surface, border: `1px solid ${t.border}`,
            padding: '22px 20px', overflow: 'hidden', position: 'relative',
            boxShadow: '0 12px 28px rgba(20,17,15,0.06)',
            fontFamily: `'JetBrains Mono', monospace`,
          }}>
            <div style={{ fontSize: 8, color: t.ink3, letterSpacing: '0.18em', fontWeight: 700 }}>
              GOVERNMENT OF INDIA
            </div>
            <div style={{
              fontSize: 14, fontWeight: 700, marginTop: 6, color: t.ink, letterSpacing: '-0.01em',
              fontFamily: `'Plus Jakarta Sans', sans-serif`,
            }}>{doc.name}</div>

            <div style={{ marginTop: 18, display: 'flex', gap: 12, alignItems: 'flex-start' }}>
              <div style={{
                width: 58, height: 72, borderRadius: 4, background: t.sub,
                display: 'flex', alignItems: 'center', justifyContent: 'center',
                color: t.ink3, fontSize: 8, fontWeight: 600, letterSpacing: '0.08em',
              }}>PHOTO</div>
              <div style={{ flex: 1 }}>
                {[['Name', '90%'],['D.O.B.', '60%'],['Address', '100%'],['ID No.', '70%']].map(([l, w]) => (
                  <div key={l} style={{ marginBottom: 7 }}>
                    <div style={{ fontSize: 7, color: t.ink3, letterSpacing: '0.12em', fontWeight: 700, marginBottom: 2 }}>{l}</div>
                    <div style={{ height: 5, background: t.sub, borderRadius: 2, width: w }}/>
                  </div>
                ))}
              </div>
            </div>
            {Array.from({ length: 5 }).map((_, i) => (
              <div key={i} style={{
                height: 4, background: t.sub, borderRadius: 2, marginTop: 8,
                width: `${100 - (i * 7)}%`,
              }}/>
            ))}
            <div style={{
              position: 'absolute', bottom: 14, right: 14, fontSize: 8, color: t.ink3,
              letterSpacing: '0.06em',
            }}>Page 1 of 1</div>
          </div>
        </div>

        {/* Meta */}
        <div style={{ padding: '18px 22px 6px' }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: 6, marginBottom: 8, flexWrap: 'wrap' }}>
            <FormatChip type={doc.type}/>
            <span style={{ fontSize: 11.5, color: t.ink2, fontWeight: 500 }}>{doc.category}</span>
            {doc.tier === 'pinned' && (
              <span style={{
                display: 'inline-flex', alignItems: 'center', gap: 4, height: 19, padding: '0 8px',
                borderRadius: 999, background: t.ink, color: t.bg, fontSize: 10, fontWeight: 700,
                letterSpacing: '0.04em',
              }}>
                <IconPin size={10} stroke={2.6}/> PINNED #{doc.pinOrder}
              </span>
            )}
          </div>
          <div style={{
            fontSize: 22, fontWeight: 700, letterSpacing: '-0.025em', color: t.ink, lineHeight: 1.15,
          }}>{doc.name}</div>
        </div>

        {/* Detail table */}
        <div style={{ padding: '12px 22px 0' }}>
          <div style={{ background: t.surface, border: `1px solid ${t.border}`, borderRadius: 16, overflow: 'hidden' }}>
            {[
              ['Uploaded',   doc.uploaded, false],
              ['File size',  doc.size,     true],
              ['Collection', doc.collection || '—', false],
              ['Expires',    doc.expiry || 'No expiry', false],
              ['Versions',   '3 kept on device',    false],
              ['Encryption', 'AES-256',     true],
            ].map(([k, v, mono], i, arr) => (
              <div key={k} style={{
                display: 'flex', justifyContent: 'space-between', alignItems: 'center',
                padding: '13px 16px',
                borderBottom: i < arr.length - 1 ? `1px solid ${t.border}` : 'none',
              }}>
                <div style={{ fontSize: 12.5, color: t.ink2, fontWeight: 500 }}>{k}</div>
                <div style={{
                  fontSize: 13, color: t.ink, fontWeight: 600,
                  fontFamily: mono ? t.mono : 'inherit',
                }}>{v}</div>
              </div>
            ))}
          </div>
        </div>

        {/* Quick actions */}
        <div style={{ padding: '16px 22px 0', display: 'grid', gridTemplateColumns: 'repeat(4, 1fr)', gap: 8 }}>
          {[
            { icon: <IconShare    size={18}/>, label: 'Share' },
            { icon: <IconDownload size={18}/>, label: 'Save'  },
            { icon: <IconFolder   size={18}/>, label: 'Move'  },
            { icon: <IconMore     size={18}/>, label: 'More'  },
          ].map(a => (
            <button key={a.label} onClick={a.label === 'More' ? () => onMore?.(doc) : undefined} style={{
              background: t.surface, border: `1px solid ${t.border}`, borderRadius: 14,
              padding: '12px 4px', display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 6,
              cursor: 'pointer', color: t.ink, fontFamily: 'inherit',
            }}>
              {a.icon}
              <span style={{ fontSize: 10.5, fontWeight: 600 }}>{a.label}</span>
            </button>
          ))}
        </div>

        <div style={{ padding: '14px 22px 24px' }}>
          <PillButton full size="lg" trailingIcon={<IconArrowR size={16}/>}>Open document</PillButton>
        </div>
      </div>
    </Screen>
  );
}

// ─────────────────────────────────────────────────────────────
// Collections list
// ─────────────────────────────────────────────────────────────
function CollectionsScreen({ onColl, onUnlockSheet }) {
  const t = useTheme();
  const colls = window.SAMPLE_COLLECTIONS;
  const lockedCount = colls.filter(c => c.locked).length;
  return (
    <Screen>
      <div style={{ overflow: 'auto', height: '100%', paddingBottom: 110 }}>
        <HeroHeader
          eyebrow="Folders inside categories"
          title="Collections"
          subtitle={`${colls.length} collections · ${lockedCount} locked`}
          trailing={<IconBtn icon={<IconPlus size={18}/>}/>}
        />

        <div style={{ padding: '6px 22px 14px' }}>
          <div style={{ display: 'flex', gap: 8 }}>
            <button style={{
              flex: 1, height: 44, borderRadius: 14, background: t.surface,
              border: `1px solid ${t.border}`, display: 'inline-flex', alignItems: 'center', gap: 10,
              padding: '0 16px', fontFamily: 'inherit', color: t.ink, fontWeight: 600, fontSize: 13,
              cursor: 'pointer',
            }}>
              <IconSort size={16}/> Sort: Custom order
            </button>
            <button style={{
              height: 44, width: 44, borderRadius: 14, background: t.surface,
              border: `1px solid ${t.border}`, display: 'inline-flex', alignItems: 'center', justifyContent: 'center',
              color: t.ink, cursor: 'pointer',
            }}><IconFilter size={16}/></button>
          </div>
        </div>

        <div style={{ display: 'flex', flexDirection: 'column', gap: 8, padding: '0 22px' }}>
          {colls.map((c, i) => (
            <button key={c.id} onClick={() => c.locked ? onUnlockSheet?.(c) : onColl?.(c)} style={{
              background: t.surface, border: `1px solid ${t.border}`, borderRadius: 18,
              padding: 14, display: 'flex', alignItems: 'center', gap: 12,
              cursor: 'pointer', textAlign: 'left', color: 'inherit', fontFamily: 'inherit',
            }}>
              <div style={{
                width: 30, height: 30, borderRadius: 8, background: t.sub, color: t.ink2,
                display: 'inline-flex', alignItems: 'center', justifyContent: 'center',
                fontWeight: 700, fontSize: 12, fontFamily: t.mono, flexShrink: 0,
              }}>{String(i + 1).padStart(2, '0')}</div>

              <div style={{
                width: 46, height: 46, borderRadius: 13, flexShrink: 0,
                background: c.locked ? t.ink : t.sub, color: c.locked ? t.bg : t.ink2,
                display: 'inline-flex', alignItems: 'center', justifyContent: 'center',
              }}>{c.locked ? <IconLock size={18}/> : <IconFolder size={18}/>}</div>

              <div style={{ flex: 1, minWidth: 0 }}>
                <div style={{ fontSize: 15, fontWeight: 700, color: t.ink, letterSpacing: '-0.012em' }}>
                  {c.name}
                </div>
                <div style={{ display: 'flex', alignItems: 'center', gap: 7, marginTop: 4 }}>
                  <span style={{ fontSize: 11.5, color: t.ink2, fontWeight: 500 }}>{c.category}</span>
                  <span style={{ fontSize: 11.5, color: t.ink3, fontFamily: t.mono }}>·</span>
                  <span style={{ fontSize: 11.5, color: t.ink3, fontFamily: t.mono }}>
                    {c.count} files
                  </span>
                  {c.locked && (
                    <span style={{
                      fontSize: 9.5, fontWeight: 700, letterSpacing: '0.1em', fontFamily: t.mono,
                      color: t.warn, marginLeft: 4,
                    }}>· LOCKED</span>
                  )}
                </div>
              </div>
              <IconChevR size={16}/>
            </button>
          ))}
        </div>

        <div style={{ height: 30 }}/>
      </div>
    </Screen>
  );
}

// ─────────────────────────────────────────────────────────────
// Collection detail
// ─────────────────────────────────────────────────────────────
function CollectionDetailScreen({ coll, onBack, onDoc, onMore }) {
  const t = useTheme();
  const docs = window.SAMPLE_DOCS.filter(d => d.collection === coll.name);
  const items = docs.length ? docs : window.SAMPLE_DOCS.slice(0, Math.min(coll.count, 5));

  return (
    <Screen pad={false}>
      <div style={{ overflow: 'auto', height: '100%' }}>
        <CompactHeader
          title={coll.name} subtitle={`${coll.category} · ${items.length} files`}
          leading={<IconBtn icon={<IconBack size={18}/>} onClick={onBack}/>}
          trailing={<><IconBtn icon={<IconMore size={16}/>}/></>}
        />

        {/* Unlocked banner */}
        <div style={{ padding: '4px 22px 12px' }}>
          <div style={{
            background: t.surface, border: `1px solid ${t.border}`, borderRadius: 16,
            padding: '12px 14px', display: 'flex', alignItems: 'center', gap: 10,
          }}>
            <div style={{
              width: 34, height: 34, borderRadius: 10, background: t.ok, color: '#fff',
              display: 'inline-flex', alignItems: 'center', justifyContent: 'center',
            }}><IconUnlock size={16}/></div>
            <div style={{ flex: 1 }}>
              <div style={{ fontSize: 12.5, fontWeight: 700, color: t.ink, letterSpacing: '-0.005em' }}>
                Unlocked for <span style={{ fontFamily: t.mono }}>4:32</span>
              </div>
              <div style={{ fontSize: 11, color: t.ink2 }}>Auto-locks when timer ends</div>
            </div>
            <button style={{
              height: 30, padding: '0 12px', borderRadius: 999, background: t.sub,
              border: 'none', cursor: 'pointer', fontFamily: 'inherit', fontWeight: 600, fontSize: 11.5, color: t.ink,
            }}>Lock now</button>
          </div>
        </div>

        <div style={{ display: 'flex', flexDirection: 'column', gap: 8, padding: '0 22px' }}>
          {items.map((d, i) => (
            <DocCard key={d.id}
                     doc={{...d, name: `${String(i + 1).padStart(2, '0')}  ${d.name}` }}
                     onClick={() => onDoc?.(d)} onMore={onMore}/>
          ))}
        </div>

        <div style={{ height: 30 }}/>
      </div>
    </Screen>
  );
}

Object.assign(window, { SearchScreen, DocDetailScreen, CollectionsScreen, CollectionDetailScreen });
