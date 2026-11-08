-- Migration: 20261108000012_phase4_decrypt_fix.sql
-- Phase 4 Decryption Fix
--
-- Fix: simple_decrypt function doesn't properly handle bytea to text conversion
-- The bytea cast to text returns hex representation (\x...), not the original text.
-- Use convert_from() for proper bytea to text conversion.

-- ============================================
-- Fix simple_decrypt to properly convert bytea to text
-- ============================================
DROP FUNCTION IF EXISTS public.simple_decrypt(bytea, text);

CREATE OR REPLACE FUNCTION public.simple_decrypt(data bytea, key text) RETURNS text
LANGUAGE sql
IMMUTABLE
AS $$
    SELECT CASE 
        WHEN convert_from(data, 'UTF8') LIKE 'enc:%' THEN substr(convert_from(data, 'UTF8'), 5)
        ELSE convert_from(data, 'UTF8')
    END;
$$;

-- Re-grant execute (not strictly necessary for IMMUTABLE functions but good practice)
GRANT EXECUTE ON FUNCTION public.simple_decrypt(bytea, text) TO authenticated;