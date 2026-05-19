// Sample data for DocVault prototype — Indian context

window.SAMPLE_PROFILES = [
  { id: 'p1', name: 'Smit',   color: '#0E0E10', initials: 'S' },
  { id: 'p2', name: 'Papa',   color: '#3F4A5C', initials: 'P' },
  { id: 'p3', name: 'Mummy',  color: '#7A5A3E', initials: 'M' },
  { id: 'p4', name: 'Krishna', color: '#D17B47', initials: 'K' },
];

window.SAMPLE_CATEGORIES = [
  { id: 'all',       name: 'All',         count: 47 },
  { id: 'ids',       name: 'Personal IDs', count: 8  },
  { id: 'education', name: 'Education',   count: 14 },
  { id: 'medical',   name: 'Medical',     count: 6  },
  { id: 'financial', name: 'Financial',   count: 11 },
  { id: 'property',  name: 'Property',    count: 3  },
  { id: 'receipts',  name: 'Receipts',    count: 5  },
];

window.SAMPLE_COLLECTIONS = [
  { id: 'c1', name: 'College Results',      category: 'Education', count: 8, locked: false },
  { id: 'c2', name: 'GTU Marksheets',        category: 'Education', count: 6, locked: false },
  { id: 'c3', name: 'Fee Receipts',          category: 'Education', count: 5, locked: false },
  { id: 'c4', name: 'Family IDs',            category: 'Personal IDs', count: 12, locked: true  },
  { id: 'c5', name: 'Insurance Papers',      category: 'Financial', count: 4, locked: true  },
  { id: 'c6', name: 'Property Documents',    category: 'Property',  count: 3, locked: true  },
  { id: 'c7', name: 'Prescriptions',         category: 'Medical',   count: 9, locked: false },
];

// Document entries. tier: 'pinned' | 'loved' | 'other'
// type: 'pdf' | 'jpg' | 'png'
window.SAMPLE_DOCS = [
  // Pinned
  { id: 'd1',  name: 'Aadhaar Card',        category: 'Personal IDs', type: 'pdf', size: '1.2 MB',
    uploaded: 'Jul 21, 2025', tier: 'pinned', pinOrder: 1, expiry: null, expired: false, collection: 'Family IDs' },
  { id: 'd2',  name: 'PAN Card',            category: 'Personal IDs', type: 'jpg', size: '420 KB',
    uploaded: 'Jul 21, 2025', tier: 'pinned', pinOrder: 2, expiry: null, expired: false, collection: 'Family IDs' },
  { id: 'd3',  name: 'Driving License',     category: 'Personal IDs', type: 'pdf', size: '880 KB',
    uploaded: 'Mar 04, 2025', tier: 'pinned', pinOrder: 3, expiry: 'Jun 12, 2026', expired: false },

  // Loved
  { id: 'd4',  name: 'GTU Sem 6 Result',    category: 'Education',    type: 'pdf', size: '640 KB',
    uploaded: 'May 18, 2025', tier: 'loved', expiry: null, expired: false, collection: 'GTU Marksheets' },
  { id: 'd5',  name: 'Internship Offer Letter', category: 'Education', type: 'pdf', size: '320 KB',
    uploaded: 'Jun 02, 2025', tier: 'loved', expiry: null, expired: false },
  { id: 'd6',  name: 'Health Insurance Card', category: 'Medical',    type: 'jpg', size: '510 KB',
    uploaded: 'Apr 11, 2025', tier: 'loved', expiry: 'Aug 30, 2026', expired: false },
  { id: 'd7',  name: 'Bank Passbook',       category: 'Financial',    type: 'pdf', size: '1.4 MB',
    uploaded: 'Feb 14, 2025', tier: 'loved', expiry: null, expired: false },

  // Other
  { id: 'd8',  name: 'Electricity Bill — May',  category: 'Receipts', type: 'pdf', size: '220 KB',
    uploaded: 'May 06, 2025', tier: 'other', expiry: 'Jun 05, 2025', expired: true },
  { id: 'd9',  name: 'Resume v3',           category: 'Education',    type: 'pdf', size: '180 KB',
    uploaded: 'Jul 09, 2025', tier: 'other', expiry: null, expired: false },
  { id: 'd10', name: 'Rent Agreement',      category: 'Property',     type: 'pdf', size: '2.1 MB',
    uploaded: 'Jan 15, 2025', tier: 'other', expiry: 'Jan 14, 2027', expired: false, collection: 'Property Documents' },
  { id: 'd11', name: 'Vehicle RC Book',     category: 'Personal IDs', type: 'jpg', size: '710 KB',
    uploaded: 'Nov 22, 2024', tier: 'other', expiry: null, expired: false },
  { id: 'd12', name: 'LIC Policy Bond',     category: 'Financial',    type: 'pdf', size: '3.2 MB',
    uploaded: 'Oct 08, 2024', tier: 'other', expiry: 'Mar 18, 2029', expired: false, collection: 'Insurance Papers' },
  { id: 'd13', name: 'Class 12 Marksheet',  category: 'Education',    type: 'pdf', size: '450 KB',
    uploaded: 'Aug 30, 2024', tier: 'other', expiry: null, expired: false },
  { id: 'd14', name: 'COVID Vaccine Cert',  category: 'Medical',      type: 'pdf', size: '110 KB',
    uploaded: 'Jul 12, 2024', tier: 'other', expiry: null, expired: false },
  { id: 'd15', name: 'Voter ID',            category: 'Personal IDs', type: 'jpg', size: '380 KB',
    uploaded: 'Mar 27, 2024', tier: 'other', expiry: null, expired: false },
];

window.RECYCLE_BIN = [
  { id: 'r1', name: 'Old Resume v2',        type: 'pdf', deleted: '3 days ago',  expiresIn: '4 days left'  },
  { id: 'r2', name: 'Scan_20250612.jpg',    type: 'jpg', deleted: '5 days ago',  expiresIn: '2 days left'  },
  { id: 'r3', name: 'Receipt_Big Bazaar',   type: 'jpg', deleted: '1 week ago',  expiresIn: 'Expires today'},
];
