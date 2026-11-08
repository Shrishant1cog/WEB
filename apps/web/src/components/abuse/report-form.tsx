"use client";

import { useState, useTransition } from "react";
import { createBrowserSupabaseClient } from "@/lib/supabase/browser-client";
import { submitAbuseReportAction, type ActionState } from "@/lib/actions/abuse";
import { ABUSE_CATEGORIES, ABUSE_SUBJECT_TYPES } from "@/lib/validation/abuse";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";

const MAX_FILE_BYTES = 10 * 1024 * 1024;
const MAX_FILES = 5;

export function AbuseReportForm({
  defaultTournamentId = "",
}: {
  defaultTournamentId?: string;
}) {
  const [state, setState] = useState<ActionState>(null);
  const [pending, startTransition] = useTransition();
  const [files, setFiles] = useState<File[]>([]);

  async function handleSubmit(event: React.FormEvent<HTMLFormElement>) {
    event.preventDefault();
    setState(null);

    const form = event.currentTarget;
    const formData = new FormData(form);

    const selected = files.slice(0, MAX_FILES);
    const tooLarge = selected.find((file) => file.size > MAX_FILE_BYTES);
    if (tooLarge) {
      setState({ error: `${tooLarge.name} is larger than 10 MB.` });
      return;
    }

    const supabase = createBrowserSupabaseClient();
    const {
      data: { user },
    } = await supabase.auth.getUser();
    if (!user) {
      setState({ error: "Please sign in to continue." });
      return;
    }

    const uploaded: string[] = [];
    for (const file of selected) {
      const safeName = file.name.replace(/[^a-zA-Z0-9._-]/g, "_").slice(0, 120);
      const path = `${user.id}/${crypto.randomUUID()}-${safeName}`;
      const { error } = await supabase.storage
        .from("abuse-evidence")
        .upload(path, file, { contentType: file.type, upsert: false });
      if (error) {
        setState({ error: `Evidence upload failed: ${error.message}` });
        return;
      }
      uploaded.push(path);
    }

    for (const path of uploaded) formData.append("evidencePaths", path);

    startTransition(async () => {
      const result = await submitAbuseReportAction(null, formData);
      setState(result);
      if (result?.success) {
        form.reset();
        setFiles([]);
      }
    });
  }

  return (
    <form onSubmit={handleSubmit} className="space-y-5" encType="multipart/form-data">
      <div className="grid gap-4 sm:grid-cols-2">
        <div className="space-y-2">
          <Label htmlFor="category">Category</Label>
          <select
            id="category"
            name="category"
            required
            className="flex h-11 w-full rounded-lg border border-input bg-background px-3 text-body-sm focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring"
            defaultValue="cheating"
          >
            {ABUSE_CATEGORIES.map(([value, label]) => (
              <option key={value} value={value}>
                {label}
              </option>
            ))}
          </select>
        </div>
        <div className="space-y-2">
          <Label htmlFor="subjectType">What are you reporting?</Label>
          <select
            id="subjectType"
            name="subjectType"
            required
            className="flex h-11 w-full rounded-lg border border-input bg-background px-3 text-body-sm focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring"
            defaultValue="tournament"
          >
            {ABUSE_SUBJECT_TYPES.map(([value, label]) => (
              <option key={value} value={value}>
                {label}
              </option>
            ))}
          </select>
        </div>
      </div>

      <div className="grid gap-4 sm:grid-cols-2">
        <div className="space-y-2">
          <Label htmlFor="tournamentId">Tournament ID (optional)</Label>
          <Input
            id="tournamentId"
            name="tournamentId"
            defaultValue={defaultTournamentId}
            placeholder="00000000-0000-0000-0000-000000000000"
            autoComplete="off"
          />
        </div>
        <div className="space-y-2">
          <Label htmlFor="subjectId">Subject ID (optional)</Label>
          <Input
            id="subjectId"
            name="subjectId"
            placeholder="Player, team, match or result ID"
            autoComplete="off"
          />
        </div>
      </div>

      <div className="space-y-2">
        <Label htmlFor="description">What happened?</Label>
        <textarea
          id="description"
          name="description"
          required
          minLength={10}
          maxLength={4000}
          rows={6}
          className="w-full rounded-lg border border-input bg-background px-3 py-2 text-body-sm focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring"
          placeholder="Include what happened, when, and who was involved. Do not include passwords or private credentials."
        />
      </div>

      <div className="space-y-2">
        <Label htmlFor="evidence">Evidence (optional, up to 5 files, 10 MB each)</Label>
        <input
          id="evidence"
          name="evidence"
          type="file"
          multiple
          accept="image/png,image/jpeg,image/webp,application/pdf,text/plain"
          onChange={(event) => setFiles(Array.from(event.currentTarget.files ?? []))}
          className="block w-full text-body-sm text-muted-foreground file:mr-3 file:rounded-md file:border-0 file:bg-primary file:px-3 file:py-2 file:text-primary-foreground"
        />
        <p className="text-label-sm text-muted-foreground">
          Evidence is private. Only you and platform administrators can read it.
        </p>
      </div>

      {state?.error && (
        <p role="alert" className="rounded-md bg-red-50 p-3 text-sm text-red-700">
          {state.error}
        </p>
      )}
      {state?.success && (
        <p role="status" className="rounded-md bg-green-50 p-3 text-sm text-green-700">
          {state.success}
        </p>
      )}

      <Button type="submit" disabled={pending} loading={pending}>
        {pending ? "Submitting…" : "Submit report"}
      </Button>
    </form>
  );
}
