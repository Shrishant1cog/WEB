-- ============================================================================
-- FIX: Create missing tournament_public_listing view and related functions
-- Run this in Supabase SQL Editor for project zjwgqjjgqbkunzhghdtb
-- This is extracted from migration 20261106000005_phase3_tournament_participation.sql
-- ============================================================================

-- ============================================================================
-- 1. Tournament configuration columns (if not already added)
-- ============================================================================
ALTER TABLE public.tournaments
    ADD COLUMN IF NOT EXISTS rules_text TEXT,
    ADD COLUMN IF NOT EXISTS cover_url TEXT,
    ADD COLUMN IF NOT EXISTS eligibility JSONB NOT NULL DEFAULT '{}'::jsonb,
    ADD COLUMN IF NOT EXISTS waitlist_enabled BOOLEAN NOT NULL DEFAULT true,
    ADD COLUMN IF NOT EXISTS withdrawal_deadline TIMESTAMPTZ,
    ADD COLUMN IF NOT EXISTS published_at TIMESTAMPTZ,
    ADD COLUMN IF NOT EXISTS registration_opened_at TIMESTAMPTZ,
    ADD COLUMN IF NOT EXISTS registration_closed_at TIMESTAMPTZ,
    ADD COLUMN IF NOT EXISTS cancelled_at TIMESTAMPTZ,
    ADD COLUMN IF NOT EXISTS cancellation_reason TEXT;

CREATE INDEX IF NOT EXISTS idx_tournaments_public_listing
    ON public.tournaments (status, tournament_starts_at)
    WHERE deleted_at IS NULL AND visibility = 'public';

CREATE INDEX IF NOT EXISTS idx_tournaments_organizer_status
    ON public.tournaments (organizer_id, status)
    WHERE deleted_at IS NULL;

-- ============================================================================
-- 2. Registration / entry extensions
-- ============================================================================
CREATE SEQUENCE IF NOT EXISTS public.tournament_waitlist_seq;

ALTER TABLE public.tournament_registrations
    ADD COLUMN IF NOT EXISTS team_id UUID REFERENCES public.teams(id) ON DELETE SET NULL,
    ADD COLUMN IF NOT EXISTS entry_type TEXT,
    ADD COLUMN IF NOT EXISTS roster_snapshot JSONB NOT NULL DEFAULT '[]'::jsonb,
    ADD COLUMN IF NOT EXISTS waitlist_seq BIGINT,
    ADD COLUMN IF NOT EXISTS waitlisted_at TIMESTAMPTZ,
    ADD COLUMN IF NOT EXISTS promoted_at TIMESTAMPTZ,
    ADD COLUMN IF NOT EXISTS withdrawn_at TIMESTAMPTZ,
    ADD COLUMN IF NOT EXISTS cancellation_reason TEXT;

ALTER TABLE public.tournament_registrations
    DROP CONSTRAINT IF EXISTS tournament_registrations_entry_type_check;
ALTER TABLE public.tournament_registrations
    ADD CONSTRAINT tournament_registrations_entry_type_check
    CHECK (entry_type IS NULL OR entry_type IN ('solo', 'squad'));

CREATE INDEX IF NOT EXISTS idx_registrations_waitlist
    ON public.tournament_registrations (tournament_id, waitlist_seq)
    WHERE status = 'waitlisted';

CREATE UNIQUE INDEX IF NOT EXISTS uq_registrations_tournament_team_active
    ON public.tournament_registrations (tournament_id, team_id)
    WHERE team_id IS NOT NULL AND status IN ('pending', 'confirmed', 'waitlisted');

-- tournament_entry_members table
CREATE TABLE IF NOT EXISTS public.tournament_entry_members (
    entry_id UUID NOT NULL REFERENCES public.tournament_registrations(id) ON DELETE CASCADE,
    tournament_id UUID NOT NULL REFERENCES public.tournaments(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    role TEXT NOT NULL DEFAULT 'member' CHECK (role IN ('captain', 'member')),
    in_game_name TEXT,
    in_game_uid TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    PRIMARY KEY (entry_id, user_id),
    UNIQUE (tournament_id, user_id)
);

CREATE INDEX IF NOT EXISTS idx_entry_members_user
    ON public.tournament_entry_members (user_id);
CREATE INDEX IF NOT EXISTS idx_entry_members_tournament
    ON public.tournament_entry_members (tournament_id);

ALTER TABLE public.tournament_entry_members ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Entry members can read own entry" ON public.tournament_entry_members;
CREATE POLICY "Entry members can read own entry"
    ON public.tournament_entry_members FOR SELECT
    USING (
        user_id = auth.uid()
        OR EXISTS (
            SELECT 1 FROM public.tournament_registrations r
            WHERE r.id = tournament_entry_members.entry_id
              AND r.user_id = auth.uid()
        )
        OR EXISTS (
            SELECT 1 FROM public.tournaments t
            WHERE t.id = tournament_entry_members.tournament_id
              AND t.organizer_id = auth.uid()
        )
        OR EXISTS (
            SELECT 1 FROM public.tournament_organizers o
            WHERE o.tournament_id = tournament_entry_members.tournament_id
              AND o.user_id = auth.uid()
        )
    );

-- ============================================================================
-- 3. Teams: captaincy + invitation hardening
-- ============================================================================
ALTER TABLE public.teams
    ADD COLUMN IF NOT EXISTS captain_id UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
    ADD COLUMN IF NOT EXISTS max_members INTEGER NOT NULL DEFAULT 10;

UPDATE public.teams SET captain_id = owner_id WHERE captain_id IS NULL;

CREATE TABLE IF NOT EXISTS public.team_invitations (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    team_id UUID NOT NULL REFERENCES public.teams(id) ON DELETE CASCADE,
    invited_by UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    invited_user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE,
    email TEXT,
    token_hash TEXT NOT NULL UNIQUE,
    status TEXT NOT NULL DEFAULT 'pending'
        CHECK (status IN ('pending', 'accepted', 'declined', 'revoked', 'expired')),
    expires_at TIMESTAMPTZ NOT NULL,
    accepted_by UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    responded_at TIMESTAMPTZ,
    CONSTRAINT team_invitation_target_required
        CHECK (invited_user_id IS NOT NULL OR email IS NOT NULL),
    CONSTRAINT team_invitation_expiry_future
        CHECK (expires_at > created_at)
);

CREATE INDEX IF NOT EXISTS idx_team_invitations_team
    ON public.team_invitations (team_id, status);
CREATE INDEX IF NOT EXISTS idx_team_invitations_user
    ON public.team_invitations (invited_user_id, status);

ALTER TABLE public.team_invitations ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Team staff can read invitations" ON public.team_invitations;
CREATE POLICY "Team staff can read invitations"
    ON public.team_invitations FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM public.teams t
            WHERE t.id = team_invitations.team_id
              AND (t.owner_id = auth.uid() OR t.captain_id = auth.uid())
        )
        OR invited_user_id = auth.uid()
    );

