/*
  # Fix admin function access

  1. Changes
    - Move is_admin function to public schema
    - Grant execute permission to authenticated users
    - Update RLS policies to use public.is_admin()

  2. Security
    - Function remains security definer to access auth.users table
    - Only authenticated users can execute the function
*/

-- First drop the policies that depend on auth.is_admin()
DROP POLICY IF EXISTS "Enable insert for admins only" ON exercises;
DROP POLICY IF EXISTS "Enable update for admins only" ON exercises;
DROP POLICY IF EXISTS "Enable delete for admins only" ON exercises;

-- Now we can safely drop the function
DROP FUNCTION IF EXISTS auth.is_admin();

-- Create the function in public schema
CREATE OR REPLACE FUNCTION public.is_admin()
RETURNS BOOLEAN AS $$
BEGIN
  RETURN (
    SELECT role = 'admin'
    FROM auth.users
    WHERE id = auth.uid()
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Grant execute permission to authenticated users
GRANT EXECUTE ON FUNCTION public.is_admin TO authenticated;

-- Recreate the policies using public.is_admin
CREATE POLICY "Enable insert for admins only" ON exercises
  FOR INSERT WITH CHECK (public.is_admin());

CREATE POLICY "Enable update for admins only" ON exercises
  FOR UPDATE USING (public.is_admin());

CREATE POLICY "Enable delete for admins only" ON exercises
  FOR DELETE USING (public.is_admin());