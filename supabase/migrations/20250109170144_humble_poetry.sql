-- Create a public wrapper for my_claims
CREATE OR REPLACE FUNCTION public.my_claims()
RETURNS jsonb
LANGUAGE sql
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT auth.my_claims();
$$;

-- Grant execute permission to authenticated users
GRANT EXECUTE ON FUNCTION public.my_claims TO authenticated;

-- Recreate exercise policies to use auth.is_admin() directly
DROP POLICY IF EXISTS "Enable insert for admins only" ON exercises;
DROP POLICY IF EXISTS "Enable update for admins only" ON exercises;
DROP POLICY IF EXISTS "Enable delete for admins only" ON exercises;

CREATE POLICY "Enable insert for admins only" ON exercises
  FOR INSERT WITH CHECK (auth.is_admin());

CREATE POLICY "Enable update for admins only" ON exercises
  FOR UPDATE USING (auth.is_admin());

CREATE POLICY "Enable delete for admins only" ON exercises
  FOR DELETE USING (auth.is_admin());