-- ============================================================================
-- 4. Helper functions
-- ============================================================================
CREATE OR REPLACE FUNCTION public.is_tournament_organizer(
    p_tournament_id UUID,
    p_user_id UUID DEFAULT auth.uid()
)
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
    SELECT EXISTS (
        SELECT 1 FROM public.tournaments t
        WHERE t.id = p_tournament_id
          AND t.organizer_id = p_user_id
    ) OR EXISTS (
        SELECT 1 FROM public.tournament_organizers o
        WHERE o.tournament_id = p_tournament_id
          AND o.user_id = p_user_id
    );
$$;

CREATE OR REPLACE FUNCTION public.is_team_captain(
    p_team_id UUID,
    p_user_id UUID DEFAULT auth.uid()
)
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
    SELECT EXISTS (
        SELECT 1 FROM public.teams t
        WHERE t.id = p_team_id
          AND t.deleted_at IS NULL
          AND (t.owner_id = p_user_id OR t.captain_id = p_user_id)
    );
$$;

-- ============================================================================
-- 5. Tournament lifecycle functions (SECURITY DEFINER)
-- ============================================================================
CREATE OR REPLACE FUNCTION public.create_tournament(p_payload JSONB)
RETURNS UUID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
DECLARE
    v_uid UUID := auth.uid();
    v_id UUID;
    v_format TEXT := p_payload->>'format';
    v_team_size INTEGER := COALESCE((p_payload->>'team_size')::INTEGER, 4);
    v_reg_start TIMESTAMPTZ := (p_payload->>'registration_starts_at')::TIMESTAMPTZ;
    v_reg_end TIMESTAMPTZ := (p_payload->>'registration_ends_at')::TIMESTAMPTZ;
    v_start TIMESTAMPTZ := (p_payload->>'tournament_starts_at')::TIMESTAMPTZ;
    v_end TIMESTAMPTZ := NULLIF(p_payload->>'tournament_ends_at', '')::TIMESTAMPTZ;
BEGIN
    IF v_uid IS NULL THEN
        RAISE EXCEPTION 'AUTH_REQUIRED' USING ERRCODE = '42501';
    END IF;
    IF COALESCE(trim(p_payload->>'title'), '') = '' THEN
        RAISE EXCEPTION 'TITLE_REQUIRED' USING ERRCODE = '22023';
    END IF;
    IF v_format NOT IN ('solo', 'duo', 'squad', 'custom') THEN
        RAISE EXCEPTION 'INVALID_FORMAT' USING ERRCODE = '22023';
    END IF;
    IF v_format = 'solo' THEN
        v_team_size := 1;
    END IF;
    IF v_reg_start IS NULL OR v_reg_end IS NULL OR v_start IS NULL THEN
        RAISE EXCEPTION 'DATES_REQUIRED' USING ERRCODE = '22023';
    END IF;

    INSERT INTO public.tournaments (
        organizer_id, title, description, format, mode, map,
        max_teams, team_size, registration_starts_at, registration_ends_at,
        tournament_starts_at, tournament_ends_at, prize_pool, rules_url,
        rules_text, contact_info, visibility, eligibility, waitlist_enabled,
        withdrawal_deadline, status
    ) VALUES (
        v_uid,
        trim(p_payload->>'title'),
        NULLIF(p_payload->>'description', ''),
        v_format,
        COALESCE(NULLIF(p_payload->>'mode', ''), 'br'),
        NULLIF(p_payload->>'map', ''),
        COALESCE((p_payload->>'max_teams')::INTEGER, 50),
        v_team_size,
        v_reg_start,
        v_reg_end,
        v_start,
        v_end,
        NULLIF(p_payload->>'prize_pool', ''),
        NULLIF(p_payload->>'rules_url', ''),
        NULLIF(p_payload->>'rules_text', ''),
        NULLIF(p_payload->>'contact_info', ''),
        COALESCE(NULLIF(p_payload->>'visibility', ''), 'public'),
        COALESCE(p_payload->'eligibility', '{}'::jsonb),
        COALESCE((p_payload->>'waitlist_enabled')::BOOLEAN, true),
        NULLIF(p_payload->>'withdrawal_deadline', '')::TIMESTAMPTZ,
        'draft'
    ) RETURNING id INTO v_id;

    INSERT INTO public.tournament_organizers (tournament_id, user_id, role)
    VALUES (v_id, v_uid, 'owner')
    ON CONFLICT (tournament_id, user_id) DO NOTHING;

    PERFORM public.log_audit(v_uid, 'tournament.created', 'tournament', v_id, NULL,
        jsonb_build_object('title', p_payload->>'title', 'format', v_format));

    RETURN v_id;
END;
$$;

CREATE OR REPLACE FUNCTION public.update_tournament(p_tournament_id UUID, p_payload JSONB)
RETURNS UUID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
DECLARE
    v_uid UUID := auth.uid();
    v_t public.tournaments%ROWTYPE;
