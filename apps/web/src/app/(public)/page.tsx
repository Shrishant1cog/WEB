import Link from "next/link";
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";

export default function LandingPage() {
  return (
    <div className="min-h-screen bg-background">
      {/* Hero Section */}
      <section className="relative overflow-hidden bg-gradient-to-b from-slate-900 via-slate-800 to-background py-20 lg:py-32">
        <div className="absolute inset-0 bg-[radial-gradient(ellipse_at_center,_var(--tw-gradient-stops))] from-primary/20 via-transparent to-transparent" />
        <div className="relative mx-auto max-w-6xl px-4 py-16 text-center">
          <div className="mx-auto max-w-3xl">
            <h1 className="text-display-md font-bold tracking-tight text-white sm:text-display-lg">
              Free Fire tournaments, run properly
            </h1>
            <p className="mt-6 text-body-lg text-slate-300 max-w-2xl mx-auto">
              FFT gives community organizers the tools to publish tournaments, manage
              registrations and run squad competitions — and gives players one place
              to find and join them.
            </p>
            <div className="mt-10 flex flex-col items-center justify-center gap-4 sm:flex-row">
              <Button asChild size="xl" className="bg-primary text-primary-foreground hover:bg-primary/90 shadow-lg">
                <Link href="/tournaments">Browse tournaments</Link>
              </Button>
              <Button asChild size="xl" variant="outline" className="border-white/30 text-white hover:bg-white/10">
                <Link href="/register">Create an account</Link>
              </Button>
            </div>
          </div>
        </div>
      </section>

      {/* Features Section */}
      <section className="mx-auto max-w-6xl px-4 py-16 lg:py-24">
        <div className="text-center mb-12">
          <h2 className="text-headline-lg font-semibold text-foreground">Built around the rules that matter</h2>
          <p className="mt-3 text-body-lg text-muted-foreground max-w-2xl mx-auto">
            Every feature is designed for fair, transparent tournament operations.
          </p>
        </div>
        <div className="grid gap-6 md:grid-cols-3">
          {[
            {
              icon: (
                <svg className="w-8 h-8" fill="none" stroke="currentColor" viewBox="0 0 24 24" aria-hidden="true">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={1.5} d="M9 12l2 2 4-4m5.618-4.016A11.955 11.955 0 0112 2.944a11.955 11.955 0 01-8.618 3.04A12.02 12.02 0 003 9c0 5.591 3.824 10.29 9 11.622 5.176-1.332 9-6.03 9-11.622 0-1.042-.133-2.052-.382-3.016z" />
                </svg>
              ),
              title: "Race-safe registration",
              body: "Capacity is enforced inside a database transaction. A full tournament never oversells, and waitlists promote in order.",
            },
            {
              icon: (
                <svg className="w-8 h-8" fill="none" stroke="currentColor" viewBox="0 0 24 24" aria-hidden="true">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={1.5} d="M17 20h5v-2a3 3 0 00-5.356-1.857M17 20H7m10 0v-2c0-.656-.126-1.283-.356-1.857M7 20H2v-2a3 3 0 015.356-1.857M7 20v-2c0-.656.126-1.283.356-1.857m0 0a5.002 5.002 0 019.288 0M15 7a3 3 0 11-6 0 3 3 0 016 0zm6 3a2 2 0 11-4 0 2 2 0 014 0zM7 10a2 2 0 11-4 0 2 2 0 014 0z" />
                </svg>
              ),
              title: "Squads with real rosters",
              body: "Captains build a roster, players consent to join, and every member is checked for duplicates before registration.",
            },
            {
              icon: (
                <svg className="w-8 h-8" fill="none" stroke="currentColor" viewBox="0 0 24 24" aria-hidden="true">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={1.5} d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" />
                </svg>
              ),
              title: "Organizer control",
              body: "Draft, publish, open and close registration, then manage entries from a single dashboard.",
            },
          ].map((item) => (
            <Card key={item.title} className="h-full border-border/50 hover:border-primary/30 transition-colors">
              <CardHeader className="pb-3">
                <div className="mx-auto mb-4 flex h-14 w-14 items-center justify-center rounded-xl bg-primary/10 text-primary">
                  {item.icon}
                </div>
                <CardTitle className="text-center">{item.title}</CardTitle>
              </CardHeader>
              <CardContent>
                <p className="text-body-sm text-muted-foreground text-center">{item.body}</p>
              </CardContent>
            </Card>
          ))}
        </div>
      </section>

      {/* CTA Section */}
      <section className="border-t bg-muted/30">
        <div className="mx-auto max-w-6xl px-4 py-16 text-center">
          <h2 className="text-headline-md font-semibold text-foreground">Ready to compete?</h2>
          <p className="mt-3 text-body-md text-muted-foreground max-w-xl mx-auto">
            Join thousands of players and organizers on FFT. Free to start, no hidden fees.
          </p>
          <div className="mt-8 flex flex-col items-center justify-center gap-4 sm:flex-row">
            <Button asChild size="lg" className="w-full sm:w-auto">
              <Link href="/tournaments">Browse tournaments</Link>
            </Button>
            <Button asChild size="lg" variant="outline" className="w-full sm:w-auto">
              <Link href="/register">Create an account</Link>
            </Button>
          </div>
        </div>
      </section>

      {/* Footer Note */}
      <section className="border-t bg-muted/30">
        <div className="mx-auto max-w-6xl px-4 py-12 text-center">
          <p className="text-body-sm text-muted-foreground">
            FFT is an independent tournament management platform. It is not affiliated
            with, endorsed by, or operated by Garena. Prize descriptions, if shown, are
            provided by organizers and are not payments made by FFT.
          </p>
        </div>
      </section>
    </div>
  );
}