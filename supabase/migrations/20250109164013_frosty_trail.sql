/*
  # Fix exercise table policies

  1. Changes
    - Update RLS policies to allow authenticated users to insert exercises
    - Remove admin-only restrictions for basic CRUD operations
    - Keep read access public

  2. Security
    - Enable insert/update/delete for all authenticated users
    - Maintain public read access
*/

-- Drop existing policies
DROP POLICY IF EXISTS "Enable read access for all users" ON exercises;
DROP POLICY IF EXISTS "Enable insert for admins only" ON exercises;
DROP POLICY IF EXISTS "Enable update for admins only" ON exercises;
DROP POLICY IF EXISTS "Enable delete for admins only" ON exercises;

-- Create new policies
CREATE POLICY "Enable read access for all users" ON exercises
  FOR SELECT USING (true);

CREATE POLICY "Enable insert for authenticated users" ON exercises
  FOR INSERT WITH CHECK (auth.role() = 'authenticated');

CREATE POLICY "Enable update for authenticated users" ON exercises
  FOR UPDATE USING (auth.role() = 'authenticated');

CREATE POLICY "Enable delete for authenticated users" ON exercises
  FOR DELETE USING (auth.role() = 'authenticated');