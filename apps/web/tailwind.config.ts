import type { Config } from 'tailwindcss';

const config: Config = {
  darkMode: 'class',
  content: [
    './src/pages/**/*.{js,ts,jsx,tsx,mdx}',
    './src/components/**/*.{js,ts,jsx,tsx,mdx}',
    './src/app/**/*.{js,ts,jsx,tsx,mdx}',
  ],
  theme: {
    extend: {
      colors: {
        // FFT Brand Colors - Tactical Slate / Competitive Amber
        primary: {
          50: '#FFF8E1',
          100: '#FFF3C4',
          200: '#FFE68A',
          300: '#FFD84D',
          400: '#FFCB10',
          500: '#E58E26',  // Primary Amber
          600: '#C4761A',  // Primary Amber Dark
          700: '#9E5D14',
          800: '#7A4610',
          900: '#62360D',
          950: '#331A05',
        },
        secondary: {
          50: '#EFF6FF',
          100: '#DBEAFE',
          200: '#BFDBFE',
          300: '#93C5FD',
          400: '#60A5FA',
          500: '#3B82F6',  // Secondary Blue
          600: '#2563EB',  // Secondary Blue Dark
          700: '#1D4ED8',
          800: '#1E40AF',
          900: '#1E3A8A',
          950: '#172554',
        },
        teal: {
          50: '#F0FDFA',
          100: '#CCFBF1',
          200: '#99F6E4',
          300: '#5EEAD4',
          400: '#2DD4BF',
          500: '#14B8A6',  // Teal Accent
          600: '#0D9488',  // Teal Accent Dark
          700: '#0F766E',
          800: '#115E59',
          900: '#134E4A',
          950: '#042F2E',
        },
        // Status colors
        success: {
          50: '#ECFDF5',
          100: '#D1FAE5',
          500: '#10B981',
          600: '#059669',
          700: '#047857',
        },
        warning: {
          50: '#FFFAEB',
          100: '#FEF3C7',
          500: '#F59E0B',
          600: '#D97706',
          700: '#B45309',
        },
        error: {
          50: '#FEF2F2',
          100: '#FEE2E2',
          500: '#EF4444',
          600: '#DC2626',
          700: '#B91C1C',
        },
        // Tournament status colors
        tournament: {
          draft: '#64748B',
          published: '#06B6D4',
          registration_open: '#10B981',
          registration_closed: '#64748B',
          in_progress: '#EF4444',
          completed: '#8B5CF6',
          cancelled: '#64748B',
          waitlisted: '#F59E0B',
          confirmed: '#10B981',
        },
        // Surface colors for dark/light themes
        surface: {
          dark: {
            background: '#181E29',
            surface: '#1F2735',
            card: '#252F3F',
            cardElevated: '#2D3A4E',
            overlay: '#141A24',
          },
          light: {
            background: '#E2E8F0',
            surface: '#EDF2F7',
            card: '#F8FAFC',
            cardElevated: '#FFFFFF',
            overlay: '#E2E8F0',
          },
        },
        // Text colors
        text: {
          dark: {
            primary: '#F8FAFC',
            secondary: '#94A3B8',
            tertiary: '#64748B',
            inverse: '#181E29',
          },
          light: {
            primary: '#181E29',
            secondary: '#475569',
            tertiary: '#64748B',
            inverse: '#F8FAFC',
          },
        },
        // Border colors
        borderColor: {
          dark: {
            primary: '#334155',
            subtle: '#1E293B',
          },
          light: {
            primary: '#CBD5E1',
            subtle: '#E2E8F0',
          },
        },
        // Focus colors
        focus: {
          ring: '#E58E26',
          ringOffset: '#181E29',
        },
        // Shadcn/ui compatibility
        border: 'hsl(var(--border))',
        input: 'hsl(var(--input))',
        ring: 'hsl(var(--ring))',
        background: 'hsl(var(--background))',
        foreground: 'hsl(var(--foreground))',
        card: {
          DEFAULT: 'hsl(var(--card))',
          foreground: 'hsl(var(--card-foreground))',
        },
        popover: {
          DEFAULT: 'hsl(var(--popover))',
          foreground: 'hsl(var(--popover-foreground))',
        },
        muted: {
          DEFAULT: 'hsl(var(--muted))',
          foreground: 'hsl(var(--muted-foreground))',
        },
        accent: {
          DEFAULT: 'hsl(var(--accent))',
          foreground: 'hsl(var(--accent-foreground))',
        },
        destructive: {
          DEFAULT: 'hsl(var(--destructive))',
          foreground: 'hsl(var(--destructive-foreground))',
        },
      },
      fontFamily: {
        sans: ['Inter', 'system-ui', 'sans-serif'],
        heading: ['Space Grotesk', 'Inter', 'system-ui', 'sans-serif'],
        mono: ['JetBrains Mono', 'monospace'],
      },
      fontSize: {
        'display-xl': ['57px', { lineHeight: '1.12', letterSpacing: '-0.02em', fontWeight: '700' }],
        'display-lg': ['45px', { lineHeight: '1.16', letterSpacing: '0', fontWeight: '700' }],
        'display-md': ['36px', { lineHeight: '1.22', letterSpacing: '0', fontWeight: '600' }],
        'headline-lg': ['32px', { lineHeight: '1.25', letterSpacing: '0', fontWeight: '600' }],
        'headline-md': ['28px', { lineHeight: '1.29', letterSpacing: '0', fontWeight: '600' }],
        'headline-sm': ['24px', { lineHeight: '1.33', letterSpacing: '0', fontWeight: '600' }],
        'title-lg': ['22px', { lineHeight: '1.27', letterSpacing: '0', fontWeight: '600' }],
        'title-md': ['16px', { lineHeight: '1.5', letterSpacing: '0.01em', fontWeight: '600' }],
        'title-sm': ['14px', { lineHeight: '1.43', letterSpacing: '0.01em', fontWeight: '600' }],
        'body-lg': ['16px', { lineHeight: '1.5', letterSpacing: '0.005em', fontWeight: '400' }],
        'body-md': ['14px', { lineHeight: '1.43', letterSpacing: '0.0025em', fontWeight: '400' }],
        'body-sm': ['12px', { lineHeight: '1.33', letterSpacing: '0.004em', fontWeight: '400' }],
        'label-lg': ['14px', { lineHeight: '1.43', letterSpacing: '0.001em', fontWeight: '500' }],
        'label-md': ['12px', { lineHeight: '1.33', letterSpacing: '0.005em', fontWeight: '500' }],
        'label-sm': ['11px', { lineHeight: '1.45', letterSpacing: '0.005em', fontWeight: '500' }],
      },
      spacing: {
        '18': '4.5rem',
        '88': '22rem',
        '128': '32rem',
      },
      borderRadius: {
        '4xl': '2rem',
        '3xl': '1.5rem',
      },
      boxShadow: {
        'level-1': '0 1px 4px 0 rgb(0 0 0 / 0.1), 0 1px 2px -1px rgb(0 0 0 / 0.05)',
        'level-2': '0 2px 8px 0 rgb(0 0 0 / 0.1), 0 1px 2px -1px rgb(0 0 0 / 0.05)',
        'level-3': '0 4px 16px 0 rgb(0 0 0 / 0.1), 0 2px 4px -1px rgb(0 0 0 / 0.05)',
        'level-4': '0 8px 24px 0 rgb(0 0 0 / 0.1), 0 4px 8px -1px rgb(0 0 0 / 0.05)',
        'card': '0 1px 4px 0 rgb(0 0 0 / 0.1), 0 1px 2px -1px rgb(0 0 0 / 0.05)',
        'card-hover': '0 4px 12px 0 rgb(0 0 0 / 0.08), 0 2px 4px -1px rgb(0 0 0 / 0.04)',
      },
      animation: {
        'fade-in': 'fadeIn 200ms ease-out',
        'slide-up': 'slideUp 300ms ease-out',
        'slide-down': 'slideDown 300ms ease-out',
        'scale-in': 'scaleIn 200ms ease-out',
        'shimmer': 'shimmer 1.5s ease-in-out infinite',
      },
      keyframes: {
        fadeIn: {
          '0%': { opacity: '0' },
          '100%': { opacity: '1' },
        },
        slideUp: {
          '0%': { opacity: '0', transform: 'translateY(10px)' },
          '100%': { opacity: '1', transform: 'translateY(0)' },
        },
        slideDown: {
          '0%': { opacity: '0', transform: 'translateY(-10px)' },
          '100%': { opacity: '1', transform: 'translateY(0)' },
        },
        scaleIn: {
          '0%': { opacity: '0', transform: 'scale(0.95)' },
          '100%': { opacity: '1', transform: 'scale(1)' },
        },
        shimmer: {
          '0%': { backgroundPosition: '-200% 0' },
          '100%': { backgroundPosition: '200% 0' },
        },
      },
    },
  },
  plugins: [],
};

export default config;