BEGIN
    IF v_uid IS NULL THEN
        RAISE EXCEPTION 'AUTH_REQUIRED' USING ERRCODE = '42501';
    END IF;
    IF NOT public.is_tournament_organizer(p_tournament_id, v_uid) THEN
        RAISE EXCEPTION 'NOT_TOURNAMENT_ORGANIZER' USING ERRCODE = '42501';
    END IF;

    SELECT * INTO v_t FROM public.tournaments WHERE id = p_tournament_id AND deleted_at IS NULL FOR UPDATE;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'TOURNAMENT_NOT_FOUND' USING ERRCODE = 'P0002';
    END IF;
    IF v_t.status NOT IN ('draft', 'published', 'registration_open') THEN
        RAISE EXCEPTION 'TOURNAMENT_NOT_EDITABLE' USING ERRCODE = 'P0001';
    END IF;

    UPDATE public.tournaments SET
        title = COALESCE(NULLIF(trim(p_payload->>'title'), ''), title),
        description = CASE WHEN p_payload ? 'description' THEN NULLIF(p_payload->>'description', '') ELSE description END,
        mode = COALESCE(NULLIF(p_payload->>'mode', ''), mode),
        map = CASE WHEN p_payload ? 'map' THEN NULLIF(p_payload->>'map', '') ELSE map END,
        max_teams = COALESCE((p_payload->>'max_teams')::INTEGER, max_teams),
        team_size = CASE
            WHEN format = 'solo' THEN 1
            ELSE COALESCE((p_payload->>'team_size')::INTEGER, team_size)
        END,
        registration_starts_at = COALESCE((p_payload->>'registration_starts_at')::TIMESTAMPTZ, registration_starts_at),
        registration_ends_at = COALESCE((p_payload->>'registration_ends_at')::TIMESTAMPTZ, registration_ends_at),
        tournament_starts_at = COALESCE((p_payload->>'tournament_starts_at')::TIMESTAMPTZ, tournament_starts_at),
        tournament_ends_at = CASE WHEN p_payload ? 'tournament_ends_at' THEN NULLIF(p_payload->>'tournament_ends_at', '')::TIMESTAMPTZ ELSE tournament_ends_at END,
        prize_pool = CASE WHEN p_payload ? 'prize_pool' THEN NULLIF(p_payload->>'prize_pool', '') ELSE prize_pool END,
        rules_url = CASE WHEN p_payload ? 'rules_url' THEN NULLIF(p_payload->>'rules_url', '') ELSE rules_url END,
        rules_text = CASE WHEN p_payload ? 'rules_text' THEN NULLIF(p_payload->>'rules_text', '') ELSE rules_text END,
        contact_info = CASE WHEN p_payload ? 'contact_info' THEN NULLIF(p_payload->>'contact_info', '') ELSE contact_info END,
        visibility = COALESCE(NULLIF(p_payload->>'visibility', ''), visibility),
        eligibility = COALESCE(p_payload->'eligibility', eligibility),
        waitlist_enabled = COALESCE((p_payload->>'waitlist_enabled')::BOOLEAN, waitlist_enabled),
        withdrawal_deadline = CASE WHEN p_payload ? 'withdrawal_deadline' THEN NULLIF(p_payload->>'withdrawal_deadline', '')::TIMESTAMPTZ ELSE withdrawal_deadline END
    WHERE id = p_tournament_id;

    PERFORM public.log_audit(v_uid, 'tournament.updated', 'tournament', p_tournament_id, NULL, p_payload);

    RETURN p_tournament_id;
END;
$$;

CREATE OR REPLACE FUNCTION public.set_tournament_status(
    p_tournament_id UUID,
    p_status TEXT,
    p_reason TEXT DEFAULT NULL
)
RETURNS public.tournaments
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
DECLARE
    v_uid UUID := auth.uid();
    v_t public.tournaments%ROWTYPE;
    v_allowed BOOLEAN := false;
BEGIN
    IF v_uid IS NULL THEN
        RAISE EXCEPTION 'AUTH_REQUIRED' USING ERRCODE = '42501';
    END IF;
    IF NOT public.is_tournament_organizer(p_tournament_id, v_uid) THEN
        RAISE EXCEPTION 'NOT_TOURNAMENT_ORGANIZER' USING ERRCODE = '42501';
    END IF;

    SELECT * INTO v_t FROM public.tournaments WHERE id = p_tournament_id AND deleted_at IS NULL FOR UPDATE;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'TOURNAMENT_NOT_FOUND' USING ERRCODE = 'P0002';
    END IF;

    v_allowed := CASE
        WHEN v_t.status = 'draft' AND p_status = 'published' THEN true
        WHEN v_t.status = 'published' AND p_status = 'registration_open' THEN true
        WHEN v_t.status = 'registration_open' AND p_status = 'registration_closed' THEN true
        WHEN v_t.status = 'registration_closed' AND p_status = 'registration_open' THEN true
        WHEN v_t.status = 'registration_closed' AND p_status = 'in_progress' THEN true
        WHEN p_status = 'cancelled' AND v_t.status IN ('draft', 'published', 'registration_open', 'registration_closed') THEN true
        ELSE false
    END;

    IF NOT v_allowed THEN
        RAISE EXCEPTION 'INVALID_STATUS_TRANSITION: % -> %', v_t.status, p_status USING ERRCODE = 'P0001';
    END IF;

    IF p_status = 'published' AND (v_t.registration_starts_at >= v_t.registration_ends_at
        OR v_t.registration_ends_at > v_t.tournament_starts_at) THEN
        RAISE EXCEPTION 'INVALID_TOURNAMENT_DATES' USING ERRCODE = '22023';
    END IF;

    UPDATE public.tournaments SET
        status = p_status,
        published_at = CASE WHEN p_status = 'published' THEN NOW() ELSE published_at END,
        registration_opened_at = CASE WHEN p_status = 'registration_open' THEN NOW() ELSE registration_opened_at END,
        registration_closed_at = CASE WHEN p_status = 'registration_closed' THEN NOW() ELSE registration_closed_at END,
        cancelled_at = CASE WHEN p_status = 'cancelled' THEN NOW() ELSE cancelled_at END,
        cancellation_reason = CASE WHEN p_status = 'cancelled' THEN p_reason ELSE cancellation_reason END
    WHERE id = p_tournament_id
    RETURNING * INTO v_t;

    IF p_status = 'cancelled' THEN
        UPDATE public.tournament_registrations
        SET status = 'cancelled',
            withdrawn_at = NOW(),
            cancellation_reason = COALESCE(p_reason, 'tournament_cancelled')
        WHERE tournament_id = p_tournament_id
          AND status IN ('pending', 'confirmed', 'waitlisted');

        PERFORM public.create_notification(
            m.user_id,
            'tournament_cancelled',
            'Tournament cancelled',
            v_t.title || ' has been cancelled.',
            jsonb_build_object('tournament_id', p_tournament_id)
        )
        FROM public.tournament_entry_members m
        WHERE m.tournament_id = p_tournament_id;
    END IF;

    PERFORM public.log_audit(v_uid, 'tournament.status_changed', 'tournament', p_tournament_id,
        jsonb_build_object('status', v_t.status), jsonb_build_object('status', p_status, 'reason', p_reason));

    RETURN v_t;
END;
$$;

-- ============================================================================
-- 6. Registration + waitlist (race safe)
-- ============================================================================
CREATE OR REPLACE FUNCTION public.promote_next_waitlisted(p_tournament_id UUID)
RETURNS UUID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
DECLARE
    v_t public.tournaments%ROWTYPE;
    v_entry public.tournament_registrations%ROWTYPE;
    v_confirmed INTEGER;
BEGIN
    SELECT * INTO v_t FROM public.tournaments WHERE id = p_tournament_id FOR UPDATE;
    IF NOT FOUND THEN
        RETURN NULL;
    END IF;

    SELECT count(*) INTO v_confirmed
    FROM public.tournament_registrations
    WHERE tournament_id = p_tournament_id AND status = 'confirmed';

    IF v_confirmed >= v_t.max_teams THEN
        RETURN NULL;
    END IF;

    SELECT * INTO v_entry
    FROM public.tournament_registrations
    WHERE tournament_id = p_tournament_id AND status = 'waitlisted'
    ORDER BY waitlist_seq NULLS LAST, registered_at
    LIMIT 1
    FOR UPDATE;

    IF NOT FOUND THEN
        RETURN NULL;
    END IF;

    UPDATE public.tournament_registrations
    SET status = 'confirmed', confirmed_at = NOW(), promoted_at = NOW()
    WHERE id = v_entry.id;

    PERFORM public.create_notification(
        v_entry.user_id,
        'waitlist_promoted',
        'You are in!',
        'A spot opened up and your registration is now confirmed.',
        jsonb_build_object('tournament_id', p_tournament_id, 'entry_id', v_entry.id)
    );

    PERFORM public.log_audit(NULL, 'tournament.waitlist_promoted', 'tournament_registration', v_entry.id,
        jsonb_build_object('status', 'waitlisted'), jsonb_build_object('status', 'confirmed'));

    RETURN v_entry.id;
