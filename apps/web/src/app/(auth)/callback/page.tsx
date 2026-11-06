"use client";

import { Suspense, useEffect, useState } from "react";
import Link from "next/link";
import { useRouter, useSearchParams } from "next/navigation";
import { createBrowserSupabaseClient } from "@/lib/supabase/browser-client";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";

function CallbackInner() {
  const router = useRouter();
  const searchParams = useSearchParams();
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    let cancelled = false;

    async function handle() {
      const code = searchParams.get("code");
      const next = searchParams.get("next") || "/dashboard";

      if (!code) {
        setError("This verification link is missing its code. Request a new email.");
        return;
      }

      const supabase = createBrowserSupabaseClient();
      const { error: exchangeError } = await supabase.auth.exchangeCodeForSession(code);
      if (cancelled) return;

      if (exchangeError) {
        setError(exchangeError.message);
        return;
      }

      router.replace(next);
      router.refresh();
    }

    handle();
    return () => {
      cancelled = true;
    };
  }, [router, searchParams]);

  return (
    <div className="flex min-h-screen items-center justify-center px-4 py-12">
      <Card className="w-full max-w-md">
        <CardHeader>
          <CardTitle>{error ? "Verification failed" : "Completing sign in"}</CardTitle>
          <CardDescription>
            {error ?? "Please wait while we activate your session."}
          </CardDescription>
        </CardHeader>
        <CardContent>
          {error ? (
            <div className="space-y-3 text-sm">
              <Link href="/verify-email" className="block font-medium text-indigo-600 hover:underline">
                Request a new verification email
              </Link>
              <Link href="/login" className="block font-medium text-indigo-600 hover:underline">
                Back to sign in
              </Link>
            </div>
          ) : (
            <p className="text-sm text-gray-600">Verifying…</p>
          )}
        </CardContent>
      </Card>
    </div>
  );
}

export default function CallbackPage() {
  return (
    <Suspense fallback={<div className="p-12 text-center text-sm text-gray-600">Loading…</div>}>
      <CallbackInner />
    </Suspense>
  );
}
