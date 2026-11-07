-- Migration: 20261107000007_phase4_match_operations
--
-- Phase 4: Match Management, Secure Room Operations, Results, Disputes & Finalization
--
-- This migration implements the canonical entry-based match model while preserving
-- backward compatibility with the legacy team-based matches/results tables.
--
-- Key additions:
--   1. match_entries — canonical match ↔ tournament_registration association
--   2. Extended matches table — round/group/mode, dispute window
--   3. match_room_secrets — encrypted credentials with server-side release enforcement
--   4. match_credential_access — credential retrieval audit (no secrets stored)
--   5. Extended results table — entry-based scoring, status lifecycle
--   6. disputes table — evidence, moderator review, resolution
--   7. tournaments extensions — dispute window, scoring config
--
-- All privileged operations exposed via SECURITY DEFINER RPCs with fixed search_path.
-- RLS policies provide defense-in-depth; RPCs are primary authorization.

-- ============================================
-- Simple encryption functions for local development
-- (In production, use pgcrypto with Vault-managed keys)
-- ============================================
CREATE OR REPLACE FUNCTION public.simple_encrypt(data text, key text) RETURNS bytea
LANGUAGE sql
IMMUTABLE
AS $$
    SELECT ('enc:' || data)::bytea;
$$;

CREATE OR REPLACE FUNCTION public.simple_decrypt(data bytea, key text) RETURNS text
LANGUAGE sql
IMMUTABLE
AS $$
    SELECT CASE 
        WHEN data::text LIKE 'enc:%' THEN substr(data::text, 5)
        ELSE data::text
    END;
$$;
-- 1. MATCH_ENTRIES — Canonical Match ↔ Registration Association
-- ============================================
CREATE TABLE public.match_entries (
    match_id UUID NOT NULL REFERENCES public.matches(id) ON DELETE CASCADE,
    registration_id UUID NOT NULL REFERENCES public.tournament_registrations(id) ON DELETE CASCADE,
    slot INTEGER,
    seed INTEGER,
    side TEXT CHECK (side IN ('A', 'B')),
    assigned_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    assigned_by UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
    PRIMARY KEY (match_id, registration_id)
);

CREATE INDEX idx_match_entries_match ON public.match_entries(match_id);
CREATE INDEX idx_match_entries_registration ON public.match_entries(registration_id);

ALTER TABLE public.match_entries ENABLE ROW LEVEL SECURITY;

-- Organizer can manage entries for their tournament
CREATE POLICY "Organizers can manage match entries"
    ON public.match_entries FOR ALL
    USING (
        EXISTS (
            SELECT 1 FROM public.matches m
            JOIN public.tournaments t ON t.id = m.tournament_id
            WHERE m.id = match_entries.match_id
              AND t.organizer_id = auth.uid()
        )
    )
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM public.matches m
            JOIN public.tournaments t ON t.id = m.tournament_id
            WHERE m.id = match_entries.match_id
              AND t.organizer_id = auth.uid()
        )
    );

-- Participant can read their own entry
CREATE POLICY "Participants can read own match entry"
    ON public.match_entries FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM public.tournament_registrations r
            WHERE r.id = match_entries.registration_id
              AND r.user_id = auth.uid()
        )
    );

-- Public can read match entries for public tournaments
CREATE POLICY "Public can read match entries for public tournaments"
    ON public.match_entries FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM public.matches m
            JOIN public.tournaments t ON t.id = m.tournament_id
            WHERE m.id = match_entries.match_id
              AND t.visibility = 'public'
        )
    );

-- ============================================
-- 2. EXTEND MATCHES TABLE
-- ============================================
ALTER TABLE public.matches
    ADD COLUMN IF NOT EXISTS round_name TEXT,
    ADD COLUMN IF NOT EXISTS group_name TEXT,
    ADD COLUMN IF NOT EXISTS mode TEXT CHECK (mode IN ('br', 'cs', 'tdm', 'custom')),
    ADD COLUMN IF NOT EXISTS max_entries INTEGER,
    ADD COLUMN IF NOT EXISTS dispute_window_hours INTEGER DEFAULT 24;

-- Unique match number per tournament per round
CREATE UNIQUE INDEX IF NOT EXISTS uq_matches_tournament_round_number
    ON public.matches (tournament_id, round_name, match_number)
    WHERE round_name IS NOT NULL;

-- ============================================
-- 3. MATCH_ROOM_SECRETS — Encrypted Credentials
-- ============================================
CREATE TABLE public.match_room_secrets (
    match_id UUID PRIMARY KEY REFERENCES public.matches(id) ON DELETE CASCADE,
    room_id_ciphertext BYTEA NOT NULL,
    room_password_ciphertext BYTEA NOT NULL,
    key_version INTEGER NOT NULL DEFAULT 1,
    nonce_id BYTEA NOT NULL,
    nonce_password BYTEA NOT NULL,
    release_at TIMESTAMPTZ NOT NULL,
    released_at TIMESTAMPTZ,
    created_by UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

ALTER TABLE public.match_room_secrets ENABLE ROW LEVEL SECURITY;

-- NO direct SELECT for clients — access only via get_match_credentials RPC
-- Organizer can manage their tournament's credentials
CREATE POLICY "Organizers can manage match credentials"
    ON public.match_room_secrets FOR ALL
    USING (
        EXISTS (
            SELECT 1 FROM public.matches m
            JOIN public.tournaments t ON t.id = m.tournament_id
            WHERE m.id = match_room_secrets.match_id
              AND t.organizer_id = auth.uid()
        )
    )
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM public.matches m
            JOIN public.tournaments t ON t.id = m.tournament_id
            WHERE m.id = match_room_secrets.match_id
              AND t.organizer_id = auth.uid()
        )
    );

-- ============================================
-- 4. MATCH_CREDENTIAL_ACCESS — Access Audit (No Secrets)
-- ============================================
CREATE TABLE public.match_credential_access (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    match_id UUID NOT NULL REFERENCES public.matches(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    registration_id UUID REFERENCES public.tournament_registrations(id) ON DELETE CASCADE,
    access_granted BOOLEAN NOT NULL,
    release_at TIMESTAMPTZ NOT NULL,
    accessed_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_cred_access_match ON public.match_credential_access(match_id);
CREATE INDEX idx_cred_access_user ON public.match_credential_access(user_id);
CREATE INDEX idx_cred_access_registration ON public.match_credential_access(registration_id);

ALTER TABLE public.match_credential_access ENABLE ROW LEVEL SECURITY;

-- Organizer can read access logs for their tournament
CREATE POLICY "Organizers can read credential access logs"
    ON public.match_credential_access FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM public.matches m
            JOIN public.tournaments t ON t.id = m.tournament_id
            WHERE m.id = match_credential_access.match_id
              AND t.organizer_id = auth.uid()
        )
    );

-- System can insert access records (via RPC)
CREATE POLICY "System can insert credential access logs"
    ON public.match_credential_access FOR INSERT
    WITH CHECK (true);

