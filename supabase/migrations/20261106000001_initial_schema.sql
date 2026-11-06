-- Initial schema for FFT tournament management platform
-- Migration: 20261106000001_initial_schema

-- Enable required extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- ============================================
-- PROFILES TABLE
-- ============================================
CREATE TABLE profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    display_name TEXT NOT NULL CHECK (char_length(display_name) BETWEEN 1 AND 50),
    username TEXT UNIQUE CHECK (username IS NULL OR username ~ '^[a-zA-Z0-9_]{3,20}$'),
    avatar_url TEXT CHECK (avatar_url IS NULL OR char_length(avatar_url) <= 500),
    in_game_name TEXT CHECK (in_game_name IS NULL OR char_length(in_game_name) <= 30),
    in_game_uid TEXT CHECK (in_game_uid IS NULL OR in_game_uid ~ '^\d{8,12}$'),
    privacy_profile_visibility TEXT NOT NULL DEFAULT 'public'
        CHECK (privacy_profile_visibility IN ('public', 'organizers_only', 'private')),
    privacy_show_in_game_info BOOLEAN NOT NULL DEFAULT false,
    notification_prefs JSONB NOT NULL DEFAULT '{
        "email_tournament_invites": true,
        "email_match_reminders": true,
        "push_tournament_updates": true,
        "push_match_results": true,
        "push_team_invites": true,
        "email_weekly_digest": false
    }'::jsonb,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    deleted_at TIMESTAMPTZ
);

-- Indexes
CREATE INDEX idx_profiles_username ON profiles(username) WHERE username IS NOT NULL;
CREATE INDEX idx_profiles_in_game_uid ON profiles(in_game_uid) WHERE in_game_uid IS NOT NULL;
CREATE INDEX idx_profiles_deleted_at ON profiles(deleted_at) WHERE deleted_at IS NOT NULL;

-- RLS Policies
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;

-- Users can read their own profile
CREATE POLICY "Users can read own profile"
    ON profiles FOR SELECT
    USING (auth.uid() = id);

-- Public profiles are readable by everyone
CREATE POLICY "Public profiles are readable"
    ON profiles FOR SELECT
    USING (privacy_profile_visibility = 'public');

-- Organizers can read profiles in their tournaments
CREATE POLICY "Organizers can read tournament profiles"
    ON profiles FOR SELECT
    USING (
        privacy_profile_visibility = 'organizers_only' AND
        EXISTS (
            SELECT 1 FROM tournament_organizers
            WHERE tournament_organizers.user_id = auth.uid()
            AND tournament_organizers.tournament_id IN (
                SELECT tournament_id FROM tournament_registrations
                WHERE tournament_registrations.user_id = profiles.id
            )
        )
    );

-- Users can update their own profile
CREATE POLICY "Users can update own profile"
    ON profiles FOR UPDATE
    USING (auth.uid() = id)
    WITH CHECK (auth.uid() = id);

-- Users can insert their own profile (on signup)
CREATE POLICY "Users can insert own profile"
    ON profiles FOR INSERT
    WITH CHECK (auth.uid() = id);

-- Soft delete - users can mark own profile as deleted
CREATE POLICY "Users can soft delete own profile"
    ON profiles FOR UPDATE
    USING (auth.uid() = id)
    WITH CHECK (auth.uid() = id AND deleted_at IS NOT NULL);

-- Function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Trigger for updated_at
CREATE TRIGGER update_profiles_updated_at
    BEFORE UPDATE ON profiles
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- ============================================
-- TOURNAMENTS TABLE (placeholder for future)
-- ============================================
CREATE TABLE tournaments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    organizer_id UUID NOT NULL REFERENCES profiles(id) ON DELETE RESTRICT,
    title TEXT NOT NULL CHECK (char_length(title) BETWEEN 3 AND 100),
    description TEXT CHECK (char_length(description) <= 5000),
    format TEXT NOT NULL CHECK (format IN ('solo', 'duo', 'squad', 'custom')),
    mode TEXT NOT NULL CHECK (mode IN ('br', 'cs', 'tdm', 'custom')),
    map TEXT,
    max_teams INTEGER NOT NULL DEFAULT 50 CHECK (max_teams > 0 AND max_teams <= 200),
    team_size INTEGER NOT NULL DEFAULT 4 CHECK (team_size IN (1, 2, 4)),
    registration_starts_at TIMESTAMPTZ NOT NULL,
    registration_ends_at TIMESTAMPTZ NOT NULL,
    tournament_starts_at TIMESTAMPTZ NOT NULL,
    tournament_ends_at TIMESTAMPTZ,
    prize_pool TEXT,
    rules_url TEXT,
    contact_info TEXT,
    status TEXT NOT NULL DEFAULT 'draft'
        CHECK (status IN ('draft', 'published', 'registration_open', 'registration_closed', 'in_progress', 'completed', 'cancelled')),
    visibility TEXT NOT NULL DEFAULT 'public' CHECK (visibility IN ('public', 'private', 'invite_only')),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    deleted_at TIMESTAMPTZ,
    CONSTRAINT valid_dates CHECK (registration_starts_at < registration_ends_at AND registration_ends_at <= tournament_starts_at)
);

