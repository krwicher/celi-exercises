/*
  # Add admin role and update policies

  1. Changes
    - Add admin role to auth schema
    - Update RLS policies to check for admin role
    - Add function to check admin status

  2. Security
    - Only admins can perform write operations
    - Maintain public read access
*/

-- Create admin role type
CREATE TYPE auth.role_type AS ENUM ('admin', 'user');

-- Add role column if it doesn't exist
DO $$ 
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_schema = 'auth' 
    AND table_name = 'users' 
    AND column_name = 'role'
  ) THEN
    ALTER TABLE auth.users ADD COLUMN role auth.role_type DEFAULT 'user';
  END IF;
END $$;

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

-- Update RLS policies for exercises
DROP POLICY IF EXISTS "Enable insert for authenticated users" ON exercises;
DROP POLICY IF EXISTS "Enable update for authenticated users" ON exercises;
DROP POLICY IF EXISTS "Enable delete for authenticated users" ON exercises;

-- Create admin-only policies
CREATE POLICY "Enable insert for admins only" ON exercises
  FOR INSERT WITH CHECK (auth.is_admin());

CREATE POLICY "Enable update for admins only" ON exercises
  FOR UPDATE USING (auth.is_admin());

CREATE POLICY "Enable delete for admins only" ON exercises
  FOR DELETE USING (auth.is_admin());