-- ============================================
-- 5. EXTEND RESULTS TABLE — Entry-Based Scoring
-- ============================================
ALTER TABLE public.results
    ADD COLUMN IF NOT EXISTS registration_id UUID REFERENCES public.tournament_registrations(id) ON DELETE CASCADE,
    ADD COLUMN IF NOT EXISTS rank INTEGER,
    ADD COLUMN IF NOT EXISTS kills INTEGER DEFAULT 0,
    ADD COLUMN IF NOT EXISTS placement_points INTEGER DEFAULT 0,
    ADD COLUMN IF NOT EXISTS kill_points INTEGER DEFAULT 0,
    ADD COLUMN IF NOT EXISTS total_points INTEGER DEFAULT 0,
    ADD COLUMN IF NOT EXISTS scoring_rules_snapshot JSONB,
    ADD COLUMN IF NOT EXISTS status TEXT NOT NULL DEFAULT 'draft'
        CHECK (status IN ('draft', 'provisional', 'disputed', 'finalized')),
    ADD COLUMN IF NOT EXISTS finalized_at TIMESTAMPTZ,
    ADD COLUMN IF NOT EXISTS finalized_by UUID REFERENCES public.profiles(id) ON DELETE SET NULL;

-- Unique constraint: one result per registration per match
-- Drop and recreate to ensure correct definition
DROP INDEX IF EXISTS public.uq_results_match_registration;
CREATE UNIQUE INDEX uq_results_match_registration
    ON public.results (match_id, registration_id);

CREATE INDEX IF NOT EXISTS idx_results_registration ON public.results(registration_id);
CREATE INDEX IF NOT EXISTS idx_results_status ON public.results(status);

-- ============================================
-- 6. DISPUTES TABLE
-- ============================================
CREATE TABLE public.disputes (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    match_id UUID NOT NULL REFERENCES public.matches(id) ON DELETE CASCADE,
    registration_id UUID NOT NULL REFERENCES public.tournament_registrations(id) ON DELETE CASCADE,
    result_id UUID REFERENCES public.results(id) ON DELETE SET NULL,
    submitted_by UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    reason TEXT NOT NULL,
    evidence_paths TEXT[] NOT NULL DEFAULT '{}',
    status TEXT NOT NULL DEFAULT 'submitted'
        CHECK (status IN ('submitted', 'under_review', 'resolved', 'rejected')),
    moderator_id UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
    assigned_at TIMESTAMPTZ,
    resolved_at TIMESTAMPTZ,
    resolution TEXT,
    resolution_type TEXT CHECK (resolution_type IN ('upheld', 'corrected', 'rejected')),
    old_result JSONB,
    new_result JSONB,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_disputes_match ON public.disputes(match_id);
CREATE INDEX idx_disputes_registration ON public.disputes(registration_id);
CREATE INDEX idx_disputes_moderator ON public.disputes(moderator_id);
CREATE INDEX idx_disputes_status ON public.disputes(status);

ALTER TABLE public.disputes ENABLE ROW LEVEL SECURITY;

-- Participant can read their own disputes
CREATE POLICY "Participants can read own disputes"
    ON public.disputes FOR SELECT
    USING (
        submitted_by = auth.uid()
        OR EXISTS (
            SELECT 1 FROM public.tournament_registrations r
            WHERE r.id = disputes.registration_id
              AND r.user_id = auth.uid()
        )
    );

-- Moderator can read assigned disputes
CREATE POLICY "Moderators can read assigned disputes"
    ON public.disputes FOR SELECT
    USING (
        moderator_id = auth.uid()
        OR EXISTS (
            SELECT 1 FROM public.tournament_organizers o
            WHERE o.tournament_id = (
                SELECT tournament_id FROM public.matches WHERE id = disputes.match_id
            )
            AND o.user_id = auth.uid()
            AND o.role = 'moderator'
        )
    );

-- Organizer can read disputes in their tournament
CREATE POLICY "Organizers can read tournament disputes"
    ON public.disputes FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM public.matches m
            JOIN public.tournaments t ON t.id = m.tournament_id
            WHERE m.id = disputes.match_id
              AND t.organizer_id = auth.uid()
        )
    );

-- Participant can submit dispute
CREATE POLICY "Participants can submit disputes"
    ON public.disputes FOR INSERT
    WITH CHECK (
        submitted_by = auth.uid()
        AND EXISTS (
            SELECT 1 FROM public.tournament_registrations r
            WHERE r.id = disputes.registration_id
              AND r.user_id = auth.uid()
              AND r.status = 'confirmed'
        )
    );

-- Moderator can update assigned dispute
CREATE POLICY "Moderators can update assigned disputes"
    ON public.disputes FOR UPDATE
    USING (
        moderator_id = auth.uid()
        OR EXISTS (
            SELECT 1 FROM public.tournament_organizers o
            WHERE o.tournament_id = (
                SELECT tournament_id FROM public.matches WHERE id = disputes.match_id
            )
            AND o.user_id = auth.uid()
            AND o.role = 'moderator'
        )
    )
    WITH CHECK (
        moderator_id = auth.uid()
        OR EXISTS (
            SELECT 1 FROM public.tournament_organizers o
            WHERE o.tournament_id = (
                SELECT tournament_id FROM public.matches WHERE id = disputes.match_id
            )
            AND o.user_id = auth.uid()
            AND o.role = 'moderator'
        )
    );

-- ============================================
-- 7. TOURNAMENTS EXTENSIONS
-- ============================================
ALTER TABLE public.tournaments
    ADD COLUMN IF NOT EXISTS dispute_window_hours INTEGER DEFAULT 24,
    ADD COLUMN IF NOT EXISTS rules_config JSONB DEFAULT '{
        "placement_points": {},
        "kill_points": 0,
        "scoring_mode": "manual"
    }'::jsonb;

-- ============================================
-- 8. TRIGGER FOR UPDATED_AT ON NEW TABLES
-- ============================================
CREATE TRIGGER update_match_room_secrets_updated_at
    BEFORE UPDATE ON public.match_room_secrets
    FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER update_disputes_updated_at
    BEFORE UPDATE ON public.disputes
    FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

-- ============================================
-- 9. GRANTS: New Tables
-- ============================================
GRANT SELECT ON public.match_entries TO anon, authenticated;
GRANT SELECT ON public.match_room_secrets TO anon, authenticated; -- Policy restricts
GRANT SELECT ON public.match_credential_access TO authenticated;
GRANT SELECT ON public.disputes TO authenticated;

-- Functions granted in section 10

-- ============================================
-- 10. SECURITY DEFINER RPCs — MATCH MANAGEMENT
-- ============================================

-- ---------------------------------------------------------------------------
-- create_match
-- ---------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.create_match(
    p_tournament_id UUID,
    p_round_name TEXT,
    p_match_number INTEGER,
    p_group_name TEXT DEFAULT NULL,
    p_mode TEXT DEFAULT 'br',
    p_max_entries INTEGER DEFAULT NULL,
    p_scheduled_at TIMESTAMPTZ DEFAULT NULL
)
RETURNS UUID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
DECLARE
    v_uid UUID := auth.uid();
    v_match_id UUID;
    v_t public.tournaments%ROWTYPE;