CREATE INDEX idx_tournaments_organizer ON tournaments(organizer_id);
CREATE INDEX idx_tournaments_status ON tournaments(status);
CREATE INDEX idx_tournaments_registration ON tournaments(registration_starts_at, registration_ends_at);

ALTER TABLE tournaments ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Public tournaments are readable"
    ON tournaments FOR SELECT
    USING (visibility = 'public' AND deleted_at IS NULL);

CREATE POLICY "Organizer can manage own tournaments"
    ON tournaments FOR ALL
    USING (auth.uid() = organizer_id)
    WITH CHECK (auth.uid() = organizer_id);

CREATE POLICY "Organizers can read private tournaments they manage"
    ON tournaments FOR SELECT
    USING (
        visibility IN ('private', 'invite_only') AND
        auth.uid() = organizer_id
    );

CREATE TRIGGER update_tournaments_updated_at
    BEFORE UPDATE ON tournaments
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- ============================================
-- TOURNAMENT ORGANIZERS (many-to-many)
-- ============================================
CREATE TABLE tournament_organizers (
    tournament_id UUID NOT NULL REFERENCES tournaments(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    role TEXT NOT NULL DEFAULT 'organizer' CHECK (role IN ('owner', 'organizer', 'moderator')),
    joined_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    PRIMARY KEY (tournament_id, user_id)
);

ALTER TABLE tournament_organizers ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Tournament organizers can read"
    ON tournament_organizers FOR SELECT
    USING (
        auth.uid() = user_id OR
        EXISTS (
            SELECT 1 FROM tournaments t
            WHERE t.id = tournament_organizers.tournament_id
            AND (t.visibility = 'public' OR t.organizer_id = auth.uid())
        )
    );

CREATE POLICY "Tournament owner can manage organizers"
    ON tournament_organizers FOR ALL
    USING (
        EXISTS (
            SELECT 1 FROM tournament_organizers to2
            WHERE to2.tournament_id = tournament_organizers.tournament_id
            AND to2.user_id = auth.uid()
            AND to2.role = 'owner'
        )
    );

-- ============================================
-- TOURNAMENT REGISTRATIONS
-- ============================================
CREATE TABLE tournament_registrations (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    tournament_id UUID NOT NULL REFERENCES tournaments(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    team_name TEXT CHECK (char_length(team_name) BETWEEN 3 AND 50),
    team_members UUID[] DEFAULT '{}',
    status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'confirmed', 'waitlisted', 'rejected', 'cancelled')),
    registered_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    confirmed_at TIMESTAMPTZ,
    UNIQUE (tournament_id, user_id)
);

CREATE INDEX idx_registrations_tournament ON tournament_registrations(tournament_id);
CREATE INDEX idx_registrations_user ON tournament_registrations(user_id);
CREATE INDEX idx_registrations_status ON tournament_registrations(status);

ALTER TABLE tournament_registrations ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can read own registrations"
    ON tournament_registrations FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Tournament organizers can read registrations"
    ON tournament_registrations FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM tournament_organizers
            WHERE tournament_organizers.tournament_id = tournament_registrations.tournament_id
            AND tournament_organizers.user_id = auth.uid()
        )
    );

CREATE POLICY "Users can create own registration"
    ON tournament_registrations FOR INSERT
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own registration"
    ON tournament_registrations FOR UPDATE
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Organizers can update registrations"
    ON tournament_registrations FOR UPDATE
    USING (
        EXISTS (
            SELECT 1 FROM tournament_organizers
            WHERE tournament_organizers.tournament_id = tournament_registrations.tournament_id
            AND tournament_organizers.user_id = auth.uid()
        )
    );

-- ============================================
-- TEAMS TABLE
-- ============================================
CREATE TABLE teams (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name TEXT NOT NULL CHECK (char_length(name) BETWEEN 3 AND 50),
    tag TEXT CHECK (char_length(tag) BETWEEN 2 AND 6),
    owner_id UUID NOT NULL REFERENCES profiles(id) ON DELETE RESTRICT,
    description TEXT CHECK (char_length(description) <= 1000),
    avatar_url TEXT,
    is_public BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    deleted_at TIMESTAMPTZ
);

