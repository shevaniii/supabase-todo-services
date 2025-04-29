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


-- curl -X POST https://lfmbbvnenbptscojsjh.supabase.co/rest/v1/notes \
--   -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsImtpZCI6ImpQRGNSV3B4RGhZdkZ2dUMiLCJ0eXAiOiJKV1QifQ.eyJpc3MiOiJodHRwczovL2lmbWJidm5lcmlicHRzY29pc2poLnN1cGFiYXNlLmNvL2F1dGgvdjEiLCJzdWIiOiJlNmMwNmZlMS01ZDk0LTQ4ZGItODA4Ni0wZGIwZDI5OTlmYjEiLCJhdWQiOiJhdXRoZW50aWNhdGVkIiwiZXhwIjoxNzQ1OTQ4MTExLCJpYXQiOjE3NDU5NDQ1MTEsImVtYWlsIjoic2hpdmFuaS5nb3N3YW1pMjEyMDA1QGdtYWlsLmNvbSIsInBob25lIjoiIiwiYXBwX21ldGFkYXRhIjp7InByb3ZpZGVyIjoiZW1haWwiLCJwcm92aWRlcnMiOlsiZW1haWwiXX0sInVzZXJfbWV0YWRhdGEiOnsiZW1haWxfdmVyaWZpZWQiOnRydWV9LCJyb2xlIjoiYXV0aGVudGljYXRlZCIsImFhbCI6ImFhbDEiLCJhbXIiOlt7Im1ldGhvZCI6InBhc3N3b3JkIiwidGltZXN0YW1wIjoxNzQ1OTQ0NTExfV0sInNlc3Npb25faWQiOiJhZDZhMTJkMC01OGIyLTQ2OWItOTIyNS0xOTQxM2JjZjY0NzQiLCJpc19hbm9ueW1vdXMiOmZhbHNlfQ.5v7Pnm_Qs6Eo2vB1W4DkJI4B5qRU5kH85m5NCRURCBI" \
--   -H "Content-Type: application/json" \
--   -d '{
--     user_id:"e6c06fe1-5d94-48db-8086-0db0d2999fb1",
--     title:"first todo",
--     content:"this is the first todo of this project"    
-- }'