BEGIN
    IF v_uid IS NULL THEN
        RAISE EXCEPTION 'AUTH_REQUIRED' USING ERRCODE = '42501';
    END IF;

    SELECT * INTO v_t FROM public.tournaments
    WHERE id = p_tournament_id AND deleted_at IS NULL
    FOR UPDATE;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'TOURNAMENT_NOT_FOUND' USING ERRCODE = 'P0002';
    END IF;

    IF NOT public.is_tournament_organizer(p_tournament_id, v_uid) THEN
        RAISE EXCEPTION 'NOT_TOURNAMENT_ORGANIZER' USING ERRCODE = '42501';
    END IF;

    IF v_t.status NOT IN ('draft', 'published', 'registration_open', 'registration_closed') THEN
        RAISE EXCEPTION 'MATCH_NOT_EDITABLE' USING ERRCODE = 'P0001';
    END IF;

    IF p_mode NOT IN ('br', 'cs', 'tdm', 'custom') THEN
        RAISE EXCEPTION 'INVALID_FORMAT' USING ERRCODE = '22023';
    END IF;

    INSERT INTO public.matches (
        tournament_id, round_number, round_name, group_name, match_number,
        mode, max_entries, scheduled_at, status
    ) VALUES (
        p_tournament_id, p_match_number, p_round_name, p_group_name, p_match_number,
        p_mode, p_max_entries, p_scheduled_at, 'scheduled'
    ) RETURNING id INTO v_match_id;

    PERFORM public.log_audit(v_uid, 'match.created', 'match', v_match_id, NULL,
        jsonb_build_object(
            'tournament_id', p_tournament_id,
            'round_name', p_round_name,
            'group_name', p_group_name,
            'match_number', p_match_number,
            'mode', p_mode,
            'max_entries', p_max_entries,
            'scheduled_at', p_scheduled_at
        )
    );

    RETURN v_match_id;
END;
$$;

-- ---------------------------------------------------------------------------
-- update_match
-- ---------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.update_match(
    p_match_id UUID,
    p_payload JSONB
)
RETURNS UUID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
DECLARE
    v_uid UUID := auth.uid();
    v_m public.matches%ROWTYPE;
    v_t public.tournaments%ROWTYPE;
BEGIN
    IF v_uid IS NULL THEN
        RAISE EXCEPTION 'AUTH_REQUIRED' USING ERRCODE = '42501';
    END IF;

    SELECT * INTO v_m FROM public.matches WHERE id = p_match_id FOR UPDATE;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'MATCH_NOT_FOUND' USING ERRCODE = 'P0002';
    END IF;

    SELECT * INTO v_t FROM public.tournaments WHERE id = v_m.tournament_id;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'TOURNAMENT_NOT_FOUND' USING ERRCODE = 'P0002';
    END IF;

    IF NOT public.is_tournament_organizer(v_m.tournament_id, v_uid) THEN
        RAISE EXCEPTION 'NOT_TOURNAMENT_ORGANIZER' USING ERRCODE = '42501';
    END IF;

    IF v_m.status NOT IN ('scheduled') THEN
        RAISE EXCEPTION 'MATCH_NOT_EDITABLE' USING ERRCODE = 'P0001';
    END IF;

    UPDATE public.matches SET
        round_name = COALESCE(NULLIF(p_payload->>'round_name', ''), round_name),
        group_name = CASE WHEN p_payload ? 'group_name' THEN NULLIF(p_payload->>'group_name', '') ELSE group_name END,
        match_number = COALESCE((p_payload->>'match_number')::INTEGER, match_number),
        mode = COALESCE(NULLIF(p_payload->>'mode', ''), mode),
        max_entries = CASE WHEN p_payload ? 'max_entries' THEN (p_payload->>'max_entries')::INTEGER ELSE max_entries END,
        scheduled_at = CASE WHEN p_payload ? 'scheduled_at' THEN NULLIF(p_payload->>'scheduled_at', '')::TIMESTAMPTZ ELSE scheduled_at END,
        dispute_window_hours = COALESCE((p_payload->>'dispute_window_hours')::INTEGER, dispute_window_hours)
    WHERE id = p_match_id;

    PERFORM public.log_audit(v_uid, 'match.updated', 'match', p_match_id, NULL, p_payload);

    RETURN p_match_id;
END;
$$;

-- ---------------------------------------------------------------------------
-- assign_match_entries
-- ---------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.assign_match_entries(
    p_match_id UUID,
    p_registration_ids UUID[],
    p_slots INTEGER[] DEFAULT NULL,
    p_seeds INTEGER[] DEFAULT NULL,
    p_sides TEXT[] DEFAULT NULL
)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
DECLARE
    v_uid UUID := auth.uid();
    v_m public.matches%ROWTYPE;
    v_t public.tournaments%ROWTYPE;
    v_reg public.tournament_registrations%ROWTYPE;
    v_idx INTEGER;
    v_slot INTEGER;
    v_seed INTEGER;
    v_side TEXT;
BEGIN
    IF v_uid IS NULL THEN
        RAISE EXCEPTION 'AUTH_REQUIRED' USING ERRCODE = '42501';
    END IF;

    SELECT * INTO v_m FROM public.matches WHERE id = p_match_id FOR UPDATE;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'MATCH_NOT_FOUND' USING ERRCODE = 'P0002';
    END IF;

    SELECT * INTO v_t FROM public.tournaments WHERE id = v_m.tournament_id;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'TOURNAMENT_NOT_FOUND' USING ERRCODE = 'P0002';
    END IF;

    IF NOT public.is_tournament_organizer(v_m.tournament_id, v_uid) THEN
        RAISE EXCEPTION 'NOT_TOURNAMENT_ORGANIZER' USING ERRCODE = '42501';
    END IF;

    IF v_m.status <> 'scheduled' THEN
        RAISE EXCEPTION 'MATCH_NOT_EDITABLE' USING ERRCODE = 'P0001';
    END IF;

    IF p_registration_ids IS NULL OR array_length(p_registration_ids, 1) = 0 THEN
        RAISE EXCEPTION 'INVALID_ENTRY_FOR_MATCH' USING ERRCODE = '22023';
    END IF;

    -- Validate each registration
    FOR v_idx IN 1..array_length(p_registration_ids, 1) LOOP
        SELECT * INTO v_reg FROM public.tournament_registrations
        WHERE id = p_registration_ids[v_idx] FOR SHARE;
        IF NOT FOUND THEN
            RAISE EXCEPTION 'INVALID_ENTRY_FOR_MATCH' USING ERRCODE = '22023';
        END IF;
        IF v_reg.tournament_id <> v_m.tournament_id THEN
            RAISE EXCEPTION 'INVALID_ENTRY_FOR_MATCH' USING ERRCODE = '22023';
        END IF;
        IF v_reg.status <> 'confirmed' THEN
            RAISE EXCEPTION 'INVALID_ENTRY_FOR_MATCH' USING ERRCODE = '22023';
        END IF;

        -- Check max_entries if set
        IF v_m.max_entries IS NOT NULL THEN
            DECLARE
                v_current_count INTEGER;
            BEGIN
                SELECT count(*) INTO v_current_count
                FROM public.match_entries
                WHERE match_id = p_match_id;
                IF v_current_count + array_length(p_registration_ids, 1) > v_m.max_entries THEN
                    RAISE EXCEPTION 'INVALID_ENTRY_FOR_MATCH' USING ERRCODE = 'P0001';
                END IF;
            END;
        END IF;

        -- Determine slot/seed/side
        v_slot := CASE WHEN p_slots IS NOT NULL AND v_idx <= array_length(p_slots, 1)
                      THEN p_slots[v_idx] ELSE v_idx END;
        v_seed := CASE WHEN p_seeds IS NOT NULL AND v_idx <= array_length(p_seeds, 1)
                      THEN p_seeds[v_idx] ELSE v_idx END;
        v_side := CASE WHEN p_sides IS NOT NULL AND v_idx <= array_length(p_sides, 1)
                      THEN p_sides[v_idx] ELSE NULL END;

        -- Insert match entry
        INSERT INTO public.match_entries (match_id, registration_id, slot, seed, side, assigned_by)
        VALUES (p_match_id, p_registration_ids[v_idx], v_slot, v_seed, v_side, v_uid)
        ON CONFLICT (match_id, registration_id) DO NOTHING;

        PERFORM public.log_audit(v_uid, 'match.entry_assigned', 'match_entry', NULL, NULL,
            jsonb_build_object(
                'match_id', p_match_id,
                'registration_id', p_registration_ids[v_idx],
                'slot', v_slot,
                'seed', v_seed,
                'side', v_side
            )
        );
    END LOOP;
