/*
  # Exercise Management Schema

  1. New Tables
    - `exercises`
      - `id` (uuid, primary key)
      - `name` (text, required)
      - `description` (text, required)
      - `mobilized_muscles` (text[], muscles that are mobilized)
      - `strengthened_muscles` (text[], muscles that are strengthened)
      - `stabilized_muscles` (text[], muscles that provide stabilization)
      - `stretched_muscles` (text[], muscles that are stretched)
      - `created_at` (timestamp with timezone)
      - `updated_at` (timestamp with timezone)

  2. Security
    - Enable RLS on `exercises` table
    - Add policies for CRUD operations
*/

CREATE TABLE exercises (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL,
  description text NOT NULL,
  mobilized_muscles text[] DEFAULT '{}',
  strengthened_muscles text[] DEFAULT '{}',
  stabilized_muscles text[] DEFAULT '{}',
  stretched_muscles text[] DEFAULT '{}',
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Enable Row Level Security
ALTER TABLE exercises ENABLE ROW LEVEL SECURITY;

-- Create policies
CREATE POLICY "Enable read access for all users" ON exercises
  FOR SELECT USING (true);

CREATE POLICY "Enable insert for authenticated users only" ON exercises
  FOR INSERT TO authenticated WITH CHECK (true);

CREATE POLICY "Enable update for authenticated users only" ON exercises
  FOR UPDATE TO authenticated USING (true);

CREATE POLICY "Enable delete for authenticated users only" ON exercises
  FOR DELETE TO authenticated USING (true);

-- Create function to automatically update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Create trigger to automatically update updated_at
CREATE TRIGGER update_exercises_updated_at
    BEFORE UPDATE ON exercises
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();