-- Migration: 20261106000003_fix_profile_cascade_and_triggers
-- Fixes:
-- 1. Change profiles FK from ON DELETE CASCADE to ON DELETE RESTRICT to allow soft-delete trigger to work
-- 2. Fix email-change trigger to actually sync email (if needed) or remove redundant trigger
-- 3. Add storage cleanup function for account deletion
-- 4. Make avatars bucket private and add signed URL policy

-- ============================================
-- Fix 1: Change FK from CASCADE to RESTRICT to allow soft-delete
-- ============================================
ALTER TABLE public.profiles 
DROP CONSTRAINT IF EXISTS profiles_id_fkey,
ADD CONSTRAINT profiles_id_fkey 
    FOREIGN KEY (id) REFERENCES auth.users(id) ON DELETE RESTRICT;

-- ============================================
-- Fix 2: Fix soft-delete trigger to work with RESTRICT FK
-- The BEFORE DELETE trigger on auth.users will now run BEFORE the FK check
-- because the FK is RESTRICT (checks after trigger)
-- ============================================
DROP TRIGGER IF EXISTS on_auth_user_deleted ON auth.users;
DROP FUNCTION IF EXISTS public.handle_user_deleted();

CREATE OR REPLACE FUNCTION public.handle_user_deleted()
RETURNS TRIGGER AS $$
BEGIN
    -- Soft delete the profile first
    UPDATE public.profiles
    SET deleted_at = NOW(), updated_at = NOW()
    WHERE id = OLD.id;
    
    -- Also delete user's storage objects (avatars, etc.)
    -- This must happen before auth user deletion due to FK RESTRICT
    DELETE FROM storage.objects 
    WHERE bucket_id IN ('avatars', 'tournament-assets', 'team-assets')
    AND (storage.foldername(name))[1] = OLD.id::text;
    
    RETURN OLD;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS on_auth_user_deleted ON auth.users;
CREATE TRIGGER on_auth_user_deleted
    BEFORE DELETE ON auth.users
    FOR EACH ROW EXECUTE FUNCTION public.handle_user_deleted();

-- ============================================
-- Fix 3: Remove redundant email-change trigger (profiles table has no email column)
-- ============================================
DROP TRIGGER IF EXISTS on_auth_user_updated ON auth.users;
DROP FUNCTION IF EXISTS public.handle_email_change();

-- ============================================
-- Fix 4: Add profile email sync if needed (optional - for search/indexing)
-- Only add if you need email in profiles for search. Otherwise rely on auth.users.
-- ============================================
-- ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS email TEXT;
-- CREATE INDEX IF NOT EXISTS idx_profiles_email ON profiles(email);
-- 
-- CREATE OR REPLACE FUNCTION public.handle_email_change()
-- RETURNS TRIGGER AS $$
-- BEGIN
--     UPDATE public.profiles
--     SET email = NEW.email, updated_at = NOW()
--     WHERE id = NEW.id;
--     RETURN NEW;
-- END;
-- $$ LANGUAGE plpgsql SECURITY DEFINER;
-- 
-- CREATE TRIGGER on_auth_user_updated
--     AFTER UPDATE ON auth.users
--     FOR EACH ROW
--     WHEN (OLD.email IS DISTINCT FROM NEW.email)
--     EXECUTE FUNCTION public.handle_email_change();

-- ============================================
-- Fix 5: Make avatars bucket private and add signed URL policy
-- ============================================
UPDATE storage.buckets 
SET public = false 
WHERE id = 'avatars';

-- Remove public read policy for avatars
DROP POLICY IF EXISTS "Public avatars are readable" ON storage.objects;

-- Add policy for users to read own avatars
CREATE POLICY "Users can read own avatars"
    ON storage.objects FOR SELECT
    USING (bucket_id = 'avatars' AND auth.uid()::text = (storage.foldername(name))[1]);

-- Add policy for public profile avatars (when profile is public)
CREATE POLICY "Public profile avatars are readable"
    ON storage.objects FOR SELECT
    USING (
        bucket_id = 'avatars' AND
        EXISTS (
            SELECT 1 FROM public.profiles p
            WHERE p.id::text = (storage.foldername(name))[1]
            AND p.privacy_profile_visibility = 'public'
            AND p.deleted_at IS NULL
        )
    );

-- Add policy for organizers to read avatars in their tournaments
CREATE POLICY "Organizers can read tournament avatars"
    ON storage.objects FOR SELECT
    USING (
        bucket_id = 'avatars' AND
        EXISTS (
            SELECT 1 FROM tournament_organizers to
            JOIN tournament_registrations tr ON tr.tournament_id = to.tournament_id
            WHERE to.user_id = auth.uid()
            AND tr.user_id::text = (storage.foldername(name))[1]
        )
    );

-- ============================================
-- Fix 6: Add file content validation for avatars (using pg_trgm or custom function)
-- Note: Full image validation should be done in Edge Function, but add DB constraint as backup
-- ============================================
-- Add check constraint for file size (backup to Edge Function validation)
-- Note: This requires a function to get file size from storage.objects
-- For now, rely on Edge Function validation

-- ============================================
-- Fix 7: Add storage cleanup function for account deletion
-- ============================================
CREATE OR REPLACE FUNCTION public.cleanup_user_storage(p_user_id UUID)
RETURNS VOID AS $$
BEGIN
    DELETE FROM storage.objects 
    WHERE bucket_id IN ('avatars', 'tournament-assets', 'team-assets')
    AND (storage.foldername(name))[1] = p_user_id::text;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;