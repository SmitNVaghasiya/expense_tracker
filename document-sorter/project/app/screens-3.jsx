// screens-3.jsx — Phone pipeline status screen (Stages 2-7 monitor)

function ScreenPipeline({ accent, telemetry }) {
  const overall = Math.round(telemetry.reduce((s, x) => s + x.progress, 0) / telemetry.length);
  const running = telemetry.find(s => s.status === 'running');
  const done = telemetry.filter(s => s.status === 'done').length;

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
            <div style={{ fontSize: 12, color: DS.sub, fontWeight: 500 }}>Backend</div>
            <div style={{ fontSize: 18, fontWeight: 700, letterSpacing: -0.3 }}>Pipeline</div>
          </div>
          <div style={{
            display: 'flex', alignItems: 'center', gap: 6, padding: '8px 12px',
            borderRadius: 999, background: '#fff', fontSize: 12, fontWeight: 600,
            boxShadow: '0 1px 0 rgba(20,17,15,.04), 0 8px 22px rgba(20,17,15,.05)',
          }}>
            <span style={{
              width: 6, height: 6, borderRadius: '50%', background: accent,
              boxShadow: `0 0 0 4px ${accent}33`,
            }}/>
            Live
          </div>
        </div>

        {/* hero */}
        <Card pad={22}>
          <div style={{ fontSize: 12, color: DS.sub, fontWeight: 500, letterSpacing: 0.3, textTransform: 'uppercase' }}>
            Overall
          </div>
          <div style={{ display: 'flex', alignItems: 'baseline', gap: 10, marginTop: 6 }}>
            <span style={{ fontSize: 48, fontWeight: 700, letterSpacing: -1.5, lineHeight: 1 }}>{overall}<span style={{ fontSize: 18, color: DS.sub, marginLeft: 2 }}>%</span></span>
            <span style={{ fontSize: 13, color: DS.sub, fontFamily: DS.mono, marginLeft: 'auto' }}>
              {done}/{telemetry.length} done
            </span>
          </div>
          <div style={{ marginTop: 14 }}><Progress value={overall} color={accent}/></div>
          {running && (
            <div style={{
              marginTop: 14, padding: 12, borderRadius: 14, background: DS.bg,
              display: 'flex', alignItems: 'center', gap: 12,
            }}>
              <Spinner accent={accent}/>
              <div style={{ flex: 1, minWidth: 0 }}>
                <div style={{ fontSize: 12, color: DS.sub, fontFamily: DS.mono }}>STAGE {running.id}</div>
                <div style={{ fontSize: 14, fontWeight: 600 }}>{running.label}</div>
              </div>
              <span style={{ fontFamily: DS.mono, fontSize: 13, color: DS.ink }}>{running.progress}%</span>
            </div>
          )}
        </Card>

        {/* stage timeline */}
        <Card pad={0}>
          {telemetry.map((s, i) => <StageRow key={s.id} s={s} accent={accent} last={i === telemetry.length - 1}/>)}
        </Card>

        {/* logs preview */}
        <Card pad={16} style={{ background: DS.pillBg, color: '#fff' }}>
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: 8 }}>
            <span style={{ fontSize: 11, opacity: .6, fontWeight: 600, letterSpacing: 0.4, textTransform: 'uppercase' }}>Logs</span>
            <span style={{ fontSize: 11, opacity: .6, fontFamily: DS.mono }}>tail -f</span>
          </div>
          <div style={{ fontFamily: DS.mono, fontSize: 11.5, lineHeight: 1.65, opacity: .85 }}>
            <div><span style={{ opacity: .5 }}>09:41:02</span> extract: thesis_draft_v7.docx → 8,214 chars</div>
            <div><span style={{ opacity: .5 }}>09:41:02</span> dedup:  exact match → trash/dup_217.pdf</div>
            <div><span style={{ opacity: .5 }}>09:41:03</span> embed:  batch 12/47 (256 docs)</div>
            <div><span style={{ opacity: .5 }}>09:41:03</span> ollama: nomic-embed-text · 2.1s</div>
            <div><span style={{ opacity: .5 }}>09:41:04</span> chroma: persist · 30,624 vectors</div>
          </div>
        </Card>
      </div>
      <BottomNav active="review"/>
    </div>
  );
}

function StageRow({ s, accent, last }) {
  const c = s.status === 'done' ? accent : s.status === 'running' ? DS.ink : DS.sub;
  return (
    <div style={{
      display: 'flex', gap: 14, padding: '14px 18px', alignItems: 'flex-start',
      borderBottom: last ? 'none' : `1px solid ${DS.hairline}`,
    }}>
      <div style={{ position: 'relative', display: 'flex', flexDirection: 'column', alignItems: 'center' }}>
        <div style={{
          width: 28, height: 28, borderRadius: '50%', flexShrink: 0,
          background: s.status === 'done' ? accent : s.status === 'running' ? DS.ink : DS.bg,
          color: s.status === 'queued' ? DS.sub : '#fff',
          display: 'flex', alignItems: 'center', justifyContent: 'center',
          fontFamily: DS.mono, fontSize: 11, fontWeight: 700,
        }}>
          {s.status === 'done' ? <IconCheck size={14} color="#fff" stroke={2.4}/> : s.id}
        </div>
        {!last && <div style={{ width: 2, flex: 1, background: DS.hairline, marginTop: 4, minHeight: 24 }}/>}
      </div>
      <div style={{ flex: 1, minWidth: 0, paddingBottom: last ? 0 : 8 }}>
        <div style={{ display: 'flex', alignItems: 'center', gap: 8 }}>
          <span style={{ fontSize: 14.5, fontWeight: 700, letterSpacing: -0.2 }}>{s.label}</span>
          <span style={{
            fontSize: 10, fontWeight: 700, padding: '2px 8px', borderRadius: 999,
            background: s.status === 'running' ? DS.bg : 'transparent',
            color: c, fontFamily: DS.mono, letterSpacing: 0.4, textTransform: 'uppercase',
          }}>{s.status}</span>
        </div>
        <div style={{ fontSize: 12.5, color: DS.sub, marginTop: 3, lineHeight: 1.4 }}>{s.desc}</div>
        <div style={{ fontSize: 11, color: DS.sub, marginTop: 6, fontFamily: DS.mono }}>{s.tech}</div>
        {s.status !== 'queued' && (
          <div style={{ marginTop: 8 }}>
            <Progress value={s.progress} color={c} height={3}/>
          </div>
        )}
      </div>
    </div>
  );
}

Object.assign(window, { ScreenPipeline });
