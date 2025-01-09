/*
  # Exercise and Muscles Relationship Schema

  1. New Tables
    - `muscles`
      - `id` (uuid, primary key)
      - `name` (text, required)
      - `description` (text)
      - `created_at` (timestamp with timezone)
      - `updated_at` (timestamp with timezone)

    - `exercise_muscles`
      - `id` (uuid, primary key)
      - `exercise_id` (uuid, foreign key to exercises)
      - `muscle_id` (uuid, foreign key to muscles)
      - `relationship_type` (enum: mobilized, strengthened, stabilized, stretched)
      - `created_at` (timestamp with timezone)

  2. Security
    - Enable RLS on all tables
    - Add policies for CRUD operations
*/

-- Create enum for muscle relationship types
CREATE TYPE muscle_relationship_type AS ENUM (
  'mobilized',
  'strengthened',
  'stabilized',
  'stretched'
);

-- Create muscles table
CREATE TABLE muscles (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL UNIQUE,
  description text,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Create exercise_muscles junction table
CREATE TABLE exercise_muscles (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  exercise_id uuid REFERENCES exercises(id) ON DELETE CASCADE,
  muscle_id uuid REFERENCES muscles(id) ON DELETE CASCADE,
  relationship_type muscle_relationship_type NOT NULL,
  created_at timestamptz DEFAULT now(),
  UNIQUE(exercise_id, muscle_id, relationship_type)
);

-- Enable RLS
ALTER TABLE muscles ENABLE ROW LEVEL SECURITY;
ALTER TABLE exercise_muscles ENABLE ROW LEVEL SECURITY;

-- Policies for muscles table
CREATE POLICY "Enable read access for all users" ON muscles
  FOR SELECT USING (true);

CREATE POLICY "Enable insert for authenticated users only" ON muscles
  FOR INSERT TO authenticated WITH CHECK (true);

CREATE POLICY "Enable update for authenticated users only" ON muscles
  FOR UPDATE TO authenticated USING (true);

CREATE POLICY "Enable delete for authenticated users only" ON muscles
  FOR DELETE TO authenticated USING (true);

-- Policies for exercise_muscles table
CREATE POLICY "Enable read access for all users" ON exercise_muscles
  FOR SELECT USING (true);

CREATE POLICY "Enable insert for authenticated users only" ON exercise_muscles
  FOR INSERT TO authenticated WITH CHECK (true);

CREATE POLICY "Enable update for authenticated users only" ON exercise_muscles
  FOR UPDATE TO authenticated USING (true);

CREATE POLICY "Enable delete for authenticated users only" ON exercise_muscles
  FOR DELETE TO authenticated USING (true);

-- Add trigger for muscles updated_at
CREATE TRIGGER update_muscles_updated_at
    BEFORE UPDATE ON muscles
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Remove old array columns from exercises table
ALTER TABLE exercises 
  DROP COLUMN mobilized_muscles,
  DROP COLUMN strengthened_muscles,
  DROP COLUMN stabilized_muscles,
  DROP COLUMN stretched_muscles;