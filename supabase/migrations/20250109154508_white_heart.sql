/*
  # Add initial muscles

  1. Data Changes
    - Insert initial set of muscles:
      - Ankles
      - Knees
      - Hips
      - Adaptus
      - Gluts
      - Spine
      - Shoulders
      - Elbows
      - Wrists
      - Hamstrings
*/

INSERT INTO muscles (name, description)
VALUES
  ('Ankles', 'The ankle joint and surrounding muscles'),
  ('Knees', 'The knee joint and surrounding muscles'),
  ('Hips', 'The hip joint and surrounding muscles'),
  ('Adaptus', 'The adductor muscles of the inner thigh'),
  ('Gluts', 'The gluteal muscles including gluteus maximus, medius, and minimus'),
  ('Spine', 'The spinal muscles and surrounding musculature'),
  ('Shoulders', 'The shoulder joint and surrounding muscles'),
  ('Elbows', 'The elbow joint and surrounding muscles'),
  ('Wrists', 'The wrist joint and surrounding muscles'),
  ('Hamstrings', 'The posterior thigh muscles')
ON CONFLICT (name) DO NOTHING;