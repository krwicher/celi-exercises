import { createClient } from '@supabase/supabase-js';

import { PUBLIC_SUPABASE_URL, PUBLIC_SUPABASE_ANON_KEY } from '$env/static/public';

if (!PUBLIC_SUPABASE_URL) throw new Error('Missing PUBLIC_SUPABASE_URL');
if (!PUBLIC_SUPABASE_ANON_KEY) throw new Error('Missing PUBLIC_SUPABASE_ANON_KEY');

export const supabase = createClient(PUBLIC_SUPABASE_URL, PUBLIC_SUPABASE_ANON_KEY);