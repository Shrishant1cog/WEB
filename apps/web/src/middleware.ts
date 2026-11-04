/// Next.js Middleware for Authentication
/// Protects routes and refreshes sessions

import { createServerClient } from '@supabase/ssr';
import { NextResponse, type NextRequest } from 'next/server';

export async function middleware(request: NextRequest) {
  let supabaseResponse = NextResponse.next({
    request,
  });

  const supabase = createServerClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!,
    {
      cookies: {
        getAll() {
          return request.cookies.getAll();
        },
        setAll(cookiesToSet) {
          cookiesToSet.forEach(({ name, value, options }) =>
            request.cookies.set(name, value)
          );
          supabaseResponse = NextResponse.next({
            request,
          });
          cookiesToSet.forEach(({ name, value, options }) =>
            supabaseResponse.cookies.set(name, value, options)
          );
        },
      },
    }
  );

  // Refresh session if expired - required for Server Components
  const { data: { user } } = await supabase.auth.getUser();

  // Route protection logic
  const pathname = request.nextUrl.pathname;

  // Public routes that don't require authentication
  const publicPaths = [
    '/',
    '/tournaments',
    '/tournaments/',
    '/privacy',
    '/terms',
    '/support',
    '/account-deletion',
    '/login',
    '/register',
    '/password-reset',
    '/password-reset/confirm',
    '/email-verify',
  ];

  const isPublicPath = publicPaths.some(path => 
    pathname === path || pathname.startsWith(path + '/')
  );

  // Auth routes - redirect authenticated users away
  const authPaths = ['/login', '/register', '/password-reset', '/password-reset/confirm'];
  const isAuthPath = authPaths.some(path => pathname.startsWith(path));

  // Protected route prefixes
  const protectedPrefixes = [
    '/profile',
    '/my-tournaments',
    '/my-teams',
    '/teams/create',
    '/matches',
    '/results',
    '/notifications',
    '/settings',
  ];
  const isProtectedPath = protectedPrefixes.some(prefix => pathname.startsWith(prefix));

  // Organizer route prefixes
  const organizerPrefixes = [
    '/organizer',
  ];
  const isOrganizerPath = organizerPrefixes.some(prefix => pathname.startsWith(prefix));

  // Admin route prefixes
  const adminPrefixes = [
    '/admin',
  ];
  const isAdminPath = adminPrefixes.some(prefix => pathname.startsWith(prefix));

  // Redirect logic
  if (isAuthPath && user) {
    // Authenticated user trying to access auth pages -> redirect to home
    return NextResponse.redirect(new URL('/', request.url));
  }

  if ((isProtectedPath || isOrganizerPath || isAdminPath) && !user) {
    // Unauthenticated user trying to access protected pages -> redirect to login
    const redirectUrl = new URL('/login', request.url);
    redirectUrl.searchParams.set('redirect', pathname);
    return NextResponse.redirect(redirectUrl);
  }

  // Organizer/Admin role checks would go here
  // For now, we just check authentication; role checks happen in Server Components/Actions

  return supabaseResponse;
}

export const config = {
  matcher: [
    /*
     * Match all request paths except for the ones starting with:
     * - _next/static (static files)
     * - _next/image (image optimization files)
     * - favicon.ico (favicon file)
     * - public folder
     */
    '/((?!_next/static|_next/image|favicon.ico|.*\\.(?:svg|png|jpg|jpeg|gif|webp)$).*)',
  ],
};