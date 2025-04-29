import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';

// This is how Edge Functions must be structured
export const handler = async (req) => {
  try {
    // Why POST /notes: RESTful convention for creating resources, using request body for data
    
    // Check if method is POST
    if (req.method !== 'POST') {
      return new Response(
        JSON.stringify({ error: 'Method not allowed' }),
        { status: 405, headers: { 'Content-Type': 'application/json' } }
      );
    }
    
    // Parse the request body
    const { title, content, tags } = await req.json();
    
    // Validate the required fields
    if (!content) {
      return new Response(
        JSON.stringify({ error: 'Content is required' }),
        { status: 400, headers: { 'Content-Type': 'application/json' } }
      );
    }
    
    // Create a Supabase client with the Auth context of the logged in user
    const supabaseClient = createClient(
      Deno.env.get('SUPABASE_URL'),
      Deno.env.get('SUPABASE_ANON_KEY')
    );
    
    // Get the user from the request context
    const authHeader = req.headers.get('Authorization');
    if (!authHeader) {
      return new Response(
        JSON.stringify({ error: 'Authorization header is required' }),
        { status: 401, headers: { 'Content-Type': 'application/json' } }
      );
    }
    
    // Set the Auth header for the Supabase client
    const supabaseAuthClient = supabaseClient.auth.setAuth(authHeader.replace('Bearer ', ''));
    
    // Get the user data
    const { data: { user }, error: userError } = await supabaseAuthClient.getUser();
    if (userError) {
      return new Response(
        JSON.stringify({ error: 'Invalid token' }),
        { status: 401, headers: { 'Content-Type': 'application/json' } }
      );
    }
    
    // Insert the note
    const { data, error } = await supabaseClient
      .from('notes')
      .insert({
        user_id: user.id,
        title: title || null,
        content,
        tags: tags || [],
      })
      .select()
      .single();
    
    if (error) {
      return new Response(
        JSON.stringify({ error: error.message }),
        { status: 500, headers: { 'Content-Type': 'application/json' } }
      );
    }
    
    // Return the created note
    return new Response(
      JSON.stringify(data),
      { status: 201, headers: { 'Content-Type': 'application/json' } }
    );
    
  } catch (error) {
    return new Response(
      JSON.stringify({ error: error.message }),
      { status: 500, headers: { 'Content-Type': 'application/json' } }
    );
  }
};