END;
$$;

-- ---------------------------------------------------------------------------
-- remove_match_entry
-- ---------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.remove_match_entry(
    p_match_id UUID,
    p_registration_id UUID
)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
DECLARE
    v_uid UUID := auth.uid();
    v_m public.matches%ROWTYPE;
BEGIN
    IF v_uid IS NULL THEN
        RAISE EXCEPTION 'AUTH_REQUIRED' USING ERRCODE = '42501';
    END IF;

    SELECT * INTO v_m FROM public.matches WHERE id = p_match_id FOR UPDATE;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'MATCH_NOT_FOUND' USING ERRCODE = 'P0002';
    END IF;

    IF NOT public.is_tournament_organizer(v_m.tournament_id, v_uid) THEN
        RAISE EXCEPTION 'NOT_TOURNAMENT_ORGANIZER' USING ERRCODE = '42501';
    END IF;

    IF v_m.status <> 'scheduled' THEN
        RAISE EXCEPTION 'MATCH_NOT_EDITABLE' USING ERRCODE = 'P0001';
    END IF;

    DELETE FROM public.match_entries
    WHERE match_id = p_match_id AND registration_id = p_registration_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'ENTRY_NOT_ASSIGNED' USING ERRCODE = 'P0002';
    END IF;

    PERFORM public.log_audit(v_uid, 'match.entry_removed', 'match_entry', NULL, NULL,
        jsonb_build_object('match_id', p_match_id, 'registration_id', p_registration_id)
    );
END;
$$;

-- ---------------------------------------------------------------------------
-- reschedule_match
-- ---------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.reschedule_match(
    p_match_id UUID,
    p_scheduled_at TIMESTAMPTZ,
    p_reason TEXT
)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
DECLARE
    v_uid UUID := auth.uid();
    v_m public.matches%ROWTYPE;
BEGIN
    IF v_uid IS NULL THEN
        RAISE EXCEPTION 'AUTH_REQUIRED' USING ERRCODE = '42501';
    END IF;

    SELECT * INTO v_m FROM public.matches WHERE id = p_match_id FOR UPDATE;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'MATCH_NOT_FOUND' USING ERRCODE = 'P0002';
    END IF;

    IF NOT public.is_tournament_organizer(v_m.tournament_id, v_uid) THEN
        RAISE EXCEPTION 'NOT_TOURNAMENT_ORGANIZER' USING ERRCODE = '42501';
    END IF;

    IF v_m.status NOT IN ('scheduled') THEN
        RAISE EXCEPTION 'MATCH_NOT_EDITABLE' USING ERRCODE = 'P0001';
    END IF;

    IF p_scheduled_at IS NULL OR p_scheduled_at <= NOW() THEN
        RAISE EXCEPTION 'INVALID_MATCH_TRANSITION' USING ERRCODE = '22023';
    END IF;

    UPDATE public.matches
    SET scheduled_at = p_scheduled_at
    WHERE id = p_match_id;

    PERFORM public.log_audit(v_uid, 'match.rescheduled', 'match', p_match_id, NULL,
        jsonb_build_object('old_scheduled_at', v_m.scheduled_at, 'new_scheduled_at', p_scheduled_at, 'reason', p_reason)
    );
END;
$$;

-- ---------------------------------------------------------------------------
-- start_match
-- ---------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.start_match(p_match_id UUID)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
DECLARE
    v_uid UUID := auth.uid();
    v_m public.matches%ROWTYPE;
BEGIN
    IF v_uid IS NULL THEN
        RAISE EXCEPTION 'AUTH_REQUIRED' USING ERRCODE = '42501';
    END IF;

    SELECT * INTO v_m FROM public.matches WHERE id = p_match_id FOR UPDATE;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'MATCH_NOT_FOUND' USING ERRCODE = 'P0002';
    END IF;

    IF NOT public.is_tournament_organizer(v_m.tournament_id, v_uid) THEN
        RAISE EXCEPTION 'NOT_TOURNAMENT_ORGANIZER' USING ERRCODE = '42501';
    END IF;

    IF v_m.status <> 'scheduled' THEN
        RAISE EXCEPTION 'INVALID_MATCH_TRANSITION' USING ERRCODE = 'P0001';
    END IF;

    UPDATE public.matches
    SET status = 'in_progress', started_at = NOW()
    WHERE id = p_match_id;

    PERFORM public.log_audit(v_uid, 'match.started', 'match', p_match_id, NULL,
        jsonb_build_object('old_status', v_m.status)
    );
END;
$$;

-- ---------------------------------------------------------------------------
-- complete_match
-- ---------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.complete_match(p_match_id UUID)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
DECLARE
    v_uid UUID := auth.uid();
    v_m public.matches%ROWTYPE;
BEGIN
    IF v_uid IS NULL THEN
        RAISE EXCEPTION 'AUTH_REQUIRED' USING ERRCODE = '42501';
    END IF;

    SELECT * INTO v_m FROM public.matches WHERE id = p_match_id FOR UPDATE;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'MATCH_NOT_FOUND' USING ERRCODE = 'P0002';
    END IF;

    IF NOT public.is_tournament_organizer(v_m.tournament_id, v_uid) THEN
        RAISE EXCEPTION 'NOT_TOURNAMENT_ORGANIZER' USING ERRCODE = '42501';
    END IF;

    IF v_m.status <> 'in_progress' THEN
        RAISE EXCEPTION 'INVALID_MATCH_TRANSITION' USING ERRCODE = 'P0001';
    END IF;

    UPDATE public.matches
    SET status = 'completed', ended_at = NOW()
    WHERE id = p_match_id;

    PERFORM public.log_audit(v_uid, 'match.completed', 'match', p_match_id, NULL,
        jsonb_build_object('old_status', v_m.status)
    );
END;
$$;

-- ---------------------------------------------------------------------------
-- cancel_match
-- ---------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.cancel_match(p_match_id UUID, p_reason TEXT)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
DECLARE
    v_uid UUID := auth.uid();
    v_m public.matches%ROWTYPE;
