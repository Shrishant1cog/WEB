/// Supabase Server-Side Client Configuration
/// For use in Server Components, Server Actions, and Route Handlers

import { createServerClient, type CookieOptions } from '@supabase/ssr';
import { cookies } from 'next/headers';
import type { Database } from '@/types/supabase';

// ============================================================================
// TYPE-SAFE DATABASE
// ============================================================================

// This is a placeholder - actual types are generated via `supabase gen types`
// See package.json script: `supabase:types`
export type TypedSupabaseClient = ReturnType<typeof createServerClient<Database>>;

// ============================================================================
// SERVER-SIDE CLIENT (Server Components, Server Actions, Route Handlers)
// ============================================================================

/**
 * Creates a Supabase client for use in Server Components and Server Actions.
 * Reads cookies from the request and writes cookies to the response.
 * Must be called in a server context (not client components).
 */
export async function createServerSupabaseClient() {
  const cookieStore = await cookies();

  return createServerClient<Database>(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!,
    {
      cookies: {
        get(name: string) {
          return cookieStore.get(name)?.value;
        },
        set(name: string, value: string, options: CookieOptions) {
          try {
            cookieStore.set({ name, value, ...options });
          } catch {
            // The `set` method was called from a Server Component.
            // This can be ignored if you have middleware refreshing user sessions.
          }
        },
        remove(name: string, options: CookieOptions) {
          try {
            cookieStore.set({ name, value: '', ...options });
          } catch {
            // The `delete` method was called from a Server Component.
            // This can be ignored if you have middleware refreshing user sessions.
          }
        },
      },
    }
  );
}

/**
 * Creates a Supabase client with service role key for administrative operations.
 * Only use in secure server-side contexts (API routes, Server Actions with auth checks).
 * NEVER expose this to the client.
 */
export function createServiceRoleClient() {
  return createServerClient<Database>(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.SUPABASE_SERVICE_ROLE_KEY!,
    {
      auth: {
        autoRefreshToken: false,
        persistSession: false,
      },
      cookies: {
        get() { return undefined; },
        set() {},
        remove() {},
      },
    }
  );
}

// ============================================================================
// HELPER FUNCTIONS (Server-side only)
// ============================================================================

/**
 * Get the current user on the server side.
 * Returns null if not authenticated.
 */
export async function getServerUser() {
  const supabase = await createServerSupabaseClient();
  const { data: { user } } = await supabase.auth.getUser();
  return user;
}

/**
 * Get the current session on the server side.
 * Returns null if no session.
 */
export async function getServerSession() {
  const supabase = await createServerSupabaseClient();
  const { data: { session } } = await supabase.auth.getSession();
  return session;
}