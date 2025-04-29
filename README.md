# 🗒️ Supabase Mini–Project – Custom Note Service

This project is a minimal backend note-taking service built using [Supabase](https://supabase.com). It demonstrates schema design, authentication-based access control, and two REST API endpoints using Supabase Edge Functions.

---

## 📌 Table of Contents

- [Project Objectives](#-project-objectives)
- [Schema Design](#-schema-design)
- [Edge Functions](#-edge-functions)
  - [POST /notes](#-post-notes)
  - [GET /notes](#-get-notes)
- [Setup & Deployment](#-setup--deploy-steps)
- [Demo: Curl Commands](#-demo-curl-commands)
- [License](#-license)

---

## 🎯 Project Objectives

- ✅ Design a clean and flexible schema for user notes
- ✅ Implement secure REST API endpoints using Supabase Edge Functions
- ✅ Apply proper Row Level Security (RLS) policies
- ✅ Demonstrate authentication and filtering

---

## 🗄️ Schema Design

**File:** `schema.sql`

```sql
CREATE TABLE notes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL,
  title TEXT,
  content TEXT NOT NULL,
  tags TEXT[] DEFAULT '{}',
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX notes_user_id_idx ON notes (user_id);

ALTER TABLE notes ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view their own notes" 
  ON notes FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own notes" 
  ON notes FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own notes" 
  ON notes FOR UPDATE
  USING (auth.uid() = user_id);

CREATE POLICY "Users can delete their own notes" 
  ON notes FOR DELETE
  USING (auth.uid() = user_id);
```

### 💡 Why this schema?

- `UUID` is used for IDs to ensure uniqueness and security.
- `tags` allows categorization and optional filtering.
- `created_at` and `updated_at` track timestamps automatically.
- RLS ensures that each user can only access their own notes securely.

---

## ⚙️ Edge Functions

### 📬 `post_notes.js` — Handles `POST /notes`

- **Why?**: POST is standard for creating resources. Parameters are read from the request body.

```js
// Why POST /notes: RESTful convention for creating resources, using request body for data
```

### 📥 `get_notes.js` — Handles `GET /notes`

- **Why?**: GET is used to retrieve data. Filtering is done via query parameters (`tag`).

```js
// Why GET /notes: RESTful convention for retrieving resources, query params for optional filtering
```

---

## 🛠️ Setup & Deploy Steps

1. **Create a Supabase Project**: Go to [supabase.com](https://supabase.com) and start a new project.

2. **Create the Table**:
   - Go to SQL Editor.
   - Paste the content from `schema.sql`.
   - Run it to create your `notes` table with RLS policies.

3. **Enable Edge Functions**:
   - In your local project, create a `functions/` directory.
   - Add `post_notes.js` and `get_notes.js` with the provided handlers.

4. **Deploy Edge Functions**:
   ```bash
   supabase functions deploy post_notes
   supabase functions deploy get_notes
   ```

5. **Set Env Vars** in your Supabase project (under settings):
   - `SUPABASE_URL`: Your project URL.
   - `SUPABASE_ANON_KEY`: Public API key.

6. **Run Functions via Supabase CLI or CURL**

---

## 🧪 Demo: Curl Commands

### ➕ Create a Note

```bash
curl -X POST "https://<your-project>.supabase.co/functions/v1/post_notes" \
  -H "Authorization: Bearer <your-access-token>" \
  -H "Content-Type: application/json" \
  -d '{
    "title": "first todo",
    "content": "this is the first todo of this project",
    "tags": ["personal", "urgent"]
}'
```

**Expected Response:**

```json
{
  "id": "generated-uuid",
  "user_id": "authenticated-user-id",
  "title": "first todo",
  "content": "this is the first todo of this project",
  "tags": ["personal", "urgent"],
  "created_at": "2025-04-30T09:30:00Z",
  "updated_at": "2025-04-30T09:30:00Z"
}
```

### 📄 List Notes

```bash
curl -X GET "https://<your-project>.supabase.co/functions/v1/get_notes" \
  -H "Authorization: Bearer <your-access-token>"
```

**Expected Response:**

```json
{
  "notes": [
    {
      "id": "generated-uuid",
      "title": "first todo",
      "content": "this is the first todo of this project",
      "tags": ["personal", "urgent"],
      "created_at": "2025-04-30T09:30:00Z",
      "updated_at": "2025-04-30T09:30:00Z"
    }
  ]
}
```

# DEMO 
# to post todo(CMD COMMAND)

curl -X POST https://ifmbbvneribptscoisjh.supabase.co/rest/v1/notes -H "apikey: YOUR_ANON_KEY" -H "Authorization: Bearer ACCESS_JWT_TOKEN" -H "Content-Type: application/json" -d "{\"user_id\":\"e6c06fe1-5d94-48db-8086-0db0d2999fb1\",\"title\":\"third todo\",\"content\":\"this is the third todo of this project\"}"

# to get all todos (CMD COMMAND)
curl -X GET "https://ifmbbvneribptscoisjh.supabase.co/rest/v1/notes" -H "apikey: YOUR_ANON_KEY" -H "Authorization: Bearer JWT_TOKEN"



