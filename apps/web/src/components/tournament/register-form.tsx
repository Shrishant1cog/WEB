"use client";

import { useState, useTransition } from "react";
import { Button } from "@/components/ui/button";
import type { ActionState } from "@/lib/actions/tournaments";

interface TeamOption {
  id: string;
  name: string;
  memberCount: number;
}

interface Props {
  action: (prev: ActionState, formData: FormData) => Promise<ActionState>;
  tournamentId: string;
  entryType: "solo" | "squad";
  teams: TeamOption[];
  requiredRosterSize: number;
}

export function TournamentRegisterForm({
  action,
  tournamentId,
  entryType,
  teams,
  requiredRosterSize,
}: Props) {
  const [state, setState] = useState<ActionState>(null);
  const [pending, startTransition] = useTransition();

  const hasReadyTeam = teams.some((team) => team.memberCount === requiredRosterSize);

  function handleSubmit(event: React.FormEvent<HTMLFormElement>) {
    event.preventDefault();
    const formData = new FormData(event.currentTarget);
    startTransition(async () => {
      const result = await action(null, formData);
      setState(result);
    });
  }

  return (
    <form onSubmit={handleSubmit} className="space-y-3">
      <input type="hidden" name="tournamentId" value={tournamentId} />
      {entryType === "squad" && (
        <div className="space-y-1">
          <label htmlFor="teamId" className="text-sm font-medium text-gray-700">
            Register your team
          </label>
          <select
            id="teamId"
            name="teamId"
            required
            className="w-full rounded-md border border-gray-300 bg-white px-3 py-2 text-sm"
            defaultValue=""
          >
            <option value="" disabled>
              Select a team
            </option>
            {teams.map((team) => (
              <option key={team.id} value={team.id}>
                {team.name} ({team.memberCount}/{requiredRosterSize} members)
              </option>
            ))}
          </select>
          {!hasReadyTeam && (
            <p className="text-xs text-amber-700">
              You need a team with exactly {requiredRosterSize} members before you can register.
            </p>
          )}
        </div>
      )}
      {state?.error && (
        <p role="alert" className="rounded-md bg-red-50 p-3 text-sm text-red-700">
          {state.error}
        </p>
      )}
      <Button type="submit" disabled={pending} className="w-full sm:w-auto">
        {pending ? "Submitting…" : entryType === "solo" ? "Register solo" : "Register team"}
      </Button>
    </form>
  );
}