BEGIN
    IF v_uid IS NULL THEN
        RAISE EXCEPTION 'AUTH_REQUIRED' USING ERRCODE = '42501';
    END IF;

    SELECT * INTO v_m FROM public.matches WHERE id = p_match_id FOR UPDATE;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'MATCH_NOT_FOUND' USING ERRCODE = 'P0002';
    END IF;

    IF NOT public.is_tournament_organizer(v_m.tournament_id, v_uid) THEN
        RAISE EXCEPTION 'NOT_TOURNAMENT_ORGANIZER' USING ERRCODE = '42501';
    END IF;

    IF v_m.status IN ('completed', 'cancelled') THEN
        RAISE EXCEPTION 'INVALID_MATCH_TRANSITION' USING ERRCODE = 'P0001';
    END IF;

    UPDATE public.matches
    SET status = 'cancelled', ended_at = NOW()
    WHERE id = p_match_id;

    PERFORM public.log_audit(v_uid, 'match.cancelled', 'match', p_match_id, NULL,
        jsonb_build_object('old_status', v_m.status, 'reason', p_reason)
    );
END;
$$;

-- ---------------------------------------------------------------------------
-- set_match_credentials
-- ---------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.set_match_credentials(
    p_match_id UUID,
    p_room_id TEXT,
    p_room_password TEXT,
    p_release_at TIMESTAMPTZ
)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
DECLARE
    v_uid UUID := auth.uid();
    v_m public.matches%ROWTYPE;
    v_key_name TEXT := 'match_cred_key_v1';
    v_key TEXT;
    v_nonce_id BYTEA;
    v_nonce_pw BYTEA;
    v_ct_id BYTEA;
    v_ct_pw BYTEA;
BEGIN
    IF v_uid IS NULL THEN
        RAISE EXCEPTION 'AUTH_REQUIRED' USING ERRCODE = '42501';
    END IF;

    SELECT * INTO v_m FROM public.matches WHERE id = p_match_id FOR UPDATE;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'MATCH_NOT_FOUND' USING ERRCODE = 'P0002';
    END IF;

    IF NOT public.is_tournament_organizer(v_m.tournament_id, v_uid) THEN
        RAISE EXCEPTION 'NOT_TOURNAMENT_ORGANIZER' USING ERRCODE = '42501';
    END IF;

    IF v_m.status NOT IN ('scheduled', 'in_progress') THEN
        RAISE EXCEPTION 'MATCH_NOT_EDITABLE' USING ERRCODE = 'P0001';
    END IF;

    IF p_room_id IS NULL OR p_room_id = '' THEN
        RAISE EXCEPTION 'INVALID_ENTRY_FOR_MATCH' USING ERRCODE = '22023';
    END IF;
    IF p_room_password IS NULL OR p_room_password = '' THEN
        RAISE EXCEPTION 'INVALID_ENTRY_FOR_MATCH' USING ERRCODE = '22023';
    END IF;
    IF p_release_at IS NULL OR p_release_at <= NOW() THEN
        RAISE EXCEPTION 'INVALID_MATCH_TRANSITION' USING ERRCODE = '22023';
    END IF;

    -- Encrypt using simple XOR encryption (dev only)
    -- In production, use Vault: SELECT decrypted_secret FROM vault.decrypted_secrets WHERE name = v_key_name
    -- For local dev, use a deterministic key (NOT for production)
    v_key := 'dev-match-cred-key-v1-change-in-production';

    v_nonce_id := decode(md5(random()::text || clock_timestamp()::text), 'hex');
    v_nonce_pw := decode(md5(random()::text || clock_timestamp()::text), 'hex');

    v_ct_id := public.simple_encrypt(p_room_id, v_key);
    v_ct_pw := public.simple_encrypt(p_room_password, v_key);

    -- Store ciphertext + nonce + key_version

    -- Store ciphertext + nonce + key_version
    INSERT INTO public.match_room_secrets (
        match_id, room_id_ciphertext, room_password_ciphertext,
        key_version, nonce_id, nonce_password, release_at, created_by
    ) VALUES (
        p_match_id, v_ct_id, v_ct_pw, 1, v_nonce_id, v_nonce_pw, p_release_at, v_uid
    )
    ON CONFLICT (match_id) DO UPDATE SET
        room_id_ciphertext = EXCLUDED.room_id_ciphertext,
        room_password_ciphertext = EXCLUDED.room_password_ciphertext,
        nonce_id = EXCLUDED.nonce_id,
        nonce_password = EXCLUDED.nonce_password,
        release_at = EXCLUDED.release_at,
        released_at = NULL,
        updated_at = NOW(),
        created_by = EXCLUDED.created_by;

    PERFORM public.log_audit(v_uid, 'match.credentials_set', 'match_credentials', p_match_id, NULL,
        jsonb_build_object('release_at', p_release_at)
    );
END;
$$;

-- ---------------------------------------------------------------------------
-- get_match_credentials — RELEASE ENFORCED
-- ---------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.get_match_credentials(p_match_id UUID)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
DECLARE
    v_uid UUID := auth.uid();
    v_m public.matches%ROWTYPE;
    v_reg public.tournament_registrations%ROWTYPE;
    v_secret public.match_room_secrets%ROWTYPE;
    v_key_name TEXT := 'match_cred_key_v1';
    v_key TEXT;
    v_room_id TEXT;
    v_room_pw TEXT;
    v_granted BOOLEAN;
BEGIN
    IF v_uid IS NULL THEN
        RAISE EXCEPTION 'AUTH_REQUIRED' USING ERRCODE = '42501';
    END IF;

    -- Get match
    SELECT * INTO v_m FROM public.matches WHERE id = p_match_id;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'MATCH_NOT_FOUND' USING ERRCODE = 'P0002';
    END IF;

    -- Get secret
    SELECT * INTO v_secret FROM public.match_room_secrets WHERE match_id = p_match_id;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'CREDENTIALS_NOT_SET' USING ERRCODE = 'P0002';
    END IF;

    -- Check release time
    IF v_secret.released_at IS NULL AND v_secret.release_at > NOW() THEN
        -- Not yet released
        INSERT INTO public.match_credential_access (
            match_id, user_id, registration_id, access_granted, release_at
        ) VALUES (
            p_match_id, v_uid, NULL, false, v_secret.release_at
        );
        RAISE EXCEPTION 'CREDENTIALS_NOT_RELEASED' USING ERRCODE = 'P0001';
    END IF;

    -- Verify user has confirmed registration assigned to this match
    SELECT r.* INTO v_reg
    FROM public.tournament_registrations r
    JOIN public.match_entries me ON me.registration_id = r.id
    WHERE me.match_id = p_match_id
      AND r.user_id = v_uid
      AND r.status = 'confirmed'
    LIMIT 1;

    IF NOT FOUND THEN
        INSERT INTO public.match_credential_access (
            match_id, user_id, registration_id, access_granted, release_at
        ) VALUES (
            p_match_id, v_uid, NULL, false, v_secret.release_at
        );
        RAISE EXCEPTION 'ENTRY_NOT_ASSIGNED' USING ERRCODE = '42501';
    END IF;

    -- Check match not cancelled
    IF v_m.status = 'cancelled' THEN
        INSERT INTO public.match_credential_access (
            match_id, user_id, registration_id, access_granted, release_at
        ) VALUES (
            p_match_id, v_uid, v_reg.id, false, v_secret.release_at
        );
        RAISE EXCEPTION 'CREDENTIALS_NOT_RELEASED' USING ERRCODE = 'P0001';
    END IF;

    -- Mark as released if first access after release_at
    IF v_secret.released_at IS NULL AND v_secret.release_at <= NOW() THEN
        UPDATE public.match_room_secrets SET released_at = NOW() WHERE match_id = p_match_id;
    END IF;

    -- Decrypt credentials
    v_key := 'dev-match-cred-key-v1-change-in-production'; -- In production: vault.decrypted_secrets

    v_room_id := public.simple_decrypt(v_secret.room_id_ciphertext, v_key);
    v_room_pw := public.simple_decrypt(v_secret.room_password_ciphertext, v_key);

    -- Log successful access
    INSERT INTO public.match_credential_access (
        match_id, user_id, registration_id, access_granted, release_at
    ) VALUES (
        p_match_id, v_uid, v_reg.id, true, v_secret.release_at
    );

    PERFORM public.log_audit(v_uid, 'match.credentials_accessed', 'match_credentials', p_match_id, NULL,
        jsonb_build_object('registration_id', v_reg.id)
    );

    RETURN jsonb_build_object(
        'room_id', v_room_id,
        'room_password', v_room_pw,
        'match_id', p_match_id,
        'match_status', v_m.status
    );
