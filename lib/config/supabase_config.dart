class SupabaseConfig {
  static const String supabaseUrl = 'https://caeovxzmsapqclyfkiqb.supabase.co'; 
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImNhZW92eHptc2FwcWNseWZraXFiIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDg2NjAxNzksImV4cCI6MjA2NDIzNjE3OX0.YqNcYqqpIRnMYVwEgeY3Xfe5fUSB1y-w6Ty96zZIX2Y';

  static Map<String, String> get headers => {
        'apikey': supabaseAnonKey,
        'Authorization': 'Bearer $supabaseAnonKey',
        'Content-Type': 'application/json',
      };
}