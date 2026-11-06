"use client";

import { useState, useTransition } from "react";
import { inviteToTeamAction, type TeamActionState } from "@/lib/actions/teams";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";

export function InviteForm({ teamId }: { teamId: string }) {
  const [state, setState] = useState<TeamActionState>(null);
  const [pending, startTransition] = useTransition();

  function handleSubmit(event: React.FormEvent<HTMLFormElement>) {
    event.preventDefault();
    const formData = new FormData(event.currentTarget);
    startTransition(async () => {
      const result = await inviteToTeamAction(null, formData);
      setState(result);
    });
  }

  const invitePath = state?.inviteToken ? `/team/invite/${state.inviteToken}` : null;

  return (
    <form onSubmit={handleSubmit} className="space-y-3">
      <input type="hidden" name="teamId" value={teamId} />
      {state?.error && (
        <p role="alert" className="rounded-md bg-red-50 p-3 text-sm text-red-700">
          {state.error}
        </p>
      )}
      <div className="space-y-2">
        <Label htmlFor="email">Player email</Label>
        <Input
          id="email"
          name="email"
          type="email"
          placeholder="player@example.com"
          required
        />
        <p className="text-xs text-gray-500">
          The link is single use, expires in 72 hours and only works for this email.
        </p>
      </div>
      <Button type="submit" size="sm" disabled={pending}>
        {pending ? "Creating…" : "Create invitation link"}
      </Button>

      {state?.success && invitePath && (
        <div className="rounded-md bg-green-50 p-3 text-sm text-green-800">
          <p>{state.success}</p>
          <code className="mt-2 block break-all rounded bg-white p-2 text-xs">
            {typeof window !== "undefined" ? `${window.location.origin}${invitePath}` : invitePath}
          </code>
          <p className="mt-2 text-xs">
            Send this link to {state.inviteEmail ?? "the invited player"}. It cannot be
            recovered later — only its hash is stored.
          </p>
        </div>
      )}
    </form>
  );
}
