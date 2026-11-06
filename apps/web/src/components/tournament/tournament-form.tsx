"use client";

import type { Tournament } from "@/types/supabase";
import type { ActionState } from "@/lib/actions/tournaments";
import { ActionForm } from "@/components/forms/action-form";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";

interface Props {
  action: (prev: ActionState, formData: FormData) => Promise<ActionState>;
  tournament?: Tournament;
  submitLabel: string;
}

function localValue(iso: string | null | undefined): string {
  if (!iso) return "";
  return new Date(iso).toISOString().slice(0, 16);
}

const selectClass =
  "mt-1 w-full rounded-md border border-gray-300 bg-white px-3 py-2 text-sm";
const textareaClass =
  "mt-1 w-full rounded-md border border-gray-300 px-3 py-2 text-sm";

export function TournamentForm({ action, tournament, submitLabel }: Props) {
  const eligibility = (tournament?.eligibility ?? {}) as Record<string, unknown>;
  const isEdit = Boolean(tournament);

  return (
    <ActionForm action={action} submitLabel={submitLabel} pendingLabel="Saving…" className="space-y-6">
      {tournament && <input type="hidden" name="tournamentId" value={tournament.id} />}

      <div className="grid gap-4 sm:grid-cols-2">
        <div className="sm:col-span-2">
          <Label htmlFor="title">Title</Label>
          <Input
            id="title"
            name="title"
            required
            minLength={3}
            maxLength={100}
            defaultValue={tournament?.title ?? ""}
            className="mt-1"
          />
        </div>

        <div className="sm:col-span-2">
          <Label htmlFor="description">Description</Label>
          <textarea
            id="description"
            name="description"
            rows={3}
            maxLength={5000}
            defaultValue={tournament?.description ?? ""}
            className={textareaClass}
          />
        </div>

        <div>
          <Label htmlFor="format">Format</Label>
          <select
            id="format"
            name="format"
            required
            defaultValue={tournament?.format ?? "squad"}
            className={selectClass}
          >
            <option value="solo">Solo</option>
            <option value="duo">Duo</option>
            <option value="squad">Squad</option>
            <option value="custom">Custom</option>
          </select>
        </div>

        <div>
          <Label htmlFor="mode">Game mode</Label>
          <select
            id="mode"
            name="mode"
            required
            defaultValue={tournament?.mode ?? "br"}
            className={selectClass}
          >
            <option value="br">Battle Royale</option>
            <option value="cs">Clash Squad</option>
            <option value="tdm">Team Deathmatch</option>
            <option value="custom">Custom</option>
          </select>
        </div>

        <div>
          <Label htmlFor="map">Map (optional)</Label>
          <Input
            id="map"
            name="map"
            maxLength={50}
            defaultValue={tournament?.map ?? ""}
            className="mt-1"
          />
        </div>

        <div>
          <Label htmlFor="visibility">Visibility</Label>
          <select
            id="visibility"
            name="visibility"
            required
            defaultValue={tournament?.visibility ?? "public"}
            disabled={isEdit}
            className={selectClass}
          >
            <option value="public">Public</option>
            <option value="private">Private (link only)</option>
            <option value="invite_only">Invite only</option>
          </select>
        </div>

        <div>
          <Label htmlFor="maxTeams">Capacity (entries)</Label>
          <Input
            id="maxTeams"
            name="maxTeams"
            type="number"
            min={1}
            max={200}
            required
            defaultValue={tournament?.max_teams ?? 50}
            className="mt-1"
          />
        </div>

        <div>
          <Label htmlFor="teamSize">Roster size</Label>
          <select
            id="teamSize"
            name="teamSize"
            required
            defaultValue={String(tournament?.team_size ?? 4)}
            className={selectClass}
          >
            <option value="1">1 (solo)</option>
            <option value="2">2 (duo)</option>
            <option value="4">4 (squad)</option>
          </select>
        </div>

        <div>
          <Label htmlFor="registrationStartsAt">Registration opens (UTC)</Label>
          <Input
            id="registrationStartsAt"
            name="registrationStartsAt"
            type="datetime-local"
            required
            defaultValue={localValue(tournament?.registration_starts_at)}
            className="mt-1"
          />
        </div>

        <div>
          <Label htmlFor="registrationEndsAt">Registration closes (UTC)</Label>
          <Input
            id="registrationEndsAt"
            name="registrationEndsAt"
            type="datetime-local"
            required
            defaultValue={localValue(tournament?.registration_ends_at)}
            className="mt-1"
          />
        </div>

        <div>
          <Label htmlFor="tournamentStartsAt">Tournament starts (UTC)</Label>
          <Input
            id="tournamentStartsAt"
            name="tournamentStartsAt"
            type="datetime-local"
            required
            defaultValue={localValue(tournament?.tournament_starts_at)}
            className="mt-1"
          />
        </div>

        <div>
          <Label htmlFor="tournamentEndsAt">Tournament ends (optional, UTC)</Label>
          <Input
            id="tournamentEndsAt"
            name="tournamentEndsAt"
            type="datetime-local"
            defaultValue={localValue(tournament?.tournament_ends_at)}
            className="mt-1"
          />
        </div>

        <div>
          <Label htmlFor="withdrawalDeadline">Withdrawal deadline (optional, UTC)</Label>
          <Input
            id="withdrawalDeadline"
            name="withdrawalDeadline"
            type="datetime-local"
            defaultValue={localValue(tournament?.withdrawal_deadline)}
            className="mt-1"
          />
        </div>

        <div>
          <Label htmlFor="prizePool">Prize description (optional)</Label>
          <Input
            id="prizePool"
            name="prizePool"
            maxLength={200}
            defaultValue={tournament?.prize_pool ?? ""}
            className="mt-1"
          />
        </div>

        <div className="sm:col-span-2">
          <Label htmlFor="rulesUrl">External rules URL (optional)</Label>
          <Input
            id="rulesUrl"
            name="rulesUrl"
            defaultValue={tournament?.rules_url ?? ""}
            className="mt-1"
            placeholder="https://"
          />
        </div>

        <div className="sm:col-span-2">
          <Label htmlFor="rulesText">Rules text</Label>
          <textarea
            id="rulesText"
            name="rulesText"
            rows={4}
            maxLength={10000}
            defaultValue={tournament?.rules_text ?? ""}
            className={textareaClass}
          />
        </div>

        <div className="sm:col-span-2">
          <Label htmlFor="contactInfo">Contact info (optional)</Label>
          <Input
            id="contactInfo"
            name="contactInfo"
            maxLength={200}
            defaultValue={tournament?.contact_info ?? ""}
            className="mt-1"
          />
        </div>
      </div>

      <div className="space-y-2 rounded-md border bg-gray-50 p-4 text-sm">
        <label className="flex items-center gap-2">
          <input
            type="checkbox"
            name="waitlistEnabled"
            defaultChecked={tournament?.waitlist_enabled ?? true}
          />
          <span>Enable FIFO waitlist when capacity is reached</span>
        </label>
        <label className="flex items-center gap-2">
          <input
            type="checkbox"
            name="requiresInGameId"
            defaultChecked={Boolean(eligibility.requires_ingame_id)}
          />
          <span>Require a Free Fire in-game UID from every roster member</span>
        </label>
      </div>

      <p className="text-xs text-gray-500">
        Drafts are only visible to organizers. Publishing makes the tournament
        discoverable according to its visibility setting.
      </p>
    </ActionForm>
  );
}