END;
$$;

CREATE OR REPLACE FUNCTION public.organizer_promote_waitlist(p_tournament_id UUID)
RETURNS UUID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
DECLARE
    v_uid UUID := auth.uid();
BEGIN
    IF v_uid IS NULL THEN
        RAISE EXCEPTION 'AUTH_REQUIRED' USING ERRCODE = '42501';
    END IF;
    IF NOT public.is_tournament_organizer(p_tournament_id, v_uid) THEN
        RAISE EXCEPTION 'NOT_TOURNAMENT_ORGANIZER' USING ERRCODE = '42501';
    END IF;
    RETURN public.promote_next_waitlisted(p_tournament_id);
END;
$$;

CREATE OR REPLACE FUNCTION public.register_tournament_entry(
    p_tournament_id UUID,
    p_team_id UUID DEFAULT NULL
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, extensions, pg_temp
AS $$
DECLARE
    v_uid UUID := auth.uid();
    v_t public.tournaments%ROWTYPE;
    v_team public.teams%ROWTYPE;
    v_members UUID[];
    v_member_count INTEGER;
    v_confirmed INTEGER;
    v_entry public.tournament_registrations%ROWTYPE;
    v_had_entry BOOLEAN := false;
    v_entry_id UUID;
    v_status TEXT;
    v_wait_seq BIGINT;
    v_entry_type TEXT;
    v_snapshot JSONB;
    v_missing_name TEXT;
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

    IF public.is_tournament_organizer(p_tournament_id, v_uid) THEN
        RAISE EXCEPTION 'ORGANIZER_CANNOT_PARTICIPATE' USING ERRCODE = 'P0001';
    END IF;
    IF v_t.status <> 'registration_open' THEN
        RAISE EXCEPTION 'REGISTRATION_NOT_OPEN' USING ERRCODE = 'P0001';
    END IF;
    IF NOW() < v_t.registration_starts_at OR NOW() > v_t.registration_ends_at THEN
        RAISE EXCEPTION 'REGISTRATION_WINDOW_CLOSED' USING ERRCODE = 'P0001';
    END IF;

    IF v_t.format = 'solo' THEN
        IF p_team_id IS NOT NULL THEN
            RAISE EXCEPTION 'TEAM_NOT_ALLOWED_FOR_SOLO' USING ERRCODE = '22023';
        END IF;
        v_entry_type := 'solo';
        v_members := ARRAY[v_uid];
    ELSE
        IF p_team_id IS NULL THEN
            RAISE EXCEPTION 'TEAM_REQUIRED_FOR_SQUAD' USING ERRCODE = '22023';
        END IF;
        SELECT * INTO v_team FROM public.teams WHERE id = p_team_id AND deleted_at IS NULL;
        IF NOT FOUND THEN
            RAISE EXCEPTION 'TEAM_NOT_FOUND' USING ERRCODE = 'P0002';
        END IF;
        IF NOT public.is_team_captain(p_team_id, v_uid) THEN
            RAISE EXCEPTION 'ONLY_CAPTAIN_CAN_REGISTER' USING ERRCODE = '42501';
        END IF;

        SELECT array_agg(user_id ORDER BY joined_at) INTO v_members
        FROM public.team_members WHERE team_id = p_team_id;
        v_member_count := COALESCE(array_length(v_members, 1), 0);
        IF v_member_count <> v_t.team_size THEN
            RAISE EXCEPTION 'ROSTER_INCOMPLETE: expected % members, found %', v_t.team_size, v_member_count
                USING ERRCODE = 'P0001';
        END IF;
        v_entry_type := 'squad';
    END IF;

    IF COALESCE((v_t.eligibility->>'requires_ingame_id')::BOOLEAN, false) THEN
        SELECT p.display_name INTO v_missing_name
        FROM public.profiles p
        WHERE p.id = ANY(v_members)
          AND (p.in_game_uid IS NULL OR p.in_game_uid = '')
        LIMIT 1;
        IF v_missing_name IS NOT NULL THEN
            RAISE EXCEPTION 'ELIGIBILITY_INGAME_ID_REQUIRED: %', v_missing_name USING ERRCODE = 'P0001';
        END IF;
    END IF;

    IF EXISTS (SELECT 1 FROM public.profiles p WHERE p.id = ANY(v_members) AND p.deleted_at IS NOT NULL) THEN
        RAISE EXCEPTION 'PLAYER_ACCOUNT_DELETED' USING ERRCODE = 'P0001';
    END IF;

    IF EXISTS (
        SELECT 1 FROM public.tournament_entry_members m
        WHERE m.tournament_id = p_tournament_id AND m.user_id = ANY(v_members)
    ) THEN
        RAISE EXCEPTION 'PLAYER_ALREADY_REGISTERED' USING ERRCODE = '23505';
    END IF;

    SELECT * INTO v_entry
    FROM public.tournament_registrations
    WHERE tournament_id = p_tournament_id AND user_id = v_uid;
    v_had_entry := FOUND;

    IF v_had_entry AND v_entry.status <> 'cancelled' THEN
        RAISE EXCEPTION 'ALREADY_REGISTERED' USING ERRCODE = '23505';
    END IF.
    IF v_had_entry AND v_entry.entry_type IS NOT NULL AND v_entry.entry_type <> v_entry_type THEN
        RAISE EXCEPTION 'ENTRY_TYPE_CONFLICT' USING ERRCODE = 'P0001';
    END IF.

    SELECT count(*) INTO v_confirmed
    FROM public.tournament_registrations
    WHERE tournament_id = p_tournament_id AND status = 'confirmed';

    IF v_confirmed < v_t.max_teams THEN
        v_status := 'confirmed';
    ELSIF v_t.waitlist_enabled THEN
        v_status := 'waitlisted';
        v_wait_seq := nextval('public.tournament_waitlist_seq');
    ELSE
        RAISE EXCEPTION 'TOURNAMENT_FULL' USING ERRCODE = 'P0001';
    END IF.

    SELECT COALESCE(jsonb_agg(jsonb_build_object(
        'user_id', p.id,
        'display_name', p.display_name,
        'in_game_name', p.in_game_name,
        'in_game_uid', p.in_game_uid
    )), '[]'::jsonb) INTO v_snapshot
    FROM public.profiles p WHERE p.id = ANY(v_members);

    IF v_had_entry THEN
        UPDATE public.tournament_registrations SET
            status = v_status,
            team_id = p_team_id,
            entry_type = v_entry_type,
            team_name = CASE WHEN v_entry_type = 'squad' THEN v_team.name ELSE NULL END,
            team_members = v_members,
            roster_snapshot = v_snapshot,
            registered_at = NOW(),
            confirmed_at = CASE WHEN v_status = 'confirmed' THEN NOW() ELSE NULL END,
            waitlisted_at = CASE WHEN v_status = 'waitlisted' THEN NOW() ELSE NULL END,
            waitlist_seq = v_wait_seq,
            promoted_at = NULL,
            withdrawn_at = NULL,
            cancellation_reason = NULL
        WHERE id = v_entry.id
        RETURNING id INTO v_entry_id;
    ELSE
        INSERT INTO public.tournament_registrations (
            tournament_id, user_id, team_id, entry_type, team_name, team_members,
            roster_snapshot, status, confirmed_at, waitlisted_at, waitlist_seq
        ) VALUES (
            p_tournament_id, v_uid, p_team_id, v_entry_type,
            CASE WHEN v_entry_type = 'squad' THEN v_team.name ELSE NULL END,
            v_members, v_snapshot, v_status,
            CASE WHEN v_status = 'confirmed' THEN NOW() ELSE NULL END,
            CASE WHEN v_status = 'waitlisted' THEN NOW() ELSE NULL END,
            v_wait_seq
        ) RETURNING id INTO v_entry_id;
    END IF.

    DELETE FROM public.tournament_entry_members WHERE entry_id = v_entry_id;
    INSERT INTO public.tournament_entry_members (
        entry_id, tournament_id, user_id, role, in_game_name, in_game_uid
    )
    SELECT v_entry_id, p_tournament_id, p.id,
           CASE WHEN p.id = v_uid THEN 'captain' ELSE 'member' END,
           p.in_game_name, p.in_game_uid
    FROM public.profiles p WHERE p.id = ANY(v_members);

    PERFORM public.create_notification(
        v_uid,
        CASE WHEN v_status = 'confirmed' THEN 'registration_confirmed' ELSE 'registration_waitlisted' END,
        CASE WHEN v_status = 'confirmed' THEN 'Registration confirmed' ELSE 'Added to waitlist' END,
        v_t.title || CASE WHEN v_status = 'confirmed'
            THEN ' - your entry is confirmed.'
            ELSE ' - the tournament is full, you are on the waitlist.' END,
        jsonb_build_object('tournament_id', p_tournament_id, 'entry_id', v_entry_id)
    );

    PERFORM public.log_audit(v_uid, 'tournament.registration_created', 'tournament_registration', v_entry_id,
        NULL, jsonb_build_object('tournament_id', p_tournament_id, 'status', v_status, 'entry_type', v_entry_type));

    RETURN jsonb_build_object(
        'entry_id', v_entry_id,
        'status', v_status,
        'waitlist_position', CASE WHEN v_status = 'waitlisted' THEN (
            SELECT count(*) FROM public.tournament_registrations r
            WHERE r.tournament_id = p_tournament_id
              AND r.status = 'waitlisted'
              AND r.waitlist_seq <= v_wait_seq
        ) ELSE NULL END
    );
END;
$$;

CREATE OR REPLACE FUNCTION public.withdraw_tournament_entry(p_entry_id UUID)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
DECLARE
    v_uid UUID := auth.uid();
    v_entry public.tournament_registrations%ROWTYPE;
    v_t public.tournaments%ROWTYPE;
    v_promoted UUID;
BEGIN
    IF v_uid IS NULL THEN
        RAISE EXCEPTION 'AUTH_REQUIRED' USING ERRCODE = '42501';
    END IF.

    SELECT * INTO v_entry FROM public.tournament_registrations WHERE id = p_entry_id FOR UPDATE;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'ENTRY_NOT_FOUND' USING ERRCODE = 'P0002'.
    END IF.
    IF v_entry.user_id <> v_uid THEN
        RAISE EXCEPTION 'NOT_ENTRY_OWNER' USING ERRCODE = '42501'.
    END IF.
    IF v_entry.status = 'cancelled' THEN
        RETURN jsonb_build_object('entry_id', v_entry.id, 'status', 'cancelled', 'promoted_entry_id', NULL).
    END IF.

    SELECT * INTO v_t FROM public.tournaments WHERE id = v_entry.tournament_id FOR UPDATE;
    IF v_t.status <> 'registration_open' THEN
        RAISE EXCEPTION 'WITHDRAWAL_CLOSED' USING ERRCODE = 'P0001'.
    END IF.
    IF NOW() > COALESCE(v_t.withdrawal_deadline, v_t.registration_ends_at) THEN
        RAISE EXCEPTION 'WITHDRAWAL_DEADLINE_PASSED' USING ERRCODE = 'P0001'.
    END IF.

    UPDATE public.tournament_registrations SET
        status = 'cancelled',
        withdrawn_at = NOW(),
        cancellation_reason = 'withdrawn_by_player'
    WHERE id = p_entry_id.

    DELETE FROM public.tournament_entry_members WHERE entry_id = p_entry_id.

    IF v_entry.status = 'confirmed' THEN
        v_promoted := public.promote_next_waitlisted(v_t.id);
    END IF.

    PERFORM public.log_audit(v_uid, 'tournament.registration_withdrawn', 'tournament_registration', p_entry_id,
        jsonb_build_object('status', v_entry.status), jsonb_build_object('status', 'cancelled'));

    RETURN jsonb_build_object(
        'entry_id', p_entry_id,
        'status', 'cancelled',
        'promoted_entry_id', v_promoted
    );
END;
$$;

-- ============================================================================
-- 7. Teams functions
-- ============================================================================
CREATE OR REPLACE FUNCTION public.create_team(
    p_name TEXT,
    p_tag TEXT DEFAULT NULL,
    p_description TEXT DEFAULT NULL
)
RETURNS UUID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
DECLARE
    v_uid UUID := auth.uid();
    v_team_id UUID;
BEGIN
    IF v_uid IS NULL THEN
        RAISE EXCEPTION 'AUTH_REQUIRED' USING ERRCODE = '42501'.
    END IF.
    IF char_length(trim(p_name)) NOT BETWEEN 3 AND 50 THEN
        RAISE EXCEPTION 'INVALID_TEAM_NAME' USING ERRCODE = '22023'.
    END IF.

    INSERT INTO public.teams (name, tag, owner_id, captain_id, description)
    VALUES (trim(p_name), NULLIF(trim(p_tag), ''), v_uid, v_uid, NULLIF(trim(p_description), ''))
    RETURNING id INTO v_team_id.

    INSERT INTO public.team_members (team_id, user_id, role)
    VALUES (v_team_id, v_uid, 'owner').

    INSERT INTO public.team_member_events (team_id, actor_id, event_type, subject_user_id)
    VALUES (v_team_id, v_uid, 'team_created', v_uid).

    PERFORM public.log_audit(v_uid, 'team.created', 'team', v_team_id, NULL,
        jsonb_build_object('name', p_name)).

    RETURN v_team_id.
END;
$$;

CREATE OR REPLACE FUNCTION public.invite_to_team(
    p_team_id UUID,
    p_invited_user_id UUID DEFAULT NULL,
    p_email TEXT DEFAULT NULL,
    p_expires_hours INTEGER DEFAULT 72
)
RETURNS TEXT
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, extensions, pg_temp
AS $$
DECLARE
    v_uid UUID := auth.uid();
    v_token TEXT;
    v_hash TEXT;
    v_member_count INTEGER;
    v_recent_invites INTEGER;
BEGIN
    IF v_uid IS NULL THEN
        RAISE EXCEPTION 'AUTH_REQUIRED' USING ERRCODE = '42501'.
    END IF.
    IF NOT public.is_team_captain(p_team_id, v_uid) THEN
        RAISE EXCEPTION 'ONLY_CAPTAIN_CAN_INVITE' USING ERRCODE = '42501'.
    END IF.
    IF p_invited_user_id IS NULL AND p_email IS NULL THEN
        RAISE EXCEPTION 'INVITE_TARGET_REQUIRED' USING ERRCODE = '22023'.
    END IF.
    IF p_expires_hours < 1 OR p_expires_hours > 168 THEN
        RAISE EXCEPTION 'INVALID_INVITE_EXPIRY' USING ERRCODE = '22023'.
    END IF.

    SELECT count(*) INTO v_recent_invites
    FROM public.team_invitations
    WHERE team_id = p_team_id AND created_at > NOW() - INTERVAL '1 hour';
    IF v_recent_invites >= 20 THEN
        RAISE EXCEPTION 'INVITE_RATE_LIMIT' USING ERRCODE = 'P0001'.
    END IF.

    SELECT count(*) INTO v_member_count FROM public.team_members WHERE team_id = p_team_id;
    IF v_member_count >= (SELECT max_members FROM public.teams WHERE id = p_team_id) THEN
        RAISE EXCEPTION 'TEAM_FULL' USING ERRCODE = 'P0001'.
    END IF.

    IF p_invited_user_id IS NOT NULL AND EXISTS (
        SELECT 1 FROM public.team_members WHERE team_id = p_team_id AND user_id = p_invited_user_id
    ) THEN
        RAISE EXCEPTION 'ALREADY_TEAM_MEMBER' USING ERRCODE = '23505'.
    END IF.

    v_token := encode(gen_random_bytes(32), 'hex');
    v_hash := encode(digest(v_token, 'sha256'), 'hex');

    INSERT INTO public.team_invitations (
        team_id, invited_by, invited_user_id, email, token_hash, expires_at
    ) VALUES (
        p_team_id, v_uid, p_invited_user_id, NULLIF(lower(trim(p_email)), ''),
        v_hash, NOW() + make_interval(hours => p_expires_hours)
    ).

    INSERT INTO public.team_member_events (team_id, actor_id, event_type, subject_user_id, metadata)
    VALUES (p_team_id, v_uid, 'invitation_created', p_invited_user_id,
        jsonb_build_object('email', p_email, 'expires_hours', p_expires_hours)).

    PERFORM public.log_audit(v_uid, 'team.invitation_created', 'team', p_team_id, NULL,
        jsonb_build_object('invited_user_id', p_invited_user_id, 'email', p_email)).

    -- The raw token is returned exactly once. Only its hash is persisted.
    RETURN v_token.
END;
$$;

CREATE OR REPLACE FUNCTION public.accept_team_invitation(p_token TEXT)
RETURNS UUID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, extensions, pg_temp
AS $$
DECLARE
    v_uid UUID := auth.uid();
    v_hash TEXT;
    v_inv public.team_invitations%ROWTYPE;
    v_team public.teams%ROWTYPE;
    v_member_count INTEGER;
BEGIN
    IF v_uid IS NULL THEN
        RAISE EXCEPTION 'AUTH_REQUIRED' USING ERRCODE = '42501'.
    END IF.
    IF p_token IS NULL OR length(p_token) < 32 THEN
        RAISE EXCEPTION 'INVALID_INVITATION' USING ERRCODE = '22023'.
    END IF.

    v_hash := encode(digest(p_token, 'sha256'), 'hex');

    SELECT * INTO v_inv FROM public.team_invitations
    WHERE token_hash = v_hash
    FOR UPDATE.

    IF NOT FOUND OR v_inv.status <> 'pending' THEN
        RAISE EXCEPTION 'INVALID_INVITATION' USING ERRCODE = 'P0002'.
    END IF.
    IF v_inv.expires_at <= NOW() THEN
        UPDATE public.team_invitations SET status = 'expired' WHERE id = v_inv.id.
        RAISE EXCEPTION 'INVITATION_EXPIRED' USING ERRCODE = 'P0001'.
    END IF.
    IF v_inv.invited_user_id IS NOT NULL AND v_inv.invited_user_id <> v_uid THEN
        RAISE EXCEPTION 'INVITATION_FOR_ANOTHER_USER' USING ERRCODE = '42501'.
    END IF.
    IF v_inv.invited_user_id IS NULL AND v_inv.email IS NOT NULL AND NOT EXISTS (
        SELECT 1 FROM auth.users u
        WHERE u.id = v_uid AND lower(u.email) = v_inv.email
    ) THEN
        RAISE EXCEPTION 'INVITATION_FOR_ANOTHER_USER' USING ERRCODE = '42501'.
    END IF.

    SELECT * INTO v_team FROM public.teams WHERE id = v_inv.team_id AND deleted_at IS NULL.
    IF NOT FOUND THEN
        RAISE EXCEPTION 'TEAM_NOT_FOUND' USING ERRCODE = 'P0002'.
    END IF.

    SELECT count(*) INTO v_member_count FROM public.team_members WHERE team_id = v_inv.team_id.
    IF v_member_count >= v_team.max_members THEN
        RAISE EXCEPTION 'TEAM_FULL' USING ERRCODE = 'P0001'.
    END IF.

    INSERT INTO public.team_members (team_id, user_id, role)
    VALUES (v_inv.team_id, v_uid, 'member')
    ON CONFLICT (team_id, user_id) DO NOTHING.

    UPDATE public.team_invitations SET
        status = 'accepted', accepted_by = v_uid, responded_at = NOW()
    WHERE id = v_inv.id.

    INSERT INTO public.team_member_events (team_id, actor_id, event_type, subject_user_id)
    VALUES (v_inv.team_id, v_uid, 'invitation_accepted', v_uid).

    PERFORM public.log_audit(v_uid, 'team.invitation_accepted', 'team', v_inv.team_id, NULL,
        jsonb_build_object('invitation_id', v_inv.id)).

    RETURN v_inv.team_id.
END;
$$;

CREATE OR REPLACE FUNCTION public.decline_team_invitation(p_token TEXT)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, extensions, pg_temp
AS $$
DECLARE
    v_uid UUID := auth.uid();
    v_inv public.team_invitations%ROWTYPE;
BEGIN
    IF v_uid IS NULL THEN
        RAISE EXCEPTION 'AUTH_REQUIRED' USING ERRCODE = '42501'.
    END IF.

    SELECT * INTO v_inv FROM public.team_invitations
    WHERE token_hash = encode(digest(p_token, 'sha256'), 'hex')
    FOR UPDATE.

    IF NOT FOUND OR v_inv.status <> 'pending' THEN
        RAISE EXCEPTION 'INVALID_INVITATION' USING ERRCODE = 'P0002'.
    END IF.
    IF v_inv.invited_user_id IS NOT NULL AND v_inv.invited_user_id <> v_uid THEN
        RAISE EXCEPTION 'INVITATION_FOR_ANOTHER_USER' USING ERRCODE = '42501'.
    END IF.

    UPDATE public.team_invitations SET
        status = 'declined', responded_at = NOW(), accepted_by = v_uid
    WHERE id = v_inv.id.

    INSERT INTO public.team_member_events (team_id, actor_id, event_type, subject_user_id)
    VALUES (v_inv.team_id, v_uid, 'invitation_declined', v_uid).
END;
$$;

CREATE OR REPLACE FUNCTION public.revoke_team_invitation(p_invitation_id UUID)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
DECLARE
    v_uid UUID := auth.uid();
    v_inv public.team_invitations%ROWTYPE;
BEGIN
    SELECT * INTO v_inv FROM public.team_invitations WHERE id = p_invitation_id FOR UPDATE.
    IF NOT FOUND THEN
        RAISE EXCEPTION 'INVITATION_NOT_FOUND' USING ERRCODE = 'P0002'.
    END IF.
    IF NOT public.is_team_captain(v_inv.team_id, v_uid) THEN
        RAISE EXCEPTION 'ONLY_CAPTAIN_CAN_REVOKE' USING ERRCODE = '42501'.
    END IF.

    UPDATE public.team_invitations SET status = 'revoked', responded_at = NOW()
    WHERE id = p_invitation_id AND status = 'pending'.

    INSERT INTO public.team_member_events (team_id, actor_id, event_type, subject_user_id)
    VALUES (v_inv.team_id, v_uid, 'invitation_revoked', v_inv.invited_user_id).
END;
$$;

CREATE OR REPLACE FUNCTION public.remove_team_member(p_team_id UUID, p_user_id UUID)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
DECLARE
    v_uid UUID := auth.uid();
BEGIN
    IF NOT public.is_team_captain(p_team_id, v_uid) THEN
        RAISE EXCEPTION 'ONLY_CAPTAIN_CAN_REMOVE' USING ERRCODE = '42501'.
    END IF.
    IF p_user_id = v_uid THEN
        RAISE EXCEPTION 'USE_LEAVE_TEAM' USING ERRCODE = 'P0001'.
    END IF.

    DELETE FROM public.team_members WHERE team_id = p_team_id AND user_id = p_user_id.
    IF NOT FOUND THEN
        RAISE EXCEPTION 'MEMBER_NOT_FOUND' USING ERRCODE = 'P0002'.
    END IF.

    INSERT INTO public.team_member_events (team_id, actor_id, event_type, subject_user_id)
    VALUES (p_team_id, v_uid, 'member_removed', p_user_id).

    PERFORM public.log_audit(v_uid, 'team.member_removed', 'team', p_team_id, NULL,
        jsonb_build_object('user_id', p_user_id)).
END;
$$;

CREATE OR REPLACE FUNCTION public.transfer_team_captaincy(p_team_id UUID, p_new_captain UUID)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
DECLARE
    v_uid UUID := auth.uid();
BEGIN
    IF NOT public.is_team_captain(p_team_id, v_uid) THEN
        RAISE EXCEPTION 'ONLY_CAPTAIN_CAN_TRANSFER' USING ERRCODE = '42501'.
    END IF.
    IF p_new_captain = v_uid THEN
        RETURN.
    END IF.
    IF NOT EXISTS (SELECT 1 FROM public.team_members WHERE team_id = p_team_id AND user_id = p_new_captain) THEN
        RAISE EXCEPTION 'NEW_CAPTAIN_MUST_BE_MEMBER' USING ERRCODE = 'P0001'.
    END IF.

    UPDATE public.teams SET owner_id = p_new_captain, captain_id = p_new_captain
    WHERE id = p_team_id.

    UPDATE public.team_members SET role = 'member'
    WHERE team_id = p_team_id AND user_id = v_uid.
    UPDATE public.team_members SET role = 'owner'
    WHERE team_id = p_team_id AND user_id = p_new_captain.

    INSERT INTO public.team_member_events (team_id, actor_id, event_type, subject_user_id)
    VALUES (p_team_id, v_uid, 'captain_transferred', p_new_captain).

    PERFORM public.log_audit(v_uid, 'team.captain_transferred', 'team', p_team_id,
        jsonb_build_object('captain_id', v_uid), jsonb_build_object('captain_id', p_new_captain)).
END;
$$;

CREATE OR REPLACE FUNCTION public.leave_team(p_team_id UUID)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
DECLARE
    v_uid UUID := auth.uid();
    v_other_members INTEGER;
BEGIN
    IF NOT EXISTS (SELECT 1 FROM public.team_members WHERE team_id = p_team_id AND user_id = v_uid) THEN
        RAISE EXCEPTION 'NOT_TEAM_MEMBER' USING ERRCODE = 'P0002'.
    END IF.

    SELECT count(*) INTO v_other_members FROM public.team_members
    WHERE team_id = p_team_id AND user_id <> v_uid.

    IF public.is_team_captain(p_team_id, v_uid) AND v_other_members > 0 THEN
        RAISE EXCEPTION 'TRANSFER_CAPTAINCY_REQUIRED' USING ERRCODE = 'P0001'.
    END IF.

    DELETE FROM public.team_members WHERE team_id = p_team_id AND user_id = v_uid.

    IF v_other_members = 0 THEN
        UPDATE public.teams SET deleted_at = NOW() WHERE id = p_team_id.
        INSERT INTO public.team_member_events (team_id, actor_id, event_type, subject_user_id)
        VALUES (p_team_id, v_uid, 'team_dissolved', v_uid).
    ELSE
        INSERT INTO public.team_member_events (team_id, actor_id, event_type, subject_user_id)
        VALUES (p_team_id, v_uid, 'member_left', v_uid).
    END IF.
END;
$$;

CREATE OR REPLACE FUNCTION public.dissolve_team(p_team_id UUID)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
DECLARE
    v_uid UUID := auth.uid();
BEGIN
    IF NOT public.is_team_captain(p_team_id, v_uid) THEN
        RAISE EXCEPTION 'ONLY_CAPTAIN_CAN_DISSOLVE' USING ERRCODE = '42501'.
    END IF.

    IF EXISTS (
        SELECT 1 FROM public.tournament_registrations r
        JOIN public.tournaments t ON t.id = r.tournament_id
        WHERE r.team_id = p_team_id
          AND r.status IN ('pending', 'confirmed', 'waitlisted')
          AND t.status IN ('published', 'registration_open', 'registration_closed', 'in_progress')
    ) THEN
        RAISE EXCEPTION 'TEAM_HAS_ACTIVE_REGISTRATION' USING ERRCODE = 'P0001'.
    END IF.

    UPDATE public.teams SET deleted_at = NOW() WHERE id = p_team_id.
    DELETE FROM public.team_members WHERE team_id = p_team_id.

    INSERT INTO public.team_member_events (team_id, actor_id, event_type, subject_user_id)
    VALUES (p_team_id, v_uid, 'team_dissolved', v_uid).

    PERFORM public.log_audit(v_uid, 'team.dissolved', 'team', p_team_id).
END;
$$;

-- ============================================================================
-- 8. Public listing view (aggregate only, no PII) - THIS IS THE MISSING VIEW
-- ============================================================================
DROP VIEW IF EXISTS public.tournament_public_listing;
CREATE VIEW public.tournament_public_listing
WITH (security_invoker = false)
AS
SELECT
    t.id,
    t.title,
    t.description,
    t.format,
    t.mode,
    t.map,
    t.max_teams,
    t.team_size,
    t.registration_starts_at,
    t.registration_ends_at,
    t.tournament_starts_at,
    t.tournament_ends_at,
    t.prize_pool,
    t.rules_url,
    t.rules_text,
    t.contact_info,
    t.status,
    t.visibility,
    t.eligibility,
    t.waitlist_enabled,
    t.withdrawal_deadline,
    t.published_at,
    t.created_at,
    t.updated_at,
    p.display_name AS organizer_name,
    (SELECT count(*) FROM public.tournament_registrations r
      WHERE r.tournament_id = t.id AND r.status = 'confirmed') AS confirmed_entries,
    (SELECT count(*) FROM public.tournament_registrations r
      WHERE r.tournament_id = t.id AND r.status = 'waitlisted') AS waitlisted_entries
FROM public.tournaments t
JOIN public.profiles p ON p.id = t.organizer_id
WHERE t.deleted_at IS NULL
  AND t.visibility = 'public'
  AND t.status <> 'draft';

GRANT SELECT ON public.tournament_public_listing TO anon, authenticated;

-- ============================================================================
-- 9. Grants: functions are the only write path
-- ============================================================================
REVOKE ALL ON FUNCTION public.create_tournament(JSONB) FROM PUBLIC;
REVOKE ALL ON FUNCTION public.update_tournament(UUID, JSONB) FROM PUBLIC;
REVOKE ALL ON FUNCTION public.set_tournament_status(UUID, TEXT, TEXT) FROM PUBLIC;
REVOKE ALL ON FUNCTION public.register_tournament_entry(UUID, UUID) FROM PUBLIC;
REVOKE ALL ON FUNCTION public.withdraw_tournament_entry(UUID) FROM PUBLIC;
REVOKE ALL ON FUNCTION public.promote_next_waitlisted(UUID) FROM PUBLIC;
REVOKE ALL ON FUNCTION public.organizer_promote_waitlist(UUID) FROM PUBLIC;
REVOKE ALL ON FUNCTION public.create_team(TEXT, TEXT, TEXT) FROM PUBLIC;
REVOKE ALL ON FUNCTION public.invite_to_team(UUID, UUID, TEXT, INTEGER) FROM PUBLIC;
REVOKE ALL ON FUNCTION public.accept_team_invitation(TEXT) FROM PUBLIC;
REVOKE ALL ON FUNCTION public.decline_team_invitation(TEXT) FROM PUBLIC;
REVOKE ALL ON FUNCTION public.revoke_team_invitation(UUID) FROM PUBLIC;
REVOKE ALL ON FUNCTION public.remove_team_member(UUID, UUID) FROM PUBLIC;
REVOKE ALL ON FUNCTION public.transfer_team_captaincy(UUID, UUID) FROM PUBLIC;
REVOKE ALL ON FUNCTION public.leave_team(UUID) FROM PUBLIC;
REVOKE ALL ON FUNCTION public.dissolve_team(UUID) FROM PUBLIC;
REVOKE ALL ON FUNCTION public.create_notification(UUID, TEXT, TEXT, TEXT, JSONB) FROM PUBLIC;
REVOKE ALL ON FUNCTION public.log_audit(UUID, TEXT, TEXT, UUID, JSONB, JSONB) FROM PUBLIC;

GRANT EXECUTE ON FUNCTION public.create_tournament(JSONB) TO authenticated;
GRANT EXECUTE ON FUNCTION public.update_tournament(UUID, JSONB) TO authenticated;
GRANT EXECUTE ON FUNCTION public.set_tournament_status(UUID, TEXT, TEXT) TO authenticated;
GRANT EXECUTE ON FUNCTION public.register_tournament_entry(UUID, UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION public.withdraw_tournament_entry(UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION public.organizer_promote_waitlist(UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION public.create_team(TEXT, TEXT, TEXT) TO authenticated;
GRANT EXECUTE ON FUNCTION public.invite_to_team(UUID, UUID, TEXT, INTEGER) TO authenticated;
GRANT EXECUTE ON FUNCTION public.accept_team_invitation(TEXT) TO authenticated;
GRANT EXECUTE ON FUNCTION public.decline_team_invitation(TEXT) TO authenticated;
GRANT EXECUTE ON FUNCTION public.revoke_team_invitation(UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION public.remove_team_member(UUID, UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION public.transfer_team_captaincy(UUID, UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION public.leave_team(UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION public.dissolve_team(UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION public.create_notification(UUID, TEXT, TEXT, TEXT, JSONB) TO authenticated;
GRANT EXECUTE ON FUNCTION public.log_audit(UUID, TEXT, TEXT, UUID, JSONB, JSONB) TO authenticated;