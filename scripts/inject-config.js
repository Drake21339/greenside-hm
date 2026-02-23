/**
 * Build-step script: write supabase/config.js from env vars.
 * Used on Vercel/Netlify so you never commit real keys.
 * Set SUPABASE_URL and SUPABASE_ANON_KEY in the host's dashboard.
 */
const fs = require('fs');
const path = require('path');

const dir = path.join(__dirname, '..', 'supabase');
const file = path.join(dir, 'config.js');

const url = process.env.SUPABASE_URL || '';
const key = process.env.SUPABASE_ANON_KEY || '';

const content = `// Generated at build time from env vars (do not commit real keys)
window.SUPABASE_URL = ${JSON.stringify(url)};
window.SUPABASE_ANON_KEY = ${JSON.stringify(key)};
`;

if (!fs.existsSync(dir)) fs.mkdirSync(dir, { recursive: true });
fs.writeFileSync(file, content, 'utf8');
console.log('Wrote supabase/config.js from env (SUPABASE_URL ' + (url ? 'set' : 'missing') + ', SUPABASE_ANON_KEY ' + (key ? 'set' : 'missing') + ')');
