"use client";

import { cn } from "@/lib/utils";
import { Button } from "@/components/ui/button";

interface EmptyStateProps {
  icon: React.ReactNode;
  title: string;
  message?: string;
  action?: React.ReactNode;
  iconSize?: number;
  className?: string;
}

export function EmptyState({
  icon,
  title,
  message,
  action,
  iconSize = 64,
  className,
}: EmptyStateProps) {
  return (
    <div className={cn('flex flex-col items-center justify-center p-10 text-center', className)}>
      <div className={cn(
        'flex items-center justify-center rounded-2xl',
        'bg-primary/10 text-primary',
        iconSize >= 64 ? 'w-20 h-20' : 'w-16 h-16'
      )}>
        <span className={cn('text-primary', iconSize >= 64 ? 'text-5xl' : 'text-4xl')}>
          {icon}
        </span>
      </div>
      <h3 className="mt-6 text-title-lg font-semibold text-foreground">{title}</h3>
      {message && (
        <p className="mt-2 text-body-md text-muted-foreground max-w-md">{message}</p>
      )}
      {action && (
        <div className="mt-6">{action}</div>
      )}
    </div>
  );
}

// Predefined empty states
export const EmptyStates = {
  noTournaments: (
    <EmptyState
      icon="🏆"
      title="No tournaments found"
      message="Try a different search or filter."
      action={
        <Button variant="outline" size="sm">
          Reset filters
        </Button>
      }
    />
  ),
  noTeams: (
    <EmptyState
      icon="👥"
      title="No teams yet"
      message="Create your first team to get started."
      action={
        <Button size="sm">
          Create team
        </Button>
      }
    />
  ),
  noMatches: (
    <EmptyState
      icon="⚔️"
      title="No matches scheduled"
      message="Matches will appear here when tournaments are live."
    />
  ),
  noNotifications: (
    <EmptyState
      icon="🔔"
      title="No notifications"
      message="You're all caught up!"
    />
  ),
  noResults: (
    <EmptyState
      icon="🔍"
      title="No results found"
      message="Try adjusting your search or filters."
    />
  ),
};

interface ErrorStateProps {
  message: string;
  onRetry?: () => void;
  retryLabel?: string;
  icon?: React.ReactNode;
  className?: string;
}

export function ErrorState({
  message,
  onRetry,
  retryLabel = 'Try again',
  icon = (
    <svg className="w-10 h-10" fill="none" stroke="currentColor" viewBox="0 0 24 24" aria-hidden="true">
      <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z" />
    </svg>
  ),
  className,
}: ErrorStateProps) {
  return (
    <div className={cn('flex flex-col items-center justify-center p-10 text-center', className)}>
      <div className="flex items-center justify-center w-20 h-20 rounded-2xl bg-error/10 text-error">
        {icon}
      </div>
      <h3 className="mt-6 text-title-lg font-semibold text-foreground">Something went wrong</h3>
      <p className="mt-2 text-body-md text-muted-foreground max-w-md">{message}</p>
      {onRetry && (
        <Button onClick={onRetry} className="mt-6" icon={<svg className="w-4 h-4 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15"/></svg>}>
          {retryLabel}
        </Button>
      )}
    </div>
  );
}

interface LoadingStateProps {
  message?: string;
  showIndicator?: boolean;
  size?: 'sm' | 'md' | 'lg';
  className?: string;
}

export function LoadingState({
  message,
  showIndicator = true,
  size = 'md',
  className,
}: LoadingStateProps) {
  const sizeClasses = {
    sm: 'w-6 h-6 border-2',
    md: 'w-10 h-10 border-3',
    lg: 'w-12 h-12 border-4',
  };

  return (
    <div className={cn('flex flex-col items-center justify-center p-10 text-center', className)}>
      {showIndicator && (
        <div className={cn('animate-spin rounded-full border-current border-t-transparent', sizeClasses[size])} />
      )}
      {message && (
        <p className={cn('mt-4 text-body-md text-muted-foreground', size === 'sm' && 'text-sm')}>
          {message}
        </p>
      )}
    </div>
  );
}

interface InlineLoadingProps {
  label?: string;
  size?: 'sm' | 'md' | 'lg';
}

export function InlineLoading({ label, size = 'md' }: InlineLoadingProps) {
  const sizeClasses = {
    sm: 'w-4 h-4 border-2',
    md: 'w-5 h-5 border-2',
    lg: 'w-6 h-6 border-3',
  };

  return (
    <div className="flex items-center gap-2">
      <div className={cn('animate-spin rounded-full border-current border-t-transparent', sizeClasses[size])} />
      {label && <span className="text-body-md text-muted-foreground">{label}</span>}
    </div>
  );
}