// Design pack — multi-page print-style layout

const PHONE_SCALE = 0.78;
const PHONE_W = 390;
const PHONE_H = 800;

function Phone({ children, scale = PHONE_SCALE }) {
  return (
    <div className="phone-frame" style={{
      width: PHONE_W * scale, height: PHONE_H * scale,
    }}>
      <div style={{
        width: PHONE_W, height: PHONE_H,
        transform: `scale(${scale})`, transformOrigin: 'top left',
      }}>
        <PhoneShell>{children}</PhoneShell>
      </div>
    </div>
  );
}

function PhoneCard({ num, label, children, scale }) {
  return (
    <div className="phone-block">
      <Phone scale={scale}>{children}</Phone>
      <div className="phone-cap">{label}</div>
      <div className="phone-cap-num">{num}</div>
    </div>
  );
}

function PageHead({ eyebrow, title, num }) {
  return (
    <div className="page-head">
      <div>
        <div className="eyebrow">{eyebrow}</div>
        <div className="page-title">{title}</div>
      </div>
      <div className="page-num">{num}</div>
    </div>
  );
}

// ── Tab screen with bottom nav baked in (for design pack)
function HomeWithNav({ profile, category = 'all', sheet = null }) {
  return (
    <>
      <HomeScreen profile={profile} category={category} setCategory={() => {}}/>
      <BottomNav tab="home"/>
      {sheet}
    </>
  );
}
function CollectionsWithNav({ unlockColl = null }) {
  return (
    <>
      <CollectionsScreen/>
      <BottomNav tab="coll"/>
      {unlockColl && <UnlockSheet open coll={unlockColl}/>}
    </>
  );
}
function SettingsWithNav() {
  return (
    <>
      <SettingsScreen/>
      <BottomNav tab="set"/>
    </>
  );
}

const profile = window.SAMPLE_PROFILES[0];
const sampleDoc = window.SAMPLE_DOCS[3]; // GTU Sem 6 Result
const sampleLockedColl = window.SAMPLE_COLLECTIONS.find(c => c.locked);
const sampleColl = window.SAMPLE_COLLECTIONS.find(c => !c.locked);

