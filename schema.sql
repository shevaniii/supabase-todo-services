-- Schema for the notes table

CREATE TABLE notes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL,
  title TEXT,
  content TEXT NOT NULL,
  tags TEXT[] DEFAULT '{}',
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Create an index on user_id for faster queries
CREATE INDEX notes_user_id_idx ON notes (user_id);

-- Add row level security (RLS) policies
ALTER TABLE notes ENABLE ROW LEVEL SECURITY;

-- Create policy for users to only see their own notes
CREATE POLICY "Users can view their own notes" 
  ON notes FOR SELECT
  USING (auth.uid() = user_id);

-- Create policy for users to insert their own notes
CREATE POLICY "Users can insert their own notes" 
  ON notes FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- Create policy for users to update their own notes
CREATE POLICY "Users can update their own notes" 
  ON notes FOR UPDATE
  USING (auth.uid() = user_id);

-- Create policy for users to delete their own notes
CREATE POLICY "Users can delete their own notes" 
  ON notes FOR DELETE
  USING (auth.uid() = user_id);


-- curl -X POST https://ifmbbvneribptscoisjh.functions.supabase.co/post_notes \
--   -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImlmbWJidm5lcmlicHRzY29pc2poIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDU5MTI2NjksImV4cCI6MjA2MTQ4ODY2OX0.TOJRuEZRv6lg7C3nkcKKGd8aEe6k5-VUBm2ILHhXFbo" \
--   -H "Content-Type: application/json" \
--   -d '{
--     "user_id": "1",
--     "title": "first todo",
--     "content": "just testing my project first time",
--     "tags": ["example", "note"]
--   }'