CREATE INDEX idx_teams_owner ON teams(owner_id);

ALTER TABLE teams ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Public teams are readable"
    ON teams FOR SELECT
    USING (is_public = true AND deleted_at IS NULL);

CREATE POLICY "Team members can read"
    ON teams FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM team_members
            WHERE team_members.team_id = teams.id
            AND team_members.user_id = auth.uid()
        )
    );

CREATE POLICY "Owner can manage team"
    ON teams FOR ALL
    USING (auth.uid() = owner_id)
    WITH CHECK (auth.uid() = owner_id);

CREATE TRIGGER update_teams_updated_at
    BEFORE UPDATE ON teams
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- ============================================
-- TEAM MEMBERS
-- ============================================
CREATE TABLE team_members (
    team_id UUID NOT NULL REFERENCES teams(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    role TEXT NOT NULL DEFAULT 'member' CHECK (role IN ('owner', 'captain', 'member')),
    joined_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    PRIMARY KEY (team_id, user_id)
);

ALTER TABLE team_members ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Team members can read"
    ON team_members FOR SELECT
    USING (
        auth.uid() = user_id OR
        EXISTS (
            SELECT 1 FROM teams t
            WHERE t.id = team_members.team_id
            AND (t.is_public = true OR t.owner_id = auth.uid())
        )
    );

CREATE POLICY "Owner/Captain can manage members"
    ON team_members FOR ALL
    USING (
        EXISTS (
            SELECT 1 FROM team_members tm
            WHERE tm.team_id = team_members.team_id
            AND tm.user_id = auth.uid()
            AND tm.role IN ('owner', 'captain')
        )
    );

-- ============================================
-- MATCHES TABLE
-- ============================================
CREATE TABLE matches (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    tournament_id UUID NOT NULL REFERENCES tournaments(id) ON DELETE CASCADE,
    round_number INTEGER NOT NULL,
    match_number INTEGER NOT NULL,
    team_a_id UUID REFERENCES teams(id) ON DELETE SET NULL,
    team_b_id UUID REFERENCES teams(id) ON DELETE SET NULL,
    winner_id UUID REFERENCES teams(id) ON DELETE SET NULL,
    status TEXT NOT NULL DEFAULT 'scheduled'
        CHECK (status IN ('scheduled', 'in_progress', 'completed', 'cancelled', 'disputed')),
    scheduled_at TIMESTAMPTZ,
    started_at TIMESTAMPTZ,
    ended_at TIMESTAMPTZ,
    score_a INTEGER DEFAULT 0,
    score_b INTEGER DEFAULT 0,
    metadata JSONB DEFAULT '{}',
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_matches_tournament ON matches(tournament_id);
CREATE INDEX idx_matches_status ON matches(status);
CREATE INDEX idx_matches_teams ON matches(team_a_id, team_b_id);

ALTER TABLE matches ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Matches readable by tournament participants"
    ON matches FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM tournaments t
            WHERE t.id = matches.tournament_id
            AND (t.visibility = 'public' OR t.organizer_id = auth.uid())
        ) OR
        EXISTS (
            SELECT 1 FROM team_members tm
            WHERE (tm.team_id = matches.team_a_id OR tm.team_id = matches.team_b_id)
            AND tm.user_id = auth.uid()
        )
    );

CREATE POLICY "Organizers can manage matches"
    ON matches FOR ALL
    USING (
        EXISTS (
            SELECT 1 FROM tournaments t
            WHERE t.id = matches.tournament_id
            AND t.organizer_id = auth.uid()
        )
    );

CREATE TRIGGER update_matches_updated_at
    BEFORE UPDATE ON matches
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- ============================================
-- RESULTS TABLE
-- ============================================
CREATE TABLE results (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    match_id UUID NOT NULL REFERENCES matches(id) ON DELETE CASCADE,
    team_id UUID NOT NULL REFERENCES teams(id) ON DELETE CASCADE,
    placement INTEGER,
    kills INTEGER DEFAULT 0,
    damage INTEGER DEFAULT 0,
    survival_time INTERVAL,
    metadata JSONB DEFAULT '{}',
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_results_match ON results(match_id);
CREATE INDEX idx_results_team ON results(team_id);

ALTER TABLE results ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Results readable by tournament participants"
    ON results FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM matches m
            JOIN tournaments t ON t.id = m.tournament_id
            WHERE m.id = results.match_id
            AND (t.visibility = 'public' OR t.organizer_id = auth.uid())
        )
    );

