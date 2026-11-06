import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

// Magic bytes for image validation
const JPEG_MAGIC = new Uint8Array([0xFF, 0xD8, 0xFF])
const PNG_MAGIC = new Uint8Array([0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A])
const WEBP_MAGIC = new Uint8Array([0x52, 0x49, 0x46, 0x46]) // RIFF header

function validateImageMagic(bytes: Uint8Array): { valid: boolean; type: string | null } {
  if (bytes.length < 12) return { valid: false, type: null }
  
  // Check JPEG
  if (bytes[0] === JPEG_MAGIC[0] && bytes[1] === JPEG_MAGIC[1] && bytes[2] === JPEG_MAGIC[2]) {
    return { valid: true, type: 'image/jpeg' }
  }
  
  // Check PNG
  if (bytes[0] === PNG_MAGIC[0] && bytes[1] === PNG_MAGIC[1] && 
      bytes[2] === PNG_MAGIC[2] && bytes[3] === PNG_MAGIC[3] &&
      bytes[4] === PNG_MAGIC[4] && bytes[5] === PNG_MAGIC[5] &&
      bytes[6] === PNG_MAGIC[6] && bytes[7] === PNG_MAGIC[7]) {
    return { valid: true, type: 'image/png' }
  }
  
  // Check WebP (RIFF + WEBP)
  if (bytes[0] === WEBP_MAGIC[0] && bytes[1] === WEBP_MAGIC[1] && 
      bytes[2] === WEBP_MAGIC[2] && bytes[3] === WEBP_MAGIC[3] &&
      bytes[8] === 0x57 && bytes[9] === 0x45 && bytes[10] === 0x42 && bytes[11] === 0x50) {
    return { valid: true, type: 'image/webp' }
  }
  
  return { valid: false, type: null }
}

function stripImageMetadata(bytes: Uint8Array, mimeType: string): Uint8Array {
  // For production, you'd use a proper image processing library
  // For now, we return the original bytes
  // In production, use a library like sharp or image-js to strip EXIF/metadata
  return bytes
}

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

const MAX_FILE_SIZE = 5 * 1024 * 1024 // 5MB
const ALLOWED_TYPES = ['image/jpeg', 'image/png', 'image/webp']

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

    const contentType = req.headers.get('Content-Type')
    if (!contentType?.startsWith('multipart/form-data')) {
      return new Response(
        JSON.stringify({ error: 'Content-Type must be multipart/form-data' }),
        { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    const formData = await req.formData()
    const file = formData.get('file')

    if (!file || !(file instanceof File)) {
      return new Response(
        JSON.stringify({ error: 'No file provided' }),
        { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    // Validate file type (MIME)
    if (!ALLOWED_TYPES.includes(file.type)) {
      return new Response(
        JSON.stringify({ error: 'Invalid file type. Must be JPEG, PNG, or WebP' }),
        { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    // Validate file size
    if (file.size > MAX_FILE_SIZE) {
      return new Response(
        JSON.stringify({ error: 'File size exceeds 5MB limit' }),
        { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    // Read file bytes for magic number validation
    const fileBytes = new Uint8Array(await file.arrayBuffer())
    
    // Validate magic bytes
    const magicValidation = validateImageMagic(fileBytes)
    if (!magicValidation.valid || magicValidation.type !== file.type) {
      return new Response(
        JSON.stringify({ error: 'File content does not match declared type' }),
        { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    // Strip metadata (EXIF, etc.)
    const cleanBytes = stripImageMetadata(fileBytes, file.type)

    // Generate unique filename
    const timestamp = Date.now()
    const random = crypto.randomUUID().replace(/-/g, '').substring(0, 8)
    const extension = file.type.split('/')[1]
    const filename = `avatars/${user.id}/${timestamp}_${random}.${extension}`

    // Upload to Supabase Storage
    const { data: uploadData, error: uploadError } = await supabase.storage
      .from('avatars')
      .upload(filename, cleanBytes, {
        cacheControl: '3600',
        upsert: false,
        contentType: file.type
      })

    if (uploadError) {
      return new Response(
        JSON.stringify({ error: uploadError.message }),
        { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    // Generate signed URL for private access (valid for 1 hour)
    const { data: signedUrlData, error: signedUrlError } = await supabase.storage
      .from('avatars')
      .createSignedUrl(uploadData.path, 3600)

    if (signedUrlError) {
      return new Response(
        JSON.stringify({ error: signedUrlError.message }),
        { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    // Update profile with new avatar URL (store the path, not the signed URL)
    const { error: profileError } = await supabase
      .from('profiles')
      .update({ avatar_url: uploadData.path, updated_at: new Date().toISOString() })
      .eq('id', user.id)

    if (profileError) {
      // Try to delete the uploaded file
      await supabase.storage.from('avatars').remove([uploadData.path])
      return new Response(
        JSON.stringify({ error: 'Failed to update profile' }),
        { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    return new Response(
      JSON.stringify({ avatarUrl: signedUrlData.signedUrl }),
      { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )
  } catch (error) {
    return new Response(
      JSON.stringify({ error: 'Internal server error' }),
      { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )
  }
})