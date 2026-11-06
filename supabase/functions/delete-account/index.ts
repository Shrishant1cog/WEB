import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const supabaseUrl = Deno.env.get('SUPABASE_URL')!
    const supabaseServiceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
    
    const supabase = createClient(supabaseUrl, supabaseServiceKey, {
      auth: { persistSession: false }
    })

    const authHeader = req.headers.get('Authorization')!
    const token = authHeader.replace('Bearer ', '')

    const { data: { user }, error: authError } = await supabase.auth.getUser(token)
    
    if (authError || !user) {
      return new Response(
        JSON.stringify({ error: 'Unauthorized' }),
        { status: 401, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    const body = await req.json()
    const { password } = body

    // For OAuth users, require recent session (no password)
    // For email/password users, require password
    const isOAuthUser = user.app_metadata?.providers && user.app_metadata.providers.length > 0
    
    if (!isOAuthUser) {
      if (!password) {
        return new Response(
          JSON.stringify({ error: 'Password required for email/password accounts' }),
          { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
        )
      }

      // Verify password by attempting to sign in
      const { error: signInError } = await supabase.auth.signInWithPassword({
        email: user.email!,
        password: password
      })

      if (signInError) {
        return new Response(
          JSON.stringify({ error: 'Invalid password' }),
          { status: 401, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
        )
      }
    } else {
      // For OAuth users, verify recent authentication (session not older than 5 minutes)
      const { data: { session } } = await supabase.auth.getSession()
      if (!session) {
        return new Response(
          JSON.stringify({ error: 'Recent authentication required. Please sign in again.' }),
          { status: 401, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
        )
      }
      
      // Check session age
      const sessionAge = Date.now() - new Date(session.updated_at).getTime()
      if (sessionAge > 5 * 60 * 1000) { // 5 minutes
        return new Response(
          JSON.stringify({ error: 'Session too old. Please re-authenticate.' }),
          { status: 401, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
        )
      }
    }

    // Delete user's storage objects first (avatars, etc.)
    // This must happen before auth user deletion due to FK RESTRICT
    const { error: storageError } = await supabase.storage
      .from('avatars')
      .remove([`avatars/${user.id}`])
    
    // Also clean up tournament-assets and team-assets if user owns any
    // This is best-effort; main cleanup happens in DB trigger
    try {
      const { data: tournamentAssets } = await supabase.storage
        .from('tournament-assets')
        .list(`tournament-assets/${user.id}`)
      if (tournamentAssets && tournamentAssets.length > 0) {
        const files = tournamentAssets.map(f => `tournament-assets/${user.id}/${f.name}`)
        await supabase.storage.from('tournament-assets').remove(files)
      }
    } catch (e) {
      // Ignore errors for non-existent folders
    }

    try {
      const { data: teamAssets } = await supabase.storage
        .from('team-assets')
        .list(`team-assets/${user.id}`)
      if (teamAssets && teamAssets.length > 0) {
        const files = teamAssets.map(f => `team-assets/${user.id}/${f.name}`)
        await supabase.storage.from('team-assets').remove(files)
      }
    } catch (e) {
      // Ignore
    }

    // Delete user - this will trigger the profile soft-delete trigger
    const { error: deleteError } = await supabase.auth.admin.deleteUser(user.id)

    if (deleteError) {
      return new Response(
        JSON.stringify({ error: 'Failed to delete account' }),
        { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    return new Response(
      JSON.stringify({ success: true }),
      { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )
  } catch (error) {
    return new Response(
      JSON.stringify({ error: 'Internal server error' }),
      { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )
  }
})