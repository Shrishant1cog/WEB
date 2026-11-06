import Link from "next/link";
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";

export default function LandingPage() {
  return (
    <div>
      <section className="bg-gradient-to-b from-indigo-700 to-indigo-900 text-white">
        <div className="mx-auto max-w-6xl px-4 py-20 text-center">
          <h1 className="text-4xl font-bold tracking-tight sm:text-5xl">
            Free Fire tournaments, run properly
          </h1>
          <p className="mx-auto mt-5 max-w-2xl text-lg text-indigo-100">
            FFT gives community organizers the tools to publish tournaments, manage
            registrations and run squad competitions — and gives players one place
            to find and join them.
          </p>
          <div className="mt-8 flex flex-col items-center justify-center gap-3 sm:flex-row">
            <Button asChild size="lg" className="bg-yellow-400 text-indigo-900 hover:bg-yellow-300">
              <Link href="/tournaments">Browse tournaments</Link>
            </Button>
            <Button asChild size="lg" variant="outline" className="border-white text-white hover:bg-indigo-800">
              <Link href="/register">Create an account</Link>
            </Button>
          </div>
        </div>
      </section>

      <section className="mx-auto max-w-6xl px-4 py-16">
        <h2 className="text-2xl font-semibold text-gray-900">Built around the rules that matter</h2>
        <div className="mt-8 grid gap-6 md:grid-cols-3">
          {[
            {
              title: "Race-safe registration",
              body: "Capacity is enforced inside a database transaction. A full tournament never oversells, and waitlists promote in order.",
            },
            {
              title: "Squads with real rosters",
              body: "Captains build a roster, players consent to join, and every member is checked for duplicates before registration.",
            },
            {
              title: "Organizer control",
              body: "Draft, publish, open and close registration, then manage entries from a single dashboard.",
            },
          ].map((item) => (
            <Card key={item.title}>
              <CardHeader>
                <CardTitle>{item.title}</CardTitle>
              </CardHeader>
              <CardContent>
                <p className="text-sm text-gray-600">{item.body}</p>
              </CardContent>
            </Card>
          ))}
        </div>
      </section>

      <section className="border-t bg-gray-50">
        <div className="mx-auto max-w-6xl px-4 py-12 text-center">
          <p className="text-sm text-gray-600">
            FFT is an independent tournament management platform. It is not affiliated
            with, endorsed by, or operated by Garena. Prize descriptions, if shown, are
            provided by organizers and are not payments made by FFT.
          </p>
        </div>
      </section>
    </div>
  );
}
