import { Skeleton, SkeletonList } from "@/components/ui/skeleton";

export default function AbuseLoading() {
  return (
    <div className="space-y-6" aria-busy="true" aria-live="polite">
      <span className="sr-only">Loading abuse reports…</span>
      <Skeleton className="h-8 w-56" />
      <Skeleton className="h-64 w-full rounded-xl" />
      <SkeletonList count={2} variant="compact" />
    </div>
  );
}