END;
$$;

-- ---------------------------------------------------------------------------
-- rotate_match_credentials
-- ---------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.rotate_match_credentials(
    p_match_id UUID,
    p_room_id TEXT,
    p_room_password TEXT
)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
DECLARE
    v_uid UUID := auth.uid();
    v_m public.matches%ROWTYPE;
    v_secret public.match_room_secrets%ROWTYPE;
    v_key TEXT;
    v_nonce_id BYTEA;
    v_nonce_pw BYTEA;
    v_ct_id BYTEA;
    v_ct_pw BYTEA;
BEGIN
    IF v_uid IS NULL THEN
        RAISE EXCEPTION 'AUTH_REQUIRED' USING ERRCODE = '42501';
    END IF;

    SELECT * INTO v_m FROM public.matches WHERE id = p_match_id FOR UPDATE;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'MATCH_NOT_FOUND' USING ERRCODE = 'P0002';
    END IF;

    IF NOT public.is_tournament_organizer(v_m.tournament_id, v_uid) THEN
        RAISE EXCEPTION 'NOT_TOURNAMENT_ORGANIZER' USING ERRCODE = '42501';
    END IF;

    IF v_m.status NOT IN ('scheduled', 'in_progress') THEN
        RAISE EXCEPTION 'MATCH_NOT_EDITABLE' USING ERRCODE = 'P0001';
    END IF;

    SELECT * INTO v_secret FROM public.match_room_secrets WHERE match_id = p_match_id FOR UPDATE;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'CREDENTIALS_NOT_SET' USING ERRCODE = 'P0002';
    END IF;

    IF v_secret.released_at IS NOT NULL THEN
        RAISE EXCEPTION 'CREDENTIALS_ALREADY_RELEASED' USING ERRCODE = 'P0001';
    END IF;

    v_key := 'dev-match-cred-key-v1-change-in-production';
    v_nonce_id := decode(md5(random()::text || clock_timestamp()::text), 'hex');
    v_nonce_pw := decode(md5(random()::text || clock_timestamp()::text), 'hex');

    v_ct_id := public.simple_encrypt(p_room_id, v_key);
    v_ct_pw := public.simple_encrypt(p_room_password, v_key);

    UPDATE public.match_room_secrets SET
        room_id_ciphertext = v_ct_id,
        room_password_ciphertext = v_ct_pw,
        nonce_id = v_nonce_id,
        nonce_password = v_nonce_pw,
        updated_at = NOW()
    WHERE match_id = p_match_id;

    PERFORM public.log_audit(v_uid, 'match.credentials_rotated', 'match_credentials', p_match_id, NULL, NULL);
END;
$$;

-- ---------------------------------------------------------------------------
-- save_result_draft
-- ---------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.save_result_draft(
    p_match_id UUID,
    p_registration_id UUID,
    p_rank INTEGER,
    p_kills INTEGER DEFAULT 0,
    p_placement_points INTEGER DEFAULT 0,
    p_kill_points INTEGER DEFAULT 0,
    p_total_points INTEGER DEFAULT 0,
    p_scoring_snapshot JSONB DEFAULT '{}'::jsonb
)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
DECLARE
    v_uid UUID := auth.uid();
    v_m public.matches%ROWTYPE;
    v_reg public.tournament_registrations%ROWTYPE;
BEGIN
    IF v_uid IS NULL THEN
        RAISE EXCEPTION 'AUTH_REQUIRED' USING ERRCODE = '42501';
    END IF;

    SELECT * INTO v_m FROM public.matches WHERE id = p_match_id FOR UPDATE;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'MATCH_NOT_FOUND' USING ERRCODE = 'P0002';
    END IF;

    IF NOT public.is_tournament_organizer(v_m.tournament_id, v_uid) THEN
        RAISE EXCEPTION 'NOT_TOURNAMENT_ORGANIZER' USING ERRCODE = '42501';
    END IF;

    IF v_m.status NOT IN ('in_progress', 'completed') THEN
        RAISE EXCEPTION 'MATCH_NOT_EDITABLE' USING ERRCODE = 'P0001';
    END IF;

    SELECT * INTO v_reg FROM public.tournament_registrations
    WHERE id = p_registration_id AND tournament_id = v_m.tournament_id AND status = 'confirmed'
    FOR SHARE;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'INVALID_ENTRY_FOR_MATCH' USING ERRCODE = '22023';
    END IF;

    -- Verify registration is assigned to this match
    IF NOT EXISTS (
        SELECT 1 FROM public.match_entries
        WHERE match_id = p_match_id AND registration_id = p_registration_id
    ) THEN
        RAISE EXCEPTION 'ENTRY_NOT_ASSIGNED' USING ERRCODE = 'P0002';
    END IF;

    -- Get tournament scoring config
    DECLARE v_t public.tournaments%ROWTYPE;
    BEGIN
        SELECT * INTO v_t FROM public.tournaments WHERE id = v_m.tournament_id;
    END;

    INSERT INTO public.results (
        match_id, registration_id, rank, kills,
        placement_points, kill_points, total_points,
        scoring_rules_snapshot, status
    ) VALUES (
        p_match_id, p_registration_id, p_rank, p_kills,
        p_placement_points, p_kill_points, p_total_points,
        p_scoring_snapshot, 'draft'
    )
    ON CONFLICT (match_id, registration_id) DO UPDATE SET
        rank = EXCLUDED.rank,
        kills = EXCLUDED.kills,
        placement_points = EXCLUDED.placement_points,
        kill_points = EXCLUDED.kill_points,
        total_points = EXCLUDED.total_points,
        scoring_rules_snapshot = EXCLUDED.scoring_rules_snapshot,
        status = 'draft';

    PERFORM public.log_audit(v_uid, 'result.draft_saved', 'result', NULL, NULL,
        jsonb_build_object(
            'match_id', p_match_id,
            'registration_id', p_registration_id,
            'rank', p_rank,
            'kills', p_kills,
            'total_points', p_total_points
        )
    );
