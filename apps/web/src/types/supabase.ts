/// Supabase Database Types
/// GENERATED FILE - DO NOT EDIT MANUALLY
/// Run `pnpm supabase:types` in apps/web to regenerate
///
/// This is a placeholder file. Actual types will be generated from the Supabase schema.
/// See package.json script: "supabase:types": "supabase gen types typescript --local > src/types/supabase.ts"

export type Json =
  | string
  | number
  | boolean
  | null
  | { [key: string]: Json | undefined }
  | Json[];

export interface Database {
  public: {
    Tables: {
      // Core tables - will be populated by Supabase CLI
      profiles: {
        Row: {
          id: string;
          display_name: string;
          avatar_url: string | null;
          in_game_name: string | null;
          in_game_uid: string | null;
          privacy_profile_visibility: 'public' | 'organizers_only' | 'private';
          privacy_show_in_game_info: boolean;
          notification_prefs: Json;
          created_at: string;
          updated_at: string;
          deleted_at: string | null;
        };
        Insert: {
          id: string;
          display_name: string;
          avatar_url?: string | null;
          in_game_name?: string | null;
          in_game_uid?: string | null;
          privacy_profile_visibility?: 'public' | 'organizers_only' | 'private';
          privacy_show_in_game_info?: boolean;
          notification_prefs?: Json;
          created_at?: string;
          updated_at?: string;
          deleted_at?: string | null;
        };
        Update: {
          id?: string;
          display_name?: string;
          avatar_url?: string | null;
          in_game_name?: string | null;
          in_game_uid?: string | null;
          privacy_profile_visibility?: 'public' | 'organizers_only' | 'private';
          privacy_show_in_game_info?: boolean;
          notification_prefs?: Json;
          created_at?: string;
          updated_at?: string;
          deleted_at?: string | null;
        };
      };
      organizations: {
        Row: {
          id: string;
          name: string;
          description: string | null;
          logo_url: string | null;
          contact_email: string;
          website_url: string | null;
          status: 'pending' | 'approved' | 'suspended';
          approved_by: string | null;
          approved_at: string | null;
          created_at: string;
          updated_at: string;
        };
        Insert: {
          id?: string;
          name: string;
          description?: string | null;
          logo_url?: string | null;
          contact_email: string;
          website_url?: string | null;
          status?: 'pending' | 'approved' | 'suspended';
          approved_by?: string | null;
          approved_at?: string | null;
          created_at?: string;
          updated_at?: string;
        };
        Update: {
          id?: string;
          name?: string;
          description?: string | null;
          logo_url?: string | null;
          contact_email?: string;
          website_url?: string | null;
          status?: 'pending' | 'approved' | 'suspended';
          approved_by?: string | null;
          approved_at?: string | null;
          created_at?: string;
          updated_at?: string;
        };
      };
      tournaments: {
        Row: {
          id: string;
          organization_id: string;
          created_by: string;
          title: string;
          description: string | null;
          format: 'solo' | 'squad';
          roster_size: number;
          max_substitutes: number;
          mode: string;
          map: string | null;
          status: 'draft' | 'published' | 'registration_open' | 'registration_closed' | 'scheduled' | 'check_in' | 'live' | 'provisional_results' | 'dispute_period' | 'finalized' | 'cancelled';
          capacity: number;
          registration_opens_at: string;
          registration_closes_at: string;
          check_in_opens_at: string | null;
          check_in_closes_at: string | null;
          starts_at: string;
          ends_at: string;
          timezone: string;
          rules_markdown: string | null;
          eligibility_criteria: Json;
          prize_description: string | null;
          cancelled_at: string | null;
          cancellation_reason: string | null;
          created_at: string;
          updated_at: string;
        };
        Insert: {
          id?: string;
          organization_id: string;
          created_by: string;
          title: string;
          description?: string | null;
          format: 'solo' | 'squad';
          roster_size?: number;
          max_substitutes?: number;
          mode: string;
          map?: string | null;
          status?: 'draft' | 'published' | 'registration_open' | 'registration_closed' | 'scheduled' | 'check_in' | 'live' | 'provisional_results' | 'dispute_period' | 'finalized' | 'cancelled';
          capacity: number;
          registration_opens_at: string;
          registration_closes_at: string;
          check_in_opens_at?: string | null;
          check_in_closes_at?: string | null;
          starts_at: string;
          ends_at: string;
          timezone?: string;
          rules_markdown?: string | null;
          eligibility_criteria?: Json;
          prize_description?: string | null;
          cancelled_at?: string | null;
          cancellation_reason?: string | null;
          created_at?: string;
          updated_at?: string;
        };
        Update: {
          id?: string;
          organization_id?: string;
          created_by?: string;
          title?: string;
          description?: string | null;
          format?: 'solo' | 'squad';
          roster_size?: number;
          max_substitutes?: number;
          mode?: string;
          map?: string | null;
          status?: 'draft' | 'published' | 'registration_open' | 'registration_closed' | 'scheduled' | 'check_in' | 'live' | 'provisional_results' | 'dispute_period' | 'finalized' | 'cancelled';
          capacity?: number;
          registration_opens_at?: string;
          registration_closes_at?: string;
          check_in_opens_at?: string | null;
          check_in_closes_at?: string | null;
          starts_at?: string;
          ends_at?: string;
          timezone?: string;
          rules_markdown?: string | null;
          eligibility_criteria?: Json;
          prize_description?: string | null;
          cancelled_at?: string | null;
          cancellation_reason?: string | null;
          created_at?: string;
          updated_at?: string;
        };
      };
      // Additional tables would be defined here...
    };
    Views: {
      [_ in never]: never;
    };
    Functions: {
      // RPC functions
      register_tournament_entry: {
        Args: { tournament_id: string; team_id?: string };
        Returns: { entry_id: string; status: 'confirmed' | 'waitlisted'; position?: number };
      };
      get_match_credentials: {
        Args: { match_id: string };
        Returns: { room_id: string; password: string } | null;
      };
      // ... more functions
    };
    Enums: {
      profile_visibility: 'public' | 'organizers_only' | 'private';
      organization_status: 'pending' | 'approved' | 'suspended';
      org_member_role: 'owner' | 'admin' | 'member';
      platform_role: 'moderator' | 'admin';
      tournament_format: 'solo' | 'squad';
      tournament_status: 'draft' | 'published' | 'registration_open' | 'registration_closed' | 'scheduled' | 'check_in' | 'live' | 'provisional_results' | 'dispute_period' | 'finalized' | 'cancelled';
      entry_status: 'confirmed' | 'withdrawn' | 'disqualified';
      waitlist_status: 'waiting' | 'promoted' | 'expired' | 'withdrawn';
      match_status: 'scheduled' | 'credential_released' | 'live' | 'completed' | 'cancelled';
      dispute_status: 'submitted' | 'under_review' | 'resolved' | 'rejected';
      notification_type: 'registration_confirmed' | 'waitlist_promoted' | 'match_scheduled' | 'credentials_released' | 'result_published' | 'dispute_update' | 'announcement' | 'system';
      notification_channel: 'push' | 'in_app' | 'email';
      delivery_status: 'pending' | 'sent' | 'failed';
      device_platform: 'android' | 'ios' | 'web';
      consent_purpose: 'tournament_registration' | 'notifications_marketing' | 'analytics' | 'third_party_sharing';
      deletion_status: 'pending' | 'verifying' | 'processing' | 'completed' | 'failed';
    };
    CompositeTypes: {
      [_ in never]: never;
    };
  };
}

// Helper type for Supabase client
export type TypedSupabaseClient = import('@supabase/supabase-js').SupabaseClient<Database>;

// Convenience types
export type Profile = Database['public']['Tables']['profiles']['Row'];
export type Organization = Database['public']['Tables']['organizations']['Row'];
export type Tournament = Database['public']['Tables']['tournaments']['Row'];

// Type guards
export function isProfile(obj: unknown): obj is Profile {
  return typeof obj === 'object' && obj !== null && 'id' in obj && 'display_name' in obj;
}

export function isOrganization(obj: unknown): obj is Organization {
  return typeof obj === 'object' && obj !== null && 'id' in obj && 'name' in obj;
}

export function isTournament(obj: unknown): obj is Tournament {
  return typeof obj === 'object' && obj !== null && 'id' in obj && 'title' in obj;
}