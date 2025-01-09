/*
  # Add shoulder area muscles and forearms

  1. Data Changes
    - Add detailed shoulder area muscles:
      - Deltoid (Anterior)
      - Deltoid (Lateral)
      - Deltoid (Posterior)
      - Rotator Cuff
      - Trapezius
    - Add forearm muscles:
      - Forearms (Flexors)
      - Forearms (Extensors)
*/

INSERT INTO muscles (name, description)
VALUES
  ('Deltoid (Anterior)', 'The front portion of the deltoid muscle, responsible for shoulder flexion and internal rotation'),
  ('Deltoid (Lateral)', 'The middle portion of the deltoid muscle, responsible for shoulder abduction'),
  ('Deltoid (Posterior)', 'The rear portion of the deltoid muscle, responsible for shoulder extension and external rotation'),
  ('Rotator Cuff', 'Group of muscles and tendons that stabilize the shoulder joint'),
  ('Trapezius', 'Large muscle extending from the back of the head to the lower thoracic vertebrae'),
  ('Forearms (Flexors)', 'The muscles on the anterior compartment of the forearm responsible for wrist and finger flexion'),
  ('Forearms (Extensors)', 'The muscles on the posterior compartment of the forearm responsible for wrist and finger extension')
ON CONFLICT (name) DO NOTHING;