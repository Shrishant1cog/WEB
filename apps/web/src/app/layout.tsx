/// Root Layout for FFT Web Application
/// Providers, fonts, and global configuration

import type { Metadata, Viewport } from 'next';
import { Inter } from 'next/font/google';
import './globals.css';

const inter = Inter({
  subsets: ['latin'],
  display: 'swap',
  variable: '--font-inter',
});

export const metadata: Metadata = {
  title: {
    default: 'FFT - Independent Free Fire India Tournament Platform',
    template: '%s | FFT',
  },
  description: 'FFT is an independent tournament management platform for Free Fire India community tournaments. Not affiliated with Garena.',
  keywords: ['tournament', 'esports', 'free fire', 'free fire india', 'competitive gaming', 'tournament management'],
  authors: [{ name: 'FFT Team' }],
  creator: 'FFT Team',
  publisher: 'FFT',
  robots: {
    index: true,
    follow: true,
    googleBot: {
      index: true,
      follow: true,
      'max-video-preview': -1,
      'max-image-preview': 'large',
      'max-snippet': -1,
    },
  },
  openGraph: {
    type: 'website',
    locale: 'en_IN',
    url: 'https://fft.app',
    siteName: 'FFT',
    title: 'FFT - Independent Free Fire India Tournament Platform',
    description: 'Manage and participate in Free Fire India community tournaments.',
    images: [
      {
        url: '/og-image.png',
        width: 1200,
        height: 630,
        alt: 'FFT Tournament Platform',
      },
    ],
  },
  twitter: {
    card: 'summary_large_image',
    title: 'FFT - Independent Free Fire India Tournament Platform',
    description: 'Manage and participate in Free Fire India community tournaments.',
    images: ['/og-image.png'],
  },
  verification: {
    google: 'google-site-verification-code',
  },
};

export const viewport: Viewport = {
  themeColor: [
    { media: '(prefers-color-scheme: light)', color: '#1e3a8a' },
    { media: '(prefers-color-scheme: dark)', color: '#1e1b4b' },
  ],
  width: 'device-width',
  initialScale: 1,
  maximumScale: 5,
};

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html lang="en" suppressHydrationWarning>
      <head>
        <link rel="icon" href="/favicon.ico" sizes="any" />
        <link rel="icon" href="/icon.svg" type="image/svg+xml" />
        <link rel="apple-touch-icon" href="/apple-touch-icon.png" />
        <link rel="manifest" href="/manifest.json" />
      </head>
      <body className={`${inter.variable} font-sans antialiased`}>
        {children}
      </body>
    </html>
  );
}