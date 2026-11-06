"use client";

import { useState, useTransition } from "react";
import { Button } from "@/components/ui/button";

type State = { error?: string; success?: string } | null;

export interface ActionFormProps {
  action: (prev: State, formData: FormData) => Promise<State>;
  children: React.ReactNode;
  submitLabel: string;
  pendingLabel?: string;
  className?: string;
  variant?: "default" | "outline" | "destructive" | "secondary" | "ghost" | "success";
  size?: "default" | "sm" | "lg";
  confirmMessage?: string;
}

/**
 * Small client wrapper so server actions can be used without React 19's
 * useActionState (this app is pinned to React 18.3).
 */
export function ActionForm({
  action,
  children,
  submitLabel,
  pendingLabel,
  className,
  variant = "default",
  size = "default",
  confirmMessage,
}: ActionFormProps) {
  const [state, setState] = useState<State>(null);
  const [pending, startTransition] = useTransition();

  function handleSubmit(event: React.FormEvent<HTMLFormElement>) {
    event.preventDefault();
    if (confirmMessage && !window.confirm(confirmMessage)) return;
    const formData = new FormData(event.currentTarget);
    startTransition(async () => {
      const result = await action(null, formData);
      setState(result);
    });
  }

  return (
    <form onSubmit={handleSubmit} className={className}>
      {children}
      {state?.error && (
        <p role="alert" className="mt-3 rounded-md bg-red-50 p-3 text-sm text-red-700">
          {state.error}
        </p>
      )}
      {state?.success && (
        <p role="status" className="mt-3 rounded-md bg-green-50 p-3 text-sm text-green-700">
          {state.success}
        </p>
      )}
      <Button type="submit" variant={variant} size={size} disabled={pending} className="mt-3">
        {pending ? (pendingLabel ?? "Working…") : submitLabel}
      </Button>
    </form>
  );
}
