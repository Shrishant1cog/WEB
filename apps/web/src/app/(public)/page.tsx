import Link from "next/link";
import { Button } from "@/components/ui/button";
import { Trophy, Users, Shield, Calendar, ArrowRight } from "lucide-react";

export default function LandingPage() {
  return (
    <div className="min-h-screen">
      {/* Hero Section */}
      <section className="relative bg-gradient-to-b from-indigo-600 to-indigo-800 text-white">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-20 sm:py-32">
          <div className="text-center">
            <h1 className="text-4xl sm:text-5xl md:text-6xl font-bold tracking-tight">
              Free Fire Tournament
              <br />
              <span className="text-yellow-300">Management Platform</span>
            </h1>
            <p className="mt-6 text-lg sm:text-xl text-indigo-100 max-w-3xl mx-auto">
              Organize, manage, and participate in Free Fire tournaments with ease.
              Built for organizers, players, and the competitive community.
            </p>
            <div className="mt-10 flex flex-col sm:flex-row items-center justify-center gap-4">
              <Button asChild size="lg" className="w-full sm:w-auto bg-yellow-400 text-indigo-900 hover:bg-yellow-300">
                <Link href="/register">Get Started Free</Link>
              </Button>
              <Button asChild size="lg" variant="outline" className="w-full sm:w-auto border-white text-white hover:bg-indigo-700">
                <Link href="/tournaments">Browse Tournaments</Link>
              </Button>
            </div>
          </div>
        </div>
      </section>

      {/* Features Section */}
      <section className="py-20 bg-white">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="text-center mb-16">
            <h2 className="text-3xl sm:text-4xl font-bold text-gray-900">Everything you need to run tournaments</h2>
            <p className="mt-4 text-lg text-gray-600">Powerful tools for organizers, seamless experience for players</p>
          </div>

          <div className="grid grid-cols-1 md:grid-cols-3 gap-8">
            <div className="text-center p-6">
              <div className="mx-auto flex h-16 w-16 items-center justify-center rounded-full bg-indigo-100">
                <Trophy className="h-8 w-8 text-indigo-600" />
              </div>
              <h3 className="mt-6 text-xl font-semibold text-gray-900">Tournament Management</h3>
              <p className="mt-2 text-gray-600">Create brackets, manage registrations, schedule matches, and track results all in one place.</p>
            </div>

            <div className="text-center p-6">
              <div className="mx-auto flex h-16 w-16 items-center justify-center rounded-full bg-green-100">
                <Users className="h-8 w-8 text-green-600" />
              </div>
              <h3 className="mt-6 text-xl font-semibold text-gray-900">Team & Player Management</h3>
              <p className="mt-2 text-gray-600">Handle team registrations, player verification, roster changes, and eligibility checks.</p>
            </div>

            <div className="text-center p-6">
              <div className="mx-auto flex h-16 w-16 items-center justify-center rounded-full bg-yellow-100">
                <Shield className="h-8 w-8 text-yellow-600" />
              </div>
              <h3 className="mt-6 text-xl font-semibold text-gray-900">Secure & Compliant</h3>
              <p className="mt-2 text-gray-600">DPDP compliant, secure authentication, role-based access control, and audit logging.</p>
            </div>
          </div>
        </div>
      </section>

      {/* For Organizers Section */}
      <section className="py-20 bg-gray-50">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="grid md:grid-cols-2 gap-12 items-center">
            <div>
              <h2 className="text-3xl font-bold text-gray-900">Built for Tournament Organizers</h2>
              <p className="mt-4 text-lg text-gray-600">
                Streamline your tournament operations with powerful tools designed specifically for Free Fire competitions.
              </p>
              <ul className="mt-8 space-y-4">
                {[
                  "Create single elimination, double elimination, or round-robin brackets",
                  "Automated match scheduling and notifications",
                  "Real-time results and bracket updates",
                  "Team registration with custom fields",
                  "Prize pool management and distribution",
                  "Compliance with DPDP and Google Play policies",
                ].map((feature) => (
                  <li key={feature} className="flex items-center text-gray-700">
                    <Shield className="h-5 w-5 text-green-500 mr-3 flex-shrink-0" />
                    {feature}
                  </li>
                ))}
              </ul>
              <Button asChild className="mt-8">
                <Link href="/register?role=organizer">
                  Start Organizing <ArrowRight className="ml-2 h-4 w-4" />
                </Link>
              </Button>
            </div>
            <div className="bg-white rounded-xl shadow-lg p-8">
              <div className="bg-indigo-50 rounded-lg p-6">
                <div className="flex items-center justify-between mb-4">
                  <h3 className="font-semibold text-gray-900">Upcoming Tournament</h3>
                  <span className="px-2 py-1 text-xs font-medium bg-green-100 text-green-800 rounded-full">
                    Registration Open
                  </span>
                </div>
                <h4 className="text-xl font-bold text-gray-900">FF India Championship 2024</h4>
                <p className="mt-2 text-gray-600">₹5,00,000 Prize Pool · 64 Teams · Squad Mode</p>
                <div className="mt-6 flex items-center text-sm text-gray-500">
                  <Calendar className="h-4 w-4 mr-2" />
                  <span>Starts Dec 15, 2024</span>
                </div>
              </div>
            </div>
          </div>
        </div>
      </section>

      {/* For Players Section */}
      <section className="py-20 bg-white">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="grid md:grid-cols-2 gap-12 items-center">
            <div className="bg-white rounded-xl shadow-lg p-8 border border-gray-200">
              <div className="bg-green-50 rounded-lg p-6">
                <div className="flex items-center justify-between mb-4">
                  <h3 className="font-semibold text-gray-900">Your Tournament</h3>
                  <span className="px-2 py-1 text-xs font-medium bg-blue-100 text-blue-800 rounded-full">
                    In Progress
                  </span>
                </div>
                <h4 className="text-xl font-bold text-gray-900">Weekly Squad Showdown</h4>
                <p className="mt-2 text-gray-600">Round 3 · Match 2 of 8</p>
                <div className="mt-6 flex items-center text-sm text-gray-500">
                  <Calendar className="h-4 w-4 mr-2" />
                  <span>Today at 7:00 PM IST</span>
                </div>
              </div>
            </div>
            <div>
              <h2 className="text-3xl font-bold text-gray-900">Compete with Confidence</h2>
              <p className="mt-4 text-lg text-gray-600">
                Join tournaments, track your progress, and climb the leaderboards. Built for competitive Free Fire players.
              </p>
              <ul className="mt-8 space-y-4">
                {[
                  "Find and join tournaments matching your skill level",
                  "Track match history, stats, and rankings",
                  "Real-time match notifications and updates",
                  "Team management and roster coordination",
                  "Secure account with MFA support",
                  "Easy password recovery and account management",
                ].map((feature) => (
                  <li key={feature} className="flex items-center text-gray-700">
                    <Trophy className="h-5 w-5 text-indigo-500 mr-3 flex-shrink-0" />
                    {feature}
                  </li>
                ))}
              </ul>
              <Button asChild className="mt-8">
                <Link href="/register">
                  Join a Tournament <ArrowRight className="ml-2 h-4 w-4" />
                </Link>
              </Button>
            </div>
          </div>
        </div>
      </section>

      {/* Footer CTA */}
      <section className="py-16 bg-indigo-600">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 text-center">
          <h2 className="text-3xl font-bold text-white">Ready to get started?</h2>
          <p className="mt-4 text-lg text-indigo-100">Create your free account and join the competitive Free Fire community today.</p>
          <div className="mt-8 flex flex-col sm:flex-row items-center justify-center gap-4">
            <Button asChild size="lg" className="w-full sm:w-auto bg-yellow-400 text-indigo-900 hover:bg-yellow-300">
              <Link href="/register">Create Free Account</Link>
            </Button>
            <Button asChild size="lg" variant="outline" className="w-full sm:w-auto border-white text-white hover:bg-indigo-700">
              <Link href="/tournaments">Browse Tournaments</Link>
            </Button>
          </div>
        </div>
      </section>
    </div>
  );
}