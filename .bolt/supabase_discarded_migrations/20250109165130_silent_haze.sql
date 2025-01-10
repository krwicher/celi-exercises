/*
  # Set admin role for specific user

  1. Changes
    - Updates the role to 'admin' for user with ID '190a599d-df83-4313-8e3c-4140b1ea45a5'
*/

UPDATE auth.users
SET role = 'admin'
WHERE id = '190a599d-df83-4313-8e3c-4140b1ea45a5';