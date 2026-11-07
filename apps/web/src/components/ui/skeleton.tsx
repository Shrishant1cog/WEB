"use client";

import { cn } from "@/lib/utils";

interface SkeletonProps extends React.HTMLAttributes<HTMLDivElement> {
  variant?: 'text' | 'circular' | 'rectangular' | 'card';
  width?: string | number;
  height?: string | number;
}

export function Skeleton({
  className,
  variant = 'text',
  width,
  height,
  ...props
}: SkeletonProps) {
  return (
    <div
      className={cn(
        'animate-shimmer rounded',
        'bg-gradient-to-r from-muted via-muted-foreground/10 to-muted bg-[length:200%_100%]',
        {
          'rounded-full': variant === 'circular',
          'rounded-lg': variant === 'rectangular' || variant === 'card',
          'h-4 w-full': variant === 'text',
          'h-10 w-10': variant === 'circular',
          'h-20 w-20': variant === 'card',
        },
        className
      )}
      style={{
        width: width !== undefined ? width : undefined,
        height: height !== undefined ? height : undefined,
      }}
      {...props}
    />
  );
}

interface SkeletonCardProps {
  variant?: 'default' | 'compact';
  className?: string;
}

export function SkeletonCard({ variant = 'default', className }: SkeletonCardProps) {
  if (variant === 'compact') {
    return (
      <div className={cn('rounded-xl border bg-card shadow-sm', className)}>
        <div className="p-4">
          <div className="space-y-3">
            <div className="flex items-start gap-3">
              <Skeleton className="flex-1 h-4" />
              <Skeleton variant="circular" className="w-12 h-12" />
            </div>
            <Skeleton className="h-3 w-3/4" />
            <Skeleton className="h-3 w-1/2" />
          </div>
        </div>
      </div>
    );
  }

  return (
    <div className={cn('rounded-xl border bg-card shadow-sm', className)}>
      <div className="p-6">
        <div className="space-y-4">
          {/* Header skeleton */}
          <div className="flex items-start gap-4">
            <Skeleton className="flex-1 h-5" />
            <Skeleton variant="circular" className="w-14 h-14" />
          </div>
          {/* Meta row */}
          <Skeleton className="h-3 w-3/4" />
          {/* Info row */}
          <div className="flex items-center gap-6">
            <Skeleton className="flex-1 h-3" />
            <Skeleton className="w-24 h-3" />
          </div>
          {/* Badges row */}
          <div className="flex items-center gap-3">
            <Skeleton variant="rectangular" className="w-20 h-6 rounded-full" />
            <Skeleton variant="rectangular" className="w-28 h-6 rounded-full" />
          </div>
        </div>
      </div>
    </div>
  );
}

interface SkeletonListProps {
  count?: number;
  variant?: 'default' | 'compact';
  className?: string;
}

export function SkeletonList({ count = 5, variant = 'default', className }: SkeletonListProps) {
  return (
    <div className={cn('space-y-4', className)}>
      {Array.from({ length: count }).map((_, i) => (
        <SkeletonCard key={i} variant={variant} />
      ))}
    </div>
  );
}