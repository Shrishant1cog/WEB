import { createClient } from "@supabase/supabase-js";

const url = process.env.SUPABASE_URL;
const serviceKey = process.env.SUPABASE_SERVICE_ROLE_KEY;

const admin = createClient(url, serviceKey, { auth: { persistSession: false } });

// Try calling submit_dispute directly with service role
const { data, error } = await admin.rpc('submit_dispute', {
  p_match_id: '00000000-0000-0000-0000-000000000000',
  p_registration_id: '00000000-0000-0000-0000-000000000000',
  p_reason: 'test',
  p_evidence_paths: []
});

console.log("submit_dispute result:", data, error?.message);