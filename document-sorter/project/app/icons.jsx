// icons.jsx — minimal stroke icons for Document Sorter
// All 24x24 viewBox, single stroke, color via prop

const Icon = ({ children, size = 22, color = 'currentColor', stroke = 1.6, fill = 'none' }) => (
  <svg width={size} height={size} viewBox="0 0 24 24" fill={fill} stroke={color}
    strokeWidth={stroke} strokeLinecap="round" strokeLinejoin="round">
    {children}
  </svg>
);

const IconScan = (p) => <Icon {...p}>
  <path d="M3 7V5a2 2 0 0 1 2-2h2"/><path d="M17 3h2a2 2 0 0 1 2 2v2"/>
  <path d="M21 17v2a2 2 0 0 1-2 2h-2"/><path d="M7 21H5a2 2 0 0 1-2-2v-2"/>
  <path d="M3 12h18"/>
</Icon>;

const IconFolder = (p) => <Icon {...p}>
  <path d="M3 7a2 2 0 0 1 2-2h4l2 2h8a2 2 0 0 1 2 2v8a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z"/>
</Icon>;

const IconFile = (p) => <Icon {...p}>
  <path d="M14 3H7a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h10a2 2 0 0 0 2-2V8z"/>
  <path d="M14 3v5h5"/>
</Icon>;

const IconUpload = (p) => <Icon {...p}>
  <path d="M21 15v3a3 3 0 0 1-3 3H6a3 3 0 0 1-3-3v-3"/>
  <path d="M7 9l5-5 5 5"/><path d="M12 4v12"/>
</Icon>;

const IconCheck = (p) => <Icon {...p}><path d="M4 12l5 5L20 6"/></Icon>;

const IconClose = (p) => <Icon {...p}><path d="M6 6l12 12M18 6L6 18"/></Icon>;

const IconChevronRight = (p) => <Icon {...p}><path d="M9 6l6 6-6 6"/></Icon>;
const IconChevronLeft = (p) => <Icon {...p}><path d="M15 6l-6 6 6 6"/></Icon>;
const IconChevronDown = (p) => <Icon {...p}><path d="M6 9l6 6 6-6"/></Icon>;
const IconArrowRight = (p) => <Icon {...p}><path d="M5 12h14M13 6l6 6-6 6"/></Icon>;

const IconSearch = (p) => <Icon {...p}>
  <circle cx="11" cy="11" r="7"/><path d="M20 20l-3.5-3.5"/>
</Icon>;

const IconSliders = (p) => <Icon {...p}>
  <path d="M4 6h10"/><path d="M18 6h2"/><circle cx="16" cy="6" r="2"/>
  <path d="M4 12h2"/><path d="M10 12h10"/><circle cx="8" cy="12" r="2"/>
  <path d="M4 18h12"/><path d="M20 18h0"/><circle cx="18" cy="18" r="2"/>
</Icon>;

const IconHome = (p) => <Icon {...p}>
  <path d="M4 11l8-7 8 7v9a2 2 0 0 1-2 2h-3v-6h-6v6H6a2 2 0 0 1-2-2z"/>
</Icon>;

const IconList = (p) => <Icon {...p}>
  <path d="M8 6h12"/><path d="M8 12h12"/><path d="M8 18h12"/>
  <circle cx="4" cy="6" r="0.8" fill="currentColor"/>
  <circle cx="4" cy="12" r="0.8" fill="currentColor"/>
  <circle cx="4" cy="18" r="0.8" fill="currentColor"/>
</Icon>;

const IconLayers = (p) => <Icon {...p}>
  <path d="M12 3l9 5-9 5-9-5z"/><path d="M3 13l9 5 9-5"/><path d="M3 18l9 5 9-5"/>
</Icon>;