CREATE POLICY "Organizers can manage results"
    ON results FOR ALL
    USING (
        EXISTS (
            SELECT 1 FROM matches m
            JOIN tournaments t ON t.id = m.tournament_id
            WHERE m.id = results.match_id
            AND t.organizer_id = auth.uid()
        )
    );

-- ============================================
-- NOTIFICATIONS TABLE
-- ============================================
CREATE TABLE notifications (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    type TEXT NOT NULL,
    title TEXT NOT NULL,
    body TEXT,
    data JSONB DEFAULT '{}',
    read_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_notifications_user ON notifications(user_id);
CREATE INDEX idx_notifications_read ON notifications(user_id, read_at) WHERE read_at IS NULL;

ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can read own notifications"
    ON notifications FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Users can mark own notifications read"
    ON notifications FOR UPDATE
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

-- System can insert notifications
CREATE POLICY "System can insert notifications"
    ON notifications FOR INSERT
    WITH CHECK (true);

-- ============================================
-- AUDIT LOGS TABLE
-- ============================================
CREATE TABLE audit_logs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES profiles(id) ON DELETE SET NULL,
    action TEXT NOT NULL,
    resource_type TEXT NOT NULL,
    resource_id UUID,
    old_data JSONB,
    new_data JSONB,
    ip_address INET,
    user_agent TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_audit_user ON audit_logs(user_id);
CREATE INDEX idx_audit_action ON audit_logs(action);
CREATE INDEX idx_audit_resource ON audit_logs(resource_type, resource_id);
CREATE INDEX idx_audit_created ON audit_logs(created_at DESC);

ALTER TABLE audit_logs ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can read own audit logs"
    ON audit_logs FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Admins can read all audit logs"
    ON audit_logs FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM profiles p
            WHERE p.id = auth.uid()
            AND p.id IN (SELECT user_id FROM profiles WHERE id = auth.uid()) -- placeholder for admin check
        )
    );

-- System can insert audit logs
CREATE POLICY "System can insert audit logs"
    ON audit_logs FOR INSERT
    WITH CHECK (true);

-- ============================================
-- STORAGE BUCKETS
-- ============================================
-- Avatars bucket
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES ('avatars', 'avatars', true, 5242880, ARRAY['image/jpeg', 'image/png', 'image/webp'])
ON CONFLICT (id) DO NOTHING;

-- Tournament assets bucket
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES ('tournament-assets', 'tournament-assets', true, 10485760, ARRAY['image/jpeg', 'image/png', 'image/webp', 'application/pdf'])
ON CONFLICT (id) DO NOTHING;

-- Team assets bucket
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES ('team-assets', 'team-assets', true, 5242880, ARRAY['image/jpeg', 'image/png', 'image/webp'])
ON CONFLICT (id) DO NOTHING;

-- Storage RLS Policies
CREATE POLICY "Users can upload own avatar"
    ON storage.objects FOR INSERT
    WITH CHECK (bucket_id = 'avatars' AND auth.uid()::text = (storage.foldername(name))[1]);

CREATE POLICY "Users can update own avatar"
    ON storage.objects FOR UPDATE
    USING (bucket_id = 'avatars' AND auth.uid()::text = (storage.foldername(name))[1]);

CREATE POLICY "Users can delete own avatar"
    ON storage.objects FOR DELETE
    USING (bucket_id = 'avatars' AND auth.uid()::text = (storage.foldername(name))[1]);

CREATE POLICY "Public avatars are readable"
    ON storage.objects FOR SELECT
    USING (bucket_id = 'avatars');

CREATE POLICY "Tournament organizers can upload assets"
    ON storage.objects FOR INSERT
    WITH CHECK (
        bucket_id = 'tournament-assets' AND
        EXISTS (
            SELECT 1 FROM tournament_organizers
            WHERE tournament_organizers.user_id = auth.uid()
            AND tournament_organizers.tournament_id::text = (storage.foldername(name))[1]
        )
    );

CREATE POLICY "Public tournament assets readable"
    ON storage.objects FOR SELECT
    USING (bucket_id = 'tournament-assets');

CREATE POLICY "Team owners can upload assets"
    ON storage.objects FOR INSERT
    WITH CHECK (
        bucket_id = 'team-assets' AND
        EXISTS (
            SELECT 1 FROM teams
            WHERE teams.id::text = (storage.foldername(name))[1]
            AND teams.owner_id = auth.uid()
        )
    );

CREATE POLICY "Public team assets readable"
    ON storage.objects FOR SELECT
    USING (bucket_id = 'team-assets');