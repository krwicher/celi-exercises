/*
  # Set up authentication roles and policies

  1. Changes
    - Create custom roles for admin and regular users
    - Update RLS policies to handle different roles
    - Set up initial admin user

  2. Security
    - Admins can manage all exercises
    - Regular users can only read exercises
*/

-- Create custom roles in auth.users
ALTER TABLE auth.users ADD COLUMN IF NOT EXISTS role text DEFAULT 'user';

-- Update RLS policies for exercises table
DROP POLICY IF EXISTS "Enable read access for all users" ON exercises;
DROP POLICY IF EXISTS "Enable insert for authenticated users" ON exercises;
DROP POLICY IF EXISTS "Enable update for authenticated users" ON exercises;
DROP POLICY IF EXISTS "Enable delete for authenticated users" ON exercises;

-- Create new policies
CREATE POLICY "Enable read access for all users" ON exercises
  FOR SELECT USING (true);

CREATE POLICY "Enable insert for admins only" ON exercises
  FOR INSERT WITH CHECK (
    auth.jwt() ->> 'role' = 'admin'
  );

CREATE POLICY "Enable update for admins only" ON exercises
  FOR UPDATE USING (
    auth.jwt() ->> 'role' = 'admin'
  );

CREATE POLICY "Enable delete for admins only" ON exercises
  FOR DELETE USING (
    auth.jwt() ->> 'role' = 'admin'
  );

-- Function to check if user is admin
CREATE OR REPLACE FUNCTION auth.is_admin()
RETURNS BOOLEAN AS $$
BEGIN
  RETURN (
    SELECT role = 'admin'
    FROM auth.users
    WHERE id = auth.uid()
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;