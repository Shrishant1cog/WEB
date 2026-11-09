import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'
import { createRemoteJWKSet, jwtVerify } from 'https://esm.sh/jose@5.2.0'

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

// JWKS for Supabase JWT verification (cached)
let jwks: ReturnType<typeof createRemoteJWKSet> | null = null

function getJWKS(): ReturnType<typeof createRemoteJWKSet> {
  if (!jwks) {
    const supabaseUrl = Deno.env.get('SUPABASE_URL')!
    jwks = createRemoteJWKSet(new URL(`${supabaseUrl}/auth/v1/.well-known/jwks.json`))
  }
  return jwks
}

async function verifyWorkerJWT(authHeader: string): Promise<boolean> {
  const token = authHeader?.replace('Bearer ', '')
  
  if (!token) return false
  
  try {
    // Verify the JWT using Supabase's JWKS (which contains the public key for service_role tokens)
    // The Supabase service_role key is a JWT signed by Supabase's private key.
    // We accept the service_role key's default audience (typically 'authenticated' or project ref)
    // since the key itself proves it's a service_role token issued by Supabase.
    const { payload } = await jwtVerify(token, getJWKS(), {
      issuer: `${Deno.env.get('SUPABASE_URL')}/auth/v1`,
      // Accept the service_role key's default audience (typically 'authenticated' or project ref)
      // The key itself proves it's a service_role token issued by Supabase.
      // We don't enforce a specific audience; the role claim is the authorization.
    })
    
    // Verify this is a service_role token with the correct role claim
    return payload.role === 'service_role'
  } catch (err) {
    console.error('JWT verification failed:', err)
    return false
  }
}

async function getFCMAccessToken(): Promise<string | null> {
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

  // Verify Supabase gateway JWT (service_role from Supabase)
  const authHeader = req.headers.get('Authorization')
  if (!(await verifyWorkerJWT(authHeader))) {
    return new Response(
      JSON.stringify({ error: 'Unauthorized: invalid or missing worker JWT' }),
      { status: 401, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )
  }

  const supabaseUrl = Deno.env.get('SUPABASE_URL')!
  const supabaseServiceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
  
  const supabase = createClient(supabaseUrl, supabaseServiceKey, {
    auth: { persistSession: false },
  })

  try {
    const accessToken = await getFCMAccessToken()
    if (!accessToken) {
      return new Response(
        JSON.stringify({ error: 'FCM credentials not configured' }),
        { status: 503, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    // Claim up to 50 deliveries (one row per device)
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
        await supabase.rpc('complete_notification_delivery', {
          p_queue_id: item.queue_id,
          p_success: false,
          p_error: result.error,
        })
        failed++
        permanentFail++
      } else {
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