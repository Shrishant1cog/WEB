import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

interface DeliveryItem {
  queue_id: string
  notification_id: string
  user_id: string
  token: string
  title: string
  body: string
  data: Record<string, unknown>
  attempts: number
  category: string
}

interface FCMMessage {
  message: {
    token: string
    notification: {
      title: string
      body: string
    }
    data: Record<string, string>
    android: {
      priority: 'high'
      notification: {
        channel_id: string
        icon: string
        color: string
      }
    }
    apns: {
      payload: {
        aps: {
          sound: string
          badge: number
        }
      }
    }
    webpush: {
      headers: {
        Urgency: string
      }
    }
  }
}

async function getFCMAccessToken(): Promise<string | null> {
  // Use Firebase Admin SDK service account credentials from secrets
  const projectId = Deno.env.get('FIREBASE_PROJECT_ID')
  const clientEmail = Deno.env.get('FIREBASE_CLIENT_EMAIL')
  const privateKey = Deno.env.get('FIREBASE_PRIVATE_KEY')

  if (!projectId || !clientEmail || !privateKey) {
    console.error('FCM credentials not configured')
    return null
  }

  const now = Math.floor(Date.now() / 1000)
  const header = { alg: 'RS256', typ: 'JWT' }
  const claim = {
    iss: clientEmail,
    scope: 'https://www.googleapis.com/auth/firebase.messaging',
    aud: 'https://oauth2.googleapis.com/token',
    exp: now + 3600,
    iat: now,
  }

  const encoder = new TextEncoder()
  const headerB64 = btoa(JSON.stringify(header)).replace(/=/g, '').replace(/\+/g, '-').replace(/\//g, '_')
  const claimB64 = btoa(JSON.stringify(claim)).replace(/=/g, '').replace(/\+/g, '-').replace(/\//g, '_')
  const signingInput = `${headerB64}.${claimB64}`

  // Import private key for signing
  const pkcs8 = privateKey
    .replace('-----BEGIN PRIVATE KEY-----', '')
    .replace('-----END PRIVATE KEY-----', '')
    .replace(/\n/g, '')
  const binaryKey = Uint8Array.from(atob(pkcs8), c => c.charCodeAt(0))
  
  const cryptoKey = await crypto.subtle.importKey(
    'pkcs8',
    binaryKey,
    { name: 'RSASSA-PKCS1-v1_5', hash: 'SHA-256' },
    false,
    ['sign']
  )
  
  const signature = await crypto.subtle.sign('RSASSA-PKCS1-v1_5', cryptoKey, encoder.encode(signingInput))
  const signatureB64 = btoa(String.fromCharCode(...new Uint8Array(signature)))
    .replace(/=/g, '').replace(/\+/g, '-').replace(/\//g, '_')
  
  const jwt = `${signingInput}.${signatureB64}`

  // Exchange JWT for access token
  const tokenResp = await fetch('https://oauth2.googleapis.com/token', {
    method: 'POST',
    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
    body: new URLSearchParams({
      grant_type: 'urn:ietf:params:oauth:grant-type:jwt-bearer',
      assertion: jwt,
    }),
  })

  if (!tokenResp.ok) {
    const err = await tokenResp.text()
    console.error('Failed to get FCM access token:', err)
    return null
  }

  const tokenData = await tokenResp.json()
  return tokenData.access_token
}

async function sendFCMMessage(accessToken: string, item: DeliveryItem): Promise<{ success: boolean; error?: string }> {
  const projectId = Deno.env.get('FIREBASE_PROJECT_ID')
  if (!projectId) return { success: false, error: 'FIREBASE_PROJECT_ID not set' }

  const message: FCMMessage = {
    message: {
      token: item.token,
      notification: {
        title: item.title,
        body: item.body || '',
      },
      data: Object.fromEntries(
        Object.entries(item.data).map(([k, v]) => [k, String(v)])
      ),
      android: {
        priority: 'high',
        notification: {
          channel_id: 'fft_notifications',
          icon: 'ic_notification',
          color: '#E58E26',
        },
      },
      apns: {
        payload: {
          aps: {
            sound: 'default',
            badge: 1,
          },
        },
      },
      webpush: {
        headers: { Urgency: 'high' },
      },
    },
  }

  const resp = await fetch(
    `https://fcm.googleapis.com/v1/projects/${projectId}/messages:send`,
    {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${accessToken}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify(message),
    }
  )

  if (!resp.ok) {
    const err = await resp.json()
    const errorMsg = err.error?.message || `HTTP ${resp.status}`
    
    // Check for permanently invalid token
    if (resp.status === 404 || 
        errorMsg.includes('UNREGISTERED') || 
        errorMsg.includes('INVALID_ARGUMENT')) {
      return { success: false, error: `PERMANENT: ${errorMsg}` }
    }
    
    return { success: false, error: errorMsg }
  }

  return { success: true }
}

serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  // Verify this is a legitimate cron/internal call
  const authHeader = req.headers.get('Authorization')
  const cronSecret = Deno.env.get('FCM_WORKER_CRON_SECRET')
  
  if (!cronSecret || authHeader !== `Bearer ${cronSecret}`) {
    return new Response(
      JSON.stringify({ error: 'Unauthorized' }),
      { status: 401, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )
  }

  const supabaseUrl = Deno.env.get('SUPABASE_URL')!
  const supabaseServiceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
  
  const supabase = createClient(supabaseUrl, supabaseServiceKey, {
    auth: { persistSession: false },
  })

  try {
    // Get FCM access token once per batch
    const accessToken = await getFCMAccessToken()
    if (!accessToken) {
      return new Response(
        JSON.stringify({ error: 'FCM credentials not configured' }),
        { status: 503, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    // Claim up to 50 deliveries
    const { data: claimed, error: claimError } = await supabase.rpc(
      'claim_notification_delivery',
      { p_limit: 50 }
    )

    if (claimError) {
      console.error('Claim error:', claimError)
      return new Response(
        JSON.stringify({ error: 'Failed to claim deliveries' }),
        { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    if (!claimed || claimed.length === 0) {
      return new Response(
        JSON.stringify({ processed: 0, message: 'No pending deliveries' }),
        { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    let sent = 0
    let failed = 0
    let permanentFail = 0

    for (const item of claimed as DeliveryItem[]) {
      const result = await sendFCMMessage(accessToken, item)
      
      if (result.success) {
        await supabase.rpc('complete_notification_delivery', {
          p_queue_id: item.queue_id,
          p_success: true,
          p_error: null,
        })
        sent++
      } else if (result.error?.startsWith('PERMANENT:')) {
        // Mark as dead immediately for permanent failures (invalid token, etc.)
        await supabase.rpc('complete_notification_delivery', {
          p_queue_id: item.queue_id,
          p_success: false,
          p_error: result.error,
        })
        failed++
        permanentFail++
      } else {
        // Transient failure - will be retried with backoff
        await supabase.rpc('complete_notification_delivery', {
          p_queue_id: item.queue_id,
          p_success: false,
          p_error: result.error,
        })
        failed++
      }
    }

    return new Response(
      JSON.stringify({ 
        processed: claimed.length,
        sent,
        failed,
        permanentFailures: permanentFail,
      }),
      { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )
  } catch (error) {
    console.error('FCM worker error:', error)
    return new Response(
      JSON.stringify({ error: 'Internal server error' }),
      { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )
  }
})