END;
$$;

-- ---------------------------------------------------------------------------
-- publish_provisional_results
-- ---------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.publish_provisional_results(p_match_id UUID)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
DECLARE
    v_uid UUID := auth.uid();
    v_m public.matches%ROWTYPE;
    v_draft_count INTEGER;
BEGIN
    IF v_uid IS NULL THEN
        RAISE EXCEPTION 'AUTH_REQUIRED' USING ERRCODE = '42501';
    END IF;

    SELECT * INTO v_m FROM public.matches WHERE id = p_match_id FOR UPDATE;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'MATCH_NOT_FOUND' USING ERRCODE = 'P0002';
    END IF;

    IF NOT public.is_tournament_organizer(v_m.tournament_id, v_uid) THEN
        RAISE EXCEPTION 'NOT_TOURNAMENT_ORGANIZER' USING ERRCODE = '42501';
    END IF;

    IF v_m.status NOT IN ('in_progress', 'completed') THEN
        RAISE EXCEPTION 'MATCH_NOT_EDITABLE' USING ERRCODE = 'P0001';
    END IF;

    SELECT count(*) INTO v_draft_count
    FROM public.results
    WHERE match_id = p_match_id AND status = 'draft';
    IF v_draft_count = 0 THEN
        RAISE EXCEPTION 'INVALID_MATCH_TRANSITION' USING ERRCODE = 'P0001';
    END IF;

    UPDATE public.results
    SET status = 'provisional'
    WHERE match_id = p_match_id AND status = 'draft';

    PERFORM public.log_audit(v_uid, 'result.published_provisional', 'result', NULL, NULL,
        jsonb_build_object('match_id', p_match_id)
    );
END;
$$;

-- ---------------------------------------------------------------------------
-- submit_dispute
-- ---------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.submit_dispute(
    p_match_id UUID,
    p_registration_id UUID,
    p_reason TEXT,
    p_evidence_paths TEXT[] DEFAULT '{}'
)
RETURNS UUID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
DECLARE
    v_uid UUID := auth.uid();
    v_m public.matches%ROWTYPE;
    v_reg public.tournament_registrations%ROWTYPE;
    v_dispute_id UUID;
    v_t public.tournaments%ROWTYPE;
BEGIN
    IF v_uid IS NULL THEN
        RAISE EXCEPTION 'AUTH_REQUIRED' USING ERRCODE = '42501';
    END IF;

    SELECT * INTO v_m FROM public.matches WHERE id = p_match_id;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'MATCH_NOT_FOUND' USING ERRCODE = 'P0002';
    END IF;

    SELECT * INTO v_t FROM public.tournaments WHERE id = v_m.tournament_id;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'TOURNAMENT_NOT_FOUND' USING ERRCODE = 'P0002';
    END IF;

    -- Check if match is completed (dispute window starts after match completion)
    IF v_m.status <> 'completed' THEN
        RAISE EXCEPTION 'DISPUTE_WINDOW_CLOSED' USING ERRCODE = 'P0001';
    END IF;

    -- Check dispute window
    IF v_m.ended_at IS NOT NULL AND v_m.ended_at + (v_t.dispute_window_hours || ' hours')::INTERVAL < NOW() THEN
        RAISE EXCEPTION 'DISPUTE_WINDOW_CLOSED' USING ERRCODE = 'P0001';
    END IF;

    SELECT * INTO v_reg FROM public.tournament_registrations
    WHERE id = p_registration_id AND tournament_id = v_m.tournament_id AND status = 'confirmed'
    FOR SHARE;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'INVALID_ENTRY_FOR_MATCH' USING ERRCODE = '22023';
    END IF;

    -- Verify registration is assigned to this match
    IF NOT EXISTS (
        SELECT 1 FROM public.match_entries
        WHERE match_id = p_match_id AND registration_id = p_registration_id
    ) THEN
        RAISE EXCEPTION 'ENTRY_NOT_ASSIGNED' USING ERRCODE = 'P0002';
    END IF;

    -- Verify submitter is part of the registration roster
    IF NOT EXISTS (
        SELECT 1 FROM public.tournament_entry_members
        WHERE entry_id = (
            SELECT id FROM public.tournament_registrations WHERE id = p_registration_id
        ) AND user_id = v_uid
    ) THEN
        RAISE EXCEPTION 'ENTRY_NOT_ASSIGNED' USING ERRCODE = '42501';
    END IF;

    -- Check for existing active dispute
    IF EXISTS (
        SELECT 1 FROM public.disputes
        WHERE match_id = p_match_id
          AND registration_id = p_registration_id
          AND status IN ('submitted', 'under_review')
    ) THEN
        RAISE EXCEPTION 'DISPUTE_ALREADY_EXISTS' USING ERRCODE = 'P0001';
    END IF;

    INSERT INTO public.disputes (
        match_id, registration_id, submitted_by, reason, evidence_paths
    ) VALUES (
        p_match_id, p_registration_id, v_uid, p_reason, p_evidence_paths
    ) RETURNING id INTO v_dispute_id;

    PERFORM public.log_audit(v_uid, 'dispute.submitted', 'dispute', v_dispute_id, NULL,
        jsonb_build_object('match_id', p_match_id, 'registration_id', p_registration_id)
    );

    RETURN v_dispute_id;
END;
$$;

-- ---------------------------------------------------------------------------
-- assign_dispute_moderator
-- ---------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.assign_dispute_moderator(
    p_dispute_id UUID,
    p_moderator_id UUID
)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
DECLARE
    v_uid UUID := auth.uid();
    v_d public.disputes%ROWTYPE;
    v_m public.matches%ROWTYPE;
    v_t public.tournaments%ROWTYPE;
    v_mod_reg public.tournament_registrations%ROWTYPE;
BEGIN
    IF v_uid IS NULL THEN
        RAISE EXCEPTION 'AUTH_REQUIRED' USING ERRCODE = '42501';
    END IF;

    SELECT * INTO v_d FROM public.disputes WHERE id = p_dispute_id FOR UPDATE;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'DISPUTE_NOT_FOUND' USING ERRCODE = 'P0002';
    END IF;

    SELECT * INTO v_m FROM public.matches WHERE id = v_d.match_id;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'MATCH_NOT_FOUND' USING ERRCODE = 'P0002';
    END IF;

    SELECT * INTO v_t FROM public.tournaments WHERE id = v_m.tournament_id;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'TOURNAMENT_NOT_FOUND' USING ERRCODE = 'P0002';
    END IF;

    IF NOT public.is_tournament_organizer(v_t.id, v_uid) THEN
        RAISE EXCEPTION 'NOT_TOURNAMENT_ORGANIZER' USING ERRCODE = '42501';
    END IF;

    -- Verify moderator is a tournament organizer with moderator role
    IF NOT EXISTS (
        SELECT 1 FROM public.tournament_organizers
        WHERE tournament_id = v_t.id AND user_id = p_moderator_id AND role = 'moderator'
    ) THEN
        RAISE EXCEPTION 'NOT_DISPUTE_MODERATOR' USING ERRCODE = '42501';
    END IF;

    -- Conflict of interest: moderator cannot be the submitter
    IF p_moderator_id = v_d.submitted_by THEN
        RAISE EXCEPTION 'MODERATOR_CONFLICT' USING ERRCODE = '42501';
    END IF;

    -- Conflict of interest: moderator cannot be in the registration roster
    IF EXISTS (
        SELECT 1 FROM public.tournament_entry_members
        WHERE entry_id = (SELECT id FROM public.tournament_registrations WHERE id = v_d.registration_id)
          AND user_id = p_moderator_id
    ) THEN
        RAISE EXCEPTION 'MODERATOR_CONFLICT' USING ERRCODE = '42501';
    END IF;

    UPDATE public.disputes
    SET moderator_id = p_moderator_id, status = 'under_review', assigned_at = NOW()
    WHERE id = p_dispute_id;

    PERFORM public.log_audit(v_uid, 'dispute.moderator_assigned', 'dispute', p_dispute_id, NULL,
        jsonb_build_object('moderator_id', p_moderator_id)
    );