const IconSettings = (p) => <Icon {...p}>
  <circle cx="12" cy="12" r="3"/>
  <path d="M19.4 15a1.7 1.7 0 0 0 .3 1.8l.1.1a2 2 0 1 1-2.8 2.8l-.1-.1a1.7 1.7 0 0 0-1.8-.3 1.7 1.7 0 0 0-1 1.5V21a2 2 0 1 1-4 0v-.1a1.7 1.7 0 0 0-1-1.5 1.7 1.7 0 0 0-1.8.3l-.1.1a2 2 0 1 1-2.8-2.8l.1-.1a1.7 1.7 0 0 0 .3-1.8 1.7 1.7 0 0 0-1.5-1H3a2 2 0 1 1 0-4h.1a1.7 1.7 0 0 0 1.5-1 1.7 1.7 0 0 0-.3-1.8l-.1-.1a2 2 0 1 1 2.8-2.8l.1.1a1.7 1.7 0 0 0 1.8.3h0a1.7 1.7 0 0 0 1-1.5V3a2 2 0 1 1 4 0v.1a1.7 1.7 0 0 0 1 1.5 1.7 1.7 0 0 0 1.8-.3l.1-.1a2 2 0 1 1 2.8 2.8l-.1.1a1.7 1.7 0 0 0-.3 1.8v0a1.7 1.7 0 0 0 1.5 1H21a2 2 0 1 1 0 4h-.1a1.7 1.7 0 0 0-1.5 1z"/>
</Icon>;

const IconWifi = (p) => <Icon {...p}>
  <path d="M5 12.5a10 10 0 0 1 14 0"/>
  <path d="M8.5 16a5 5 0 0 1 7 0"/>
  <circle cx="12" cy="19.5" r="0.8" fill="currentColor"/>
</Icon>;

const IconLaptop = (p) => <Icon {...p}>
  <rect x="3" y="5" width="18" height="11" rx="2"/>
  <path d="M2 19h20"/>
</Icon>;

const IconPhone = (p) => <Icon {...p}>
  <rect x="7" y="2" width="10" height="20" rx="2"/>
  <path d="M11 18h2"/>
</Icon>;

const IconShield = (p) => <Icon {...p}>
  <path d="M12 3l8 3v6c0 5-3.5 8.5-8 9-4.5-.5-8-4-8-9V6z"/>
</Icon>;

const IconTrash = (p) => <Icon {...p}>
  <path d="M3 6h18"/><path d="M8 6V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"/>
  <path d="M19 6l-1 14a2 2 0 0 1-2 2H8a2 2 0 0 1-2-2L5 6"/>
</Icon>;

const IconPause = (p) => <Icon {...p}>
  <rect x="6" y="5" width="4" height="14" rx="1"/>
  <rect x="14" y="5" width="4" height="14" rx="1"/>
</Icon>;

const IconRefresh = (p) => <Icon {...p}>
  <path d="M21 12a9 9 0 1 1-3-6.7"/><path d="M21 4v5h-5"/>
</Icon>;

const IconAlert = (p) => <Icon {...p}>
  <path d="M12 9v4"/><circle cx="12" cy="17" r="0.6" fill="currentColor"/>
  <path d="M10.3 3.9 2.6 17.5A2 2 0 0 0 4.4 20.5h15.2a2 2 0 0 0 1.7-3L13.7 3.9a2 2 0 0 0-3.4 0z"/>
</Icon>;

const IconLink = (p) => <Icon {...p}>
  <path d="M10 14a5 5 0 0 0 7 0l3-3a5 5 0 0 0-7-7l-1 1"/>
  <path d="M14 10a5 5 0 0 0-7 0l-3 3a5 5 0 0 0 7 7l1-1"/>
</Icon>;

Object.assign(window, {
  IconScan, IconFolder, IconFile, IconUpload, IconCheck, IconClose,
  IconChevronRight, IconChevronLeft, IconChevronDown, IconArrowRight,
  IconSearch, IconSliders, IconHome, IconList, IconLayers, IconSettings,
  IconWifi, IconLaptop, IconPhone, IconShield, IconTrash, IconPause,
  IconRefresh, IconAlert, IconLink,
});
