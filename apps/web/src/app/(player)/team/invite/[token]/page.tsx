import Link from "next/link";
import { requireUser } from "@/lib/auth/require-user";
import { acceptInvitationAction, declineInvitationAction } from "@/lib/actions/teams";
import { ActionForm } from "@/components/forms/action-form";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";

export const dynamic = "force-dynamic";

interface PageProps {
  params: Promise<{ token: string }>;
}

export default async function TeamInvitePage({ params }: PageProps) {
  const { token } = await params;
  await requireUser(`/team/invite/${token}`);

  return (
    <div className="mx-auto max-w-xl">
      <Card>
        <CardHeader>
          <CardTitle>Team invitation</CardTitle>
          <CardDescription>
            Accepting adds you to the team roster. Your consent is required and recorded.
          </CardDescription>
        </CardHeader>
        <CardContent className="space-y-5">
          <ActionForm
            action={acceptInvitationAction}
            submitLabel="Accept invitation"
            pendingLabel="Accepting…"
          >
            <input type="hidden" name="token" value={token} />
          </ActionForm>

          <ActionForm
            action={declineInvitationAction}
            submitLabel="Decline"
            pendingLabel="Declining…"
            variant="outline"
          >
            <input type="hidden" name="token" value={token} />
          </ActionForm>

          <Link href="/my-teams" className="block text-sm font-medium text-indigo-600 hover:underline">
            Back to my teams
          </Link>
        </CardContent>
      </Card>
    </div>
  );
}
