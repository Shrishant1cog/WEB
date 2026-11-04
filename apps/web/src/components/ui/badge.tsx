/// Badge Component
/// Status and label badges with multiple variants

import * as React from 'react';
import { cva, type VariantProps } from 'class-variance-authority';
import { cn } from '@/lib/utils';

const badgeVariants = cva(
  'inline-flex items-center rounded-full border px-2.5 py-0.5 text-label-sm font-medium transition-colors focus:outline-none focus:ring-2 focus:ring-ring focus:ring-offset-2',
  {
    variants: {
      variant: {
        default: 'border-transparent bg-primary-100 text-primary-700 hover:bg-primary-100/80 dark:bg-primary-900/30 dark:text-primary-300',
        secondary: 'border-transparent bg-secondary-100 text-secondary-700 hover:bg-secondary-100/80 dark:bg-secondary-900/30 dark:text-secondary-300',
        destructive: 'border-transparent bg-error-100 text-error-700 hover:bg-error-100/80 dark:bg-error-900/30 dark:text-error-300',
        success: 'border-transparent bg-success-100 text-success-700 hover:bg-success-100/80 dark:bg-success-900/30 dark:text-success-300',
        warning: 'border-transparent bg-warning-100 text-warning-700 hover:bg-warning-100/80 dark:bg-warning-900/30 dark:text-warning-300',
        outline: 'text-foreground',
        ghost: 'bg-transparent text-foreground hover:bg-accent',
      },
    },
    defaultVariants: {
      variant: 'default',
    },
  }
);

export interface BadgeProps
  extends React.HTMLAttributes<HTMLDivElement>,
    VariantProps<typeof badgeVariants> {}

function Badge({ className, variant, ...props }: BadgeProps) {
  return (
    <div className={cn(badgeVariants({ variant }), className)} {...props} />
  );
}

export { Badge, badgeVariants };