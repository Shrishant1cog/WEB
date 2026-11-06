/// Supabase Client-Side Configuration
/// For use in Client Components only

import { createBrowserClient } from '@supabase/ssr';
import type { Database } from '@/types/supabase';

// ============================================================================
// CLIENT-SIDE CLIENT (Client Components)
// ============================================================================

let browserClient: ReturnType<typeof createBrowserClient<Database>> | null = null;

/**
 * Creates a Supabase client for use in Client Components.
 * Uses singleton pattern to avoid multiple instances.
 * Only use in client components (with 'use client' directive).
 */
export function createBrowserSupabaseClient() {
  if (typeof window === 'undefined') {
    throw new Error('createBrowserSupabaseClient can only be used in client components');
  }

  if (browserClient) return browserClient;

  browserClient = createBrowserClient<Database>(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!
  );

  return browserClient;
}

// ============================================================================
// HELPER FUNCTIONS (Client-side only)
// ============================================================================

/**
 * Get the current user on the client side.
 * Returns null if not authenticated.
 */
export async function getBrowserUser() {
  const supabase = createBrowserSupabaseClient();
  const { data: { user } } = await supabase.auth.getUser();
  return user;
}

/**
 * Get the current session on the client side.
 * Returns null if no session.
 */
export async function getBrowserSession() {
  const supabase = createBrowserSupabaseClient();
  const { data: { session } } = await supabase.auth.getSession();
  return session;
}