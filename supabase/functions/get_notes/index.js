import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';

// This is how Edge Functions must be structured
export const handler = async (req) => {
  try {
    // Get the user_id from the query string (optional filtering)
    const url = new URL(req.url);
    const tag = url.searchParams.get('tag');
    
    // Why GET /notes: RESTful convention for retrieving resources, query params for optional filtering
    
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
    
    // Fetch notes for the authenticated user
    let query = supabaseClient
      .from('notes')
      .select('*')
      .eq('user_id', user.id)
      .order('created_at', { ascending: false });
    
    // Apply tag filter if provided
    if (tag) {
      query = query.contains('tags', [tag]);
    }
    
    const { data, error } = await query;
    
    if (error) {
      return new Response(
        JSON.stringify({ error: error.message }),
        { status: 500, headers: { 'Content-Type': 'application/json' } }
      );
    }
    
    // Return the notes
    return new Response(
      JSON.stringify({ notes: data }),
      { status: 200, headers: { 'Content-Type': 'application/json' } }
    );
    
  } catch (error) {
    return new Response(
      JSON.stringify({ error: error.message }),
      { status: 500, headers: { 'Content-Type': 'application/json' } }
    );
  }
};