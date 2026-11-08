import Link from "next/link";
import { Button } from "@/components/ui/button";
import { signOutAction } from "@/lib/actions/auth";

/**
 * Shown in place of protected application content when the signed-in account
 * is suspended or banned. The database still enforces every restriction; this
 * only gives the user a clear explanation and a way out.
 */
export function AccountSuspendedNotice({ status }: { status: string }) {
  return (
    <div
      role="alert"
      className="mx-auto max-w-xl rounded-xl border border-destructive/30 bg-card p-8 text-center"
    >
      <div className="mx-auto flex h-16 w-16 items-center justify-center rounded-2xl bg-destructive/10 text-destructive">
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
            d="M12 15v2m-6 4h12a2 2 0 002-2v-6a2 2 0 00-2-2H6a2 2 0 00-2 2v6a2 2 0 002 2zm10-10V7a4 4 0 00-8 0v4h8z"
          />
        </svg>
      </div>
      <h1 className="mt-6 text-title-lg font-semibold text-foreground">
        Your account is {status === "banned" ? "banned" : "suspended"}
      </h1>
      <p className="mt-2 text-body-sm text-muted-foreground">
        Tournament registration, team management and reporting are unavailable while your account
        is restricted. The reason for this action is available in your notifications.
      </p>
      <div className="mt-6 flex flex-wrap justify-center gap-3">
        <Button asChild variant="outline" size="sm">
          <Link href="/notifications">View notifications</Link>
        </Button>
        <form action={signOutAction}>
          <Button type="submit" variant="ghost" size="sm">
            Sign out
          </Button>
        </form>
      </div>
    </div>
  );
}
