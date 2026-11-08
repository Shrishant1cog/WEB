"use client";

import { Button } from "@/components/ui/button";

/**
 * Shared recovery UI for Next.js error boundaries. Keeps route-level error
 * files small while presenting a consistent, accessible failure state.
 */
export function RouteError({
  error,
  reset,
  title = "Something went wrong",
}: {
  error: Error & { digest?: string };
  reset: () => void;
  title?: string;
}) {
  return (
    <div
      role="alert"
      className="mx-auto flex max-w-xl flex-col items-center justify-center rounded-xl border bg-card p-10 text-center"
    >
      <div className="flex h-16 w-16 items-center justify-center rounded-2xl bg-destructive/10 text-destructive">
        <svg
          className="h-8 w-8"
          fill="none"
          stroke="currentColor"
          viewBox="0 0 24 24"
          aria-hidden="true"
        >
          <path
            strokeLinecap="round"
            strokeLinejoin="round"
            strokeWidth={2}
            d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z"
          />
        </svg>
      </div>
      <h2 className="mt-6 text-title-lg font-semibold text-foreground">{title}</h2>
      <p className="mt-2 text-body-sm text-muted-foreground">
        {error.message && error.message !== "An error occurred in the Server Components render."
          ? error.message
          : "We could not load this page. Please try again."}
      </p>
      {error.digest && (
        <p className="mt-1 font-mono text-label-sm text-muted-foreground">Ref: {error.digest}</p>
      )}
      <Button onClick={reset} className="mt-6" variant="outline">
        Try again
      </Button>
    </div>
  );
}
