// Outline icons — single weight, currentColor.
// All 24×24 viewBox unless noted, strokeWidth=1.6 for crispness at mobile sizes.

const Icon = ({ children, size = 22, stroke = 1.6, fill = 'none' }) => (
  <svg width={size} height={size} viewBox="0 0 24 24" fill={fill}
       stroke="currentColor" strokeWidth={stroke}
       strokeLinecap="round" strokeLinejoin="round">
    {children}
  </svg>
);

const IconSearch   = (p) => <Icon {...p}><circle cx="11" cy="11" r="7"/><path d="M20 20l-3.5-3.5"/></Icon>;
const IconClose    = (p) => <Icon {...p}><path d="M6 6l12 12M18 6L6 18"/></Icon>;
const IconBack     = (p) => <Icon {...p}><path d="M15 6l-6 6 6 6"/></Icon>;
const IconChevR    = (p) => <Icon {...p}><path d="M9 6l6 6-6 6"/></Icon>;
const IconChevD    = (p) => <Icon {...p}><path d="M6 9l6 6 6-6"/></Icon>;
const IconChevU    = (p) => <Icon {...p}><path d="M6 15l6-6 6 6"/></Icon>;
const IconPlus     = (p) => <Icon {...p}><path d="M12 5v14M5 12h14"/></Icon>;
const IconMore     = (p) => <Icon {...p}><circle cx="5" cy="12"  r="1.4" fill="currentColor" stroke="none"/><circle cx="12" cy="12" r="1.4" fill="currentColor" stroke="none"/><circle cx="19" cy="12" r="1.4" fill="currentColor" stroke="none"/></Icon>;
const IconPin      = (p) => <Icon {...p}><path d="M12 2v6l3 4v3H9v-3l3-4V2zM12 15v7"/></Icon>;
const IconHeart    = (p) => <Icon {...p}><path d="M12 20s-7-4.5-7-10a4 4 0 017-2.6A4 4 0 0119 10c0 5.5-7 10-7 10z"/></Icon>;
const IconHeartF   = (p) => <Icon {...p} fill="currentColor"><path d="M12 20s-7-4.5-7-10a4 4 0 017-2.6A4 4 0 0119 10c0 5.5-7 10-7 10z"/></Icon>;
const IconFolder   = (p) => <Icon {...p}><path d="M3 7a2 2 0 012-2h4l2 2h8a2 2 0 012 2v9a2 2 0 01-2 2H5a2 2 0 01-2-2V7z"/></Icon>;
const IconLock     = (p) => <Icon {...p}><rect x="5" y="11" width="14" height="9" rx="1.5"/><path d="M8 11V8a4 4 0 018 0v3"/></Icon>;
const IconUnlock   = (p) => <Icon {...p}><rect x="5" y="11" width="14" height="9" rx="1.5"/><path d="M8 11V8a4 4 0 017.5-2"/></Icon>;
const IconHome     = (p) => <Icon {...p}><path d="M4 11l8-7 8 7v9a1 1 0 01-1 1h-4v-7h-6v7H5a1 1 0 01-1-1v-9z"/></Icon>;
const IconHomeF    = (p) => <Icon {...p}><path d="M4 11l8-7 8 7v9a1 1 0 01-1 1h-4v-7h-6v7H5a1 1 0 01-1-1v-9z" fill="currentColor"/></Icon>;
const IconStack    = (p) => <Icon {...p}><rect x="3"  y="4"  width="18" height="5" rx="1"/><rect x="3"  y="11" width="18" height="5" rx="1"/><rect x="3"  y="18" width="18" height="3" rx="1"/></Icon>;
const IconSettings = (p) => <Icon {...p}><circle cx="12" cy="12" r="3"/><path d="M19.4 15a1.7 1.7 0 00.34 1.87l.06.06a2 2 0 11-2.83 2.83l-.06-.06a1.7 1.7 0 00-1.87-.34 1.7 1.7 0 00-1.03 1.56V21a2 2 0 11-4 0v-.09a1.7 1.7 0 00-1.11-1.56 1.7 1.7 0 00-1.87.34l-.06.06a2 2 0 11-2.83-2.83l.06-.06a1.7 1.7 0 00.34-1.87 1.7 1.7 0 00-1.56-1.03H3a2 2 0 110-4h.09A1.7 1.7 0 004.65 9a1.7 1.7 0 00-.34-1.87l-.06-.06a2 2 0 112.83-2.83l.06.06A1.7 1.7 0 009 4.65 1.7 1.7 0 0010.03 3.09V3a2 2 0 114 0v.09A1.7 1.7 0 0015 4.65a1.7 1.7 0 001.87-.34l.06-.06a2 2 0 112.83 2.83l-.06.06A1.7 1.7 0 0019.35 9a1.7 1.7 0 001.56 1.03H21a2 2 0 110 4h-.09a1.7 1.7 0 00-1.56 1.03z"/></Icon>;
const IconCamera   = (p) => <Icon {...p}><path d="M4 8a2 2 0 012-2h2l1.5-2h5L16 6h2a2 2 0 012 2v9a2 2 0 01-2 2H6a2 2 0 01-2-2V8z"/><circle cx="12" cy="13" r="3.5"/></Icon>;
const IconFile     = (p) => <Icon {...p}><path d="M7 3h7l5 5v12a2 2 0 01-2 2H7a2 2 0 01-2-2V5a2 2 0 012-2z"/><path d="M14 3v5h5"/></Icon>;
const IconUpload   = (p) => <Icon {...p}><path d="M12 16V4M7 9l5-5 5 5"/><path d="M5 20h14"/></Icon>;
const IconShare    = (p) => <Icon {...p}><path d="M4 12v7a1 1 0 001 1h14a1 1 0 001-1v-7"/><path d="M16 6l-4-4-4 4"/><path d="M12 2v13"/></Icon>;
const IconTrash    = (p) => <Icon {...p}><path d="M4 7h16"/><path d="M9 7V4h6v3"/><path d="M6 7l1 13a2 2 0 002 2h6a2 2 0 002-2l1-13"/></Icon>;
const IconRestore  = (p) => <Icon {...p}><path d="M3 12a9 9 0 109-9"/><path d="M3 3v6h6"/></Icon>;
const IconFilter   = (p) => <Icon {...p}><path d="M4 5h16M7 12h10M10 19h4"/></Icon>;
const IconSort     = (p) => <Icon {...p}><path d="M7 4v16M7 4l-3 3M7 4l3 3"/><path d="M17 20V4M17 20l-3-3M17 20l3-3"/></Icon>;
const IconFingerprint = (p) => <Icon {...p}><path d="M6 11a6 6 0 0112 0v3"/><path d="M9 14v2a3 3 0 005 2.2"/><path d="M12 11v5"/><path d="M15 15v1a4 4 0 01-1 2.5"/><path d="M9 8.5a4 4 0 016.5 1"/></Icon>;
const IconClock    = (p) => <Icon {...p}><circle cx="12" cy="12" r="9"/><path d="M12 7v5l3 2"/></Icon>;
const IconCalendar = (p) => <Icon {...p}><rect x="4" y="5" width="16" height="16" rx="2"/><path d="M4 9h16M9 3v4M15 3v4"/></Icon>;
const IconCheck    = (p) => <Icon {...p}><path d="M5 12l5 5L20 7"/></Icon>;
const IconDownload = (p) => <Icon {...p}><path d="M12 4v12M7 11l5 5 5-5"/><path d="M5 20h14"/></Icon>;
const IconPdf      = (p) => <Icon {...p}><path d="M7 3h7l5 5v12a2 2 0 01-2 2H7a2 2 0 01-2-2V5a2 2 0 012-2z"/><path d="M14 3v5h5"/></Icon>;
const IconWarning  = (p) => <Icon {...p}><path d="M12 4L2 21h20L12 4z"/><path d="M12 10v5M12 18v.5"/></Icon>;
const IconCloud    = (p) => <Icon {...p}><path d="M7 18a4 4 0 010-8 5 5 0 019.5-1.5A4 4 0 0117 18H7z"/></Icon>;
const IconUsers    = (p) => <Icon {...p}><circle cx="9" cy="8" r="3.5"/><path d="M3 20a6 6 0 0112 0"/><circle cx="17" cy="9" r="2.8"/><path d="M21 19a5 5 0 00-5-5"/></Icon>;
const IconBell     = (p) => <Icon {...p}><path d="M6 16V11a6 6 0 0112 0v5l1.5 2h-15L6 16z"/><path d="M10 20a2 2 0 004 0"/></Icon>;
const IconArrowR   = (p) => <Icon {...p}><path d="M5 12h14M13 6l6 6-6 6"/></Icon>;

Object.assign(window, {
  IconSearch, IconClose, IconBack, IconChevR, IconChevD, IconChevU,
  IconPlus, IconMore, IconPin, IconHeart, IconHeartF, IconFolder,
  IconLock, IconUnlock, IconHome, IconHomeF, IconStack, IconSettings,
  IconCamera, IconFile, IconUpload, IconShare, IconTrash, IconRestore,
  IconFilter, IconSort, IconFingerprint, IconClock, IconCalendar, IconCheck,
  IconDownload, IconPdf, IconWarning, IconCloud, IconUsers, IconBell, IconArrowR,
});