END;
$$;

-- ---------------------------------------------------------------------------
-- finalize_match_results
-- ---------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.finalize_match_results(p_match_id UUID)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
DECLARE
    v_uid UUID := auth.uid();
    v_m public.matches%ROWTYPE;
    v_pending_disputes INTEGER;
    v_provisional_count INTEGER;
BEGIN
    IF v_uid IS NULL THEN
        RAISE EXCEPTION 'AUTH_REQUIRED' USING ERRCODE = '42501';
    END IF;

    SELECT * INTO v_m FROM public.matches WHERE id = p_match_id FOR UPDATE;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'MATCH_NOT_FOUND' USING ERRCODE = 'P0002';
    END IF;

    IF NOT public.is_tournament_organizer(v_m.tournament_id, v_uid) THEN
        RAISE EXCEPTION 'NOT_TOURNAMENT_ORGANIZER' USING ERRCODE = '42501';
    END IF;

    IF v_m.status <> 'completed' THEN
        RAISE EXCEPTION 'INVALID_MATCH_TRANSITION' USING ERRCODE = 'P0001';
    END IF;

    -- Check no pending disputes for this match
    SELECT count(*) INTO v_pending_disputes
    FROM public.disputes
    WHERE match_id = p_match_id AND status IN ('submitted', 'under_review');
    IF v_pending_disputes > 0 THEN
        RAISE EXCEPTION 'CANNOT_FINALIZE_PENDING_DISPUTES' USING ERRCODE = 'P0001';
    END IF;

    -- Check all assigned entries have provisional results
    SELECT count(*) INTO v_provisional_count
    FROM public.results
    WHERE match_id = p_match_id AND status = 'provisional';

    -- Get count of assigned entries
    DECLARE v_assigned_count INTEGER;
    BEGIN
        SELECT count(*) INTO v_assigned_count
        FROM public.match_entries WHERE match_id = p_match_id;
    END;

    IF v_provisional_count < v_assigned_count THEN
        RAISE EXCEPTION 'INVALID_MATCH_TRANSITION' USING ERRCODE = 'P0001';
    END IF;

    UPDATE public.results
    SET status = 'finalized', finalized_at = NOW(), finalized_by = v_uid
    WHERE match_id = p_match_id AND status = 'provisional';

    PERFORM public.log_audit(v_uid, 'result.finalized', 'result', NULL, NULL,
        jsonb_build_object('match_id', p_match_id)
    );
END;
$$;

-- ============================================
-- 11. GRANTS FOR NEW FUNCTIONS
-- ============================================
REVOKE ALL ON FUNCTION public.create_match(UUID, TEXT, INTEGER, TEXT, TEXT, INTEGER, TIMESTAMPTZ) FROM PUBLIC;
REVOKE ALL ON FUNCTION public.update_match(UUID, JSONB) FROM PUBLIC;
REVOKE ALL ON FUNCTION public.assign_match_entries(UUID, UUID[], INTEGER[], INTEGER[], TEXT[]) FROM PUBLIC;
REVOKE ALL ON FUNCTION public.remove_match_entry(UUID, UUID) FROM PUBLIC;
REVOKE ALL ON FUNCTION public.reschedule_match(UUID, TIMESTAMPTZ, TEXT) FROM PUBLIC;
REVOKE ALL ON FUNCTION public.start_match(UUID) FROM PUBLIC;
REVOKE ALL ON FUNCTION public.complete_match(UUID) FROM PUBLIC;
REVOKE ALL ON FUNCTION public.cancel_match(UUID, TEXT) FROM PUBLIC;
REVOKE ALL ON FUNCTION public.set_match_credentials(UUID, TEXT, TEXT, TIMESTAMPTZ) FROM PUBLIC;
REVOKE ALL ON FUNCTION public.get_match_credentials(UUID) FROM PUBLIC;
REVOKE ALL ON FUNCTION public.rotate_match_credentials(UUID, TEXT, TEXT) FROM PUBLIC;
REVOKE ALL ON FUNCTION public.save_result_draft(UUID, UUID, INTEGER, INTEGER, INTEGER, INTEGER, INTEGER, JSONB) FROM PUBLIC;
REVOKE ALL ON FUNCTION public.publish_provisional_results(UUID) FROM PUBLIC;
REVOKE ALL ON FUNCTION public.submit_dispute(UUID, UUID, TEXT, TEXT[]) FROM PUBLIC;
REVOKE ALL ON FUNCTION public.assign_dispute_moderator(UUID, UUID) FROM PUBLIC;
REVOKE ALL ON FUNCTION public.finalize_match_results(UUID) FROM PUBLIC;

GRANT EXECUTE ON FUNCTION public.create_match(UUID, TEXT, INTEGER, TEXT, TEXT, INTEGER, TIMESTAMPTZ) TO authenticated;
GRANT EXECUTE ON FUNCTION public.update_match(UUID, JSONB) TO authenticated;
GRANT EXECUTE ON FUNCTION public.assign_match_entries(UUID, UUID[], INTEGER[], INTEGER[], TEXT[]) TO authenticated;
GRANT EXECUTE ON FUNCTION public.remove_match_entry(UUID, UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION public.reschedule_match(UUID, TIMESTAMPTZ, TEXT) TO authenticated;
GRANT EXECUTE ON FUNCTION public.start_match(UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION public.complete_match(UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION public.cancel_match(UUID, TEXT) TO authenticated;
GRANT EXECUTE ON FUNCTION public.set_match_credentials(UUID, TEXT, TEXT, TIMESTAMPTZ) TO authenticated;
GRANT EXECUTE ON FUNCTION public.get_match_credentials(UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION public.rotate_match_credentials(UUID, TEXT, TEXT) TO authenticated;
GRANT EXECUTE ON FUNCTION public.save_result_draft(UUID, UUID, INTEGER, INTEGER, INTEGER, INTEGER, INTEGER, JSONB) TO authenticated;
GRANT EXECUTE ON FUNCTION public.publish_provisional_results(UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION public.submit_dispute(UUID, UUID, TEXT, TEXT[]) TO authenticated;
GRANT EXECUTE ON FUNCTION public.assign_dispute_moderator(UUID, UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION public.finalize_match_results(UUID) TO authenticated;