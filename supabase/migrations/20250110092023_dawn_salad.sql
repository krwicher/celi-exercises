-- First clean up existing role implementation
DROP POLICY IF EXISTS "Enable insert for admins only" ON exercises;
DROP POLICY IF EXISTS "Enable update for admins only" ON exercises;
DROP POLICY IF EXISTS "Enable delete for admins only" ON exercises;
DROP FUNCTION IF EXISTS public.is_admin();
DROP TYPE IF EXISTS auth.role_type;

-- Drop existing claims table and related objects if they exist
DROP TABLE IF EXISTS auth.users_claims CASCADE;
DROP FUNCTION IF EXISTS auth.get_claims(uuid);
DROP FUNCTION IF EXISTS auth.my_claims();
DROP FUNCTION IF EXISTS auth.set_claim(uuid, text, jsonb);
DROP FUNCTION IF EXISTS auth.remove_claim(uuid, text);
DROP FUNCTION IF EXISTS auth.has_role(text);
DROP FUNCTION IF EXISTS auth.is_admin();
DROP FUNCTION IF EXISTS auth.set_user_roles(uuid, text[]);
DROP FUNCTION IF EXISTS public.my_claims();

-- Create the custom claims table
CREATE TABLE auth.users_claims (
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  claim text NOT NULL,
  value jsonb NOT NULL,
  PRIMARY KEY (user_id, claim)
);

-- Enable RLS
ALTER TABLE auth.users_claims ENABLE ROW LEVEL SECURITY;

-- Create policy for users_claims (no IF NOT EXISTS needed since we dropped everything)
CREATE POLICY "Users can view own claims"
  ON auth.users_claims
  FOR SELECT
  USING (auth.uid() = user_id);

-- Function to get claims
CREATE FUNCTION auth.get_claims(uid uuid)
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
CREATE FUNCTION auth.my_claims()
RETURNS jsonb
LANGUAGE sql
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT auth.get_claims(auth.uid());
$$;

-- Function to set a claim
CREATE FUNCTION auth.set_claim(
  p_user_id uuid,
  p_claim text,
  p_value jsonb
)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  INSERT INTO auth.users_claims (user_id, claim, value)
  VALUES (p_user_id, p_claim, p_value)
  ON CONFLICT (user_id, claim)
  DO UPDATE SET value = EXCLUDED.value;
END;
$$;

-- Function to remove a claim
CREATE FUNCTION auth.remove_claim(
  p_user_id uuid,
  p_claim text
)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  DELETE FROM auth.users_claims
  WHERE user_id = p_user_id AND claim = p_claim;
END;
$$;

-- Function to check if user has a specific role
CREATE FUNCTION auth.has_role(p_role text)
RETURNS boolean
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  RETURN COALESCE(
    (auth.my_claims() -> 'roles' ? p_role),
    false
  );
END;
$$;

-- Function to check if user is admin (convenience function)
CREATE FUNCTION auth.is_admin()
RETURNS boolean
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  RETURN auth.has_role('admin');
END;
$$;

-- Create public wrapper for my_claims
CREATE FUNCTION public.my_claims()
RETURNS jsonb
LANGUAGE sql
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT auth.my_claims();
$$;

-- Grant execute permission to authenticated users
GRANT EXECUTE ON FUNCTION public.my_claims TO authenticated;

-- Update exercise policies to use new role system
CREATE POLICY "Enable insert for admins only" ON exercises
  FOR INSERT WITH CHECK (auth.is_admin());

CREATE POLICY "Enable update for admins only" ON exercises
  FOR UPDATE USING (auth.is_admin());

CREATE POLICY "Enable delete for admins only" ON exercises
  FOR DELETE USING (auth.is_admin());

-- Function to set user roles
CREATE FUNCTION auth.set_user_roles(
  p_user_id uuid,
  p_roles text[]
)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  PERFORM auth.set_claim(
    p_user_id,
    'roles',
    jsonb_build_array(VARIADIC p_roles)
  );
END;
$$;

-- Set initial admin role for existing admin user
SELECT auth.set_user_roles(
  '190a599d-df83-4313-8e3c-4140b1ea45a5',
  ARRAY['admin']
);