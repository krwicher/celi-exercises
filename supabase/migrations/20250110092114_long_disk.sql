-- Drop previous policies
DROP POLICY IF EXISTS "Enable insert for admins only" ON exercises;
DROP POLICY IF EXISTS "Enable update for admins only" ON exercises;
DROP POLICY IF EXISTS "Enable delete for admins only" ON exercises;

-- Create basic policies for all authenticated users
CREATE POLICY "Enable read for all users" ON exercises
  FOR SELECT USING (true);

CREATE POLICY "Enable insert for authenticated users" ON exercises
  FOR INSERT WITH CHECK (auth.role() = 'authenticated');

CREATE POLICY "Enable update for authenticated users" ON exercises
  FOR UPDATE USING (auth.role() = 'authenticated');

CREATE POLICY "Enable delete for authenticated users" ON exercises
  FOR DELETE USING (auth.role() = 'authenticated');

-- Create a simple function to check if user is authenticated
CREATE OR REPLACE FUNCTION public.is_authenticated()
RETURNS boolean
LANGUAGE sql
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT auth.role() = 'authenticated';
$$;

-- Grant execute permission to authenticated users
GRANT EXECUTE ON FUNCTION public.is_authenticated TO authenticated;