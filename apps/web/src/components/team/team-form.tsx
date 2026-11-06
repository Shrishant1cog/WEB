"use client";

import { useState, useTransition } from "react";
import { createTeamAction, type TeamActionState } from "@/lib/actions/teams";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";

export function TeamForm() {
  const [state, setState] = useState<TeamActionState>(null);
  const [pending, startTransition] = useTransition();

  function handleSubmit(event: React.FormEvent<HTMLFormElement>) {
    event.preventDefault();
    const formData = new FormData(event.currentTarget);
    startTransition(async () => {
      const result = await createTeamAction(null, formData);
      setState(result);
    });
  }

  return (
    <form onSubmit={handleSubmit} className="space-y-4">
      {state?.error && (
        <p role="alert" className="rounded-md bg-red-50 p-3 text-sm text-red-700">
          {state.error}
        </p>
      )}
      <div className="space-y-2">
        <Label htmlFor="name">Team name</Label>
        <Input id="name" name="name" required minLength={3} maxLength={50} />
      </div>
      <div className="space-y-2">
        <Label htmlFor="tag">Tag (optional, 2-6 characters)</Label>
        <Input id="tag" name="tag" minLength={2} maxLength={6} />
      </div>
      <div className="space-y-2">
        <Label htmlFor="description">Description (optional)</Label>
        <textarea
          id="description"
          name="description"
          rows={3}
          maxLength={1000}
          className="w-full rounded-md border border-gray-300 px-3 py-2 text-sm"
        />
      </div>
      <Button type="submit" disabled={pending}>
        {pending ? "Creating…" : "Create team"}
      </Button>
    </form>
  );
}
