/// Homepage for FFT Web Application
/// Public landing page with tournament listing

import Link from 'next/link';
import { Button } from '@/components/ui/button';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Badge } from '@/components/ui/badge';
import { Separator } from '@/components/ui/separator';
import { LucideIcon, Calendar, Users, Trophy, Shield, ArrowRight, ExternalLink } from 'lucide-react';

export default function HomePage() {
  return (
    <main className="min-h-screen">
      {/* Hero Section */}
      <section className="relative overflow-hidden bg-gradient-to-b from-primary-50 to-white dark:from-primary-950 dark:to-primary-900 py-20 lg:py-32">
        <div className="container mx-auto px-4 lg:px-8">
          <div className="max-w-4xl mx-auto text-center">
            <div className="inline-flex items-center gap-2 px-3 py-1 rounded-full bg-primary-100 dark:bg-primary-900/30 text-primary-700 dark:text-primary-300 text-sm font-medium mb-6">
              <span className="relative flex h-2 w-2">
                <span className="animate-ping absolute inline-flex h-full w-full rounded-full bg-primary-400 opacity-75"></span>
                <span className="relative inline-flex rounded-full h-2 w-2 bg-primary-500"></span>
              </span>
              Independent Platform • Not affiliated with Garena
            </div>
            
            <h1 className="text-display-xl lg:text-display-lg font-bold text-foreground mb-6">
              FFT Tournament Platform
            </h1>
            
            <p className="text-body-lg text-muted-foreground mb-8 max-w-2xl mx-auto">
              Manage and participate in Free Fire India community tournaments.
              Built for organizers and players with secure registration, team management,
              and transparent results.
            </p>
            
            <div className="flex flex-col sm:flex-row items-center justify-center gap-4 mb-12">
              <Link href="/tournaments">
                <Button size="lg" className="gap-2">
                  Browse Tournaments
                  <ArrowRight className="h-4 w-4" />
                </Button>
              </Link>
              <Link href="/register">
                <Button size="lg" variant="outline" className="gap-2">
                  Create Account
                </Button>
              </Link>
            </div>
            
            {/* Legal Disclaimer */}
            <p className="text-body-sm text-muted-foreground/70">
              FFT is an independent tournament management platform. It is not affiliated with, endorsed by, or operated by Garena.
            </p>
          </div>
        </div>
      </section>

      {/* Features Section */}
      <section className="py-20 lg:py-24 bg-background">
        <div className="container mx-auto px-4 lg:px-8">
          <div className="text-center mb-16">
            <h2 className="text-headline-lg font-bold text-foreground mb-4">Built for Tournament Operations</h2>
            <p className="text-body-lg text-muted-foreground max-w-2xl mx-auto">
              Professional tools for organizers, clear experience for players
            </p>
          </div>
          
          <div className="grid md:grid-cols-2 lg:grid-cols-4 gap-6">
            {features.map((feature) => (
              <FeatureCard key={feature.title} feature={feature} />
            ))}
          </div>
        </div>
      </section>

      {/* Tournament Listing Preview */}
      <section className="py-20 lg:py-24 bg-muted/30">
        <div className="container mx-auto px-4 lg:px-8">
          <div className="flex items-center justify-between mb-8">
            <div>
              <h2 className="text-headline-lg font-bold text-foreground mb-2">Upcoming Tournaments</h2>
              <p className="text-body-md text-muted-foreground">Join the competition</p>
            </div>
            <Link href="/tournaments" className="text-primary-600 hover:text-primary-700 font-medium flex items-center gap-1">
              View All
              <ArrowRight className="h-4 w-4" />
            </Link>
          </div>
          
          <div className="grid md:grid-cols-2 lg:grid-cols-3 gap-6">
            {mockTournaments.map((tournament) => (
              <TournamentCard key={tournament.id} tournament={tournament} />
            ))}
          </div>
        </div>
      </section>

      {/* Platform Stats */}
      <section className="py-20 bg-primary-900 text-white">
        <div className="container mx-auto px-4 lg:px-8">
          <div className="grid md:grid-cols-4 gap-8 text-center">
            {stats.map((stat) => (
              <div key={stat.label}>
                <div className="text-4xl lg:text-5xl font-bold mb-2">{stat.value}</div>
                <div className="text-primary-200">{stat.label}</div>
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* Footer */}
      <footer className="bg-muted/50 border-t py-12">
        <div className="container mx-auto px-4 lg:px-8">
          <div className="grid md:grid-cols-4 gap-8 mb-8">
            <div>
              <h3 className="font-semibold mb-4">FFT</h3>
              <p className="text-sm text-muted-foreground mb-4">
                Independent tournament management platform for Free Fire India.
              </p>
              <p className="text-xs text-muted-foreground/70">
                Not affiliated with, endorsed by, or operated by Garena.
              </p>
            </div>
            <div>
              <h3 className="font-semibold mb-4">Platform</h3>
              <ul className="space-y-2 text-sm">
                <li><Link href="/tournaments" className="text-muted-foreground hover:text-foreground">Browse Tournaments</Link></li>
                <li><Link href="/register" className="text-muted-foreground hover:text-foreground">Create Account</Link></li>
                <li><Link href="/support" className="text-muted-foreground hover:text-foreground">Support</Link></li>
              </ul>
            </div>
            <div>
              <h3 className="font-semibold mb-4">Legal</h3>
              <ul className="space-y-2 text-sm">
                <li><Link href="/privacy" className="text-muted-foreground hover:text-foreground">Privacy Policy</Link></li>
                <li><Link href="/terms" className="text-muted-foreground hover:text-foreground">Terms of Service</Link></li>
                <li><Link href="/account-deletion" className="text-muted-foreground hover:text-foreground">Account Deletion</Link></li>
              </ul>
            </div>
            <div>
              <h3 className="font-semibold mb-4">Contact</h3>
              <ul className="space-y-2 text-sm text-muted-foreground">
                <li>support@fft.app</li>
                <li>grievance@fft.app</li>
              </ul>
            </div>
          </div>
          <Separator />
          <div className="mt-8 text-center text-sm text-muted-foreground">
            © 2026 FFT. All rights reserved. Independent platform.
          </div>
        </div>
      </footer>
    </main>
  );
}

// ============================================================================
// COMPONENTS
// ============================================================================

interface Feature {
  title: string;
  description: string;
  icon: LucideIcon;
}

const features: Feature[] = [
  {
    title: 'Secure Registration',
    description: 'Race-safe registration with capacity enforcement and waitlist management',
    icon: Shield,
  },
  {
    title: 'Team Management',
    description: 'Create squads, invite members, and register as a team with full roster validation',
    icon: Users,
  },
  {
    title: 'Match Operations',
    description: 'Schedule matches, manage room credentials with time-gated release, and track results',
    icon: Calendar,
  },
  {
    title: 'Transparent Results',
    description: 'Provisional results, dispute system, moderator review, and audited finalization',
    icon: Trophy,
  },
];

function FeatureCard({ feature }: { feature: Feature }) {
  const { title, description, icon: Icon } = feature;
  return (
    <Card className="h-full transition-shadow hover:shadow-card-hover">
      <CardHeader>
        <div className="w-12 h-12 rounded-lg bg-primary-100 dark:bg-primary-900/30 flex items-center justify-center mb-4">
          <Icon className="h-6 w-6 text-primary-600 dark:text-primary-400" />
        </div>
        <CardTitle className="text-title-lg">{title}</CardTitle>
      </CardHeader>
      <CardContent>
        <p className="text-body-md text-muted-foreground">{description}</p>
      </CardContent>
    </Card>
  );
}

interface Tournament {
  id: string;
  title: string;
  format: 'solo' | 'squad';
  status: 'registration_open' | 'registration_closed' | 'live' | 'finalized';
  startsAt: string;
  capacity: number;
  registered: number;
  organization: string;
}

const mockTournaments: Tournament[] = [
  {
    id: '1',
    title: 'FFT Championship Season 1',
    format: 'squad',
    status: 'registration_open',
    startsAt: '2026-11-15T18:00:00+05:30',
    capacity: 64,
    registered: 42,
    organization: 'FFT Official',
  },
  {
    id: '2',
    title: 'Community Cup - November',
    format: 'solo',
    status: 'registration_open',
    startsAt: '2026-11-20T19:00:00+05:30',
    capacity: 100,
    registered: 67,
    organization: 'Community Gaming',
  },
  {
    id: '3',
    title: 'Weekend Warrior Series',
    format: 'squad',
    status: 'registration_closed',
    startsAt: '2026-11-10T18:00:00+05:30',
    capacity: 32,
    registered: 32,
    organization: 'Weekend Warriors',
  },
];

function TournamentCard({ tournament }: { tournament: Tournament }) {
  const statusConfig = {
    registration_open: { label: 'Open', color: 'bg-success-100 text-success-700 dark:bg-success-900/30 dark:text-success-400' },
    registration_closed: { label: 'Closed', color: 'bg-muted text-muted-foreground' },
    live: { label: 'Live', color: 'bg-error-100 text-error-700 dark:bg-error-900/30 dark:text-error-400' },
    finalized: { label: 'Finalized', color: 'bg-primary-100 text-primary-700 dark:bg-primary-900/30 dark:text-primary-400' },
  };

  const config = statusConfig[tournament.status];
  const startDate = new Date(tournament.startsAt).toLocaleDateString('en-IN', {
    weekday: 'short',
    month: 'short',
    day: 'numeric',
    hour: '2-digit',
    minute: '2-digit',
  });

  return (
    <Card className="h-full transition-shadow hover:shadow-card-hover">
      <CardHeader>
        <div className="flex items-start justify-between gap-4">
          <div className="flex-1 min-w-0">
            <div className="flex items-center gap-2 mb-2">
              <Badge variant={tournament.format === 'squad' ? 'default' : 'secondary'}>
                {tournament.format === 'squad' ? 'Squad (4)' : 'Solo'}
              </Badge>
              <Badge className={config.color}>{config.label}</Badge>
            </div>
            <CardTitle className="text-title-lg truncate">{tournament.title}</CardTitle>
          </div>
        </div>
      </CardHeader>
      <CardContent className="space-y-4">
        <div className="flex items-center gap-4 text-sm text-muted-foreground">
          <span className="flex items-center gap-1">
            <Calendar className="h-4 w-4" />
            {startDate}
          </span>
          <span className="flex items-center gap-1">
            <Users className="h-4 w-4" />
            {tournament.registered}/{tournament.capacity}
          </span>
        </div>
        <div className="flex items-center justify-between">
          <span className="text-sm text-muted-foreground">{tournament.organization}</span>
          <Link
            href={`/tournaments/${tournament.id}`}
            className="text-sm font-medium text-primary-600 hover:text-primary-700 flex items-center gap-1"
          >
            View Details
            <ArrowRight className="h-3.5 w-3.5" />
          </Link>
        </div>
      </CardContent>
    </Card>
  );
}

const stats = [
  { value: '50+', label: 'Tournaments Hosted' },
  { value: '2,000+', label: 'Registered Players' },
  { value: '150+', label: 'Teams Formed' },
  { value: '99.9%', label: 'Uptime Guarantee' },
];