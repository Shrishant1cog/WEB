"use client";

import { useState, useEffect } from "react";
import { useRouter, useSearchParams } from "next/navigation";
import { createBrowserSupabaseClient } from "@/lib/supabase/client";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Card, CardContent, CardDescription, CardFooter, CardHeader, CardTitle } from "@/components/ui/card";
import { AlertCircle, Mail, Loader2, CheckCircle, AlertCircle as AlertCircleIcon } from "lucide-react";

export default function VerifyEmailPage() {
  const router = useRouter();
  const searchParams = useSearchParams();
  const [email, setEmail] = useState("");
  const [loading, setLoading] = useState(false);
  const [message, setMessage] = useState<string | null>(null);
  const [error, setError] = useState<string | null>(null);
  const [resendCooldown, setResendCooldown] = useState(0);

  // Get email from URL params if provided
  useEffect(() => {
    const emailParam = searchParams.get("email");
    if (emailParam) {
      setEmail(emailParam);
    }
  }, [searchParams]);

  // Handle resend cooldown
  useEffect(() => {
    if (resendCooldown > 0) {
      const timer = setInterval(() => {
        setResendCooldown((prev) => prev - 1);
      }, 1000);
      return () => clearInterval(timer);
    }
  }, [resendCooldown]);

  const handleResend = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!email || resendCooldown > 0) return;

    setLoading(true);
    setError(null);
    setMessage(null);

    const supabase = createBrowserSupabaseClient();

    const { error } = await supabase.auth.resend({
      type: "signup",
      email,
      options: {
        emailRedirectTo: `${window.location.origin}/auth/callback`,
      },
    });

    if (error) {
      setError(error.message);
      setLoading(false);
      return;
    }

    setMessage("Verification email resent! Check your inbox.");
    setResendCooldown(60); // 60 second cooldown
    setLoading(false);
  };

  return (
    <div className="min-h-screen flex items-center justify-center bg-gray-50 py-12 px-4 sm:px-6 lg:px-8">
      <div className="max-w-md w-full space-y-8">
        <div>
          <h2 className="mt-6 text-center text-3xl font-extrabold text-gray-900">
            Verify your email
          </h2>
          <p className="mt-2 text-center text-sm text-gray-600">
            We've sent a verification link to
          </p>
          <p className="text-center text-sm font-medium text-indigo-600">{email || "your email"}</p>
        </div>

        <div className="bg-white px-4 py-8 shadow-md rounded-lg">
          <div className="text-center">
            <svg
              className="mx-auto h-12 w-12 text-indigo-600"
              fill="none"
              viewBox="0 0 24 24"
              stroke="currentColor"
              aria-hidden="true"
            >
              <path
                strokeLinecap="round"
                strokeLinejoin="round"
                strokeWidth={2}
                d="M3 8l7.89 5.26a2 2 0 002.22 0L21 8M5 19h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z"
              />
            </svg>
            <h3 className="mt-4 text-lg font-medium text-gray-900">Check your inbox</h3>
            <p className="mt-2 text-gray-600">
              Click the verification link in the email we sent you. The link expires in 24 hours.
            </p>
          </div>

          {message && (
            <div className="mt-6 flex items-center text-sm text-green-600">
              <CheckCircle className="mr-2 h-4 w-4" />
              {message}
            </div>
          )}

          {error && (
            <div className="mt-6 flex items-center text-sm text-red-600">
              <AlertCircleIcon className="mr-2 h-4 w-4" />
              {error}
            </div>
          )}

          <form onSubmit={handleResend} className="mt-8 space-y-6">
            <div className="rounded-md shadow-sm -space-y-px">
              <div>
                <Label htmlFor="email" className="sr-only">
                  Email address
                </Label>
                <div className="relative">
                  <Mail className="absolute left-3 top-1/2 -translate-y-1/2 h-5 w-5 text-gray-400" />
                  <Input
                    id="email"
                    name="email"
                    type="email"
                    autoComplete="email"
                    required
                    value={email}
                    onChange={(e) => setEmail(e.target.value)}
                    placeholder="Email address"
                    className="pl-10"
                    disabled={loading}
                  />
                </div>
              </div>
            </div>

            <div>
              <Button
                type="submit"
                disabled={loading || resendCooldown > 0 || !email}
                className="w-full"
              >
                {loading ? (
                  <>
                    <Loader2 className="mr-2 h-4 w-4 animate-spin" />
                    Sending...
                  </>
                ) : resendCooldown > 0 ? (
                  `Resend in ${resendCooldown}s`
                ) : (
                  "Resend verification email"
                )}
              </Button>
            </div>
          </form>

          <div className="mt-6">
            <p className="text-center text-sm text-gray-500">
              Didn't receive the email?{" "}
              <span className="font-medium text-indigo-600">Check your spam folder</span>
              {" or "}
              <button
                type="button"
                onClick={handleResend}
                disabled={resendCooldown > 0 || loading}
                className="font-medium text-indigo-600 hover:text-indigo-500 disabled:opacity-50"
              >
                resend
              </button>
            </p>
          </div>
        </div>

        <div className="text-center">
          <p className="text-sm text-gray-500">
            Wrong email?{" "}
            <a href="/register" className="font-medium text-indigo-600 hover:text-indigo-500">
              Sign up again
            </a>
          </p>
        </div>
      </div>
    </div>
  );
}