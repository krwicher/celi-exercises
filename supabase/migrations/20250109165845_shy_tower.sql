/*
  # Implement custom claims for user roles
  
  1. Changes
    - Creates custom claims infrastructure
    - Adds role management functions
    - Updates existing role handling
    - Adds policies based on custom claims
  
  2. Security
    - All functions are SECURITY DEFINER
    - Strict access control through claims
    - Safe role management
*/

-- First clean up existing role implementation
DROP POLICY IF EXISTS "Enable insert for admins only" ON exercises;
DROP POLICY IF EXISTS "Enable update for admins only" ON exercises;
DROP POLICY IF EXISTS "Enable delete for admins only" ON exercises;
DROP FUNCTION IF EXISTS public.is_admin();
DROP TYPE IF EXISTS auth.role_type;

-- Create the custom claims table
CREATE TABLE IF NOT EXISTS auth.users_claims (
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  claim text NOT NULL,
  value jsonb NOT NULL,
  PRIMARY KEY (user_id, claim)
);

-- Enable RLS
ALTER TABLE auth.users_claims ENABLE ROW LEVEL SECURITY;

-- Create policy for users_claims
CREATE POLICY "Users can view own claims"
  ON auth.users_claims
  FOR SELECT
  USING (auth.uid() = user_id);

-- Function to get claims
CREATE OR REPLACE FUNCTION auth.get_claims(uid uuid)
RETURNS jsonb
LANGUAGE sql
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT COALESCE(
    jsonb_object_agg(claim, value),
    '{}'::jsonb
  )
  FROM auth.users_claims
  WHERE user_id = uid;
$$;

-- Function to get current user's claims
CREATE OR REPLACE FUNCTION auth.my_claims()
RETURNS jsonb
LANGUAGE sql
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT auth.get_claims(auth.uid());
$$;

-- Function to set a claim
CREATE OR REPLACE FUNCTION auth.set_claim(
  uid uuid,
  claim_name text,
  claim_value jsonb
)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  INSERT INTO auth.users_claims (user_id, claim, value)
  VALUES (uid, claim_name, claim_value)
  ON CONFLICT (user_id, claim)
  DO UPDATE SET value = EXCLUDED.value;
END;
$$;

-- Function to remove a claim
CREATE OR REPLACE FUNCTION auth.remove_claim(
  uid uuid,
  claim_name text
)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  DELETE FROM auth.users_claims
  WHERE user_id = uid AND claim = claim_name;
END;
$$;

-- Function to check if user has a specific role
CREATE OR REPLACE FUNCTION auth.has_role(role text)
RETURNS boolean
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  RETURN COALESCE(
    (auth.my_claims() -> 'roles' ? role),
    false
  );
END;
$$;

-- Function to check if user is admin (convenience function)
CREATE OR REPLACE FUNCTION auth.is_admin()
RETURNS boolean
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  RETURN auth.has_role('admin');
END;
$$;

-- Update exercise policies to use new role system
CREATE POLICY "Enable insert for admins only" ON exercises
  FOR INSERT WITH CHECK (auth.is_admin());

CREATE POLICY "Enable update for admins only" ON exercises
  FOR UPDATE USING (auth.is_admin());

CREATE POLICY "Enable delete for admins only" ON exercises
  FOR DELETE USING (auth.is_admin());

-- Function to set user roles
CREATE OR REPLACE FUNCTION auth.set_user_roles(
  uid uuid,
  roles text[]
)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  PERFORM auth.set_claim(
    uid,
    'roles',
    jsonb_build_array(VARIADIC roles)
  );
END;
$$;

-- Set initial admin role for existing admin user
SELECT auth.set_user_roles(
  '190a599d-df83-4313-8e3c-4140b1ea45a5',
  ARRAY['admin']
);