-- Migration: 20261108000016_phase5_admin_abuse
--
-- Phase 5 — Platform administration, organizer approval, account suspension,
-- platform settings/feature flags, abuse reporting and moderator assignment.
--
-- Additive only. Security model:
--   * Platform administrators live in their own table. There is no
--     self-assignable role column on profiles.
--   * Every privileged mutation is a SECURITY DEFINER RPC that re-checks the
--     caller's administrator role server-side. The browser never supplies a
--     role.
--   * Direct table writes for clients are revoked; reads are narrowed by RLS.
--   * Sensitive administrator actions are written to audit_logs.

-- ============================================
-- 1. Platform administrators
-- ============================================
CREATE TABLE IF NOT EXISTS public.platform_admins (
    user_id UUID PRIMARY KEY REFERENCES public.profiles(id) ON DELETE CASCADE,
    role TEXT NOT NULL DEFAULT 'support',
    granted_by UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
    granted_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    revoked_at TIMESTAMPTZ,
    notes TEXT,
    CONSTRAINT platform_admins_role_check CHECK (role IN ('super_admin', 'admin', 'support'))
);

CREATE INDEX IF NOT EXISTS idx_platform_admins_active
    ON public.platform_admins (user_id)
    WHERE revoked_at IS NULL;

ALTER TABLE public.platform_admins ENABLE ROW LEVEL SECURITY;

REVOKE INSERT, UPDATE, DELETE ON public.platform_admins FROM anon, authenticated;
GRANT SELECT ON public.platform_admins TO authenticated;

CREATE OR REPLACE FUNCTION public.platform_admin_role(p_user_id UUID DEFAULT auth.uid())
RETURNS TEXT
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
    SELECT pa.role
    FROM public.platform_admins pa
    WHERE pa.user_id = p_user_id AND pa.revoked_at IS NULL
    LIMIT 1;
$$;

CREATE OR REPLACE FUNCTION public.is_platform_admin(p_user_id UUID DEFAULT auth.uid())
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
    SELECT public.platform_admin_role(p_user_id) IS NOT NULL;
$$;

CREATE OR REPLACE FUNCTION public.require_platform_admin(p_min_role TEXT DEFAULT 'support')
RETURNS UUID
LANGUAGE plpgsql
STABLE
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
DECLARE
    v_uid UUID := auth.uid();
    v_role TEXT;
    v_rank INTEGER;
    v_min_rank INTEGER;
BEGIN
    IF v_uid IS NULL THEN
        RAISE EXCEPTION 'AUTH_REQUIRED' USING ERRCODE = '42501';
    END IF;

    v_role := public.platform_admin_role(v_uid);
    IF v_role IS NULL THEN
        RAISE EXCEPTION 'NOT_PLATFORM_ADMIN' USING ERRCODE = '42501';
    END IF;

    v_rank := CASE v_role WHEN 'super_admin' THEN 3 WHEN 'admin' THEN 2 ELSE 1 END;
    v_min_rank := CASE p_min_role WHEN 'super_admin' THEN 3 WHEN 'admin' THEN 2 ELSE 1 END;

    IF v_rank < v_min_rank THEN
        RAISE EXCEPTION 'INSUFFICIENT_ADMIN_ROLE' USING ERRCODE = '42501';
    END IF;

    RETURN v_uid;
END;
$$;

