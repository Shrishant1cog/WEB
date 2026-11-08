import { Skeleton, SkeletonList } from "@/components/ui/skeleton";

export default function NotificationsLoading() {
  return (
    <div className="space-y-6" aria-busy="true" aria-live="polite">
      <span className="sr-only">Loading notifications…</span>
      <Skeleton className="h-8 w-56" />
      <SkeletonList count={4} variant="compact" />
    </div>
  );
}
