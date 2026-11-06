/// Supabase Database Types — hand-maintained to match supabase/migrations.
/// Regenerate with `pnpm supabase:types` once a local database is running.
///
/// Every table/column here must exist in a migration. Keep this file in sync
/// when adding a migration.

export type Json =
  | string
  | number
  | boolean
  | null
  | { [key: string]: Json | undefined }
  | Json[];

export type TournamentFormat = "solo" | "duo" | "squad" | "custom";
export type TournamentStatus =
  | "draft"
  | "published"
  | "registration_open"
  | "registration_closed"
  | "in_progress"
  | "completed"
  | "cancelled";
export type RegistrationStatus =
  | "pending"
  | "confirmed"
  | "waitlisted"
  | "rejected"
  | "cancelled";
export type TournamentVisibility = "public" | "private" | "invite_only";

type Table<Row, Insert, Update> = {
  Row: Row;
  Insert: Insert;
  Update: Update;
  Relationships: [];
};

export interface Database {
  public: {
    Tables: {
      profiles: Table<
        {
          id: string;
          display_name: string;
          username: string | null;
          avatar_url: string | null;
          in_game_name: string | null;
          in_game_uid: string | null;
          privacy_profile_visibility: "public" | "organizers_only" | "private";
          privacy_show_in_game_info: boolean;
          notification_prefs: Json;
          email: string | null;
          terms_accepted: boolean;
          age_attestation: boolean;
          created_at: string;
          updated_at: string;
          deleted_at: string | null;
        },
        {
          id: string;
          display_name: string;
          username?: string | null;
          avatar_url?: string | null;
          in_game_name?: string | null;
          in_game_uid?: string | null;
          privacy_profile_visibility?: "public" | "organizers_only" | "private";
          privacy_show_in_game_info?: boolean;
          notification_prefs?: Json;
          email?: string | null;
          terms_accepted?: boolean;
          age_attestation?: boolean;
          created_at?: string;
          updated_at?: string;
          deleted_at?: string | null;
        },
        {
          display_name?: string;
          username?: string | null;
          avatar_url?: string | null;
          in_game_name?: string | null;
          in_game_uid?: string | null;
          privacy_profile_visibility?: "public" | "organizers_only" | "private";
          privacy_show_in_game_info?: boolean;
          notification_prefs?: Json;
          email?: string | null;
          terms_accepted?: boolean;
          age_attestation?: boolean;
          updated_at?: string;
          deleted_at?: string | null;
        }
      >;
      tournaments: Table<
        {
          id: string;
          organizer_id: string;
          title: string;
          description: string | null;
          format: TournamentFormat;
          mode: string;
          map: string | null;
          max_teams: number;
          team_size: number;
          registration_starts_at: string;
          registration_ends_at: string;
          tournament_starts_at: string;
          tournament_ends_at: string | null;
          prize_pool: string | null;
          rules_url: string | null;
          rules_text: string | null;
          cover_url: string | null;
          contact_info: string | null;
          status: TournamentStatus;
          visibility: TournamentVisibility;
          eligibility: Json;
          waitlist_enabled: boolean;
          withdrawal_deadline: string | null;
          published_at: string | null;
          registration_opened_at: string | null;
          registration_closed_at: string | null;
          cancelled_at: string | null;
          cancellation_reason: string | null;
          created_at: string;
          updated_at: string;
          deleted_at: string | null;
        },
        {
          id?: string;
          organizer_id: string;
          title: string;
          description?: string | null;
          format: TournamentFormat;
          mode: string;
          map?: string | null;
          max_teams?: number;
          team_size?: number;
          registration_starts_at: string;
          registration_ends_at: string;
          tournament_starts_at: string;
          tournament_ends_at?: string | null;
          prize_pool?: string | null;
          rules_url?: string | null;
          rules_text?: string | null;
          cover_url?: string | null;
          contact_info?: string | null;
          status?: TournamentStatus;
          visibility?: TournamentVisibility;
          eligibility?: Json;
          waitlist_enabled?: boolean;
          withdrawal_deadline?: string | null;
          published_at?: string | null;
          registration_opened_at?: string | null;
          registration_closed_at?: string | null;
          cancelled_at?: string | null;
          cancellation_reason?: string | null;
          created_at?: string;
          updated_at?: string;
          deleted_at?: string | null;
        },
        {
          title?: string;
          description?: string | null;
          format?: TournamentFormat;
          mode?: string;
          map?: string | null;
          max_teams?: number;
          team_size?: number;
          registration_starts_at?: string;
          registration_ends_at?: string;
          tournament_starts_at?: string;
          tournament_ends_at?: string | null;
          prize_pool?: string | null;
          rules_url?: string | null;
          rules_text?: string | null;
          cover_url?: string | null;
          contact_info?: string | null;
          status?: TournamentStatus;
          visibility?: TournamentVisibility;
          eligibility?: Json;
          waitlist_enabled?: boolean;
          withdrawal_deadline?: string | null;
          published_at?: string | null;
          registration_opened_at?: string | null;
          registration_closed_at?: string | null;
          cancelled_at?: string | null;
          cancellation_reason?: string | null;
          deleted_at?: string | null;
          updated_at?: string;
        }
      >;
      tournament_organizers: Table<
        {
          tournament_id: string;
          user_id: string;
          role: "owner" | "organizer" | "moderator";
          joined_at: string;
        },
        {
          tournament_id: string;
          user_id: string;
          role?: "owner" | "organizer" | "moderator";
          joined_at?: string;
        },
        {
          role?: "owner" | "organizer" | "moderator";
        }
      >;
      tournament_registrations: Table<
        {
          id: string;
          tournament_id: string;
          user_id: string;
          team_id: string | null;
          entry_type: "solo" | "squad" | null;
          team_name: string | null;
          team_members: string[];
          roster_snapshot: Json;
          status: RegistrationStatus;
          waitlist_seq: number | null;
          waitlisted_at: string | null;
          promoted_at: string | null;
          withdrawn_at: string | null;
          cancellation_reason: string | null;
          registered_at: string;
          confirmed_at: string | null;
        },
        {
          id?: string;
          tournament_id: string;
          user_id: string;
          team_id?: string | null;
          entry_type?: "solo" | "squad" | null;
          team_name?: string | null;
          team_members?: string[];
          roster_snapshot?: Json;
          status?: RegistrationStatus;
          waitlist_seq?: number | null;
          waitlisted_at?: string | null;
          promoted_at?: string | null;
          withdrawn_at?: string | null;
          cancellation_reason?: string | null;
          registered_at?: string;
          confirmed_at?: string | null;
        },
        {
          team_id?: string | null;
          entry_type?: "solo" | "squad" | null;
          team_name?: string | null;
          team_members?: string[];
          roster_snapshot?: Json;
          status?: RegistrationStatus;
          waitlist_seq?: number | null;
          waitlisted_at?: string | null;
          promoted_at?: string | null;
          withdrawn_at?: string | null;
          cancellation_reason?: string | null;
          confirmed_at?: string | null;
        }
      >;
      tournament_entry_members: Table<
        {
          entry_id: string;
          tournament_id: string;
          user_id: string;
          role: "captain" | "member";
          in_game_name: string | null;
          in_game_uid: string | null;
          created_at: string;
        },
        {
          entry_id: string;
          tournament_id: string;
          user_id: string;
          role?: "captain" | "member";
          in_game_name?: string | null;
          in_game_uid?: string | null;
          created_at?: string;
        },
        {
          role?: "captain" | "member";
          in_game_name?: string | null;
          in_game_uid?: string | null;
        }
      >;
      teams: Table<
        {
          id: string;
          name: string;
          tag: string | null;
          owner_id: string;
          captain_id: string | null;
          description: string | null;
          avatar_url: string | null;
          is_public: boolean;
          max_members: number;
          created_at: string;
          updated_at: string;
          deleted_at: string | null;
        },
        {
          id?: string;
          name: string;
          tag?: string | null;
          owner_id: string;
          captain_id?: string | null;
          description?: string | null;
          avatar_url?: string | null;
          is_public?: boolean;
          max_members?: number;
          created_at?: string;
          updated_at?: string;
          deleted_at?: string | null;
        },
        {
          name?: string;
          tag?: string | null;
          owner_id?: string;
          captain_id?: string | null;
          description?: string | null;
          avatar_url?: string | null;
          is_public?: boolean;
          max_members?: number;
          deleted_at?: string | null;
        }
      >;
      team_members: Table<
        {
          team_id: string;
          user_id: string;
          role: "owner" | "captain" | "member";
          joined_at: string;
        },
        {
          team_id: string;
          user_id: string;
          role?: "owner" | "captain" | "member";
          joined_at?: string;
        },
        {
          role?: "owner" | "captain" | "member";
        }
      >;
      team_invitations: Table<
        {
          id: string;
          team_id: string;
          invited_by: string;
          invited_user_id: string | null;
          email: string | null;
          token_hash: string;
          status: "pending" | "accepted" | "declined" | "revoked" | "expired";
          expires_at: string;
          accepted_by: string | null;
          created_at: string;
          responded_at: string | null;
        },
        {
          id?: string;
          team_id: string;
          invited_by: string;
          invited_user_id?: string | null;
          email?: string | null;
          token_hash: string;
          status?: "pending" | "accepted" | "declined" | "revoked" | "expired";
          expires_at: string;
          accepted_by?: string | null;
          created_at?: string;
          responded_at?: string | null;
        },
        {
          status?: "pending" | "accepted" | "declined" | "revoked" | "expired";
          accepted_by?: string | null;
          responded_at?: string | null;
        }
      >;
      team_member_events: Table<
        {
          id: string;
          team_id: string;
          actor_id: string | null;
          event_type: string;
          subject_user_id: string | null;
          metadata: Json;
          created_at: string;
        },
        {
          id?: string;
          team_id: string;
          actor_id?: string | null;
          event_type: string;
          subject_user_id?: string | null;
          metadata?: Json;
          created_at?: string;
        },
        {
          event_type?: string;
          metadata?: Json;
        }
      >;
      notifications: Table<
        {
          id: string;
          user_id: string;
          type: string;
          title: string;
          body: string | null;
          data: Json;
          read_at: string | null;
          created_at: string;
        },
        {
          id?: string;
          user_id: string;
          type: string;
          title: string;
          body?: string | null;
          data?: Json;
          read_at?: string | null;
          created_at?: string;
        },
        {
          read_at?: string | null;
        }
      >;
      audit_logs: Table<
        {
          id: string;
          user_id: string | null;
          action: string;
          resource_type: string;
          resource_id: string | null;
          old_data: Json | null;
          new_data: Json | null;
          ip_address: string | null;
          user_agent: string | null;
          created_at: string;
        },
        {
          id?: string;
          user_id?: string | null;
          action: string;
          resource_type: string;
          resource_id?: string | null;
          old_data?: Json | null;
          new_data?: Json | null;
          ip_address?: string | null;
          user_agent?: string | null;
          created_at?: string;
        },
        {
          read_at?: never;
        }
      >;
      matches: Table<
        {
          id: string;
          tournament_id: string;
          round_number: number;
          match_number: number;
          team_a_id: string | null;
          team_b_id: string | null;
          winner_id: string | null;
          status: "scheduled" | "in_progress" | "completed" | "cancelled" | "disputed";
          scheduled_at: string | null;
          started_at: string | null;
          ended_at: string | null;
          score_a: number | null;
          score_b: number | null;
          metadata: Json | null;
          created_at: string;
          updated_at: string;
        },
        {
          id?: string;
          tournament_id: string;
          round_number: number;
          match_number: number;
          team_a_id?: string | null;
          team_b_id?: string | null;
          winner_id?: string | null;
          status?: "scheduled" | "in_progress" | "completed" | "cancelled" | "disputed";
          scheduled_at?: string | null;
          started_at?: string | null;
          ended_at?: string | null;
          score_a?: number | null;
          score_b?: number | null;
          metadata?: Json | null;
          created_at?: string;
          updated_at?: string;
        },
        {
          team_a_id?: string | null;
          team_b_id?: string | null;
          winner_id?: string | null;
          status?: "scheduled" | "in_progress" | "completed" | "cancelled" | "disputed";
          scheduled_at?: string | null;
          started_at?: string | null;
          ended_at?: string | null;
          score_a?: number | null;
          score_b?: number | null;
          metadata?: Json | null;
          updated_at?: string;
        }
      >;
      results: Table<
        {
          id: string;
          match_id: string;
          team_id: string;
          placement: number | null;
          kills: number | null;
          damage: number | null;
          survival_time: string | null;
          metadata: Json | null;
          created_at: string;
        },
        {
          id?: string;
          match_id: string;
          team_id: string;
          placement?: number | null;
          kills?: number | null;
          damage?: number | null;
          survival_time?: string | null;
          metadata?: Json | null;
          created_at?: string;
        },
        {
          placement?: number | null;
          kills?: number | null;
          damage?: number | null;
          survival_time?: string | null;
          metadata?: Json | null;
        }
      >;
    };
    Views: {
      tournament_public_listing: {
        Row: {
          id: string;
          title: string;
          description: string | null;
          format: TournamentFormat;
          mode: string;
          map: string | null;
          max_teams: number;
          team_size: number;
          registration_starts_at: string;
          registration_ends_at: string;
          tournament_starts_at: string;
          tournament_ends_at: string | null;
          prize_pool: string | null;
          rules_url: string | null;
          rules_text: string | null;
          contact_info: string | null;
          status: TournamentStatus;
          visibility: TournamentVisibility;
          eligibility: Json;
          waitlist_enabled: boolean;
          withdrawal_deadline: string | null;
          published_at: string | null;
          created_at: string;
          updated_at: string;
          organizer_name: string;
          confirmed_entries: number;
          waitlisted_entries: number;
        };
        Relationships: [];
      };
    };
    Functions: {
      create_tournament: {
        Args: { p_payload: Json };
        Returns: string;
      };
      update_tournament: {
        Args: { p_tournament_id: string; p_payload: Json };
        Returns: string;
      };
      set_tournament_status: {
        Args: { p_tournament_id: string; p_status: string; p_reason?: string | null };
        Returns: Database["public"]["Tables"]["tournaments"]["Row"];
      };
      register_tournament_entry: {
        Args: { p_tournament_id: string; p_team_id?: string | null };
        Returns: {
          entry_id: string;
          status: "confirmed" | "waitlisted";
          waitlist_position: number | null;
        };
      };
      withdraw_tournament_entry: {
        Args: { p_entry_id: string };
        Returns: {
          entry_id: string;
          status: "cancelled";
          promoted_entry_id: string | null;
        };
      };
      organizer_promote_waitlist: {
        Args: { p_tournament_id: string };
        Returns: string | null;
      };
      create_team: {
        Args: { p_name: string; p_tag?: string | null; p_description?: string | null };
        Returns: string;
      };
      invite_to_team: {
        Args: {
          p_team_id: string;
          p_invited_user_id?: string | null;
          p_email?: string | null;
          p_expires_hours?: number;
        };
        Returns: string;
      };
      accept_team_invitation: {
        Args: { p_token: string };
        Returns: string;
      };
      decline_team_invitation: {
        Args: { p_token: string };
        Returns: undefined;
      };
      revoke_team_invitation: {
        Args: { p_invitation_id: string };
        Returns: undefined;
      };
      remove_team_member: {
        Args: { p_team_id: string; p_user_id: string };
        Returns: undefined;
      };
      transfer_team_captaincy: {
        Args: { p_team_id: string; p_new_captain: string };
        Returns: undefined;
      };
      leave_team: {
        Args: { p_team_id: string };
        Returns: undefined;
      };
      dissolve_team: {
        Args: { p_team_id: string };
        Returns: undefined;
      };
    };
    Enums: {
      [_ in never]: never;
    };
    CompositeTypes: {
      [_ in never]: never;
    };
  };
}

export type TypedSupabaseClient = import("@supabase/supabase-js").SupabaseClient<Database>;

export type Profile = Database["public"]["Tables"]["profiles"]["Row"];
export type Tournament = Database["public"]["Tables"]["tournaments"]["Row"];
export type TournamentListing = Database["public"]["Views"]["tournament_public_listing"]["Row"];
export type TournamentOrganizer = Database["public"]["Tables"]["tournament_organizers"]["Row"];
export type TournamentRegistration =
  Database["public"]["Tables"]["tournament_registrations"]["Row"];
export type TournamentEntryMember =
  Database["public"]["Tables"]["tournament_entry_members"]["Row"];
export type Team = Database["public"]["Tables"]["teams"]["Row"];
export type TeamMember = Database["public"]["Tables"]["team_members"]["Row"];
export type TeamInvitation = Database["public"]["Tables"]["team_invitations"]["Row"];

export function isProfile(obj: unknown): obj is Profile {
  return typeof obj === "object" && obj !== null && "id" in obj && "display_name" in obj;
}

export function isTournament(obj: unknown): obj is Tournament {
  return typeof obj === "object" && obj !== null && "id" in obj && "title" in obj;
}