REVOKE ALL ON FUNCTION public.platform_admin_role(UUID) FROM PUBLIC, anon;
REVOKE ALL ON FUNCTION public.is_platform_admin(UUID) FROM PUBLIC, anon;
REVOKE ALL ON FUNCTION public.require_platform_admin(TEXT) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.platform_admin_role(UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION public.is_platform_admin(UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION public.require_platform_admin(TEXT) TO authenticated;

DROP POLICY IF EXISTS "Admins read platform admins" ON public.platform_admins;
CREATE POLICY "Admins read platform admins"
    ON public.platform_admins FOR SELECT
    USING (public.is_platform_admin(auth.uid()));

-- ============================================
-- 2. Account status (suspension)
-- ============================================
-- Suspension state is deliberately kept out of profiles: public profile rows
-- are readable by other users, and suspension reasons are private moderation
-- data. Columns would also be updatable through the broad "own profile"
-- policy. A dedicated table with its own RLS avoids both problems.
CREATE TABLE IF NOT EXISTS public.account_suspensions (
    user_id UUID PRIMARY KEY REFERENCES public.profiles(id) ON DELETE CASCADE,
    status TEXT NOT NULL DEFAULT 'active',
    suspended_at TIMESTAMPTZ,
    suspended_by UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
    reason TEXT,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT account_suspensions_status_check CHECK (status IN ('active', 'suspended', 'banned'))
);

ALTER TABLE public.account_suspensions ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users read own account status" ON public.account_suspensions;
CREATE POLICY "Users read own account status"
    ON public.account_suspensions FOR SELECT
    USING (auth.uid() = user_id OR public.is_platform_admin(auth.uid()));

REVOKE INSERT, UPDATE, DELETE ON public.account_suspensions FROM anon, authenticated;
GRANT SELECT ON public.account_suspensions TO authenticated;

CREATE OR REPLACE FUNCTION public.account_status(p_user_id UUID DEFAULT auth.uid())
RETURNS TEXT
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
    SELECT COALESCE((
        SELECT s.status FROM public.account_suspensions s WHERE s.user_id = p_user_id
    ), 'active');
$$;

CREATE OR REPLACE FUNCTION public.is_account_active(p_user_id UUID DEFAULT auth.uid())
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
    SELECT EXISTS (
        SELECT 1 FROM public.profiles p
        WHERE p.id = p_user_id
          AND p.deleted_at IS NULL
          AND public.account_status(p_user_id) = 'active'
    );
$$;

REVOKE ALL ON FUNCTION public.account_status(UUID) FROM PUBLIC, anon;
REVOKE ALL ON FUNCTION public.is_account_active(UUID) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.account_status(UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION public.is_account_active(UUID) TO authenticated;

-- ============================================
-- 3. Audit log policy repair
-- ============================================
DROP POLICY IF EXISTS "Admins can read all audit logs" ON public.audit_logs;

DROP POLICY IF EXISTS "Platform admins read audit logs" ON public.audit_logs;
CREATE POLICY "Platform admins read audit logs"
    ON public.audit_logs FOR SELECT
    USING (public.is_platform_admin(auth.uid()));

REVOKE INSERT, UPDATE, DELETE ON public.audit_logs FROM anon, authenticated;
GRANT SELECT ON public.audit_logs TO authenticated;

-- ============================================
-- 4. Platform settings and feature flags
-- ============================================
CREATE TABLE IF NOT EXISTS public.platform_settings (
    key TEXT PRIMARY KEY,
    value JSONB NOT NULL DEFAULT '{}'::jsonb,
    description TEXT,
    is_public BOOLEAN NOT NULL DEFAULT FALSE,
    updated_by UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT platform_settings_key_check CHECK (key ~ '^[a-z0-9_.]{2,80}$')
);

ALTER TABLE public.platform_settings ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Public settings are readable" ON public.platform_settings;
CREATE POLICY "Public settings are readable"
    ON public.platform_settings FOR SELECT
    USING (is_public = TRUE OR public.is_platform_admin(auth.uid()));

REVOKE INSERT, UPDATE, DELETE ON public.platform_settings FROM anon, authenticated;
GRANT SELECT ON public.platform_settings TO authenticated;

INSERT INTO public.platform_settings (key, value, description, is_public)
VALUES
    ('organizer_approval_required', 'false'::jsonb, 'Require an approved organizer account before creating tournaments.', TRUE),
    ('abuse_reporting_enabled', 'true'::jsonb, 'Allow players and organizers to submit abuse reports.', TRUE),
    ('push_notifications_enabled', 'false'::jsonb, 'Queue FCM push delivery. Disabled until credentials are configured.', TRUE),
    ('maintenance_mode', 'false'::jsonb, 'Show the platform maintenance notice.', TRUE)
ON CONFLICT (key) DO NOTHING;

CREATE OR REPLACE FUNCTION public.platform_setting_bool(p_key TEXT, p_default BOOLEAN DEFAULT FALSE)
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
    SELECT COALESCE((
        SELECT CASE
            WHEN jsonb_typeof(ps.value) = 'boolean' THEN (ps.value)::BOOLEAN
            WHEN ps.value #>> '{}' IN ('true', 'false') THEN (ps.value #>> '{}')::BOOLEAN
            ELSE p_default
        END
        FROM public.platform_settings ps
        WHERE ps.key = p_key
    ), p_default);
$$;

REVOKE ALL ON FUNCTION public.platform_setting_bool(TEXT, BOOLEAN) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.platform_setting_bool(TEXT, BOOLEAN) TO authenticated;

CREATE OR REPLACE FUNCTION public.admin_set_platform_setting(
    p_key TEXT,
    p_value JSONB,
    p_is_public BOOLEAN DEFAULT FALSE,
    p_description TEXT DEFAULT NULL
)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
DECLARE
    v_uid UUID := public.require_platform_admin('admin');
    v_old JSONB;
BEGIN
    IF p_key IS NULL OR p_key !~ '^[a-z0-9_.]{2,80}$' THEN
        RAISE EXCEPTION 'INVALID_SETTING_KEY' USING ERRCODE = '22023';
    END IF;
    IF p_value IS NULL THEN
        RAISE EXCEPTION 'INVALID_SETTING_VALUE' USING ERRCODE = '22023';
    END IF;

    SELECT value INTO v_old FROM public.platform_settings WHERE key = p_key;

    INSERT INTO public.platform_settings (key, value, description, is_public, updated_by)
    VALUES (p_key, p_value, p_description, COALESCE(p_is_public, FALSE), v_uid)
    ON CONFLICT (key) DO UPDATE
    SET value = EXCLUDED.value,
        description = COALESCE(EXCLUDED.description, public.platform_settings.description),
        is_public = EXCLUDED.is_public,
        updated_by = v_uid,
        updated_at = NOW();

    PERFORM public.log_audit(
        v_uid, 'platform.setting_updated', 'platform_setting', NULL,
        jsonb_build_object('key', p_key, 'value', v_old),
        jsonb_build_object('key', p_key, 'value', p_value, 'is_public', COALESCE(p_is_public, FALSE))
    );
END;
$$;

REVOKE ALL ON FUNCTION public.admin_set_platform_setting(TEXT, JSONB, BOOLEAN, TEXT) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.admin_set_platform_setting(TEXT, JSONB, BOOLEAN, TEXT) TO authenticated;

-- ============================================
-- 5. Organizer accounts and approval
-- ============================================
CREATE TABLE IF NOT EXISTS public.organizer_accounts (
    user_id UUID PRIMARY KEY REFERENCES public.profiles(id) ON DELETE CASCADE,
    status TEXT NOT NULL DEFAULT 'pending',
    organization_name TEXT,
    contact_note TEXT,
    approved_by UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
    approved_at TIMESTAMPTZ,
    suspended_at TIMESTAMPTZ,
    suspension_reason TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT organizer_accounts_status_check CHECK (status IN ('pending', 'approved', 'suspended'))
);

CREATE INDEX IF NOT EXISTS idx_organizer_accounts_status
    ON public.organizer_accounts (status);

ALTER TABLE public.organizer_accounts ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users read own organizer account" ON public.organizer_accounts;
CREATE POLICY "Users read own organizer account"
    ON public.organizer_accounts FOR SELECT
    USING (auth.uid() = user_id OR public.is_platform_admin(auth.uid()));

REVOKE INSERT, UPDATE, DELETE ON public.organizer_accounts FROM anon, authenticated;
GRANT SELECT ON public.organizer_accounts TO authenticated;

-- Backfill: anyone who already owns a tournament is treated as approved so
-- enabling the feature flag later cannot lock out existing organizers.
INSERT INTO public.organizer_accounts (user_id, status, approved_at, contact_note)
SELECT DISTINCT t.organizer_id, 'approved', NOW(), 'Backfilled from existing tournaments'
FROM public.tournaments t
ON CONFLICT (user_id) DO NOTHING;

CREATE OR REPLACE FUNCTION public.organizer_is_approved(p_user_id UUID)
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
    SELECT EXISTS (
        SELECT 1 FROM public.organizer_accounts oa
        WHERE oa.user_id = p_user_id AND oa.status = 'approved'
    );
$$;

REVOKE ALL ON FUNCTION public.organizer_is_approved(UUID) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.organizer_is_approved(UUID) TO authenticated;

CREATE OR REPLACE FUNCTION public.enforce_organizer_approval()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
BEGIN
    IF public.platform_setting_bool('organizer_approval_required', FALSE)
       AND NOT public.is_platform_admin(NEW.organizer_id)
       AND NOT public.organizer_is_approved(NEW.organizer_id) THEN
        RAISE EXCEPTION 'ORGANIZER_NOT_APPROVED' USING ERRCODE = '42501';
    END IF;
    RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_enforce_organizer_approval ON public.tournaments;
CREATE TRIGGER trg_enforce_organizer_approval
    BEFORE INSERT ON public.tournaments
    FOR EACH ROW EXECUTE FUNCTION public.enforce_organizer_approval();

CREATE OR REPLACE FUNCTION public.request_organizer_account(
    p_organization_name TEXT DEFAULT NULL,
    p_contact_note TEXT DEFAULT NULL
)
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
    IF NOT public.is_account_active(v_uid) THEN
        RAISE EXCEPTION 'ACCOUNT_INACTIVE' USING ERRCODE = '42501';
    END IF;

    INSERT INTO public.organizer_accounts (user_id, status, organization_name, contact_note)
    VALUES (v_uid, 'pending', NULLIF(trim(p_organization_name), ''), NULLIF(trim(p_contact_note), ''))
    ON CONFLICT (user_id) DO UPDATE
    SET organization_name = COALESCE(EXCLUDED.organization_name, public.organizer_accounts.organization_name),
        contact_note = COALESCE(EXCLUDED.contact_note, public.organizer_accounts.contact_note),
        status = CASE
            WHEN public.organizer_accounts.status = 'approved' THEN 'approved'
            ELSE 'pending'
        END,
        updated_at = NOW();

    RETURN v_uid;
END;
$$;

REVOKE ALL ON FUNCTION public.request_organizer_account(TEXT, TEXT) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.request_organizer_account(TEXT, TEXT) TO authenticated;

-- ============================================
-- 6. Abuse reports and moderation history
-- ============================================
CREATE TABLE IF NOT EXISTS public.abuse_reports (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    reporter_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    category TEXT NOT NULL,
    subject_type TEXT NOT NULL,
    subject_id UUID,
    tournament_id UUID REFERENCES public.tournaments(id) ON DELETE SET NULL,
    description TEXT NOT NULL,
    evidence_paths TEXT[] NOT NULL DEFAULT '{}',
    status TEXT NOT NULL DEFAULT 'submitted',
    severity TEXT NOT NULL DEFAULT 'medium',
    assigned_admin_id UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
    resolution TEXT,
    resolved_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT abuse_reports_category_check CHECK (category IN (
        'harassment', 'cheating', 'match_fixing', 'inappropriate_content',
        'impersonation', 'spam', 'other'
    )),
    CONSTRAINT abuse_reports_subject_type_check CHECK (subject_type IN (
        'user', 'tournament', 'team', 'match', 'result', 'dispute', 'other'
    )),
    CONSTRAINT abuse_reports_status_check CHECK (status IN (
        'submitted', 'triaged', 'investigating', 'resolved', 'dismissed'
    )),
    CONSTRAINT abuse_reports_severity_check CHECK (severity IN (
        'low', 'medium', 'high', 'critical'
    )),
    CONSTRAINT abuse_reports_description_check CHECK (
        char_length(trim(description)) BETWEEN 10 AND 4000
    ),
    CONSTRAINT abuse_reports_evidence_check CHECK (array_length(evidence_paths, 1) IS NULL OR array_length(evidence_paths, 1) <= 10)
);

CREATE INDEX IF NOT EXISTS idx_abuse_reports_reporter
    ON public.abuse_reports (reporter_id, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_abuse_reports_status
    ON public.abuse_reports (status, severity, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_abuse_reports_tournament
    ON public.abuse_reports (tournament_id, created_at DESC);

ALTER TABLE public.abuse_reports ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Reporters read own abuse reports" ON public.abuse_reports;
CREATE POLICY "Reporters read own abuse reports"
    ON public.abuse_reports FOR SELECT
    USING (reporter_id = auth.uid() OR public.is_platform_admin(auth.uid()));

REVOKE INSERT, UPDATE, DELETE ON public.abuse_reports FROM anon, authenticated;
GRANT SELECT ON public.abuse_reports TO authenticated;

CREATE TABLE IF NOT EXISTS public.abuse_report_events (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    report_id UUID NOT NULL REFERENCES public.abuse_reports(id) ON DELETE CASCADE,
    actor_id UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
    event_type TEXT NOT NULL,
    from_status TEXT,
    to_status TEXT,
    note TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_abuse_report_events_report
    ON public.abuse_report_events (report_id, created_at);

ALTER TABLE public.abuse_report_events ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Reporters read own report history" ON public.abuse_report_events;
CREATE POLICY "Reporters read own report history"
    ON public.abuse_report_events FOR SELECT
    USING (
        public.is_platform_admin(auth.uid())
        OR EXISTS (
            SELECT 1 FROM public.abuse_reports r
            WHERE r.id = abuse_report_events.report_id
              AND r.reporter_id = auth.uid()
        )
    );

REVOKE INSERT, UPDATE, DELETE ON public.abuse_report_events FROM anon, authenticated;
GRANT SELECT ON public.abuse_report_events TO authenticated;

-- Append-only history.
CREATE OR REPLACE FUNCTION public.prevent_abuse_event_mutation()
RETURNS TRIGGER
LANGUAGE plpgsql
SET search_path = public, pg_temp
AS $$
BEGIN
    RAISE EXCEPTION 'ABUSE_REPORT_HISTORY_IMMUTABLE' USING ERRCODE = '42501';
END;
$$;

DROP TRIGGER IF EXISTS trg_prevent_abuse_event_mutation ON public.abuse_report_events;
CREATE TRIGGER trg_prevent_abuse_event_mutation
    BEFORE UPDATE OR DELETE ON public.abuse_report_events
    FOR EACH ROW EXECUTE FUNCTION public.prevent_abuse_event_mutation();

CREATE OR REPLACE FUNCTION public.notify_platform_admins(
    p_type TEXT,
    p_title TEXT,
    p_body TEXT,
    p_data JSONB DEFAULT '{}'::jsonb,
    p_category TEXT DEFAULT 'moderation',
    p_dedupe_prefix TEXT DEFAULT NULL
)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
DECLARE
    v_admin UUID;
BEGIN
    FOR v_admin IN
        SELECT pa.user_id FROM public.platform_admins pa WHERE pa.revoked_at IS NULL
    LOOP
        PERFORM public.create_notification(
            v_admin, p_type, p_title, p_body, p_data, p_category,
            CASE WHEN p_dedupe_prefix IS NULL THEN NULL
                 ELSE format('%s:%s', p_dedupe_prefix, v_admin) END
        );
    END LOOP;
END;
$$;

REVOKE ALL ON FUNCTION public.notify_platform_admins(TEXT, TEXT, TEXT, JSONB, TEXT, TEXT) FROM PUBLIC, anon, authenticated;

CREATE OR REPLACE FUNCTION public.submit_abuse_report(
    p_category TEXT,
    p_subject_type TEXT,
    p_description TEXT,
    p_subject_id UUID DEFAULT NULL,
    p_tournament_id UUID DEFAULT NULL,
    p_evidence_paths TEXT[] DEFAULT '{}'
)
RETURNS UUID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
DECLARE
    v_uid UUID := auth.uid();
    v_id UUID;
BEGIN
    IF v_uid IS NULL THEN
        RAISE EXCEPTION 'AUTH_REQUIRED' USING ERRCODE = '42501';
    END IF;
    IF NOT public.is_account_active(v_uid) THEN
        RAISE EXCEPTION 'ACCOUNT_INACTIVE' USING ERRCODE = '42501';
    END IF;
    IF NOT public.platform_setting_bool('abuse_reporting_enabled', TRUE) THEN
        RAISE EXCEPTION 'ABUSE_REPORTING_DISABLED' USING ERRCODE = '42501';
    END IF;
    IF p_category NOT IN (
        'harassment', 'cheating', 'match_fixing', 'inappropriate_content',
        'impersonation', 'spam', 'other'
    ) THEN
        RAISE EXCEPTION 'INVALID_REPORT_CATEGORY' USING ERRCODE = '22023';
    END IF;
    IF p_subject_type NOT IN ('user', 'tournament', 'team', 'match', 'result', 'dispute', 'other') THEN
        RAISE EXCEPTION 'INVALID_REPORT_SUBJECT' USING ERRCODE = '22023';
    END IF;
    IF p_description IS NULL OR char_length(trim(p_description)) < 10 OR char_length(trim(p_description)) > 4000 THEN
        RAISE EXCEPTION 'INVALID_REPORT_DESCRIPTION' USING ERRCODE = '22023';
    END IF;
    IF p_evidence_paths IS NOT NULL AND array_length(p_evidence_paths, 1) > 10 THEN
        RAISE EXCEPTION 'TOO_MANY_EVIDENCE_FILES' USING ERRCODE = '22023';
    END IF;

    INSERT INTO public.abuse_reports (
        reporter_id, category, subject_type, subject_id, tournament_id,
        description, evidence_paths
    ) VALUES (
        v_uid, p_category, p_subject_type, p_subject_id, p_tournament_id,
        trim(p_description), COALESCE(p_evidence_paths, '{}')
    ) RETURNING id INTO v_id;

    INSERT INTO public.abuse_report_events (report_id, actor_id, event_type, to_status, note)
    VALUES (v_id, v_uid, 'submitted', 'submitted', NULL);

    PERFORM public.log_audit(
        v_uid, 'abuse_report.submitted', 'abuse_report', v_id, NULL,
        jsonb_build_object('category', p_category, 'subject_type', p_subject_type,
                           'tournament_id', p_tournament_id)
    );

    PERFORM public.notify_platform_admins(
        'abuse_report_submitted',
        'New abuse report',
        format('A %s report was submitted and needs triage.', p_category),
        jsonb_build_object('report_id', v_id, 'tournament_id', p_tournament_id),
        'moderation',
        format('abuse_report_admin:%s', v_id)
    );

    PERFORM public.create_notification(
        v_uid,
        'abuse_report_received',
        'Report received',
        'Your report was received. Platform staff will review it.',
        jsonb_build_object('report_id', v_id),
        'moderation',
        format('abuse_report_received:%s:%s', v_id, v_uid)
    );

    RETURN v_id;
END;
$$;

REVOKE ALL ON FUNCTION public.submit_abuse_report(TEXT, TEXT, TEXT, UUID, UUID, TEXT[]) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.submit_abuse_report(TEXT, TEXT, TEXT, UUID, UUID, TEXT[]) TO authenticated;

CREATE OR REPLACE FUNCTION public.admin_triage_abuse_report(
    p_report_id UUID,
    p_status TEXT,
    p_severity TEXT DEFAULT NULL,
    p_assigned_admin_id UUID DEFAULT NULL,
    p_note TEXT DEFAULT NULL
)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
DECLARE
    v_uid UUID := public.require_platform_admin('support');
    v_old public.abuse_reports%ROWTYPE;
BEGIN
    SELECT * INTO v_old FROM public.abuse_reports WHERE id = p_report_id FOR UPDATE;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'REPORT_NOT_FOUND' USING ERRCODE = 'P0002';
    END IF;

    IF p_status NOT IN ('submitted', 'triaged', 'investigating', 'resolved', 'dismissed') THEN
        RAISE EXCEPTION 'INVALID_REPORT_STATUS' USING ERRCODE = '22023';
    END IF;
    IF p_severity IS NOT NULL AND p_severity NOT IN ('low', 'medium', 'high', 'critical') THEN
        RAISE EXCEPTION 'INVALID_REPORT_SEVERITY' USING ERRCODE = '22023';
    END IF;
    IF p_assigned_admin_id IS NOT NULL AND NOT public.is_platform_admin(p_assigned_admin_id) THEN
        RAISE EXCEPTION 'ASSIGNEE_NOT_ADMIN' USING ERRCODE = '22023';
    END IF;

    UPDATE public.abuse_reports
    SET status = p_status,
        severity = COALESCE(p_severity, severity),
        assigned_admin_id = COALESCE(p_assigned_admin_id, assigned_admin_id),
        resolved_at = CASE WHEN p_status IN ('resolved', 'dismissed') THEN COALESCE(resolved_at, NOW()) ELSE NULL END,
        updated_at = NOW()
    WHERE id = p_report_id;

    INSERT INTO public.abuse_report_events (report_id, actor_id, event_type, from_status, to_status, note)
    VALUES (p_report_id, v_uid, 'status_changed', v_old.status, p_status, NULLIF(trim(p_note), ''));

    PERFORM public.log_audit(
        v_uid, 'abuse_report.triaged', 'abuse_report', p_report_id,
        jsonb_build_object('status', v_old.status, 'severity', v_old.severity,
                           'assigned_admin_id', v_old.assigned_admin_id),
        jsonb_build_object('status', p_status, 'severity', COALESCE(p_severity, v_old.severity),
                           'assigned_admin_id', COALESCE(p_assigned_admin_id, v_old.assigned_admin_id))
    );

    IF p_status IN ('triaged', 'investigating') AND v_old.status IS DISTINCT FROM p_status THEN
        PERFORM public.create_notification(
            v_old.reporter_id,
            'abuse_report_updated',
            'Report update',
            format('Your report is now %s.', p_status),
            jsonb_build_object('report_id', p_report_id, 'status', p_status),
            'moderation',
            format('abuse_report_status:%s:%s', p_report_id, p_status)
        );
    END IF;
END;
$$;

REVOKE ALL ON FUNCTION public.admin_triage_abuse_report(UUID, TEXT, TEXT, UUID, TEXT) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.admin_triage_abuse_report(UUID, TEXT, TEXT, UUID, TEXT) TO authenticated;

CREATE OR REPLACE FUNCTION public.admin_resolve_abuse_report(
    p_report_id UUID,
    p_resolution TEXT,
    p_dismiss BOOLEAN DEFAULT FALSE
)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
DECLARE
    v_uid UUID := public.require_platform_admin('admin');
    v_old public.abuse_reports%ROWTYPE;
    v_status TEXT := CASE WHEN COALESCE(p_dismiss, FALSE) THEN 'dismissed' ELSE 'resolved' END;
BEGIN
    IF p_resolution IS NULL OR char_length(trim(p_resolution)) < 5 THEN
        RAISE EXCEPTION 'INVALID_RESOLUTION' USING ERRCODE = '22023';
    END IF;

    SELECT * INTO v_old FROM public.abuse_reports WHERE id = p_report_id FOR UPDATE;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'REPORT_NOT_FOUND' USING ERRCODE = 'P0002';
    END IF;

    UPDATE public.abuse_reports
    SET status = v_status,
        resolution = trim(p_resolution),
        resolved_at = NOW(),
        updated_at = NOW()
    WHERE id = p_report_id;

    INSERT INTO public.abuse_report_events (report_id, actor_id, event_type, from_status, to_status, note)
    VALUES (p_report_id, v_uid, 'resolved', v_old.status, v_status, trim(p_resolution));

    PERFORM public.log_audit(
        v_uid, 'abuse_report.resolved', 'abuse_report', p_report_id,
        jsonb_build_object('status', v_old.status),
        jsonb_build_object('status', v_status, 'resolution', trim(p_resolution))
    );

    PERFORM public.create_notification(
        v_old.reporter_id,
        'abuse_report_resolved',
        CASE WHEN COALESCE(p_dismiss, FALSE) THEN 'Report dismissed' ELSE 'Report resolved' END,
        trim(p_resolution),
        jsonb_build_object('report_id', p_report_id, 'status', v_status),
        'moderation',
        format('abuse_report_resolved:%s', p_report_id)
    );
END;
$$;

REVOKE ALL ON FUNCTION public.admin_resolve_abuse_report(UUID, TEXT, BOOLEAN) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.admin_resolve_abuse_report(UUID, TEXT, BOOLEAN) TO authenticated;

-- ============================================
-- 7. Administrator user / organizer management
-- ============================================
CREATE OR REPLACE FUNCTION public.admin_search_users(
    p_query TEXT DEFAULT NULL,
    p_limit INTEGER DEFAULT 25,
    p_offset INTEGER DEFAULT 0
)
RETURNS TABLE (
    user_id UUID,
    display_name TEXT,
    username TEXT,
    email TEXT,
    account_status TEXT,
    created_at TIMESTAMPTZ,
    is_platform_admin BOOLEAN,
    organizer_status TEXT
)
LANGUAGE plpgsql
STABLE
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
DECLARE
    v_uid UUID := public.require_platform_admin('support');
BEGIN
    RETURN QUERY
    SELECT p.id,
           p.display_name,
           p.username,
           COALESCE(p.email, au.email),
           public.account_status(p.id),
           p.created_at,
           public.is_platform_admin(p.id),
           oa.status
    FROM public.profiles p
    LEFT JOIN auth.users au ON au.id = p.id
    LEFT JOIN public.organizer_accounts oa ON oa.user_id = p.id
    WHERE p.deleted_at IS NULL
      AND (
          p_query IS NULL OR trim(p_query) = ''
          OR p.display_name ILIKE '%' || trim(p_query) || '%'
          OR COALESCE(p.username, '') ILIKE '%' || trim(p_query) || '%'
          OR COALESCE(p.email, au.email, '') ILIKE '%' || trim(p_query) || '%'
      )
    ORDER BY p.created_at DESC
    LIMIT GREATEST(COALESCE(p_limit, 25), 1)
    OFFSET GREATEST(COALESCE(p_offset, 0), 0);
END;
$$;

REVOKE ALL ON FUNCTION public.admin_search_users(TEXT, INTEGER, INTEGER) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.admin_search_users(TEXT, INTEGER, INTEGER) TO authenticated;

CREATE OR REPLACE FUNCTION public.admin_get_user(p_user_id UUID)
RETURNS JSONB
LANGUAGE plpgsql
STABLE
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
DECLARE
    v_uid UUID := public.require_platform_admin('support');
    v_profile public.profiles%ROWTYPE;
    v_email TEXT;
BEGIN
    SELECT * INTO v_profile FROM public.profiles WHERE id = p_user_id;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'USER_NOT_FOUND' USING ERRCODE = 'P0002';
    END IF;

    SELECT au.email INTO v_email FROM auth.users au WHERE au.id = p_user_id;

    RETURN jsonb_build_object(
        'profile', jsonb_build_object(
            'id', v_profile.id,
            'display_name', v_profile.display_name,
            'username', v_profile.username,
            'email', COALESCE(v_profile.email, v_email),
            'in_game_name', v_profile.in_game_name,
            'account_status', public.account_status(p_user_id),
            'created_at', v_profile.created_at
        ),
        'suspension', (SELECT to_jsonb(s) FROM public.account_suspensions s WHERE s.user_id = p_user_id),
        'platform_admin_role', public.platform_admin_role(p_user_id),
        'organizer', (SELECT to_jsonb(oa) FROM public.organizer_accounts oa WHERE oa.user_id = p_user_id),
        'counts', jsonb_build_object(
            'tournaments', (SELECT count(*) FROM public.tournaments t WHERE t.organizer_id = p_user_id AND t.deleted_at IS NULL),
            'registrations', (SELECT count(*) FROM public.tournament_registrations r WHERE r.user_id = p_user_id),
            'abuse_reports_filed', (SELECT count(*) FROM public.abuse_reports ar WHERE ar.reporter_id = p_user_id)
        )
    );
END;
$$;

REVOKE ALL ON FUNCTION public.admin_get_user(UUID) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.admin_get_user(UUID) TO authenticated;

CREATE OR REPLACE FUNCTION public.admin_suspend_user(p_user_id UUID, p_reason TEXT)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
DECLARE
    v_uid UUID := public.require_platform_admin('admin');
    v_target_role TEXT;
    v_old public.account_suspensions%ROWTYPE;
    v_exists BOOLEAN;
BEGIN
    IF p_user_id = v_uid THEN
        RAISE EXCEPTION 'CANNOT_SUSPEND_SELF' USING ERRCODE = '22023';
    END IF;
    IF p_reason IS NULL OR char_length(trim(p_reason)) < 3 THEN
        RAISE EXCEPTION 'SUSPENSION_REASON_REQUIRED' USING ERRCODE = '22023';
    END IF;

    v_target_role := public.platform_admin_role(p_user_id);
    IF v_target_role = 'super_admin' THEN
        RAISE EXCEPTION 'CANNOT_SUSPEND_SUPER_ADMIN' USING ERRCODE = '42501';
    END IF;
    IF v_target_role = 'admin' AND public.platform_admin_role(v_uid) <> 'super_admin' THEN
        RAISE EXCEPTION 'INSUFFICIENT_ADMIN_ROLE' USING ERRCODE = '42501';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM public.profiles WHERE id = p_user_id AND deleted_at IS NULL) THEN
        RAISE EXCEPTION 'USER_NOT_FOUND' USING ERRCODE = 'P0002';
    END IF;

    SELECT * INTO v_old FROM public.account_suspensions WHERE user_id = p_user_id FOR UPDATE;
    v_exists := FOUND;

    INSERT INTO public.account_suspensions (user_id, status, suspended_at, suspended_by, reason)
    VALUES (p_user_id, 'suspended', NOW(), v_uid, trim(p_reason))
    ON CONFLICT (user_id) DO UPDATE
    SET status = 'suspended',
        suspended_at = NOW(),
        suspended_by = v_uid,
        reason = trim(p_reason),
        updated_at = NOW();

    PERFORM public.log_audit(
        v_uid, 'user.suspended', 'profile', p_user_id,
        jsonb_build_object('account_status', CASE WHEN v_exists THEN v_old.status ELSE 'active' END),
        jsonb_build_object('account_status', 'suspended', 'reason', trim(p_reason))
    );

    PERFORM public.create_notification(
        p_user_id,
        'account_suspended',
        'Account suspended',
        format('Your account was suspended: %s', trim(p_reason)),
        jsonb_build_object('suspended_at', NOW()),
        'system',
        format('account_suspended:%s', p_user_id)
    );
END;
$$;

REVOKE ALL ON FUNCTION public.admin_suspend_user(UUID, TEXT) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.admin_suspend_user(UUID, TEXT) TO authenticated;

CREATE OR REPLACE FUNCTION public.admin_restore_user(p_user_id UUID, p_note TEXT DEFAULT NULL)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
DECLARE
    v_uid UUID := public.require_platform_admin('admin');
    v_old public.account_suspensions%ROWTYPE;
    v_exists BOOLEAN;
BEGIN
    IF NOT EXISTS (SELECT 1 FROM public.profiles WHERE id = p_user_id AND deleted_at IS NULL) THEN
        RAISE EXCEPTION 'USER_NOT_FOUND' USING ERRCODE = 'P0002';
    END IF;

    SELECT * INTO v_old FROM public.account_suspensions WHERE user_id = p_user_id FOR UPDATE;
    v_exists := FOUND;

    INSERT INTO public.account_suspensions (user_id, status, suspended_at, suspended_by, reason)
    VALUES (p_user_id, 'active', NULL, NULL, NULL)
    ON CONFLICT (user_id) DO UPDATE
    SET status = 'active',
        suspended_at = NULL,
        suspended_by = NULL,
        reason = NULL,
        updated_at = NOW();

    PERFORM public.log_audit(
        v_uid, 'user.restored', 'profile', p_user_id,
        jsonb_build_object('account_status', CASE WHEN v_exists THEN v_old.status ELSE 'active' END,
                           'reason', CASE WHEN v_exists THEN v_old.reason ELSE NULL END),
        jsonb_build_object('account_status', 'active', 'note', NULLIF(trim(p_note), ''))
    );

    PERFORM public.create_notification(
        p_user_id,
        'account_restored',
        'Account restored',
        'Your account has been restored.',
        '{}'::jsonb,
        'system',
        format('account_restored:%s:%s', p_user_id, extract(epoch FROM NOW())::BIGINT)
    );
END;
$$;

REVOKE ALL ON FUNCTION public.admin_restore_user(UUID, TEXT) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.admin_restore_user(UUID, TEXT) TO authenticated;

CREATE OR REPLACE FUNCTION public.admin_list_organizers(
    p_status TEXT DEFAULT NULL,
    p_limit INTEGER DEFAULT 50,
    p_offset INTEGER DEFAULT 0
)
RETURNS TABLE (
    user_id UUID,
    display_name TEXT,
    email TEXT,
    status TEXT,
    organization_name TEXT,
    contact_note TEXT,
    approved_at TIMESTAMPTZ,
    suspended_at TIMESTAMPTZ,
    suspension_reason TEXT,
    created_at TIMESTAMPTZ
)
LANGUAGE plpgsql
STABLE
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
DECLARE
    v_uid UUID := public.require_platform_admin('support');
BEGIN
    RETURN QUERY
    SELECT oa.user_id, p.display_name, p.email, oa.status, oa.organization_name,
           oa.contact_note, oa.approved_at, oa.suspended_at, oa.suspension_reason, oa.created_at
    FROM public.organizer_accounts oa
    JOIN public.profiles p ON p.id = oa.user_id
    WHERE p_status IS NULL OR oa.status = p_status
    ORDER BY oa.created_at DESC
    LIMIT GREATEST(COALESCE(p_limit, 50), 1)
    OFFSET GREATEST(COALESCE(p_offset, 0), 0);
END;
$$;

REVOKE ALL ON FUNCTION public.admin_list_organizers(TEXT, INTEGER, INTEGER) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.admin_list_organizers(TEXT, INTEGER, INTEGER) TO authenticated;

CREATE OR REPLACE FUNCTION public.admin_set_organizer_status(
    p_user_id UUID,
    p_status TEXT,
    p_reason TEXT DEFAULT NULL,
    p_organization_name TEXT DEFAULT NULL
)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
DECLARE
    v_uid UUID := public.require_platform_admin('admin');
    v_old public.organizer_accounts%ROWTYPE;
BEGIN
    IF p_status NOT IN ('pending', 'approved', 'suspended') THEN
        RAISE EXCEPTION 'INVALID_ORGANIZER_STATUS' USING ERRCODE = '22023';
    END IF;

    SELECT * INTO v_old FROM public.organizer_accounts WHERE user_id = p_user_id FOR UPDATE;

    INSERT INTO public.organizer_accounts (
        user_id, status, organization_name, approved_by, approved_at,
        suspended_at, suspension_reason
    ) VALUES (
        p_user_id, p_status, NULLIF(trim(p_organization_name), ''),
        CASE WHEN p_status = 'approved' THEN v_uid ELSE NULL END,
        CASE WHEN p_status = 'approved' THEN NOW() ELSE NULL END,
        CASE WHEN p_status = 'suspended' THEN NOW() ELSE NULL END,
        CASE WHEN p_status = 'suspended' THEN NULLIF(trim(p_reason), '') ELSE NULL END
    )
    ON CONFLICT (user_id) DO UPDATE
    SET status = EXCLUDED.status,
        organization_name = COALESCE(EXCLUDED.organization_name, public.organizer_accounts.organization_name),
        approved_by = CASE WHEN EXCLUDED.status = 'approved' THEN v_uid ELSE public.organizer_accounts.approved_by END,
        approved_at = CASE WHEN EXCLUDED.status = 'approved' THEN NOW() ELSE public.organizer_accounts.approved_at END,
        suspended_at = CASE WHEN EXCLUDED.status = 'suspended' THEN NOW() ELSE NULL END,
        suspension_reason = CASE WHEN EXCLUDED.status = 'suspended' THEN EXCLUDED.suspension_reason ELSE NULL END,
        updated_at = NOW();

    PERFORM public.log_audit(
        v_uid, 'organizer.status_changed', 'organizer_account', p_user_id,
        jsonb_build_object('status', v_old.status, 'reason', v_old.suspension_reason),
        jsonb_build_object('status', p_status, 'reason', NULLIF(trim(p_reason), ''))
    );

    PERFORM public.create_notification(
        p_user_id,
        'organizer_status_changed',
        'Organizer account update',
        format('Your organizer account is now %s.', p_status),
        jsonb_build_object('status', p_status),
        'system',
        format('organizer_status:%s:%s', p_user_id, p_status)
    );
END;
$$;

REVOKE ALL ON FUNCTION public.admin_set_organizer_status(UUID, TEXT, TEXT, TEXT) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.admin_set_organizer_status(UUID, TEXT, TEXT, TEXT) TO authenticated;

-- ============================================
-- 8. Tournament oversight and moderator assignment
-- ============================================
CREATE OR REPLACE FUNCTION public.admin_list_tournaments(
    p_query TEXT DEFAULT NULL,
    p_status TEXT DEFAULT NULL,
    p_limit INTEGER DEFAULT 50,
    p_offset INTEGER DEFAULT 0
)
RETURNS TABLE (
    tournament_id UUID,
    title TEXT,
    organizer_id UUID,
    organizer_name TEXT,
    status TEXT,
    visibility TEXT,
    format TEXT,
    max_teams INTEGER,
    registered_count BIGINT,
    created_at TIMESTAMPTZ
)
LANGUAGE plpgsql
STABLE
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
DECLARE
    v_uid UUID := public.require_platform_admin('support');
BEGIN
    RETURN QUERY
    SELECT t.id, t.title, t.organizer_id, p.display_name, t.status, t.visibility,
           t.format, t.max_teams,
           (SELECT count(*) FROM public.tournament_registrations r
             WHERE r.tournament_id = t.id AND r.status = 'confirmed'),
           t.created_at
    FROM public.tournaments t
    JOIN public.profiles p ON p.id = t.organizer_id
    WHERE t.deleted_at IS NULL
      AND (p_status IS NULL OR t.status = p_status)
      AND (
          p_query IS NULL OR trim(p_query) = ''
          OR t.title ILIKE '%' || trim(p_query) || '%'
          OR COALESCE(p.display_name, '') ILIKE '%' || trim(p_query) || '%'
      )
    ORDER BY t.created_at DESC
    LIMIT GREATEST(COALESCE(p_limit, 50), 1)
    OFFSET GREATEST(COALESCE(p_offset, 0), 0);
END;
$$;

REVOKE ALL ON FUNCTION public.admin_list_tournaments(TEXT, TEXT, INTEGER, INTEGER) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.admin_list_tournaments(TEXT, TEXT, INTEGER, INTEGER) TO authenticated;

CREATE OR REPLACE FUNCTION public.admin_assign_moderator(
    p_tournament_id UUID,
    p_user_id UUID
)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
DECLARE
    v_uid UUID := public.require_platform_admin('admin');
    v_existing TEXT;
BEGIN
    IF NOT EXISTS (SELECT 1 FROM public.tournaments WHERE id = p_tournament_id AND deleted_at IS NULL) THEN
        RAISE EXCEPTION 'TOURNAMENT_NOT_FOUND' USING ERRCODE = 'P0002';
    END IF;
    IF NOT EXISTS (SELECT 1 FROM public.profiles WHERE id = p_user_id AND deleted_at IS NULL) THEN
        RAISE EXCEPTION 'USER_NOT_FOUND' USING ERRCODE = 'P0002';
    END IF;

    -- Moderators must be neutral: no participation in the tournament they
    -- moderate (directly or through a team entry).
    IF EXISTS (
        SELECT 1 FROM public.tournament_registrations r
        WHERE r.tournament_id = p_tournament_id
          AND r.status IN ('confirmed', 'waitlisted')
          AND (
              r.user_id = p_user_id
              OR EXISTS (SELECT 1 FROM public.tournament_entry_members tem
                         WHERE tem.entry_id = r.id AND tem.user_id = p_user_id)
          )
    ) THEN
        RAISE EXCEPTION 'MODERATOR_PARTICIPATES_IN_TOURNAMENT' USING ERRCODE = '42501';
    END IF;

    SELECT role INTO v_existing
    FROM public.tournament_organizers
    WHERE tournament_id = p_tournament_id AND user_id = p_user_id;

    IF v_existing = 'owner' THEN
        RAISE EXCEPTION 'CANNOT_DEMOTE_OWNER' USING ERRCODE = '42501';
    END IF;

    INSERT INTO public.tournament_organizers (tournament_id, user_id, role)
    VALUES (p_tournament_id, p_user_id, 'moderator')
    ON CONFLICT (tournament_id, user_id) DO UPDATE SET role = 'moderator';

    PERFORM public.log_audit(
        v_uid, 'moderator.assigned', 'tournament', p_tournament_id,
        jsonb_build_object('user_id', p_user_id, 'role', v_existing),
        jsonb_build_object('user_id', p_user_id, 'role', 'moderator')
    );

    PERFORM public.create_notification(
        p_user_id,
        'moderator_assigned',
        'Moderator assignment',
        'You were assigned as a moderator for a tournament.',
        jsonb_build_object('tournament_id', p_tournament_id),
        'system',
        format('moderator_assigned:%s:%s', p_tournament_id, p_user_id)
    );
END;
$$;

REVOKE ALL ON FUNCTION public.admin_assign_moderator(UUID, UUID) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.admin_assign_moderator(UUID, UUID) TO authenticated;

CREATE OR REPLACE FUNCTION public.admin_remove_moderator(
    p_tournament_id UUID,
    p_user_id UUID
)
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
DECLARE
    v_uid UUID := public.require_platform_admin('admin');
    v_rows INTEGER;
BEGIN
    DELETE FROM public.tournament_organizers
    WHERE tournament_id = p_tournament_id
      AND user_id = p_user_id
      AND role = 'moderator';

    GET DIAGNOSTICS v_rows = ROW_COUNT;

    IF v_rows > 0 THEN
        PERFORM public.log_audit(
            v_uid, 'moderator.removed', 'tournament', p_tournament_id,
            jsonb_build_object('user_id', p_user_id, 'role', 'moderator'), NULL
        );
    END IF;

    RETURN v_rows > 0;
END;
$$;

REVOKE ALL ON FUNCTION public.admin_remove_moderator(UUID, UUID) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.admin_remove_moderator(UUID, UUID) TO authenticated;

CREATE OR REPLACE FUNCTION public.admin_list_moderators(p_tournament_id UUID)
RETURNS TABLE (
    user_id UUID,
    display_name TEXT,
    email TEXT,
    assigned_at TIMESTAMPTZ
)
LANGUAGE plpgsql
STABLE
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
DECLARE
    v_uid UUID := public.require_platform_admin('support');
BEGIN
    RETURN QUERY
    SELECT o.user_id, p.display_name, p.email, o.joined_at
    FROM public.tournament_organizers o
    JOIN public.profiles p ON p.id = o.user_id
    WHERE o.tournament_id = p_tournament_id AND o.role = 'moderator'
    ORDER BY o.joined_at;
END;
$$;

REVOKE ALL ON FUNCTION public.admin_list_moderators(UUID) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.admin_list_moderators(UUID) TO authenticated;

-- ============================================
-- 9. Audit search, metrics and admin provisioning
-- ============================================
CREATE OR REPLACE FUNCTION public.admin_search_audit_logs(
    p_query TEXT DEFAULT NULL,
    p_action TEXT DEFAULT NULL,
    p_limit INTEGER DEFAULT 50,
    p_offset INTEGER DEFAULT 0
)
RETURNS TABLE (
    id UUID,
    user_id UUID,
    action TEXT,
    resource_type TEXT,
    resource_id UUID,
    old_data JSONB,
    new_data JSONB,
    created_at TIMESTAMPTZ
)
LANGUAGE plpgsql
STABLE
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
DECLARE
    v_uid UUID := public.require_platform_admin('support');
BEGIN
    RETURN QUERY
    SELECT a.id, a.user_id, a.action, a.resource_type, a.resource_id,
           a.old_data, a.new_data, a.created_at
    FROM public.audit_logs a
    WHERE (p_action IS NULL OR a.action = p_action)
      AND (
          p_query IS NULL OR trim(p_query) = ''
          OR a.action ILIKE '%' || trim(p_query) || '%'
          OR COALESCE(a.resource_type, '') ILIKE '%' || trim(p_query) || '%'
          OR COALESCE(a.resource_id::TEXT, '') ILIKE '%' || trim(p_query) || '%'
      )
    ORDER BY a.created_at DESC
    LIMIT GREATEST(COALESCE(p_limit, 50), 1)
    OFFSET GREATEST(COALESCE(p_offset, 0), 0);
END;
$$;

REVOKE ALL ON FUNCTION public.admin_search_audit_logs(TEXT, TEXT, INTEGER, INTEGER) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.admin_search_audit_logs(TEXT, TEXT, INTEGER, INTEGER) TO authenticated;

CREATE OR REPLACE FUNCTION public.admin_platform_metrics()
RETURNS JSONB
LANGUAGE plpgsql
STABLE
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
DECLARE
    v_uid UUID := public.require_platform_admin('support');
BEGIN
    RETURN jsonb_build_object(
        'generated_at', NOW(),
        'users', jsonb_build_object(
            'total', (SELECT count(*) FROM public.profiles WHERE deleted_at IS NULL),
            'active', (SELECT count(*) FROM public.profiles p WHERE p.deleted_at IS NULL AND public.account_status(p.id) = 'active'),
            'suspended', (SELECT count(*) FROM public.profiles p WHERE p.deleted_at IS NULL AND public.account_status(p.id) <> 'active'),
            'new_24h', (SELECT count(*) FROM public.profiles WHERE created_at >= NOW() - INTERVAL '24 hours')
        ),
        'organizers', jsonb_build_object(
            'pending', (SELECT count(*) FROM public.organizer_accounts WHERE status = 'pending'),
            'approved', (SELECT count(*) FROM public.organizer_accounts WHERE status = 'approved'),
            'suspended', (SELECT count(*) FROM public.organizer_accounts WHERE status = 'suspended')
        ),
        'tournaments', jsonb_build_object(
            'total', (SELECT count(*) FROM public.tournaments WHERE deleted_at IS NULL),
            'active', (SELECT count(*) FROM public.tournaments WHERE deleted_at IS NULL AND status IN ('published', 'registration_open', 'registration_closed', 'in_progress')),
            'completed', (SELECT count(*) FROM public.tournaments WHERE deleted_at IS NULL AND status = 'completed')
        ),
        'abuse_reports', jsonb_build_object(
            'open', (SELECT count(*) FROM public.abuse_reports WHERE status IN ('submitted', 'triaged', 'investigating')),
            'resolved_24h', (SELECT count(*) FROM public.abuse_reports WHERE resolved_at >= NOW() - INTERVAL '24 hours')
        ),
        'notifications', jsonb_build_object(
            'last_24h', (SELECT count(*) FROM public.notifications WHERE created_at >= NOW() - INTERVAL '24 hours'),
            'unread', (SELECT count(*) FROM public.notifications WHERE read_at IS NULL AND in_app_visible = TRUE),
            'push_pending', (SELECT count(*) FROM public.notification_delivery_queue WHERE status IN ('pending', 'failed')),
            'push_dead', (SELECT count(*) FROM public.notification_delivery_queue WHERE status = 'dead'),
            'scheduled_due', (SELECT count(*) FROM public.scheduled_notifications WHERE processed_at IS NULL AND scheduled_at <= NOW())
        ),
        'settings', jsonb_build_object(
            'organizer_approval_required', public.platform_setting_bool('organizer_approval_required', FALSE),
            'abuse_reporting_enabled', public.platform_setting_bool('abuse_reporting_enabled', TRUE),
            'push_notifications_enabled', public.platform_setting_bool('push_notifications_enabled', FALSE),
            'maintenance_mode', public.platform_setting_bool('maintenance_mode', FALSE)
        )
    );
END;
$$;

REVOKE ALL ON FUNCTION public.admin_platform_metrics() FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.admin_platform_metrics() TO authenticated;

CREATE OR REPLACE FUNCTION public.admin_grant_platform_admin(
    p_user_id UUID,
    p_role TEXT,
    p_notes TEXT DEFAULT NULL
)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
DECLARE
    v_uid UUID := public.require_platform_admin('super_admin');
    v_old public.platform_admins%ROWTYPE;
BEGIN
    IF p_role NOT IN ('super_admin', 'admin', 'support') THEN
        RAISE EXCEPTION 'INVALID_ADMIN_ROLE' USING ERRCODE = '22023';
    END IF;
    IF NOT EXISTS (SELECT 1 FROM public.profiles WHERE id = p_user_id AND deleted_at IS NULL) THEN
        RAISE EXCEPTION 'USER_NOT_FOUND' USING ERRCODE = 'P0002';
    END IF;

    SELECT * INTO v_old FROM public.platform_admins WHERE user_id = p_user_id FOR UPDATE;

    INSERT INTO public.platform_admins (user_id, role, granted_by, notes)
    VALUES (p_user_id, p_role, v_uid, NULLIF(trim(p_notes), ''))
    ON CONFLICT (user_id) DO UPDATE
    SET role = p_role,
        granted_by = v_uid,
        granted_at = NOW(),
        revoked_at = NULL,
        notes = COALESCE(NULLIF(trim(p_notes), ''), public.platform_admins.notes);

    PERFORM public.log_audit(
        v_uid, 'platform_admin.granted', 'profile', p_user_id,
        CASE WHEN v_old.user_id IS NULL THEN NULL ELSE to_jsonb(v_old) END,
        jsonb_build_object('role', p_role)
    );
END;
$$;

REVOKE ALL ON FUNCTION public.admin_grant_platform_admin(UUID, TEXT, TEXT) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.admin_grant_platform_admin(UUID, TEXT, TEXT) TO authenticated;

CREATE OR REPLACE FUNCTION public.admin_revoke_platform_admin(
    p_user_id UUID,
    p_note TEXT DEFAULT NULL
)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
DECLARE
    v_uid UUID := public.require_platform_admin('super_admin');
    v_old public.platform_admins%ROWTYPE;
BEGIN
    IF p_user_id = v_uid THEN
        RAISE EXCEPTION 'CANNOT_REVOKE_SELF' USING ERRCODE = '22023';
    END IF;

    SELECT * INTO v_old FROM public.platform_admins WHERE user_id = p_user_id FOR UPDATE;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'ADMIN_NOT_FOUND' USING ERRCODE = 'P0002';
    END IF;

    UPDATE public.platform_admins
    SET revoked_at = NOW()
    WHERE user_id = p_user_id;

    PERFORM public.log_audit(
        v_uid, 'platform_admin.revoked', 'profile', p_user_id,
        to_jsonb(v_old), jsonb_build_object('note', NULLIF(trim(p_note), ''))
    );
END;
$$;

REVOKE ALL ON FUNCTION public.admin_revoke_platform_admin(UUID, TEXT) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.admin_revoke_platform_admin(UUID, TEXT) TO authenticated;

-- ============================================
-- 10. Abuse evidence storage policies
-- ============================================
-- Evidence uploaded by reporters is private: only the uploader (path prefix is
-- their uid) and platform admins may read it. The bucket is created when the
-- storage extension is available.
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
    'abuse-evidence',
    'abuse-evidence',
    FALSE,
    10485760,
    ARRAY['image/png', 'image/jpeg', 'image/webp', 'application/pdf', 'text/plain']
)
ON CONFLICT (id) DO NOTHING;

DROP POLICY IF EXISTS "Reporters upload own abuse evidence" ON storage.objects;
CREATE POLICY "Reporters upload own abuse evidence"
    ON storage.objects FOR INSERT
    WITH CHECK (
        bucket_id = 'abuse-evidence'
        AND auth.uid() IS NOT NULL
        AND (storage.foldername(name))[1] = auth.uid()::TEXT
    );

DROP POLICY IF EXISTS "Reporters and admins read abuse evidence" ON storage.objects;
CREATE POLICY "Reporters and admins read abuse evidence"
    ON storage.objects FOR SELECT
    USING (
        bucket_id = 'abuse-evidence'
        AND (
            (storage.foldername(name))[1] = auth.uid()::TEXT
            OR public.is_platform_admin(auth.uid())
        )
    );

DROP POLICY IF EXISTS "Reporters delete own abuse evidence" ON storage.objects;
CREATE POLICY "Reporters delete own abuse evidence"
    ON storage.objects FOR DELETE
    USING (
        bucket_id = 'abuse-evidence'
        AND (storage.foldername(name))[1] = auth.uid()::TEXT
    );

-- ============================================
-- 11. Anonymous least-privilege cleanup
-- ============================================
-- Supabase grants table privileges to anon/authenticated by default. Nothing
-- in Phase 5 needs unauthenticated table access; RLS would filter most reads
-- anyway, but revoking the privilege is defense in depth.
REVOKE ALL ON public.notifications FROM anon;
REVOKE ALL ON public.notification_preferences FROM anon;
REVOKE ALL ON public.device_tokens FROM anon;
REVOKE ALL ON public.scheduled_notifications FROM anon;
REVOKE ALL ON public.notification_delivery_queue FROM anon;
REVOKE ALL ON public.platform_admins FROM anon;
REVOKE ALL ON public.audit_logs FROM anon;
REVOKE ALL ON public.account_suspensions FROM anon;
REVOKE ALL ON public.organizer_accounts FROM anon;
REVOKE ALL ON public.platform_settings FROM anon;
REVOKE ALL ON public.abuse_reports FROM anon;
REVOKE ALL ON public.abuse_report_events FROM anon;
REVOKE ALL ON public.tournament_announcements FROM anon;

-- ============================================
-- 12. Ask PostgREST to reload the schema cache
-- ============================================
NOTIFY pgrst, 'reload schema';
