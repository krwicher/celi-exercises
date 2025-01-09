/*
  # Fix RLS policies for exercises table

  1. Changes
    - Drop existing RLS policies for exercises table
    - Create new policies that properly handle authentication
    - Add policy for authenticated users to manage their own exercises
*/

-- Drop existing policies
DROP POLICY IF EXISTS "Enable read access for all users" ON exercises;
DROP POLICY IF EXISTS "Enable insert for authenticated users only" ON exercises;
DROP POLICY IF EXISTS "Enable update for authenticated users only" ON exercises;
DROP POLICY IF EXISTS "Enable delete for authenticated users only" ON exercises;

-- Create new policies
CREATE POLICY "Enable read access for all users" ON exercises
  FOR SELECT USING (true);

CREATE POLICY "Enable insert for authenticated users" ON exercises
  FOR INSERT WITH CHECK (auth.role() = 'authenticated');

CREATE POLICY "Enable update for authenticated users" ON exercises
  FOR UPDATE USING (auth.role() = 'authenticated');

CREATE POLICY "Enable delete for authenticated users" ON exercises
  FOR DELETE USING (auth.role() = 'authenticated');