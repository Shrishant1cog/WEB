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
          category: string;
          dedupe_key: string | null;
          in_app_visible: boolean;
          push_requested: boolean;
          updated_at: string;
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
          category?: string;
          dedupe_key?: string | null;
          in_app_visible?: boolean;
          push_requested?: boolean;
          updated_at?: string;
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
      notification_preferences: Table<
        {
          user_id: string;
          category: string;
          in_app: boolean;
          push: boolean;
          email: boolean;
          updated_at: string;
        },
        {
          user_id: string;
          category: string;
          in_app?: boolean;
          push?: boolean;
          email?: boolean;
          updated_at?: string;
        },
        {
          in_app?: boolean;
          push?: boolean;
          email?: boolean;
          updated_at?: string;
        }
      >;
      device_tokens: Table<
        {
          id: string;
          user_id: string;
          token: string;
          platform: string;
          device_name: string | null;
          created_at: string;
          updated_at: string;
          last_seen_at: string;
          revoked_at: string | null;
        },
        {
          id?: string;
          user_id: string;
          token: string;
          platform?: string;
          device_name?: string | null;
          created_at?: string;
          updated_at?: string;
          last_seen_at?: string;
          revoked_at?: string | null;
        },
        {
          revoked_at?: string | null;
          last_seen_at?: string;
          updated_at?: string;
        }
      >;
      notification_delivery_queue: Table<
        {
          id: string;
          notification_id: string;
          channel: string;
          status: string;
          attempts: number;
          last_error: string | null;
          next_attempt_at: string;
          locked_at: string | null;
          sent_at: string | null;
          created_at: string;
          updated_at: string;
        },
        {
          id?: string;
          notification_id: string;
          channel?: string;
          status?: string;
          attempts?: number;
          last_error?: string | null;
          next_attempt_at?: string;
          locked_at?: string | null;
          sent_at?: string | null;
          created_at?: string;
          updated_at?: string;
        },
        {
          status?: string;
          attempts?: number;
          last_error?: string | null;
          next_attempt_at?: string;
          locked_at?: string | null;
          sent_at?: string | null;
          updated_at?: string;
        }
      >;
      scheduled_notifications: Table<
        {
          id: string;
          user_id: string;
          category: string;
          type: string;
          title: string;
          body: string | null;
          data: Json;
          dedupe_key: string | null;
          scheduled_at: string;
          processed_at: string | null;
          created_at: string;
        },
        {
          id?: string;
          user_id: string;
          category?: string;
          type: string;
          title: string;
          body?: string | null;
          data?: Json;
          dedupe_key?: string | null;
          scheduled_at: string;
          processed_at?: string | null;
          created_at?: string;
        },
        {
          scheduled_at?: string;
          processed_at?: string | null;
        }
      >;
      tournament_announcements: Table<
        {
          id: string;
          tournament_id: string;
          author_id: string;
          title: string;
          body: string;
          pinned: boolean;
          published_at: string;
          created_at: string;
        },
        {
          id?: string;
          tournament_id: string;
          author_id: string;
          title: string;
          body: string;
          pinned?: boolean;
          published_at?: string;
          created_at?: string;
        },
        {
          title?: string;
          body?: string;
          pinned?: boolean;
        }
      >;
      platform_admins: Table<
        {
          user_id: string;
          role: "super_admin" | "admin" | "support";
          granted_by: string | null;
          granted_at: string;
          revoked_at: string | null;
          notes: string | null;
        },
        {
          user_id: string;
          role?: "super_admin" | "admin" | "support";
          granted_by?: string | null;
          granted_at?: string;
          revoked_at?: string | null;
          notes?: string | null;
        },
        {
          role?: "super_admin" | "admin" | "support";
          granted_by?: string | null;
          granted_at?: string;
          revoked_at?: string | null;
          notes?: string | null;
        }
      >;
      account_suspensions: Table<
        {
          user_id: string;
          status: "active" | "suspended" | "banned";
          suspended_at: string | null;
          suspended_by: string | null;
          reason: string | null;
          updated_at: string;
        },
        {
          user_id: string;
          status?: "active" | "suspended" | "banned";
          suspended_at?: string | null;
          suspended_by?: string | null;
          reason?: string | null;
          updated_at?: string;
        },
        {
          status?: "active" | "suspended" | "banned";
          suspended_at?: string | null;
          suspended_by?: string | null;
          reason?: string | null;
          updated_at?: string;
        }
      >;
      organizer_accounts: Table<
        {
          user_id: string;
          status: "pending" | "approved" | "suspended";
          organization_name: string | null;
          contact_note: string | null;
          approved_by: string | null;
          approved_at: string | null;
          suspended_at: string | null;
          suspension_reason: string | null;
          created_at: string;
          updated_at: string;
        },
        {
          user_id: string;
          status?: "pending" | "approved" | "suspended";
          organization_name?: string | null;
          contact_note?: string | null;
          approved_by?: string | null;
          approved_at?: string | null;
          suspended_at?: string | null;
          suspension_reason?: string | null;
          created_at?: string;
          updated_at?: string;
        },
        {
          status?: "pending" | "approved" | "suspended";
          organization_name?: string | null;
          contact_note?: string | null;
          approved_by?: string | null;
          approved_at?: string | null;
          suspended_at?: string | null;
          suspension_reason?: string | null;
          updated_at?: string;
        }
      >;
      platform_settings: Table<
        {
          key: string;
          value: Json;
          description: string | null;
          is_public: boolean;
          updated_by: string | null;
          updated_at: string;
        },
        {
          key: string;
          value: Json;
          description?: string | null;
          is_public?: boolean;
          updated_by?: string | null;
          updated_at?: string;
        },
        {
          value?: Json;
          description?: string | null;
          is_public?: boolean;
          updated_by?: string | null;
          updated_at?: string;
        }
      >;
      abuse_reports: Table<
        {
          id: string;
          reporter_id: string;
          category: string;
          subject_type: string;
          subject_id: string | null;
          tournament_id: string | null;
          description: string;
          evidence_paths: string[];
          status: string;
          severity: string;
          assigned_admin_id: string | null;
          resolution: string | null;
          resolved_at: string | null;
          created_at: string;
          updated_at: string;
        },
        {
          id?: string;
          reporter_id: string;
          category: string;
          subject_type: string;
          subject_id?: string | null;
          tournament_id?: string | null;
          description: string;
          evidence_paths?: string[];
          status?: string;
          severity?: string;
          assigned_admin_id?: string | null;
          resolution?: string | null;
          resolved_at?: string | null;
          created_at?: string;
          updated_at?: string;
        },
        {
          status?: string;
          severity?: string;
          assigned_admin_id?: string | null;
          resolution?: string | null;
          resolved_at?: string | null;
          updated_at?: string;
        }
      >;
      abuse_report_events: Table<
        {
          id: string;
          report_id: string;
          actor_id: string | null;
          event_type: string;
          from_status: string | null;
          to_status: string | null;
          note: string | null;
          created_at: string;
        },
        {
          id?: string;
          report_id: string;
          actor_id?: string | null;
          event_type: string;
          from_status?: string | null;
          to_status?: string | null;
          note?: string | null;
          created_at?: string;
        },
        {
          note?: string | null;
        }
      >;
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
      platform_admin_role: {
        Args: { p_user_id?: string };
        Returns: string | null;
      };
      is_platform_admin: {
        Args: { p_user_id?: string };
        Returns: boolean;
      };
      account_status: {
        Args: { p_user_id?: string };
        Returns: string;
      };
      is_account_active: {
        Args: { p_user_id?: string };
        Returns: boolean;
      };
      mark_notification_read: {
        Args: { p_notification_id: string };
        Returns: boolean;
      };
      mark_all_notifications_read: {
        Args: Record<string, never>;
        Returns: number;
      };
      set_notification_preference: {
        Args: { p_category: string; p_in_app: boolean; p_push: boolean; p_email?: boolean };
        Returns: undefined;
      };
      register_device_token: {
        Args: { p_token: string; p_platform?: string; p_device_name?: string | null };
        Returns: string;
      };
      remove_device_token: {
        Args: { p_token: string };
        Returns: boolean;
      };
      process_scheduled_notifications: {
        Args: { p_limit?: number };
        Returns: number;
      };
      create_tournament_announcement: {
        Args: { p_tournament_id: string; p_title: string; p_body: string; p_pinned?: boolean };
        Returns: string;
      };
      request_organizer_account: {
        Args: { p_organization_name?: string | null; p_contact_note?: string | null };
        Returns: string;
      };
      submit_abuse_report: {
        Args: {
          p_category: string;
          p_subject_type: string;
          p_description: string;
          p_subject_id?: string | null;
          p_tournament_id?: string | null;
          p_evidence_paths?: string[];
        };
        Returns: string;
      };
      admin_search_users: {
        Args: { p_query?: string | null; p_limit?: number; p_offset?: number };
        Returns: {
          user_id: string;
          display_name: string;
          username: string | null;
          email: string | null;
          account_status: string;
          created_at: string;
          is_platform_admin: boolean;
          organizer_status: string | null;
        }[];
      };
      admin_get_user: {
        Args: { p_user_id: string };
        Returns: Json;
      };
      admin_suspend_user: {
        Args: { p_user_id: string; p_reason: string };
        Returns: undefined;
      };
      admin_restore_user: {
        Args: { p_user_id: string; p_note?: string | null };
        Returns: undefined;
      };
      admin_list_organizers: {
        Args: { p_status?: string | null; p_limit?: number; p_offset?: number };
        Returns: {
          user_id: string;
          display_name: string;
          email: string | null;
          status: string;
          organization_name: string | null;
          contact_note: string | null;
          approved_at: string | null;
          suspended_at: string | null;
          suspension_reason: string | null;
          created_at: string;
        }[];
      };
      admin_set_organizer_status: {
        Args: {
          p_user_id: string;
          p_status: string;
          p_reason?: string | null;
          p_organization_name?: string | null;
        };
        Returns: undefined;
      };
      admin_list_tournaments: {
        Args: { p_query?: string | null; p_status?: string | null; p_limit?: number; p_offset?: number };
        Returns: {
          tournament_id: string;
          title: string;
          organizer_id: string;
          organizer_name: string;
          status: string;
          visibility: string;
          format: string;
          max_teams: number;
          registered_count: number;
          created_at: string;
        }[];
      };
      admin_assign_moderator: {
        Args: { p_tournament_id: string; p_user_id: string };
        Returns: undefined;
      };
      admin_remove_moderator: {
        Args: { p_tournament_id: string; p_user_id: string };
        Returns: boolean;
      };
      admin_list_moderators: {
        Args: { p_tournament_id: string };
        Returns: {
          user_id: string;
          display_name: string;
          email: string | null;
          assigned_at: string;
        }[];
      };
      admin_search_audit_logs: {
        Args: { p_query?: string | null; p_action?: string | null; p_limit?: number; p_offset?: number };
        Returns: {
          id: string;
          user_id: string | null;
          action: string;
          resource_type: string;
          resource_id: string | null;
          old_data: Json | null;
          new_data: Json | null;
          created_at: string;
        }[];
      };
      admin_platform_metrics: {
        Args: Record<string, never>;
        Returns: Json;
      };
      admin_set_platform_setting: {
        Args: {
          p_key: string;
          p_value: Json;
          p_is_public?: boolean;
          p_description?: string | null;
        };
        Returns: undefined;
      };
      admin_grant_platform_admin: {
        Args: { p_user_id: string; p_role: string; p_notes?: string | null };
        Returns: undefined;
      };
      admin_revoke_platform_admin: {
        Args: { p_user_id: string; p_note?: string | null };
        Returns: undefined;
      };
      admin_triage_abuse_report: {
        Args: {
          p_report_id: string;
          p_status: string;
          p_severity?: string | null;
          p_assigned_admin_id?: string | null;
          p_note?: string | null;
        };
        Returns: undefined;
      };
      admin_resolve_abuse_report: {
        Args: { p_report_id: string; p_resolution: string; p_dismiss?: boolean };
        Returns: undefined;
      };
      create_notification: {
        Args: {
          p_user_id: string;
          p_type: string;
          p_title: string;
          p_body: string | null;
          p_data: Json;
          p_category: string | null;
          p_dedupe_key: string | null;
        };
        Returns: string | null;
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