function DesignPack() {
  return (
    <ThemeCtx.Provider value={window.PALETTES.paper}>
      {/* ─────────────────────────────── COVER ─────────────────────────────── */}
      <div className="page" style={{ minHeight: 880, display: 'flex', justifyContent: 'center' }}>
        <div style={{ maxWidth: 1080, margin: 'auto', width: '100%' }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: 14, marginBottom: 28 }}>
            <div style={{
              width: 48, height: 48, borderRadius: 14, background: '#14110F', color: '#F0EEE9',
              display: 'inline-flex', alignItems: 'center', justifyContent: 'center',
              fontWeight: 800, fontSize: 22, letterSpacing: '-0.04em',
            }}>D</div>
            <div>
              <div className="eyebrow">DocVault · Android · v0.2 MVP</div>
              <div style={{ fontSize: 18, fontWeight: 700, letterSpacing: '-0.01em', marginTop: 2 }}>
                Personal document organizer
              </div>
            </div>
          </div>

          <div style={{
            fontSize: 88, fontWeight: 700, letterSpacing: '-0.045em', lineHeight: 0.98,
          }}>
            UI design pack<br/>
            <span style={{ color: '#7A736B' }}>Android mobile app</span>
          </div>

          <div style={{
            fontSize: 17, color: '#3A3631', marginTop: 32, lineHeight: 1.55, maxWidth: 720, fontWeight: 500,
          }}>
            A calm, offline-first document vault for individuals and families. Three-tier sorting
            (Pinned · Loved · Other), per-collection locks with auto-relock, Netflix-style family profiles,
            and metadata-only cloud sync — your files never leave the device unencrypted.
          </div>

          <div style={{
            display: 'grid', gridTemplateColumns: 'repeat(4, 1fr)', gap: 16, marginTop: 56,
            maxWidth: 880,
          }}>
            {[
              ['12', 'screens'],
              ['7',  'sections'],
              ['3',  'tiers'],
              ['v1+v2', 'scope'],
            ].map(([n, l]) => (
              <div key={l} style={{
                padding: '22px 22px 20px', borderRadius: 16, background: '#fff', border: '1px solid #E0DAD0',
              }}>
                <div style={{
                  fontSize: 38, fontWeight: 700, letterSpacing: '-0.04em',
                  fontFamily: `'JetBrains Mono', monospace`, lineHeight: 1,
                }}>{n}</div>
                <div style={{
                  fontSize: 11, color: '#7A736B', marginTop: 8, textTransform: 'uppercase',
                  letterSpacing: 0.14 + 'em', fontWeight: 700, fontFamily: `'JetBrains Mono', monospace`,
                }}>{l}</div>
              </div>
            ))}
          </div>

          <div style={{
            marginTop: 'auto', paddingTop: 56, display: 'flex', justifyContent: 'space-between',
            fontSize: 11, fontFamily: `'JetBrains Mono', monospace`, color: '#7A736B',
            letterSpacing: '0.12em', textTransform: 'uppercase', fontWeight: 600,
          }}>
            <span>Plus Jakarta Sans · JetBrains Mono</span>
            <span>Paper palette · Android 14 target</span>
            <span>May 2026</span>
          </div>
        </div>
      </div>

      {/* ─────────────────────────────── P1 · AUTH ─────────────────────────────── */}
      <div className="page">
        <PageHead eyebrow="Section 01 · Authentication" title="App lock & family pick" num="P1 / 07"/>
        <div className="phone-row">
          <PhoneCard num="01" label="App lock · PIN + biometric">
            <LockScreen/>
          </PhoneCard>
          <PhoneCard num="02" label="Family profile picker">
            <ProfilesScreen current="p1"/>
          </PhoneCard>
        </div>
        <div className="note">
          <div className="note-eyebrow">Notes</div>
          The vault opens with a 4-digit PIN or device fingerprint. After unlock, the user picks a family member —
          each profile keeps its own documents on-device, shared collections are visible to everyone.
          Profiles are local-only; <strong>not synced to the cloud</strong> (Option A from the v1 plan).
        </div>
      </div>

      {/* ─────────────────────────────── P2 · HOME ─────────────────────────────── */}
      <div className="page">
        <PageHead eyebrow="Section 02 · Home" title="The three-tier vault list" num="P2 / 07"/>
        <div className="phone-row">
          <PhoneCard num="03" label="Home · Pinned, Loved, All Documents">
            <HomeWithNav profile={profile}/>
          </PhoneCard>
          <PhoneCard num="04" label="Search · recents + suggestions">
            <SearchScreen/>
          </PhoneCard>
        </div>
        <div className="note">
          <div className="note-eyebrow">Three-tier system</div>
          <strong>Pinned</strong> (dark cards, numbered #01/#02/#03) sit at the top of every view — they ignore filters.
          <strong> Loved</strong> is the user's favourites with its own sort. <strong> All Documents</strong> is everything
          else. The stat strip under the hero gives at-a-glance counts (<em>47 total · 3 pinned · 1 expired · synced 2h</em>).
          The right side of the search bar collapses to a filter pill — both expand into the search overlay.
        </div>
      </div>

      {/* ─────────────────────────────── P3 · BROWSE ─────────────────────────────── */}
      <div className="page">
        <PageHead eyebrow="Section 03 · Browse" title="Document detail & actions" num="P3 / 07"/>
        <div className="phone-row">
          <PhoneCard num="05" label="Document detail · preview + meta">
            <DocDetailScreen doc={sampleDoc}/>
          </PhoneCard>
          <PhoneCard num="06" label="More actions sheet · over Home">
            <HomeWithNav profile={profile} sheet={<DocActionsSheet open doc={sampleDoc}/>}/>
          </PhoneCard>
        </div>
        <div className="note">
          <div className="note-eyebrow">Notes</div>
          Detail view shows a faux-document preview, format chip, expiry, and a clean meta table
          (size, collection, expiry, version count, encryption). The bottom action sheet handles
          everything secondary — Pin, Love, Rename, Move, Versions, Share, Drive backup, Delete — keeping
          the detail screen calm. Delete is destructive-tinted and routes through Recycle Bin (7-day retention).
        </div>
      </div>

      {/* ─────────────────────────────── P4 · COLLECTIONS ─────────────────────────────── */}
      <div className="page">
        <PageHead eyebrow="Section 04 · Collections" title="Folders inside categories" num="P4 / 07"/>
        <div className="phone-row">
          <PhoneCard num="07" label="Collections list · ordered + locked">
            <CollectionsWithNav/>
          </PhoneCard>
          <PhoneCard num="08" label="Collection detail · auto-relock timer">
            <CollectionDetailScreen coll={sampleColl}/>
          </PhoneCard>
        </div>
        <div className="note">
          <div className="note-eyebrow">Per-collection lock</div>
          Collections are sub-folders inside Categories (College Results, Fee Receipts, Family IDs…). Each can carry
          its own lock independent of the app lock — and when unlocked, an <strong>auto-relock timer</strong> shows in
          the banner. Tap-to-edit anything inside requires the collection be unlocked first; the user can never
          accidentally rename or delete a sensitive file.
        </div>
      </div>

      {/* ─────────────────────────────── P5 · UNLOCK ─────────────────────────────── */}
      <div className="page">
        <PageHead eyebrow="Section 05 · Unlock" title="Locked collection flow" num="P5 / 07"/>
        <div className="phone-row">
          <PhoneCard num="09" label="Unlock sheet · over Collections">
            <CollectionsWithNav unlockColl={sampleLockedColl}/>
          </PhoneCard>
          <PhoneCard num="10" label="Add document · chooser sheet">
            <>
              <HomeScreen profile={profile}/>
              <BottomNav tab="home"/>
              <UploadChooserSheet open/>
            </>
          </PhoneCard>
        </div>
        <div className="note">
          <div className="note-eyebrow">Two sheet patterns</div>
          Locked collections show the <strong>unlock sheet</strong> with a compact 4-digit pad and a fingerprint
          shortcut. The Add (+) tab in the bottom nav opens the <strong>chooser sheet</strong> with camera, file,
          new collection, and Drive import — the two primary capture paths up top, secondary actions below.
        </div>
      </div>

      {/* ─────────────────────────────── P6 · UPLOAD ─────────────────────────────── */}
      <div className="page">
        <PageHead eyebrow="Section 06 · Upload" title="New document form" num="P6 / 07"/>
        <div className="phone-row">
          <PhoneCard num="11" label="Upload form · category + collection + expiry">
            <UploadFormScreen/>
          </PhoneCard>
          <PhoneCard num="12" label="Settings · vault size + sections">
            <SettingsWithNav/>
          </PhoneCard>
        </div>
        <div className="note">
          <div className="note-eyebrow">Capture flow</div>
          After camera or file pick, the user lands in the metadata form. <strong>Category</strong> is fixed
          (Personal IDs, Education, Medical, Financial, Property, Receipts) and chosen via chips for fast tapping.
          <strong> Collection</strong> is optional and free-form. <strong>Expiry</strong> drives the reminder
          system — 1-month-ahead notification, then a red badge once expired. Encryption is on by default.
        </div>
      </div>

      {/* ─────────────────────────────── P7 · RECYCLE / END ─────────────────────────────── */}
      <div className="page">
        <PageHead eyebrow="Section 07 · Safety net" title="Recycle bin & version history" num="P7 / 07"/>
        <div className="phone-row">
          <PhoneCard num="13" label="Recycle Bin · 7-day retention">
            <RecycleBinScreen/>
          </PhoneCard>
          <PhoneCard num="14" label="Settings (continued) · scroll position">
            <div style={{ width: '100%', height: '100%', overflow: 'hidden' }}>
              <div style={{ transform: 'translateY(-380px)', height: 'calc(100% + 380px)' }}>
                <SettingsScreen/>
              </div>
              <BottomNav tab="set"/>
            </div>
          </PhoneCard>
        </div>
        <div className="note">
          <div className="note-eyebrow">Mistake-proofing</div>
          Everything destructive lands in Recycle Bin for 7 days (configurable). Re-uploading a doc
          asks "keep old version?" — the version history table tracks up to 5 prior copies.
          Combined with the per-collection lock, the user has three layers of protection against
          accidental loss: <strong>lock → recycle bin → version history</strong>.
        </div>
      </div>
    </ThemeCtx.Provider>
  );
}

ReactDOM.createRoot(document.getElementById('root')).render(<DesignPack/>);
