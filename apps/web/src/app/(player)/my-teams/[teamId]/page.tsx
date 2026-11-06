import Link from "next/link";
import { notFound } from "next/navigation";
import { requireUser } from "@/lib/auth/require-user";
import { getTeamDetail } from "@/lib/data/tournaments";
import {
  dissolveTeamAction,
  leaveTeamAction,
  removeTeamMemberAction,
  revokeInvitationAction,
  transferCaptaincyAction,
} from "@/lib/actions/teams";
import { ActionForm } from "@/components/forms/action-form";
import { InviteForm } from "@/components/team/invite-form";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { formatDate } from "@/components/tournament/status-badge";

export const dynamic = "force-dynamic";

interface PageProps {
  params: Promise<{ teamId: string }>;
}

export default async function TeamDetailPage({ params }: PageProps) {
  const { teamId } = await params;
  const { user } = await requireUser(`/my-teams/${teamId}`);
  const team = await getTeamDetail(teamId, user.id);
  if (!team) notFound();

  const isMember = team.members.some((member) => member.user_id === user.id);
  const otherMembers = team.members.filter((member) => member.user_id !== user.id);
  const rosterComplete = team.members.length;

  return (
    <div className="space-y-6">
      <div className="flex flex-col justify-between gap-3 sm:flex-row sm:items-start">
        <div>
          <h1 className="text-3xl font-bold text-gray-900">{team.name}</h1>
          <p className="mt-1 text-sm text-gray-600">
            {team.tag ? `[${team.tag}] · ` : ""}
            {rosterComplete}/{team.max_members} members
            {team.isCaptain ? " · You are the captain" : ""}
          </p>
          {team.description && <p className="mt-2 text-sm text-gray-700">{team.description}</p>}
        </div>
        <Link href="/my-teams" className="text-sm font-medium text-indigo-600 hover:underline">
          Back to teams
        </Link>
      </div>

      <Card>
        <CardHeader>
          <CardTitle>Roster</CardTitle>
        </CardHeader>
        <CardContent className="space-y-3">
          {team.members.map((member) => (
            <div
              key={member.user_id}
              className="flex flex-wrap items-center justify-between gap-2 rounded-md border p-3 text-sm"
            >
              <div>
                <p className="font-medium text-gray-900">
                  {member.profile?.display_name ?? "Player"}
                  {member.user_id === user.id ? " (you)" : ""}
                </p>
                <p className="text-xs text-gray-500">
                  {member.role === "owner" || member.role === "captain" ? "Captain" : "Member"}
                  {member.profile?.in_game_name
                    ? ` · ${member.profile.in_game_name}`
                    : ""}
                  {member.profile?.in_game_uid ? ` · UID ${member.profile.in_game_uid}` : ""}
                </p>
              </div>
              {team.isCaptain && member.user_id !== user.id && (
                <ActionForm
                  action={removeTeamMemberAction}
                  submitLabel="Remove"
                  pendingLabel="Removing…"
                  variant="outline"
                  size="sm"
                  confirmMessage={`Remove ${member.profile?.display_name ?? "this player"} from the team?`}
                >
                  <input type="hidden" name="teamId" value={team.id} />
                  <input type="hidden" name="userId" value={member.user_id} />
                </ActionForm>
              )}
            </div>
          ))}
        </CardContent>
      </Card>

      {team.isCaptain && (
        <>
          <Card>
            <CardHeader>
              <CardTitle>Invite a player</CardTitle>
            </CardHeader>
            <CardContent>
              <InviteForm teamId={team.id} />
            </CardContent>
          </Card>

          {team.invitations.length > 0 && (
            <Card>
              <CardHeader>
                <CardTitle>Pending invitations</CardTitle>
              </CardHeader>
              <CardContent className="space-y-3">
                {team.invitations.map((invitation) => (
                  <div
                    key={invitation.id}
                    className="flex flex-wrap items-center justify-between gap-2 rounded-md border p-3 text-sm"
                  >
                    <div>
                      <p className="font-medium text-gray-900">
                        {invitation.email ?? invitation.invited_user_id}
                      </p>
                      <p className="text-xs text-gray-500">
                        Expires {formatDate(invitation.expires_at)}
                      </p>
                    </div>
                    <ActionForm
                      action={revokeInvitationAction}
                      submitLabel="Revoke"
                      pendingLabel="Revoking…"
                      variant="outline"
                      size="sm"
                    >
                      <input type="hidden" name="invitationId" value={invitation.id} />
                      <input type="hidden" name="teamId" value={team.id} />
                    </ActionForm>
                  </div>
                ))}
              </CardContent>
            </Card>
          )}

          {otherMembers.length > 0 && (
            <Card>
              <CardHeader>
                <CardTitle>Transfer captaincy</CardTitle>
              </CardHeader>
              <CardContent>
                <ActionForm
                  action={transferCaptaincyAction}
                  submitLabel="Transfer captaincy"
                  pendingLabel="Transferring…"
                  variant="outline"
                  confirmMessage="Transfer captaincy? You will become a regular member."
                >
                  <input type="hidden" name="teamId" value={team.id} />
                  <label htmlFor="newCaptain" className="text-sm font-medium text-gray-700">
                    New captain
                  </label>
                  <select
                    id="newCaptain"
                    name="newCaptain"
                    required
                    defaultValue=""
                    className="mt-1 w-full rounded-md border border-gray-300 bg-white px-3 py-2 text-sm"
                  >
                    <option value="" disabled>
                      Select a member
                    </option>
                    {otherMembers.map((member) => (
                      <option key={member.user_id} value={member.user_id}>
                        {member.profile?.display_name ?? member.user_id}
                      </option>
                    ))}
                  </select>
                </ActionForm>
              </CardContent>
            </Card>
          )}
        </>
      )}

      {isMember && (
        <div className="flex flex-col gap-3 sm:flex-row">
          <ActionForm
            action={leaveTeamAction}
            submitLabel="Leave team"
            pendingLabel="Leaving…"
            variant="outline"
            confirmMessage="Leave this team?"
          >
            <input type="hidden" name="teamId" value={team.id} />
          </ActionForm>
          {team.isCaptain && (
            <ActionForm
              action={dissolveTeamAction}
              submitLabel="Dissolve team"
              pendingLabel="Dissolving…"
              variant="destructive"
              confirmMessage="Dissolve this team permanently? This is blocked while the team has an active tournament registration."
            >
              <input type="hidden" name="teamId" value={team.id} />
            </ActionForm>
          )}
        </div>
      )}
    </div>
  );
}
